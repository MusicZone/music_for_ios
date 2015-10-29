//
//  gntvTabBarController.m
//  RemoteIME
//
//  Created by 李微辰 on 11/12/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "ImusicTabBarController.h"
#import "LocalViewController.h"
#import "ImusicViewController.h"
@interface ImusicTabBarController ()

@end

@implementation ImusicTabBarController

//@synthesize ip;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSArray *cons = [self viewControllers];
    if (viewController == [cons objectAtIndex:0]) {
         LocalViewController *local = [cons objectAtIndex:1];
        [local closeAll];
    }else if(viewController == [cons objectAtIndex:1]) {
        ImusicViewController *imusic = [cons objectAtIndex:0];
        [imusic closeAll];
    }else{
        ImusicViewController *imusic = [cons objectAtIndex:0];
        [imusic closeAll];
        LocalViewController *local = [cons objectAtIndex:1];
        [local closeAll];
    }
}
@end
