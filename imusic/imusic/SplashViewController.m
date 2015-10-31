//
//  SplashViewController.m
//  RemoteIME
//
//  Created by APPLE28 on 15-1-6.
//  Copyright (c) 2015年 none. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@property (strong,nonatomic) UIPageControl *pageControl;
@end

@implementation SplashViewController
@synthesize isFirstTime,pageControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initGuide];
}
- (void)initGuide
{
    CGFloat height=self.view.bounds.size.height;
    CGFloat width = self.view.bounds.size.width;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scrollView.delegate = self;
    [scrollView setContentSize:CGSizeMake(width*3, height)];
    [scrollView setPagingEnabled:YES];  //视图整页显示
    [scrollView setBounces:NO];

    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [imageview setImage:[UIImage imageNamed:@"guide_01.jpg"]];
    [scrollView addSubview:imageview];

    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    [imageview1 setImage:[UIImage imageNamed:@"guide_02.jpg"]];
    [scrollView addSubview:imageview1];

    UIImageView *imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(width*2, 0, width, height)];
    [imageview2 setImage:[UIImage imageNamed:@"guide_03.jpg"]];
    imageview2.userInteractionEnabled = YES;
    [scrollView addSubview:imageview2];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//在imageview3上加载一个透明的button
    if (isFirstTime) {
        [button setTitle:@"开始使用" forState:UIControlStateNormal];
    }else{
        [button setTitle:@"继续使用" forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [button setFrame:CGRectMake(46, 371, 37, 37)];
    [button addTarget:self action:@selector(firstpressed) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    //[button sizeToFit];
    [button setBackgroundImage:[UIImage imageNamed:@"bone.png"] forState:UIControlStateNormal];
    [imageview2 addSubview:button];

    [imageview2 addConstraint:[NSLayoutConstraint
                              
                              constraintWithItem:button
                              
                              attribute:NSLayoutAttributeCenterX
                              
                              relatedBy:NSLayoutRelationEqual
                              
                              toItem:imageview2
                              
                              attribute:NSLayoutAttributeCenterX
                              
                              multiplier:1
                              
                              constant:0]];
    [imageview2 addConstraint:[NSLayoutConstraint
                              
                              constraintWithItem:button
                              
                              attribute:NSLayoutAttributeBottom
                              
                              relatedBy:NSLayoutRelationEqual
                              
                              toItem:imageview2
                              
                              attribute:NSLayoutAttributeBottom
                              
                              multiplier:0.55
                              
                              constant:0]];
    [imageview2 addConstraint:[NSLayoutConstraint
                           
                           constraintWithItem:button
                           
                           attribute:NSLayoutAttributeWidth
                           
                           relatedBy:NSLayoutRelationEqual
                           
                           toItem:imageview2
                           
                           attribute:NSLayoutAttributeWidth
                           
                           multiplier:0.5
                           
                           constant:0]];
    [imageview2 addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:button
                               
                               attribute:NSLayoutAttributeHeight
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:imageview2
                               
                               attribute:NSLayoutAttributeWidth
                               
                               multiplier:0.25
                               
                               constant:0]];
    [self.view addSubview:scrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    pageControl.numberOfPages = 3;
    pageControl.currentPage = 0;
    pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pageControl];
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:pageControl
                               
                               attribute:NSLayoutAttributeCenterX
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeCenterX
                               
                               multiplier:1
                               
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:pageControl
                               
                               attribute:NSLayoutAttributeBottom
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeBottom
                               
                               multiplier:0.95
                               
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:pageControl
                               
                               attribute:NSLayoutAttributeWidth
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeWidth
                               
                               multiplier:0.5
                               
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:pageControl
                               
                               attribute:NSLayoutAttributeHeight
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeWidth
                               
                               multiplier:0.25
                               
                               constant:0]];
    
}
- (void)firstpressed
{
    if (isFirstTime) {
        UINavigationController *transview = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"start"];
        [self presentViewController:transview animated:YES completion:nil];

    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    if(!isFirstTime){
        [self.navigationController setNavigationBarHidden:YES];
    }
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    if(!isFirstTime){
        [self.navigationController setNavigationBarHidden:NO];
    }
    [super viewWillDisappear:animated];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.view.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}
@end
