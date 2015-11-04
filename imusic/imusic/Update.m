//
//  Update.m
//  imusic
//
//  Created by APPLE28 on 15/11/4.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import "Update.h"

#define HTTP_URL @"http://www.imusic.ren/app/?m=IosUpdate&a=get"
@implementation Update

-(void)checkVersion
{
    dispatch_queue_t que = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(que, ^{
        NSString *newVersion;
        getUrls = [self getUpdateInfo:[NSURL URLWithString:HTTP_URL]];
        
        NSString *surl = [getUrls valueForKey:@"appurl"];
        
        if (surl != nil && ![surl isEqualToString:@""]) {
            
            NSURL *url = [NSURL URLWithString:surl];
            //通过url获取数据
            NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"通过appStore获取的数据是：%@",jsonResponseString);
            if (jsonResponseString != nil && ![jsonResponseString isEqualToString:@""]) {
                //解析json数据为数据字典
                NSDictionary *loginAuthenticationResponse = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];
                
                //从数据字典中检出版本号数据
                NSArray *configData = [loginAuthenticationResponse valueForKey:@"results"];
                for(id config in configData)
                {
                    newVersion = [config valueForKey:@"version"];
                }
                
                NSLog(@"通过appStore获取的版本号是：%@",newVersion);
                
                //获取本地软件的版本号
                NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"];
                
                NSString *msg = [NSString stringWithFormat:@"你当前的版本是V%@，发现新版本V%@，是否下载新版本？",localVersion,newVersion];
                
                //对比发现的新版本和本地的版本
                if ([newVersion floatValue] > [localVersion floatValue])
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:@"升级提示!" message:msg delegate:self cancelButtonTitle:@"现在升级" otherButtonTitles: nil, nil];
                        [createUserResponseAlert show];
                    });
                }
            }
        }
    });
}
-(NSDictionary *)getUpdateInfo:(NSURL *)url
{
    //通过url获取数据
    NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    //解析json数据为数据字典
    NSDictionary *Response = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];
    
    return Response;
    
}
-(NSMutableDictionary *)dictionaryFromJsonFormatOriginalData:(NSString *)str
{
    SBJsonParser *sbJsonParser = [[SBJsonParser alloc]init];
    NSError *error = nil;
    id re = [sbJsonParser objectWithString:str error:&error];
    NSMutableDictionary *tempDictionary;
    if([re isKindOfClass:[NSArray class]]){
        //添加autorelease 解决 内存泄漏问题
        tempDictionary = [[NSMutableDictionary alloc]initWithDictionary:(NSDictionary *)(re[0])];
    }else{
        tempDictionary = [[NSMutableDictionary alloc]initWithDictionary:(NSDictionary *)re];
        
    }
    return tempDictionary;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //如果选择“现在升级”
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[getUrls valueForKey:@"downloadurl"]]];
    }
}



@end



