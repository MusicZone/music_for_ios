//
//  localTableViewCell.h
//  imusic
//
//  Created by APPLE28 on 15/10/23.
//  Copyright © 2015年 weshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface localTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UILabel *artist;
@property (strong, nonatomic) IBOutlet UILabel *title;

@end
