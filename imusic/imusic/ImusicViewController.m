//
//  ImusicViewController.m
//  imusic
//
//  Created by APPLE28 on 15/10/21.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import "ImusicViewController.h"
#import "NSString+AESCrypt.h"
#import "FileHash.h"

#define HTTP_URL @"http://www.imusic.ren/app/?"
//#define HTTP_URL @"http://192.168.119.101/imusic/app/"
#define NOTICE @"播放过程需要使用网络流量，最好使用WIFI网络！"
@interface NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
@end

@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}
@end

@interface ImusicViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadind;
@property (strong, nonatomic) IBOutlet UILabel *progressTitle;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UIButton *playbutton;
@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong,nonatomic) Update *up;
@property (nonatomic,strong) NSMutableData *receivedData;
@property long expectedBytes;
@property (nonatomic,strong) NSString *key;
@property int current_present;
@property int step_present;
@property (nonatomic,strong) NSEnumerator *md5It;
@property (nonatomic,strong) NSString *md5;
@property (nonatomic,strong) NSEnumerator *urlIt;
@property BOOL s_finished;
@property int times;
@property int block;
@property int fz;
@property int steps;
@property (nonatomic,strong) NSMutableData *buffer;
@property (atomic,strong) NSMutableDictionary *allparts;
@property (atomic,strong) NSOperationQueue * queue;
@property (atomic,strong) NSMutableDictionary *mdmap;

@property (nonatomic,strong) NSArray *abstractRes;
@property (nonatomic,strong) NSArray *albumRes;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) NSMutableArray *playeritems;
@property (nonatomic,strong) NSEnumerator *itemen;
@end

@implementation ImusicViewController
@synthesize key,progress,loadind,playbutton,expectedBytes,receivedData,abstractRes,albumRes,player,playeritems,itemen,title,up,progressTitle,current_present,step_present,md5It,md5,urlIt,s_finished,times,block,fz,steps,buffer,allparts,queue,mdmap;
- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
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
    key = @"+imusic2015weshiimusic2015weshi+";
    
    
    
    [self reload];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoEnd) name:UIApplicationWillTerminateNotification object:nil];
    // Do any additional setup after loading the view.
}
- (void) gotoBackground
{
    if (queue != nil) {/*
        [queue cancelAllOperations];
        [progress setHidden:YES];
        [progressTitle setHidden:YES];
        [progressTitle setText:@""];
        [playbutton setHidden:NO];
        [title setHidden:NO];
        queue = nil;*/
        [queue setSuspended:YES];
                    
        
    }
    
}
- (void) gotoForeground
{
    if (queue != nil) {/*
                        [queue cancelAllOperations];
                        [progress setHidden:YES];
                        [progressTitle setHidden:YES];
                        [progressTitle setText:@""];
                        [playbutton setHidden:NO];
                        [title setHidden:NO];
                        queue = nil;*/
        [queue setSuspended:NO];
        
        
    }
    
}
- (void) gotoEnd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        int test = receivedEvent.subtype;
        switch (test) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlStop:
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
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                break;
                
            default:
                break;
        }
    }
}
-(void)reload{
    [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:NO];
    [[[[self.tabBarController tabBar] items] objectAtIndex:2] setEnabled:NO];
    [playbutton setHidden:YES];
    [loadind startAnimating];
    dispatch_queue_t myqueue = dispatch_queue_create("serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(myqueue, ^{
        
        NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *formatstring = [NSString stringWithFormat:@"m=Abstracts&a=get&sys=ios&ver=%.2f",[localVersion floatValue]];
        NSString *urlstr = [HTTP_URL stringByAppendingString:formatstring];
        //NSString *urlstr = [HTTP_URL stringByAppendingString:@"m=Abstracts&a=get"];
        //通过url获取数据
        NSURL * url = [NSURL URLWithString:urlstr];
        NSError *err;
        NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        if(jsonResponseString != nil){
            abstractRes = [self dictionaryFromJsonFormatOriginalData:jsonResponseString];

        }
        
    });
    
    dispatch_async(myqueue, ^{
        NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *formatstring = [NSString stringWithFormat:@"m=Albums&a=get&sys=ios&ver=%.2f",[localVersion floatValue]];
        
        NSString *urlstr = [HTTP_URL stringByAppendingString:formatstring];
        //NSString *urlstr = [HTTP_URL stringByAppendingString:@"m=Albums&a=get"];
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
- (NSString *)getDecodeString:(NSDictionary *)dic section:(NSString *)sec{
    NSString *enstr = [dic objectForKey:sec];
    return [enstr AES256DecryptWithKey:key];

}
- (void)addFourTimes:(NSMutableDictionary *)dic{
    NSEnumerator *enumerator = [dic keyEnumerator];
    id key = [enumerator nextObject];
    while (key) {
        NSMutableArray *ar =  [dic objectForKey:key];
        ar = [ar arrayByAddingObjectsFromArray:ar];
        ar = [ar arrayByAddingObjectsFromArray:ar];
        [dic setValue:ar forKey:key];
        key = [enumerator nextObject];
    }

}
- (long long)freeDiskSpace

{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *fattributes = [[ NSFileManager defaultManager ] attributesOfFileSystemForPath : [paths lastObject] error : nil ];
    if (fattributes != nil) {
        NSNumber *result = [fattributes objectForKey : NSFileSystemFreeSize ];
        return [result longLongValue];
    }else{
        return 0;
    }
    
}
- (NSDictionary *)getFileSize:(NSString *)urlstring
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60];
    
    NSError * error;
    NSURLResponse * rep;
    
    
    theRequest.HTTPMethod = @"HEAD";
    //[theRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    NSData *headdata = [NSURLConnection sendSynchronousRequest:(NSURLRequest *)theRequest returningResponse:&rep error:&error];
    int filesize = rep.expectedContentLength;
    NSHTTPURLResponse *rp = (NSHTTPURLResponse *)rep;
    //int ttt = rp.statusCode;
    if(rp.statusCode==200 || rp.statusCode == 206){
        
        NSDictionary *dc = [rp allHeaderFields];
        
        if([[dc allKeys] containsObject:@"Content-Type"]){
            
            NSString *range = [dc objectForKey:@"Content-Type"];
            if ([range isEqualToString:@"text/html"]) {
                
                [result setObject:[NSNumber numberWithInt:0] forKey:@"size"];
                [result setObject:[NSNumber numberWithInt:-1] forKey:@"status"];
                return result;
            }
        
        }
        
        [result setObject:[NSNumber numberWithInt:filesize] forKey:@"size"];
        //[result setObject:[NSNumber numberWithInt:1024*110] forKey:@"size"];
        
        if([[dc allKeys] containsObject:@"Accept-Ranges"]){
            
            NSString *range = [dc objectForKey:@"Accept-Ranges"];
            if ([range isEqualToString:@"bytes"]) {
                [result setObject:[NSNumber numberWithInt:1] forKey:@"status"];

            }else{
                [result setObject:[NSNumber numberWithInt:0] forKey:@"status"];
            }
        }else{
        
            [result setObject:[NSNumber numberWithInt:0] forKey:@"status"];
        }
        
        return result;
    }else{
        [result setObject:[NSNumber numberWithInt:0] forKey:@"size"];
        [result setObject:[NSNumber numberWithInt:-1] forKey:@"status"];
        
    }
    return result;

}
- (void)downByThread:(NSString *)url fromwhere:(int)from blocksize:(int)size index:(int)ind mdstr:(NSString *)md filebuf:(NSMutableData *)buf
{
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:100.f];
    
    NSString *range = [NSString stringWithFormat:@"bytes=%d-%d", from, from+size-1];
    //SLog(@"%@", range);
    [theRequest setValue:range forHTTPHeaderField:@"Range"];
    
    NSError * error;
    NSURLResponse * rep;
    //SLog(@"openthreadstart:%@",range);
    NSData *syData = [NSURLConnection sendSynchronousRequest:(NSURLRequest *)theRequest returningResponse:&rep error:&error];
    //SLog(@"openthreadend:%@",range);
    if (syData !=nil && [syData length]==size) {
        NSRange range;
        range.location = from;
        range.length = size;
        [buf replaceBytesInRange:range withBytes:[syData bytes]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [allparts setObject:@"1" forKey:[NSString stringWithFormat:@"%d",ind]];
                
                int gets = allparts.count;
                int progressive =  current_present +  (step_present*gets)/steps;
                
                [progress setProgress:(float)progressive/100];
                NSString *ptx = [NSString stringWithFormat:@"歌曲同步了%i%%!",progressive];
                [progressTitle setText:ptx];
                //SLog(@"***********downloadfinnished:%i/%i****************",gets,steps);
                if(gets == steps){
                    s_finished = true;
                    queue = nil;
                }
            });
    }else{
        NSHTTPURLResponse *rp = (NSHTTPURLResponse *)rep;
        int ttt = rp.statusCode;

        dispatch_sync(dispatch_get_main_queue(), ^{
            if(times>0) {
                times--;
                NSArray *urlinfo = [urlIt nextObject];
                if(urlinfo != nil) {
                    NSString *utemp = [urlinfo objectAtIndex:1];
                    long downloadsize = [urlinfo objectAtIndex:0];
                    
                    if(downloadsize!=0 && downloadsize <= [self freeDiskSpace] && queue != nil){
                        [queue addOperationWithBlock:^{
                            //SLog(@"========Aqueueworkon:%i-%@-%i-%i",ind,utemp,from,size);
                            [self downByThread:utemp fromwhere:from blocksize:size index:ind mdstr:md filebuf:buf];
                            
                        }];
                    }
                }else{
                    int checktime = 5;
                    while(checktime>0) {
                        
                        NSString *md5_temp = [md5It nextObject];
                        while (md5_temp != nil) {
                            
                            
                            NSMutableArray *temp = [mdmap objectForKey:md5];
                            
                            urlIt = [temp objectEnumerator];
                            
                            NSArray *urlinfo = [urlIt nextObject];
                            while (urlinfo != nil) {
                                NSString *downloadurl = [urlinfo objectAtIndex:1];
                                long downloadsize = [urlinfo objectAtIndex:0];
                                if (md5 == md5_temp) {
                                    if(downloadsize!=0 && downloadsize <= [self freeDiskSpace]  && queue != nil){
                                        [queue addOperationWithBlock:^{
                                            //SLog(@"========Bqueueworkon:%i-%@-%i-%i",ind,downloadurl,from,size);
                                            [self downByThread:downloadurl fromwhere:from blocksize:size index:ind mdstr:md filebuf:buf];
                                            
                                        }];
                                        return;
                                    }
                                }else{
                                    md5 = md5_temp;
                                    if(downloadsize==0 || downloadsize> [self freeDiskSpace]){
                                        urlinfo = [urlIt nextObject];
                                        continue;
                                    }
                                    
                                    NSString *url1 = downloadurl;
                                    
                                    NSString *url2 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                                    if (url2 ==nil) {
                                        url2 = downloadurl;
                                    }
                                    NSString *url3 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                                    if (url3 ==nil) {
                                        url3 = downloadurl;
                                    }
                                    NSString *url4 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                                    if (url4 ==nil) {
                                        url4 = downloadurl;
                                    }
                                    NSString *url5 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                                    if (url5 ==nil) {
                                        url5 = downloadurl;
                                    }
                                    
                                    
                                    NSArray *firstgroup = [NSArray arrayWithObjects:url1,url2,url3,url4,url5, nil];
                                    
                                    if([self downUrls:firstgroup mdstr:md5] == 1){
                                        return;
                                    }
                                }
                                
                                
                                
                                urlinfo = [urlIt nextObject];

                            }
                            md5_temp = [md5It nextObject];

                        }
                        checktime--;
                        md5It = [mdmap keyEnumerator];
                    }
                
                
                }
            }
        });
    }
}
- (int)downUrls:(NSArray *)urlsgroup mdstr:(NSString *)md
{
    //here liweichen
    times = 100;
    int trys =3;
    while (trys>0) {
        NSArray *temp = [urlsgroup objectAtIndex:(3-trys)];
        NSDictionary *sizedic = [self getFileSize:temp];
        int status = [(NSNumber*)[sizedic objectForKey:@"status"] intValue];
        int size = [(NSNumber*)[sizedic objectForKey:@"size"] intValue];
        if (status == 1) {
            fz = size;
            block =1024*100;
            break;
        }else if (status == 0){
            fz = block = size;
            break;
        }else{
        
            trys--;
        }
    }
    if (trys <=0) {
        return -1;
    }
    
    if (fz%block) {
        steps = fz/block+1;
    }else{
        steps = fz/block;
    }
    
    
    buffer = [[NSMutableData alloc] initWithLength:fz];
    allparts = [[NSMutableDictionary alloc] initWithCapacity:steps];
    s_finished = false;
    int from = 0;
    
    queue=[[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:10];
    
    
    for(int thnum=0;thnum<steps;thnum++){
    //for(int thnum=0;thnum<1;thnum++){
        NSString *utemp = [urlsgroup objectAtIndex:thnum%5];
        int btemp;
        int ftemp = from;
        if(fz-1>=from+block-1){
            btemp = block;
            from += block;
        }else{
            btemp = fz - from;
            from = fz;
        }
        if(queue != nil){
            [queue addOperationWithBlock:^{
            //SLog(@"queueworkonM:%i-%@-%i-%i",thnum,utemp,ftemp,btemp);
            [self downByThread:utemp fromwhere:ftemp blocksize:btemp index:thnum mdstr:md filebuf:buffer];
            
            }];
            [NSThread sleepForTimeInterval:0.01];
        }
        
        

        
    }
    
    return 1;
}

- (NSString *)downFile:(NSDictionary *)dic filename:(NSString *)name current:(int)cur thisstep:(int)step
{
    
    NSString *imusicDir = [self getDirectory];
    NSString *path = [imusicDir stringByAppendingPathComponent:name];
    NSFileManager* fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:path]){
        int progressive =  cur+step;//(float)which/whole + (float)1/whole;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [progress setProgress:(float)progressive/100];
            NSString *ptx = [NSString stringWithFormat:@"歌曲同步了%i%%!",progressive];
            [progressTitle setText:ptx];
        });
        return path;
    }else{
        NSString *downloadurl;
        int downloadsize=0;
        
        current_present = cur;
        step_present = step;
        
        md5It = [dic keyEnumerator];
        md5 = [md5It nextObject];
        while (md5 != nil) {
            NSMutableArray *temp = [dic objectForKey:md5];
            
            urlIt = [temp objectEnumerator];
            
            NSArray *urls = [urlIt nextObject];
            while (urls != nil) {
                downloadsize = [(NSNumber *)[urls objectAtIndex:0] intValue];
                downloadurl = [urls objectAtIndex:1];
                if(downloadsize==0 || downloadsize> [self freeDiskSpace])
                {
                    urls = [urlIt nextObject];
                    continue;
                }
                
                NSString *url1 = downloadurl;
                
                NSString *url2 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                if (url2 ==nil) {
                    url2 = downloadurl;
                }
                NSString *url3 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                if (url3 ==nil) {
                    url3 = downloadurl;
                }
                NSString *url4 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                if (url4 ==nil) {
                    url4 = downloadurl;
                }
                NSString *url5 = [(NSArray *)[urlIt nextObject] objectAtIndex:1];
                if (url5 ==nil) {
                    url5 = downloadurl;
                }
                
                
                NSArray *firstgroup = [NSArray arrayWithObjects:url1,url2,url3,url4,url5, nil];
                
                if([self downUrls:firstgroup mdstr:md5] !=1)
                    return nil;
                while(!s_finished || queue != nil){
                
                    [NSThread sleepForTimeInterval:0.5]; 
                }
                if (buffer != nil) {
                    if (md5 != nil) {
                        
                        //for test
                        NSString *timusicDir = [self getDirectory];
                        NSString *tpath = [imusicDir stringByAppendingPathComponent:name];
                        [self saveToFile:buffer filepath:tpath];
                        
                        NSString *checksum = [self computeMD5HashOfData:buffer];
                        if (![checksum isEqualToString:md5]) {
                            allparts = nil;
                            return nil;
                        }
                        NSString *aResults = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
                        if(aResults && [aResults containsString:@"<html>"]) {
                            allparts = nil;
                            return nil;
                        }
                        NSString *imusicDir = [self getDirectory];
                        NSString *path = [imusicDir stringByAppendingPathComponent:name];
                        [self saveToFile:buffer filepath:path];
                        allparts = nil;
                        return path;
                    }
                }else{
                    allparts = nil;
                    return nil;
                }
                urls = [urlIt nextObject];
            }
            
            md5 = [md5It nextObject];
        }
        
    }
    return nil;
}

- (void)downloadSongs:(int)ind{
    [title setHidden:YES];
    [playbutton setHidden:YES];
    [progress setHidden:NO];
    [progressTitle setHidden:NO];
    [progressTitle setText:@""];
    [progress setProgress:0];
    [progressTitle setText:@"歌曲同步了0%!"];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    //dispatch_sync(dispatch_get_main_queue(), ^{
    //解析json数据为数据字典
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        
        float num = (float)albumRes.count;
        playeritems = [[NSMutableArray alloc] init];
        int current =0;
        int step = 100/num;
        
        
        for( int i=0; i<num; i++){
            NSDictionary *song =[albumRes objectAtIndex:i];
            
            
            
            NSString *enstr = [song objectForKey:@"name"];
            NSString *destr = [enstr AES256DecryptWithKey:key];
            
            NSString *name=destr;
            
            int nm = 1;
            NSString *sec = @"";
            NSString *path = @"";
            
            
            int sum=[[self getDecodeString:song section:@"urls_count"] intValue];
            mdmap = [[NSMutableDictionary alloc] init];
            
            NSString *urlstr;
            NSString *sizestr;
            NSString *mdstr;
            NSString *url;
            NSString *size;
            NSString *md;
            for(int i=1;i<=sum;i++){
                urlstr = [NSString stringWithFormat:@"%@%d",@"url",i];
                sizestr = [NSString stringWithFormat:@"%@%d",@"size",i];
                mdstr = [NSString stringWithFormat:@"%@%d",@"md",i];
            
                url = [self getDecodeString:song section:urlstr];
                size = [self getDecodeString:song section:sizestr];
                md = [self getDecodeString:song section:mdstr];
                
                if(url == nil || [url isEqualToString:@""])
                    continue;
                if(size == nil || [size isEqualToString:@"0"] || [size isEqualToString:@""])
                    continue;
                if(md == nil || [md isEqualToString:@"0"] || [md isEqualToString:@""])
                    continue;
                NSMutableArray *urls;
                if ([[mdmap allKeys] containsObject:md]) {
                    urls = [mdmap objectForKey:md];
                    
                }else{
                    
                    urls = [[NSMutableArray alloc] init];
                    [mdmap setObject:urls forKey:md];
                }
                NSArray *urlinfo = [NSArray arrayWithObjects:size,url, nil];
                //NSArray *urlinfo = [NSArray arrayWithObjects:size,@"http://192.168.119.101/test.mp3", nil];
                [urls addObject:urlinfo];
                
            }
            [self addFourTimes:mdmap];
            NSString *ph = [self downFile:mdmap filename:name current:current thisstep:step];
            current +=step;
            if (ph != nil) {
                NSURL *furl = [NSURL URLWithString:[self getDecodeString:[abstractRes objectAtIndex:i] section:@"url"]];
                [playeritems addObject:[AVPlayerItem playerItemWithURL:furl]];
                furl = [NSURL fileURLWithPath:ph];
                [playeritems addObject:[AVPlayerItem playerItemWithURL:furl]];
            }
            
            
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [progress setHidden:YES];
            [progressTitle setHidden:YES];
            [progressTitle setText:@""];
            [playbutton setHidden:NO];
            [title setHidden:NO];
            //[sender addTarget:self
            // action:@selector(playSong:)
            // forControlEvents:UIControlEventTouchUpInside];
            itemen =[playeritems objectEnumerator];
            for (int i=0; i<ind; i++) {
                [itemen nextObject];
            }
            [self play];
            
            
            [UIApplication sharedApplication].idleTimerDisabled=NO;
            
        });
    });
}
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
        
        bool re = [[aurl scheme] isEqualToString:@"http"] | [[aurl scheme] isEqualToString:@"https"];
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
            //[title setHidden:NO];
            CGFloat width = title.frame.size.width;
            CGSize labelSize = [tt sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(width, 500) lineBreakMode:UILineBreakModeWordWrap];
            
            title.numberOfLines = 0;
            title.lineBreakMode = UILineBreakModeWordWrap;
            title.frame = CGRectMake(0, 0, 300, labelSize.height);
            [title setHidden:NO];
            [self.view setNeedsLayout];
        }
        
        AVURLAsset      *asset          = bj.asset;
        AVPlayerItem    *playerItem     = [AVPlayerItem playerItemWithAsset:asset];
        AVAssetResourceLoader *loader   = asset.resourceLoader;
        [loader setDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        player = [AVPlayer playerWithPlayerItem:bj];
        [bj addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:bj];
        [playbutton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                              forState:UIControlStateNormal];
    }else{
        player = nil;
        [playbutton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                              forState:UIControlStateNormal];
        [title setText:@""];
        [title setHidden:YES];
    }
}
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader    shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    
    //Handle NSURLConnection to the SSL secured resource here
    return YES;
}
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge
{
    //server trust
    NSURLProtectionSpace *protectionSpace = authenticationChallenge.protectionSpace;
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [authenticationChallenge.sender useCredential:[NSURLCredential credentialForTrust:authenticationChallenge.protectionSpace.serverTrust] forAuthenticationChallenge:authenticationChallenge];
        [authenticationChallenge.sender continueWithoutCredentialForAuthenticationChallenge:authenticationChallenge];
        
    }
    else{ // other type: username password, client trust..
    }
    return YES;
}

- (void)closeAll
{
    [player pause];
    [playbutton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                          forState:UIControlStateNormal];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if([keyPath isEqualToString:@"status"]){
        AVPlayerItemStatus  tt = [playerItem status];
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [player play];
        }else{
            AVPlayerItem * ss = [player currentItem];
            NSError *er = ss.error;
            int index = [playeritems indexOfObject:[player currentItem]];
            [[player currentItem] removeObserver:self forKeyPath:@"status" context:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
            [self downloadSongs:index];
        }
        
    }
}
- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    [[player currentItem] removeObserver:self forKeyPath:@"status" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
    [self play];
}
-(NSArray *)dictionaryFromJsonFormatOriginalData:(NSString *)str
{
    SBJsonParser *sbJsonParser = [[SBJsonParser alloc]init];
    return [sbJsonParser objectWithString:str error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)saveToFile:(NSData *)data filepath:(NSString *)path{
    
    NSFileManager* fm=[NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path]){
        //下面是对该文件进行制定路径的保存
        [data writeToFile:path atomically:YES];
    }
    
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
- (NSString *)computeMD5HashOfData:(NSData *)dt {
    //NSString *executablePath = [[NSBundle mainBundle] executablePath];
    NSString *dataMD5Hash = [FileHash md5HashOfData:dt];
    return dataMD5Hash ? dataMD5Hash : @"";
}
@end