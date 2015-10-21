//
//  settingViewController.m
//  RemoteIME
//
//  Created by APPLE28 on 15-1-8.
//  Copyright (c) 2015年 none. All rights reserved.
//

#import "settingViewController.h"

@interface settingViewController ()

@end

@implementation settingViewController
//@synthesize buttonTable;
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
    [self.view addSubview:tb];
    
    
    
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:tb
                               
                               attribute:NSLayoutAttributeTop
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeTop
                               
                               multiplier:1
                               
                               constant:10]];
    [self.view addConstraint:[NSLayoutConstraint
                               
                               constraintWithItem:tb
                               
                               attribute:NSLayoutAttributeBottom
                               
                               relatedBy:NSLayoutRelationEqual
                               
                               toItem:self.view
                               
                               attribute:NSLayoutAttributeBottom
                               
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
    return 3;
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
    }else if(row == 1){
        cell.textLabel.text=@"使用教程";
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
        [self.navigationController pushViewController:transview animated:YES];
    }else if(indexPath.row == 1 ){
        //SplashViewController *splash = [[SplashViewController alloc] init];
        SplashViewController *splash = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"splash"];
        splash.isFirstTime = NO;
        [self.navigationController pushViewController:splash animated:YES];

    }else{
        [self checkVersion];
    }
    
}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 60.0f;
//}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
    [title setText:@"系统帮助"];
    [title setFont:[UIFont boldSystemFontOfSize:18]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor blackColor]];
    [title setTextAlignment:NSTextAlignmentLeft];
    [container addSubview:title];
    return container;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    
    return 40.0;
    
}
-(NSMutableDictionary *)dictionaryFromJsonFormatOriginalData:(NSString *)str
{
    SBJsonParser *sbJsonParser = [[SBJsonParser alloc]init];
    NSError *error = nil;
    
    //添加autorelease 解决 内存泄漏问题
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc]initWithDictionary:[sbJsonParser objectWithString:str error:&error]];
    return tempDictionary;
}
-(NSDictionary *)getUpdateInfo:(NSURL *)url
{
    //通过url获取数据
    NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    //解析json数据为数据字典
    NSDictionary *Response = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];
    
    return Response;

}
-(void)checkVersion
{
    NSString *newVersion;
    getUrls = [self getUpdateInfo:[NSURL URLWithString:@"http://123.150.174.234/update/iosupdate.json"]];
    
    
    NSURL *url = [NSURL URLWithString:[getUrls valueForKey:@"appurl"]];
    
    //通过url获取数据
    NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"通过appStore获取的数据是：%@",jsonResponseString);
    
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
        UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:@"升级提示!" message:msg delegate:self cancelButtonTitle:@"下次再说" otherButtonTitles: @"现在升级", nil];
        [createUserResponseAlert show];
    }
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //如果选择“现在升级”
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[getUrls valueForKey:@"downloadurl"]]];
    }
}
@end
