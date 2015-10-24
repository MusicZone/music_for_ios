//
//  LocalViewController.m
//  imusic
//
//  Created by APPLE28 on 15/10/21.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import "LocalViewController.h"
#import "localTableViewCell.h"

@interface LocalViewController ()
@property int mp3count;
@property (strong, nonatomic) IBOutlet UITableView *songtable;
@property (nonatomic,strong) NSMutableArray *albums;
@property (nonatomic,strong)  AVAudioPlayer *player;
@end

@implementation LocalViewController
@synthesize mp3count,albums,player,songtable;
- (void)viewDidLoad {
    [super viewDidLoad];
    mp3count=0;
    // Do any additional setup after loading the view.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dir = [documentsDirectory stringByAppendingPathComponent:@"imusic"];
    
    NSArray *mp3Array = [NSBundle pathsForResourcesOfType:@"mp3" inDirectory:dir];
    mp3count = [mp3Array count];
    albums = [[NSMutableArray alloc] init];
    //int ord = 0;
    
    for (NSString *filePath in mp3Array) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:filePath forKey:@"path"];
        [info setObject:[filePath lastPathComponent] forKey:@"title"];
        [info setObject:@"unknown" forKey:@"artist"];
        
        for (NSString *format in [mp3Asset availableMetadataFormats]) {
            NSArray<AVMetadataItem *> *dd = [mp3Asset metadataForFormat:format];
            for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
                //artwork这个key对应的value里面存的就是封面缩略图，其它key可以取出其它摘要信息，例如title - 标题
                /*if ([metadataItem.commonKey isEqual:]) {
                    NSData *data = [(NSDictionary*)metadataItem.value objectForKey:@"data"];
                    NSString *mime = [(NSDictionary*)metadataItem.value objectForKey:@"MIME"];
                    NSLog(@"mime = %@, data = %@, image = %@", mime, data, [UIImage imageWithData:data]);
                    break;
                }*/
                if ([metadataItem.commonKey isEqual:AVMetadataCommonKeyArtist]) {
                    NSLog(@"%@", (NSString *)metadataItem.value);
                    [info setObject:metadataItem.value forKey:@"artist"];
                }
                // 2、获取音乐名字commonKey：AVMetadataCommonKeyTitle
                else if ([metadataItem.commonKey isEqual:AVMetadataCommonKeyTitle]) {
                    NSLog(@"%@", (NSString *)metadataItem.value);
                    [info setObject:metadataItem.value forKey:@"title"];
                }
                // 3、获取专辑图片commonKey：AVMetadataCommonKeyArtwork
                else if ([metadataItem.commonKey isEqual:AVMetadataCommonKeyArtwork]) {
                    NSLog(@"%@", (NSData *)metadataItem.value);
                }
                // 4、获取专辑名commonKey：AVMetadataCommonKeyAlbumName
                else if ([metadataItem.commonKey isEqual:AVMetadataCommonKeyAlbumName]) {
                    NSLog(@"%@", (NSString *)metadataItem.value);
                }
                
                
                
            }
            
            NSLog(@"%@", @"asdfasdf");
        }
        [albums addObject:info];
        NSLog(@"%@", @"asdfasdf");
    }
    
    
    
    
    
    
    //UITableView *tb = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [songtable setDataSource:self];
    [songtable setDelegate:self];
    //[self.view addSubview:tb];
    
    
    
    
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mp3count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{/*
    static NSString *CellIdentifier = @"localcellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text =@"hello world";
    return cell;
    
    */
    
    
    
    static NSString *myCell = @"localcellid";
    /*static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ContactsTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:myCell];
        nibsRegistered = YES;
    }*/
    localTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"localTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.title.tag = indexPath.row;
    cell.artist.tag = indexPath.row;
    cell.deleteButton.tag = indexPath.row;
    cell.playButton.tag = indexPath.row;
    
    //[cell setCellValue:[selectedInfo objectAtIndex:indexPath.row]];
    NSDictionary *info = [albums objectAtIndex:indexPath.row];
    cell.title.text = [info objectForKey:@"title"];
    cell.artist.text = [info objectForKey:@"artist"];
    [cell.playButton addTarget:self
                        action:@selector(playSong:)
              forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteButton addTarget:self
                        action:@selector(deleteSong:)
              forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (void)deleteSong:(id)sender{
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *MapLayerDataPath = [[albums objectAtIndex:index] objectForKey:@"path"];
    BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
    }
}


- (void)playSong:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag;
    NSURL *url = [NSURL fileURLWithPath:[[albums objectAtIndex:index] objectForKey:@"path"]];
    dispatch_queue_t que = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(que, ^{
        NSData *filedata = [NSData dataWithContentsOfURL:url];
        player = [[AVAudioPlayer alloc] initWithData:filedata error:nil];
        if(player != nil){
            [player setDelegate:self];
            if([player prepareToPlay]){
                [player play];
            }
        }
    });
    
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
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
}
@end
