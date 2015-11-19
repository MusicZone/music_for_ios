//
//  NSString+AESCrypt.m
//
//  Created by Michael Sedlaczek, Gone Coding on 2011-02-22
//

#import "NSString+AESCrypt.h"
#import<objc/runtime.h>
@implementation NSString (SiruoxianAESCrypt)

- (NSString *)AES256EncryptWithKey:(NSString *)key
{
   NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
   NSData *encryptedData = [plainData AES256EncryptWithKey:key];
   
   NSString *encryptedString = [encryptedData base64Encoding];
   
   return encryptedString;
}

- (NSString *)AES256DecryptWithKey:(NSString *)key
{
   NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
   NSData *plainData = [encryptedData AES256DecryptWithKey:key];
   
   NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
   
   return [plainString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey
{
    
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
    
    for (int i= 0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=1;
    
    for (short i=0; i<256; i++) {
        
        UniChar c = [aKey characterAtIndex:i%aKey.length];
        
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    j=0;
    
    for (int i=0; i<255; i++) {
        int is = [[iS objectAtIndex:i] intValue];
        UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
        
        j = (j + is + ik)%256;
        NSNumber *temp = [iS objectAtIndex:i];
        [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
        [iS replaceObjectAtIndex:j withObject:temp];
        
    }
    
    int i=0;
    j=0;
    
    NSString *result = aInput;
    
    for (short x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue];
        
        int t = (is_i+is_j) % 256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        
        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
    }
    
    
    return result;
}

@end



