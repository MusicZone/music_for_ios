//
//  ImusicViewController.h
//  imusic
//
//  Created by APPLE28 on 15/10/21.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJson.h"
#import "Update.h"
#import <AVFoundation/AVFoundation.h>
@interface ImusicViewController : UIViewController<NSURLSessionDelegate,AVAssetResourceLoaderDelegate>
- (void)closeAll;
@end
