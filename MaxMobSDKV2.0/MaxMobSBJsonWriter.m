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

#import "MaxMobSBJsonWriter.h"

@interface MaxMobSBJsonWriter ()

- (BOOL)AYappendValue:(id)fragment into:(NSMutableString*)json;
- (BOOL)AYappendArray:(NSArray*)fragment into:(NSMutableString*)json;
- (BOOL)AYappendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json;
- (BOOL)AYappendString:(NSString*)fragment into:(NSMutableString*)json;

- (NSString*)AYindent;

@end

@implementation MaxMobSBJsonWriter

@synthesize AYsortKeys;
@synthesize AYhumanReadable;

/**
 @deprecated This exists in order to provide fragment support in older APIs in one more version.
 It should be removed in the next major version.
 */
- (NSString*)AYstringWithFragment:(id)value {
    [self AYclearErrorTrace];
    depth = 0;
    NSMutableString *json = [NSMutableString stringWithCapacity:128];
    
    if ([self AYappendValue:value into:json])
        return json;
    
    return nil;
}


- (NSString*)AYstringWithObject:(id)value {
    
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
        return [self AYstringWithFragment:value];
    }

    [self AYclearErrorTrace];
    [self AYaddErrorWithCode:MaxMobEFRAGMENT description:@"Not valid type for JSON"];
    return nil;
}


- (NSString*)AYindent {
    return [@"\n" stringByPaddingToLength:1 + 2 * depth withString:@" " startingAtIndex:0];
}

- (BOOL)AYappendValue:(id)fragment into:(NSMutableString*)json {
    if ([fragment isKindOfClass:[NSDictionary class]]) {
        if (![self AYappendDictionary:fragment into:json])
            return NO;
        
    } else if ([fragment isKindOfClass:[NSArray class]]) {
        if (![self AYappendArray:fragment into:json])
            return NO;
        
    } else if ([fragment isKindOfClass:[NSString class]]) {
        if (![self AYappendString:fragment into:json])
            return NO;
        
    } else if ([fragment isKindOfClass:[NSNumber class]]) {
        if ('c' == *[fragment objCType])
            [json appendString:[fragment boolValue] ? @"true" : @"false"];
        else
            [json appendString:[fragment stringValue]];
        
    } else if ([fragment isKindOfClass:[NSNull class]]) {
        [json appendString:@"null"];
    } else if ([fragment respondsToSelector:@selector(proxyForJson)]) {
        [self AYappendValue:[fragment AYproxyForJson] into:json];
        
    } else {
        [self AYaddErrorWithCode:MaxMobEUNSUPPORTED description:[NSString stringWithFormat:@"JSON serialisation not supported for %@", [fragment class]]];
        return NO;
    }
    return YES;
}

- (BOOL)AYappendArray:(NSArray*)fragment into:(NSMutableString*)json {
    if (maxDepth && ++depth > maxDepth) {
        [self AYaddErrorWithCode:MaxMobEDEPTH description: @"Nested too deep"];
        return NO;
    }
    [json appendString:@"["];
    
    BOOL addComma = NO;    
    for (id value in fragment) {
        if (addComma)
            [json appendString:@","];
        else
            addComma = YES;
        
        if ([self AYhumanReadable])
            [json appendString:[self AYindent]];
        
        if (![self AYappendValue:value into:json]) {
            return NO;
        }
    }
    
    depth--;
    if ([self AYhumanReadable] && [fragment count])
        [json appendString:[self AYindent]];
    [json appendString:@"]"];
    return YES;
}

- (BOOL)AYappendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json {
    if (maxDepth && ++depth > maxDepth) {
        [self AYaddErrorWithCode:MaxMobEDEPTH description: @"Nested too deep"];
        return NO;
    }
    [json appendString:@"{"];
    
    NSString *colon = [self AYhumanReadable] ? @" : " : @":";
    BOOL addComma = NO;
    NSArray *keys = [fragment allKeys];
    if (self.AYsortKeys)
        keys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    for (id value in keys) {
        if (addComma)
            [json appendString:@","];
        else
            addComma = YES;
        
        if ([self AYhumanReadable])
            [json appendString:[self AYindent]];
        
        if (![value isKindOfClass:[NSString class]]) {
            [self AYaddErrorWithCode:MaxMobEUNSUPPORTED description: @"JSON object key must be string"];
            return NO;
        }
        
        if (![self AYappendString:value into:json])
            return NO;
        
        [json appendString:colon];
        if (![self AYappendValue:[fragment objectForKey:value] into:json]) {
            [self AYaddErrorWithCode:MaxMobEUNSUPPORTED description:[NSString stringWithFormat:@"Unsupported value for key %@ in object", value]];
            return NO;
        }
    }
    
    depth--;
    if ([self AYhumanReadable] && [fragment count])
        [json appendString:[self AYindent]];
    [json appendString:@"}"];
    return YES;    
}

- (BOOL)AYappendString:(NSString*)fragment into:(NSMutableString*)json {
    
    static NSMutableCharacterSet *kEscapeChars;
    if( ! kEscapeChars ) {
        kEscapeChars = [NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)];
        [kEscapeChars addCharactersInString: @"\"\\"];
    }
    
    [json appendString:@"\""];
    
    NSRange esc = [fragment rangeOfCharacterFromSet:kEscapeChars];
    if ( !esc.length ) {
        // No special chars -- can just add the raw string:
        [json appendString:fragment];
        
    } else {
        NSUInteger length = [fragment length];
        for (NSUInteger i = 0; i < length; i++) {
            unichar uc = [fragment characterAtIndex:i];
            switch (uc) {
                case '"':   [json appendString:@"\\\""];       break;
                case '\\':  [json appendString:@"\\\\"];       break;
                case '\t':  [json appendString:@"\\t"];        break;
                case '\n':  [json appendString:@"\\n"];        break;
                case '\r':  [json appendString:@"\\r"];        break;
                case '\b':  [json appendString:@"\\b"];        break;
                case '\f':  [json appendString:@"\\f"];        break;
                default:    
                    if (uc < 0x20) {
                        [json appendFormat:@"\\u%04x", uc];
                    } else {
                        CFStringAppendCharacters((CFMutableStringRef)json, &uc, 1);
                    }
                    break;
                    
            }
        }
    }
    
    [json appendString:@"\""];
    return YES;
}


@end
