/*
 Copyright (C) 2007-2009 Stig Brautaset. All rights reserved.
 
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

#import "MaxMobSBJSON.h"

@implementation MaxMobSBJSON

- (id)init {
    self = [super init];
    if (self) {
        jsonWriter = [[MaxMobSBJsonWriter alloc] init];
        jsonParser = [[MaxMobSBJsonParser alloc] init];
        [self AYsetMaxDepth:512];
    }
    return self;
}

#pragma mark Writer 


- (NSString *)AYstringWithObject:(id)obj {
    NSString *repr = [jsonWriter AYstringWithObject:obj];
    if (repr)
        return repr;
    errorTrace = [[jsonWriter AYerrorTrace] mutableCopy];
    return nil;
}

/**
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p *error can be interrogated to find the cause of the error.
 
 @param value any instance that can be represented as a JSON fragment
 @param allowScalar wether to return json fragments for scalar objects
 @param error used to return an error by reference (pass NULL if this is not desired)
 
@deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (NSString*)AYstringWithObject:(id)value allowScalar:(BOOL)allowScalar error:(NSError**)error {
    
    NSString *json = allowScalar ? [jsonWriter AYstringWithFragment:value] : [jsonWriter AYstringWithObject:value];
    if (json)
        return json;

    errorTrace = [[jsonWriter AYerrorTrace] mutableCopy];
    
    if (error)
        *error = [errorTrace lastObject];
    return nil;
}

/**
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p error can be interrogated to find the cause of the error.
 
 @param value any instance that can be represented as a JSON fragment
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (NSString*)AYstringWithFragment:(id)value error:(NSError**)error {
    return [self AYstringWithObject:value
                      allowScalar:YES
                            error:error];
}

/**
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p error can be interrogated to find the cause of the error.
 
 @param value a NSDictionary or NSArray instance
 @param error used to return an error by reference (pass NULL if this is not desired)
 */
- (NSString*)AYstringWithObject:(id)value error:(NSError**)error {
    return [self AYstringWithObject:value
                      allowScalar:NO
                            error:error];
}

#pragma mark Parsing

- (id)AYobjectWithString:(NSString *)repr {
    id obj = [jsonParser AYobjectWithString:repr];
    if (obj)
        return obj;
    errorTrace = [[jsonParser AYerrorTrace] mutableCopy];
    
    return nil;
}

/**
 Returns the object represented by the passed-in string or nil on error. The returned object can be
 a string, number, boolean, null, array or dictionary.
 
 @param value the json string to parse
 @param allowScalar whether to return objects for JSON fragments
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (id)AYobjectWithString:(id)value allowScalar:(BOOL)allowScalar error:(NSError**)error {

    id obj = allowScalar ? [jsonParser AYfragmentWithString:value] : [jsonParser AYobjectWithString:value];
    if (obj)
        return obj;
    
    errorTrace = [[jsonParser AYerrorTrace] mutableCopy];

    if (error)
        *error = [errorTrace lastObject];
    return nil;
}

/**
 Returns the object represented by the passed-in string or nil on error. The returned object can be
 a string, number, boolean, null, array or dictionary.
 
 @param repr the json string to parse
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed. 
 */
- (id)AYfragmentWithString:(NSString*)repr error:(NSError**)error {
    return [self AYobjectWithString:repr
                      allowScalar:YES
                            error:error];
}

/**
 Returns the object represented by the passed-in string or nil on error. The returned object
 will be either a dictionary or an array.
 
 @param repr the json string to parse
 @param error used to return an error by reference (pass NULL if this is not desired)
 */
- (id)AYobjectWithString:(NSString*)repr error:(NSError**)error {
    return [self AYobjectWithString:repr
                      allowScalar:NO
                            error:error];
}



#pragma mark Properties - parsing

- (NSUInteger)AYmaxDepth {
    return jsonParser.AYmaxDepth;
}

- (void)AYsetMaxDepth:(NSUInteger)d {
     jsonWriter.AYmaxDepth = jsonParser.AYmaxDepth = d;
}


#pragma mark Properties - writing

- (BOOL)AYhumanReadable {
    return jsonWriter.AYhumanReadable;
}

- (void)AYsetHumanReadable:(BOOL)x {
    jsonWriter.AYhumanReadable = x;
}

- (BOOL)AYsortKeys {
    return jsonWriter.AYsortKeys;
}

- (void)AYsetSortKeys:(BOOL)x {
    jsonWriter.AYsortKeys = x;
}

//- (void)dealloc
//{
//    [jsonWriter release];
//    [jsonParser release];
//    
//    [super dealloc];
//}

@end
