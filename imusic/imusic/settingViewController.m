//
//  settingViewController.m
//  RemoteIME
//
//  Created by APPLE28 on 15-1-8.
//  Copyright (c) 2015年 none. All rights reserved.
//

#import "settingViewController.h"
//#define HTTP_URL @"http://www.imusic.ren/ios/iosupdate.json"

@interface settingViewController ()
@property (strong,nonatomic) Update *up;
@end

@implementation settingViewController
@synthesize up;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //buttonTable.delegate=self;
    //buttonTable.dataSource=self;
    
    UITableView *tb = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tb.dataSource =self;
    tb.delegate =self;
    tb.backgroundColor = [UIColor clearColor];
    tb.translatesAutoresizingMaskIntoConstraints = NO;
    tb.separatorStyle = UITableViewCellSeparatorStyleNone;
    tb.bounces = NO;
    [self.view addSubview:tb];
    
    
    
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:tb
                               
                               attribute:NSLayoutAttributeTop
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeTop
                               
                               multiplier:1
                               
                               constant:60]];
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:tb
                               
                               attribute:NSLayoutAttributeBottom
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.bottomLayoutGuide
                               
                               attribute:NSLayoutAttributeTop
                               
                               multiplier:1
                               
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              
                              constraintWithItem:tb
                              
                              attribute:NSLayoutAttributeLeft
                              
                              relatedBy:NSLayoutRelationEqual
                              
                              toItem:self.view
                              
                              attribute:NSLayoutAttributeLeft
                              
                              multiplier:1
                              
                              constant:20]];
    [self.view addConstraint:[NSLayoutConstraint
                              
                              constraintWithItem:tb
                              
                              attribute:NSLayoutAttributeRight
                              
                              relatedBy:NSLayoutRelationEqual
                              
                              toItem:self.view
                              
                              attribute:NSLayoutAttributeRight
                              
                              multiplier:1
                              
                              constant:-20]];
    
    //buttonTable.style = UITableViewStyleGrouped;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    }
    
    else {
        while ([cell.contentView.subviews lastObject ]!=nil) {
            [(UIView*)[cell.contentView.subviews lastObject]removeFromSuperview];
        }
    }
    //    获取当前行信息值
    NSUInteger row = [indexPath row];
    //    填充行的详细内容
    //cell.detailTextLabel.text = @"详细内容";
    //    把数组中的值赋给单元格显示出来
    if(row == 0){
        cell.textLabel.text=@"关于";//[self.listData objectAtIndex:row];
    }else{
        cell.textLabel.text=@"更新";
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    //    cell.textLabel.backgroundColor= [UIColor greenColor];
    
    //    表视图单元提供的UILabel属性，设置字体大小
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    
    UIImageView *lineImage;
    lineImage= [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, tableView.frame.size.width, 1)];
    lineImage.image = [UIImage imageNamed:@"unsolidline.png"];
    [cell.contentView addSubview:lineImage];
    
    //    tableView.editing=YES;
    /*
     cell.textLabel.backgroundColor = [UIColor clearColor];
     UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
     backgroundView.backgroundColor = [UIColor greenColor];
     cell.backgroundView=backgroundView;
     */
    //    设置单元格UILabel属性背景颜色
    //cell.textLabel.backgroundColor=[UIColor clearColor];
    //    正常情况下现实的图片
    //UIImage *image = [UIImage imageNamed:@"2.png"];
    //cell.imageView.image=image;
    
    //    被选中后高亮显示的照片
    //UIImage *highLightImage = [UIImage imageNamed:@"1.png"];
    //cell.imageView.highlightedImage = highLightImage;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row ==0 ){
        UIViewController *transview = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"instruct"];
        UINavigationController *tt = self.navigationController;
        
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:transview animated:YES];
    }else{
        up = [[Update alloc] init];
        [up checkVersion];
    }
    
}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 60.0f;
//}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat wid = tableView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, 40)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, wid, 40)];
    [title setText:@"系统帮助"];
    [title setFont:[UIFont boldSystemFontOfSize:18]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor blackColor]];
    [title setTextAlignment:NSTextAlignmentLeft];
    
    
    [container addSubview:title];
    UIImageView *lineImage;
    lineImage= [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, tableView.frame.size.width, 1)];
    lineImage.image = [UIImage imageNamed:@"unsolidline.png"];
    [container addSubview:lineImage];
    
    
    
    
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 10)];
    container.backgroundColor = [UIColor whiteColor];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = container.bounds;
    maskLayer.path = maskPath.CGPath;
    container.layer.mask = maskLayer;
    
    
    return container;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CGFloat wid = tableView.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, 10)];
    view.backgroundColor = [UIColor whiteColor];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
    
    return view;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    
    return 40.0;
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section

{
    
    return 10.0;
    
}




+(void)setImageCornerRadius:(UIImageView *)imageView topLeftAndRight:(BOOL)isTop bottomLeftAndRight:(BOOL)isBottom {
    if (isTop && !isBottom) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = imageView.bounds;
        maskLayer.path = maskPath.CGPath;
        imageView.layer.mask = maskLayer;
    } else if (!isTop && isBottom) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = imageView.bounds;
        maskLayer.path = maskPath.CGPath;
        imageView.layer.mask = maskLayer;
    }else{
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = imageView.bounds;
        maskLayer.path = maskPath.CGPath;
        imageView.layer.mask = maskLayer;
    }
}/*
- (void) viewDidLayoutSubviews {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}*/
@end
