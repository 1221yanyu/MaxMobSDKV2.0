/*
 Copyright (C) 2009 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MaxMobSBJsonParser.h"

@interface MaxMobSBJsonParser ()

- (BOOL)AYscanValue:(NSObject **)o;

- (BOOL)AYscanRestOfArray:(NSMutableArray **)o;
- (BOOL)AYscanRestOfDictionary:(NSMutableDictionary **)o;
- (BOOL)AYscanRestOfNull:(NSNull **)o;
- (BOOL)AYscanRestOfFalse:(NSNumber **)o;
- (BOOL)AYscanRestOfTrue:(NSNumber **)o;
- (BOOL)AYscanRestOfString:(NSMutableString **)o;

// Cannot manage without looking at the first digit
- (BOOL)AYscanNumber:(NSNumber **)o;

- (BOOL)AYscanHexQuad:(unichar *)x;
- (BOOL)AYscanUnicodeChar:(unichar *)x;

- (BOOL)AYscanIsAtEnd;

@end

#define AYskipWhitespace(c) while (isspace(*c)) c++
#define AYskipDigits(c) while (isdigit(*c)) c++


@implementation MaxMobSBJsonParser

static char ctrl[0x22];

+ (void)initialize
{
    ctrl[0] = '\"';
    ctrl[1] = '\\';
    for (int i = 1; i < 0x20; i++)
        ctrl[i+1] = i;
    ctrl[0x21] = 0;    
}

/**
 @deprecated This exists in order to provide fragment support in older APIs in one more version.
 It should be removed in the next major version.
 */
- (id)AYfragmentWithString:(id)repr {
    [self AYclearErrorTrace];
    
    if (!repr) {
        [self AYaddErrorWithCode:MaxMobEINPUT description:@"Input was 'nil'"];
        return nil;
    }
    
    depth = 0;
    c = [repr UTF8String];
    
    id o;
    if (![self AYscanValue:&o]) {
        return nil;
    }
    
    // We found some valid JSON. But did it also contain something else?
    if (![self AYscanIsAtEnd]) {
        [self AYaddErrorWithCode:MaxMobETRAILGARBAGE description:@"Garbage after JSON"];
        return nil;
    }
        
    NSAssert1(o, @"Should have a valid object from %@", repr);
    return o;    
}

- (id)AYobjectWithString:(NSString *)repr {

    id o = [self AYfragmentWithString:repr];
    if (!o)
        return nil;
    
    // Check that the object we've found is a valid JSON container.
    if (![o isKindOfClass:[NSDictionary class]] && ![o isKindOfClass:[NSArray class]]) {
        [self AYaddErrorWithCode:MaxMobEFRAGMENT description:@"Valid fragment, but not JSON"];
        return nil;
    }

    return o;
}

/*
 In contrast to the public methods, it is an error to omit the error parameter here.
 */
- (BOOL)AYscanValue:(NSObject **)o
{
    AYskipWhitespace(c);
    
    switch (*c++) {
        case '{':
            return [self AYscanRestOfDictionary:(NSMutableDictionary **)o];
            break;
        case '[':
            return [self AYscanRestOfArray:(NSMutableArray **)o];
            break;
        case '"':
            return [self AYscanRestOfString:(NSMutableString **)o];
            break;
        case 'f':
            return [self AYscanRestOfFalse:(NSNumber **)o];
            break;
        case 't':
            return [self AYscanRestOfTrue:(NSNumber **)o];
            break;
        case 'n':
            return [self AYscanRestOfNull:(NSNull **)o];
            break;
        case '-':
        case '0'...'9':
            c--; // cannot verify number correctly without the first character
            return [self AYscanNumber:(NSNumber **)o];
            break;
        case '+':
            [self AYaddErrorWithCode:MaxMobEPARSENUM description: @"Leading + disallowed in number"];
            return NO;
            break;
        case 0x0:
            [self AYaddErrorWithCode:MaxMobEEOF description:@"Unexpected end of string"];
            return NO;
            break;
        default:
            [self AYaddErrorWithCode:MaxMobEPARSE description: @"Unrecognised leading character"];
            return NO;
            break;
    }
    
    NSAssert(0, @"Should never get here");
    return NO;
}

- (BOOL)AYscanRestOfTrue:(NSNumber **)o
{
    if (!strncmp(c, "rue", 3)) {
        c += 3;
        *o = [NSNumber numberWithBool:YES];
        return YES;
    }
    [self AYaddErrorWithCode:MaxMobEPARSE description:@"Expected 'true'"];
    return NO;
}

- (BOOL)AYscanRestOfFalse:(NSNumber **)o
{
    if (!strncmp(c, "alse", 4)) {
        c += 4;
        *o = [NSNumber numberWithBool:NO];
        return YES;
    }
    [self AYaddErrorWithCode:MaxMobEPARSE description: @"Expected 'false'"];
    return NO;
}

- (BOOL)AYscanRestOfNull:(NSNull **)o {
    if (!strncmp(c, "ull", 3)) {
        c += 3;
        *o = [NSNull null];
        return YES;
    }
    [self AYaddErrorWithCode:MaxMobEPARSE description: @"Expected 'null'"];
    return NO;
}

- (BOOL)AYscanRestOfArray:(NSMutableArray **)o {
    if (maxDepth && ++depth > maxDepth) {
        [self AYaddErrorWithCode:MaxMobEDEPTH description: @"Nested too deep"];
        return NO;
    }
    
    *o = [NSMutableArray arrayWithCapacity:8];
    
    for (; *c ;) {
        id v;
        
        AYskipWhitespace(c);
        if (*c == ']' && c++) {
            depth--;
            return YES;
        }
        
        if (![self AYscanValue:&v]) {
            [self AYaddErrorWithCode:MaxMobEPARSE description:@"Expected value while parsing array"];
            return NO;
        }
        
        [*o addObject:v];
        
        AYskipWhitespace(c);
        if (*c == ',' && c++) {
            AYskipWhitespace(c);
            if (*c == ']') {
                [self AYaddErrorWithCode:MaxMobETRAILCOMMA description: @"Trailing comma disallowed in array"];
                return NO;
            }
        }        
    }
    
    [self AYaddErrorWithCode:MaxMobEEOF description: @"End of input while parsing array"];
    return NO;
}

- (BOOL)AYscanRestOfDictionary:(NSMutableDictionary **)o 
{
    if (maxDepth && ++depth > maxDepth) {
        [self AYaddErrorWithCode:MaxMobEDEPTH description: @"Nested too deep"];
        return NO;
    }
    
    *o = [NSMutableDictionary dictionaryWithCapacity:7];
    
    for (; *c ;) {
        id k, v;
        
        AYskipWhitespace(c);
        if (*c == '}' && c++) {
            depth--;
            return YES;
        }    
        
        if (!(*c == '\"' && c++ && [self AYscanRestOfString:&k])) {
            [self AYaddErrorWithCode:MaxMobEPARSE description: @"Object key string expected"];
            return NO;
        }
        
        AYskipWhitespace(c);
        if (*c != ':') {
            [self AYaddErrorWithCode:MaxMobEPARSE description: @"Expected ':' separating key and value"];
            return NO;
        }
        
        c++;
        if (![self AYscanValue:&v]) {
            NSString *string = [NSString stringWithFormat:@"Object value expected for key: %@", k];
            [self AYaddErrorWithCode:MaxMobEPARSE description: string];
            return NO;
        }
        
        [*o setObject:v forKey:k];
        
        AYskipWhitespace(c);
        if (*c == ',' && c++) {
            AYskipWhitespace(c);
            if (*c == '}') {
                [self AYaddErrorWithCode:MaxMobETRAILCOMMA description: @"Trailing comma disallowed in object"];
                return NO;
            }
        }        
    }
    
    [self AYaddErrorWithCode:MaxMobEEOF description: @"End of input while parsing object"];
    return NO;
}

- (BOOL)AYscanRestOfString:(NSMutableString **)o 
{
    *o = [NSMutableString stringWithCapacity:16];
    do {
        // First see if there's a portion we can grab in one go. 
        // Doing this caused a massive speedup on the long string.
        size_t len = strcspn(c, ctrl);
        if (len) {
            // check for 
            id t = [[NSString alloc] initWithBytesNoCopy:(char*)c length:len encoding:NSUTF8StringEncoding freeWhenDone:NO];
            if (t) {
                [*o appendString:t];
                c += len;
            }
            
//            [t release];
            t = nil;
        }
        
        if (*c == '"') {
            c++;
            return YES;
            
        } else if (*c == '\\') {
            unichar uc = *++c;
            switch (uc) {
                case '\\':
                case '/':
                case '"':
                    break;
                    
                case 'b':   uc = '\b';  break;
                case 'n':   uc = '\n';  break;
                case 'r':   uc = '\r';  break;
                case 't':   uc = '\t';  break;
                case 'f':   uc = '\f';  break;                    
                    
                case 'u':
                    c++;
                    if (![self AYscanUnicodeChar:&uc]) {
                        [self AYaddErrorWithCode:MaxMobEUNICODE description: @"Broken unicode character"];
                        return NO;
                    }
                    c--; // hack.
                    break;
                default:
                    [self AYaddErrorWithCode:MaxMobEESCAPE description: [NSString stringWithFormat:@"Illegal escape sequence '0x%x'", uc]];
                    return NO;
                    break;
            }
            CFStringAppendCharacters((CFMutableStringRef)*o, &uc, 1);
            c++;
            
        } else if (*c < 0x20) {
            [self AYaddErrorWithCode:MaxMobECTRL description: [NSString stringWithFormat:@"Unescaped control character '0x%x'", *c]];
            return NO;
            
        } else {
            NSLog(@"should not be able to get here");
        }
    } while (*c);
    
    [self AYaddErrorWithCode:MaxMobEEOF description:@"Unexpected EOF while parsing string"];
    return NO;

}

- (BOOL)AYscanUnicodeChar:(unichar *)x
{
    unichar hi, lo;
    
    if (![self AYscanHexQuad:&hi]) {
        [self AYaddErrorWithCode:MaxMobEUNICODE description: @"Missing hex quad"];
        return NO;        
    }
    
    if (hi >= 0xd800) {     // high surrogate char?
        if (hi < 0xdc00) {  // yes - expect a low char
            
            if (!(*c == '\\' && ++c && *c == 'u' && ++c && [self AYscanHexQuad:&lo])) {
                [self AYaddErrorWithCode:MaxMobEUNICODE description: @"Missing low character in surrogate pair"];
                return NO;
            }
            
            if (lo < 0xdc00 || lo >= 0xdfff) {
                [self AYaddErrorWithCode:MaxMobEUNICODE description:@"Invalid low surrogate char"];
                return NO;
            }
            
            hi = (hi - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000;
            
        } else if (hi < 0xe000) {
            [self AYaddErrorWithCode:MaxMobEUNICODE description:@"Invalid high character in surrogate pair"];
            return NO;
        }
    }
    
    *x = hi;
    return YES;
}

- (BOOL)AYscanHexQuad:(unichar *)x
{
    *x = 0;
    for (int i = 0; i < 4; i++) {
        unichar uc = *c;
        c++;
        int d = (uc >= '0' && uc <= '9')
        ? uc - '0' : (uc >= 'a' && uc <= 'f')
        ? (uc - 'a' + 10) : (uc >= 'A' && uc <= 'F')
        ? (uc - 'A' + 10) : -1;
        if (d == -1) {
            [self AYaddErrorWithCode:MaxMobEUNICODE description:@"Missing hex digit in quad"];
            return NO;
        }
        *x *= 16;
        *x += d;
    }
    return YES;
}

- (BOOL)AYscanNumber:(NSNumber **)o
{
    const char *ns = c;
    
    // The logic to test for validity of the number formatting is relicensed
    // from JSON::XS with permission from its author Marc Lehmann.
    // (Available at the CPAN: http://search.cpan.org/dist/JSON-XS/ .)
    
    if ('-' == *c)
        c++;
    
    if ('0' == *c && c++) {        
        if (isdigit(*c)) {
            [self AYaddErrorWithCode:MaxMobEPARSENUM description: @"Leading 0 disallowed in number"];
            return NO;
        }
        
    } else if (!isdigit(*c) && c != ns) {
        [self AYaddErrorWithCode:MaxMobEPARSENUM description: @"No digits after initial minus"];
        return NO;
        
    } else {
        AYskipDigits(c);
    }
    
    // Fractional part
    if ('.' == *c && c++) {
        
        if (!isdigit(*c)) {
            [self AYaddErrorWithCode:MaxMobEPARSENUM description: @"No digits after decimal point"];
            return NO;
        }        
        AYskipDigits(c);
    }
    
    // Exponential part
    if ('e' == *c || 'E' == *c) {
        c++;
        
        if ('-' == *c || '+' == *c)
            c++;
        
        if (!isdigit(*c)) {
            [self AYaddErrorWithCode:MaxMobEPARSENUM description: @"No digits after exponent"];
            return NO;
        }
        AYskipDigits(c);
    }
    
    id str = [[NSString alloc] initWithBytesNoCopy:(char*)ns
                                            length:c - ns
                                          encoding:NSUTF8StringEncoding
                                      freeWhenDone:NO];
    if (str && (*o = [NSDecimalNumber decimalNumberWithString:str])){
//        [str release];
        return YES;
    }
        
    
    [self AYaddErrorWithCode:MaxMobEPARSENUM description: @"Failed creating decimal instance"];
    
//    [str release];
    return NO;
}

- (BOOL)AYscanIsAtEnd
{
    AYskipWhitespace(c);
    return !*c;
}


@end
