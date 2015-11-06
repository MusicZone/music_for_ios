//
//  ImusicViewController.m
//  imusic
//
//  Created by APPLE28 on 15/10/21.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import "ImusicViewController.h"

#define HTTP_URL @"http://www.imusic.ren/app/?"
#define NOTICE @"播放过程需要使用网络流量，最好使用WIFI网络！"


@interface ImusicViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadind;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UIButton *playbutton;
@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong,nonatomic) Update *up;
@property (nonatomic,strong) NSMutableData *receivedData;
@property long expectedBytes;
@property (nonatomic,strong) NSArray *abstractRes;
@property (nonatomic,strong) NSArray *albumRes;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) NSMutableArray *playeritems;
@property (nonatomic,strong) NSEnumerator *itemen;
@end

@implementation ImusicViewController
@synthesize progress,loadind,playbutton,expectedBytes,receivedData,abstractRes,albumRes,player,playeritems,itemen,title,up;
- (void)viewDidLoad {
    [super viewDidLoad];
    up = [[Update alloc] init];
    [up checkVersion];
    
    player=nil;
    abstractRes = nil;
    albumRes = nil;
    progress.layer.cornerRadius = 10.0;
    progress.clipsToBounds = YES;
    
    
    [title setText:NOTICE];
    CGFloat width = title.frame.size.width;
    CGSize labelSize = [NOTICE sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(width, 500) lineBreakMode:UILineBreakModeWordWrap];
    
    title.numberOfLines = 0;
    title.lineBreakMode = UILineBreakModeWordWrap;
    title.frame = CGRectMake(0, 0, 300, labelSize.height);
    [title setHidden:NO];
    
    
    
    
    [self reload];
    
    // Do any additional setup after loading the view.
}
-(void)reload{
    [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:NO];
    [[[[self.tabBarController tabBar] items] objectAtIndex:2] setEnabled:NO];
    [playbutton setHidden:YES];
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
            abstractRes = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             //解析json数据为数据字典
             
             });*/
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
            
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(albumRes !=nil){
                [playbutton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                                      forState:UIControlStateNormal];
                [playbutton addTarget:self
                               action:@selector(pressPlay:)
                     forControlEvents:UIControlEventTouchUpInside];
                
            }else{
                [playbutton setBackgroundImage:[UIImage imageNamed:@"reload.png"]
                                      forState:UIControlStateNormal];
                [playbutton addTarget:self
                               action:@selector(pressReload:)
                     forControlEvents:UIControlEventTouchUpInside];
                [self showAlertView:@"请连接网络后重新刷新歌单!"];
            }
            [playbutton setHidden:NO];
            [loadind stopAnimating];
            [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:YES];
            [[[[self.tabBarController tabBar] items] objectAtIndex:2] setEnabled:YES];
            
        });
        
        
    });
}
- (void)downloadSongs:(int)ind{
    [title setHidden:YES];
    [playbutton setHidden:YES];
    [progress setHidden:NO];
    [progress setProgress:0];
    //dispatch_sync(dispatch_get_main_queue(), ^{
    //解析json数据为数据字典
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        
        float num = (float)albumRes.count;
        playeritems = [[NSMutableArray alloc] init];
        
        for( int i=0; i<num; i++){
            NSDictionary *song =[albumRes objectAtIndex:i];
            NSString *url=[song objectForKey:@"url"];
            NSString *name=[song objectForKey:@"name"];
            NSString *path = [self downloadFiles:url filename:name];
            
            float progressive = (float)(i+1) / num;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [progress setProgress:progressive];
            });
            
            if ([path isEqualToString:@""]) {
                break;
            }
            NSURL *furl = [NSURL URLWithString:[[abstractRes objectAtIndex:i] objectForKey:@"url"]];
            [playeritems addObject:[AVPlayerItem playerItemWithURL:furl]];
            
            furl = [NSURL fileURLWithPath:path];
            [playeritems addObject:[AVPlayerItem playerItemWithURL:furl]];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [progress setHidden:YES];
            [playbutton setHidden:NO];
            [title setHidden:NO];
            /*[sender addTarget:self
             action:@selector(playSong:)
             forControlEvents:UIControlEventTouchUpInside];*/
            itemen =[playeritems objectEnumerator];
            for (int i=0; i<ind; i++) {
                [itemen nextObject];
            }
            [self play];
            [playbutton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                  forState:UIControlStateNormal];
            
        });
    });
}/*
- (void)downloadSongsAgain:(int)ind{
    [title setHidden:YES];
    [playbutton setHidden:YES];
    [progress setHidden:NO];
    [progress setProgress:0];
    //dispatch_sync(dispatch_get_main_queue(), ^{
    //解析json数据为数据字典
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        
        float num = (float)albumRes.count;
        playeritems = [[NSMutableArray alloc] init];
        
        for( int i=0; i<num; i++){
            NSDictionary *song =[albumRes objectAtIndex:i];
            NSString *url=[song objectForKey:@"url"];
            NSString *name=[song objectForKey:@"name"];
            NSString *path = [self downloadFiles:url filename:name];
            
            float progressive = (float)(i+1) / num;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [progress setProgress:progressive];
            });
            
            if ([path isEqualToString:@""]) {
                break;
            }
            NSURL *furl = [NSURL URLWithString:[[abstractRes objectAtIndex:i] objectForKey:@"url"]];
            [playeritems addObject:[AVPlayerItem playerItemWithURL:furl]];
            
            furl = [NSURL fileURLWithPath:path];
            [playeritems addObject:[AVPlayerItem playerItemWithURL:furl]];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [progress setHidden:YES];
            [playbutton setHidden:NO];
            [title setHidden:YES];
            
            /*[sender addTarget:self
             action:@selector(playSong:)
             forControlEvents:UIControlEventTouchUpInside];*//*
            itemen =[playeritems objectEnumerator];
            
            
            
            
            [self play];

            
            
            
            /*[sender addTarget:self
             action:@selector(playSong:)
             forControlEvents:UIControlEventTouchUpInside];*/
            //itemen =[playeritems objectEnumerator];
            //AVPlayerItem *bj = [player currentItem];
            //AVPlayerItem *bj = [itemen nextObject];
            //[player replaceCurrentItemWithPlayerItem:item];
            //NSError * er = [item error];
            //er =nil;
            //player = [AVPlayer playerWithPlayerItem:bj];
            //player = [AVPlayer playerWithPlayerItem:item];
            //[player play];
            ////player = [AVPlayer r:item];
            //[bj addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
            //[player seekToTime:kCMTimeZero];
            //[self play];
            /*[playbutton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                  forState:UIControlStateNormal];
            
        });
    });
}*/
- (void)pressPlay:(id)sender {
    if (player != nil && player.rate > 0 && !player.error) {
        [player pause];
        [playbutton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                              forState:UIControlStateNormal];
    }else{
        
        if(player == nil){
            [self downloadSongs:0];
        }else{
            [player play];
            [playbutton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                  forState:UIControlStateNormal];
        }
    }
    
}
- (void)pressReload:(id)sender {
    [self reload];
}
- (void)play{
    AVPlayerItem *bj = [itemen nextObject];
    if(bj != nil){
        NSURL *aurl = [(AVURLAsset *)bj.asset URL];
        
        bool re = [[aurl scheme] isEqualToString:@"http"];
        if(re){
            
            [title setHidden:YES];
        }else{
            
            AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:aurl options:nil];
            NSString *tt = [[[aurl absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            for (NSString *format in [mp3Asset availableMetadataFormats]) {
                NSArray<AVMetadataItem *> *dd = [mp3Asset metadataForFormat:format];
                for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
                    if ([metadataItem.commonKey isEqual:AVMetadataCommonKeyTitle]) {
                        tt = (NSString *)metadataItem.value;
                    }
                }
            }
            [title setText:tt];
            [title setHidden:NO];
            CGFloat width = title.frame.size.width;
            CGSize labelSize = [tt sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(width, 500) lineBreakMode:UILineBreakModeWordWrap];
            
            title.numberOfLines = 0;
            title.lineBreakMode = UILineBreakModeWordWrap;
            title.frame = CGRectMake(0, 0, 300, labelSize.height);
            [title setHidden:NO];
            [self.view setNeedsLayout];
        }
        
        player = [AVPlayer playerWithPlayerItem:bj];
        [bj addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:bj];
    }else{
        player = nil;
        [playbutton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                              forState:UIControlStateNormal];
        
    }
}
- (void)closeAll
{
    [player pause];
    [playbutton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                          forState:UIControlStateNormal];
}
//- (void)playSong:(id)sender{
/*
 NSURL *url = [NSURL fileURLWithPath:[[abstractRes objectAtIndex:0] objectForKey:@"url"]];
 player = [[AVPlayer alloc] initWithURL:url];
 [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
 */

/*
 NSURL *videoUrl = [NSURL URLWithString:@"http://www.jxvdy.com/file/upload/201405/05/18-24-58-42-627.mp4"];
 self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
 [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
 [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
 self.player = [AVPlayer playerWithPlayerItem:self.playerItem];<br>[[NSNotificationCenterdefaultCenter]addObserver:selfselector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotificationobject:self.playerItem];
 */

/*
 
 NSURL *url = [NSURL fileURLWithPath:[[albums objectAtIndex:index] objectForKey:@"path"]];
 NSURL *videoUrl = [NSURL URLWithString:
 @"http:/1/v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
 self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
 [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
 [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
 self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
 self.playerView.player = _player;
 self.stateButton.enabled = NO;
 
 
 
 
 
 */

/*
 NSData *filedata = [NSData dataWithContentsOfURL:url];
 player = [[AVAudioPlayer alloc] initWithData:filedata error:nil];
 if(player != nil){
 [player setDelegate:self];
 if([player prepareToPlay]){
 [player play];
 }
 }*/
//}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if([keyPath isEqualToString:@"status"]){
        AVPlayerItemStatus  tt = [playerItem status];
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [player play];
        }else{
            int index = [playeritems indexOfObject:[player currentItem]];
            /*AVPlayerItem *bj = [player currentItem];
            if(bj)
                bj =nil;
            [[player currentItem] removeObserver:self forKeyPath:@"status" context:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];*/
            [[player currentItem] removeObserver:self forKeyPath:@"status" context:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
            [self downloadSongs:index];
            //player = [AVPlayer playerWithPlayerItem:[player currentItem]];
            
            //[self play];
        }
        
    }
    
    /*
     AVPlayerItem *playerItem = (AVPlayerItem *)object;
     if ([keyPath isEqualToString:@"status"]) {
     if ([playerItem status] == AVPlayerStatusReadyToPlay) {
     NSLog(@"AVPlayerStatusReadyToPlay");
     self.stateButton.enabled = YES;
     CMTime duration = self.playerItem.duration;// 获取视频总长度
     CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
     _totalTime = [self convertTime:totalSecond];// 转换成播放时间
     [self customVideoSlider:duration];// 自定义UISlider外观
     NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
     [self monitoringPlayback:self.playerItem];// 监听播放状态
     } else if ([playerItem status] == AVPlayerStatusFailed) {
     NSLog(@"AVPlayerStatusFailed");
     }
     } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
     NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
     NSLog(@"Time Interval:%f",timeInterval);
     CMTime duration = self.playerItem.duration;
     CGFloat totalDuration = CMTimeGetSeconds(duration);
     [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
     
     }*/
}
- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    [[player currentItem] removeObserver:self forKeyPath:@"status" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
    
    
    
    [self play];
    /*
     NSLog(@"Play end");
     
     __weak typeof(self) weakSelf = self;
     [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
     [weakSelf.videoSlider setValue:0.0 animated:YES];
     [weakSelf.stateButton setTitle:@"Play" forState:UIControlStateNormal];
     }];*/
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

- (NSString *)downloadFiles:(NSString *)urlstring filename:(NSString *)name
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
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self saveToFile:syData filepath:path];
        return path;
    }
    return @"";
}
- (void)saveToFile:(NSData *)data filepath:(NSString *)path{
    
    NSFileManager* fm=[NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path]){
        //下面是对该文件进行制定路径的保存
        [data writeToFile:path atomically:YES];
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
/*
- (void) viewDidLayoutSubviews {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}*/


#pragma mark - alert


-(void)showAlertView:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert setTag:index];
    [alert show];
}

















@end