//
//  Update.h
//  imusic
//
//  Created by APPLE28 on 15/11/4.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SBJson.h"
@interface Update : NSObject<UIAlertViewDelegate>
{
    NSDictionary *getUrls;
}
-(void)checkVersion;
@end
