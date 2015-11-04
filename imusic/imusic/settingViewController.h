//
//  settingViewController.h
//  RemoteIME
//
//  Created by APPLE28 on 15-1-8.
//  Copyright (c) 2015年 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"
#import "Update.h"

@interface settingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSDictionary *getUrls;
}

//@property (strong, nonatomic) IBOutlet UITableView *buttonTable;
@end
