//
// Copyright (c) 2013 Aaron Jubbal
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "SATextFieldUtility.h"
#import "NSString+SATextField.h"
#import "Logging.h" // optional

@implementation SATextFieldUtility

+ (void)selectTextForInput:(UITextField *)input
                   atRange:(NSRange)range
{
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    UITextPosition *start = [input positionFromPosition:[input beginningOfDocument]
                                                 offset:range.location];
    UITextPosition *end = [input positionFromPosition:start
                                               offset:range.length];
    [input setSelectedTextRange:[input textRangeFromPosition:start toPosition:end]];
}

+ (NSString *) append:(id) first, ...
{
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    NSString * result = @"";
    id eachArg;
    va_list alist;
    if(first)
    {
        result = [result stringByAppendingString:first];
        va_start(alist, first);
        while ((eachArg = va_arg(alist, id)))
			result = [result stringByAppendingString:eachArg];
        va_end(alist);
    }
    return result;
}

+ (NSString *)insertDecimalInString:(NSString *)string
                  atPositionFromEnd:(NSUInteger)position
{
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    NSUInteger decimalPosition = string.length - position;
    NSString *leftOfDecimal = [string substringToIndex:decimalPosition];
    NSString *rightOfDecimal = [string substringFromIndex:decimalPosition];
    NSString *returnable = [SATextFieldUtility append:leftOfDecimal, @".", rightOfDecimal, nil];
    return returnable;
}

/**
 @see http://stackoverflow.com/questions/2166809/number-of-occurrences-of-a-substring-in-an-nsstring
 */
+ (NSUInteger) numberOfOccurrencesOfString:(NSString *)needle
                                  inString:(NSString *)haystack
{
    const char * rawNeedle = [needle UTF8String];
    NSUInteger needleLength = strlen(rawNeedle);
    
    const char * rawHaystack = [haystack UTF8String];
    NSUInteger haystackLength = strlen(rawHaystack);
    
    NSUInteger needleCount = 0;
    NSUInteger needleIndex = 0;
    for (NSUInteger index = 0; index < haystackLength; ++index) {
        const char thisCharacter = rawHaystack[index];
        if (thisCharacter != rawNeedle[needleIndex]) {
            needleIndex = 0; //they don't match; reset the needle index
        }
        
        //resetting the needle might be the beginning of another match
        if (thisCharacter == rawNeedle[needleIndex]) {
            needleIndex++; //char match
            if (needleIndex >= needleLength) {
                needleCount++; //we completed finding the needle
                needleIndex = 0;
            }
        }
    }
    
    return needleCount;
}// numberOfOccurrencesOfString:inString:
@end
