//
//  FileHash.h
//  imusic
//
//  Created by APPLE28 on 16/1/5.
//  Copyright © 2016年 weshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHash : NSObject
+ (NSString *)md5HashOfData:(NSData *)dt;
+ (NSString *)md5HashOfFileAtPath:(NSString *)filePath;
+ (NSString *)sha1HashOfFileAtPath:(NSString *)filePath;
+ (NSString *)sha512HashOfFileAtPath:(NSString *)filePath;
@end
