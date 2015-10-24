//
//  ImusicViewController.m
//  imusic
//
//  Created by APPLE28 on 15/10/21.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import "ImusicViewController.h"

#define HTTP_URL @"http://www.imusic.ren/app/?"



@interface ImusicViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadind;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UIButton *playbutton;

@property (nonatomic,strong) NSMutableData *receivedData;
@property long expectedBytes;
@property (nonatomic,strong) NSArray *abstractRes;
@property (nonatomic,strong) NSArray *albumRes;
@end

@implementation ImusicViewController
@synthesize progress,loadind,playbutton,expectedBytes,receivedData,abstractRes,albumRes;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    abstractRes = nil;
    albumRes = nil;
    [loadind startAnimating];
    dispatch_queue_t myqueue = dispatch_queue_create("serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(myqueue, ^{
        /*NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[HTTP_URL stringByAppendingString:@"m=Abstracts&a=get"]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        if ([data length] > 0 && error == nil) {
            NSLog(@"%lu bytes of data was returned.",(unsigned long)[data length]);
        }else if ([data length] == 0 && error == nil){
            NSLog(@"No data was returned.");
        }else if (error != nil){
            NSLog(@"Error happened = %@",error);
        }*/
        
        NSString *urlstr = [HTTP_URL stringByAppendingString:@"m=Abstracts&a=get"];
        //通过url获取数据
        NSURL * url = [NSURL URLWithString:urlstr];
        NSError *err;
        NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        if(jsonResponseString != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                //解析json数据为数据字典
                abstractRes = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];

            });
        }
        
        
    });
    
    dispatch_async(myqueue, ^{
        /*NSURL *url = [NSURL URLWithString:urlString];
         NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[HTTP_URL stringByAppendingString:@"m=Abstracts&a=get"]];
         NSURLResponse *response = nil;
         NSError *error = nil;
         NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
         if ([data length] > 0 && error == nil) {
         NSLog(@"%lu bytes of data was returned.",(unsigned long)[data length]);
         }else if ([data length] == 0 && error == nil){
         NSLog(@"No data was returned.");
         }else if (error != nil){
         NSLog(@"Error happened = %@",error);
         }*/
        
        NSString *urlstr = [HTTP_URL stringByAppendingString:@"m=Albums&a=get"];
        //通过url获取数据
        NSURL * url = [NSURL URLWithString:urlstr];
        NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        if(jsonResponseString != nil){
            albumRes = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];
            [playbutton setHidden:NO];
        }
        [loadind stopAnimating];
        
        
    });
    
    
    
    
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}
- (IBAction)pressPlay:(id)sender {
    [playbutton setHidden:YES];
    [progress setHidden:NO];
    [progress setProgress:0];
    //dispatch_sync(dispatch_get_main_queue(), ^{
        //解析json数据为数据字典
        
        
        float num = (float)albumRes.count;
        
        
        for( int i=0; i<num; i++){
            NSDictionary *song =[albumRes objectAtIndex:i];
            NSString *url=[song objectForKey:@"url"];
            NSString *name=[song objectForKey:@"name"];
            [self downloadFiles:url filename:name];
            float progressive = (float)i / num;
            [progress setProgress:progressive];
        }
        
        
    //});
    [progress setHidden:YES];
    [playbutton setHidden:NO];
}

-(NSArray *)dictionaryFromJsonFormatOriginalData:(NSString *)str
{
    SBJsonParser *sbJsonParser = [[SBJsonParser alloc]init];
    //NSError *error = nil;
    //NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc]initWithDictionary:[sbJsonParser objectWithString:str error:&error]];
    return [sbJsonParser objectWithString:str error:nil];
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











//==================DownLoad Code=============================

- (void)downloadFiles:(NSString *)urlstring filename:(NSString *)name
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
    /*receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest
                                                                   delegate:self
                                                           startImmediately:YES];
    */
    

    NSData *syData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];

    if (syData != nil) {
            
        NSString *imusicDir = [self getDirectory];
        NSString *path = [imusicDir stringByAppendingPathComponent:name];
            //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [syData writeToFile:path atomically:YES];
        progress.hidden = YES;
    }
    
}

/*
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
}*/
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
/*
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imusicDir = [self getDirectory];
    NSString *path = [imusicDir stringByAppendingPathComponent:[@"dfs" stringByAppendingString:@".mp3"]];
    //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [receivedData writeToFile:path atomically:YES];
    progress.hidden = YES;
}*/
//=================================================






















@end