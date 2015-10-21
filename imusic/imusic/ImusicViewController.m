//
//  ImusicViewController.m
//  imusic
//
//  Created by APPLE28 on 15/10/21.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import "ImusicViewController.h"

@interface ImusicViewController ()
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (nonatomic,strong) NSMutableData *receivedData;
@property long expectedBytes;
@end

@implementation ImusicViewController
@synthesize progress,expectedBytes,receivedData;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tb = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [tb setDataSource:self];
    [tb setDelegate:self];
    [self.view addSubview:tb];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text =@"hello world";
    return cell;
}










//==================DownLoad Code=============================

- (void)downloadFiles:(NSString *)urlstring
{/*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        BOOL needBackup = [self.backupDelegate checkNeedBackup];// 跑在子线程
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if(needBackup){
                UIAlertView *confirmBackupAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"backup_confirm_alert_view_message", @"") delegate:mainViewDelegate cancelButtonTitle:NSLocalizedString(@"button_cancel", @"") otherButtonTitles:NSLocalizedString(@"button_confirm", @""), nil nil];
                confirmBackupAlert.tag = ALERT_TAG_CONFIRM_BACKUP;
                [confirmBackupAlert show];
            }else{
                UIAlertView *noNeedBackupAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"backup_no_need", @"") delegate:mainViewDelegate cancelButtonTitle:NSLocalizedString(@"button_iknow", @"") otherButtonTitles:nil];
                noNeedBackupAlert.tag = ALERT_TAG_BACKUP_NO_NEED;
                [noNeedBackupAlert show];
            }
        });
        
    });*/
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:60];
    receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest
                                                                   delegate:self
                                                           startImmediately:YES];
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    progress.hidden = NO;
    [receivedData setLength:0];
    expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    float progressive = (float)[receivedData length] / (float)expectedBytes;
    [progress setProgress:progressive];
    
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}
- (NSString *)getDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dir = [documentsDirectory stringByAppendingPathComponent:@"imusic"];
    
    
    
    NSFileManager* fm=[NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dir]){
        //下面是对该文件进行制定路径的保存
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
    
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imusicDir = [self getDirectory];
    NSString *path = [imusicDir stringByAppendingPathComponent:[@"dfs" stringByAppendingString:@".mp3"]];
    //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [receivedData writeToFile:path atomically:YES];
    progress.hidden = YES;
}
//=================================================























@end