//
//  VideoCell.h
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *digestLb;
@property (weak, nonatomic) IBOutlet UIImageView *PicCoverView;
@property (weak, nonatomic) IBOutlet UILabel *durationLb;
@property (weak, nonatomic) IBOutlet UILabel *playCountLb;
@property (weak, nonatomic) IBOutlet UILabel *replyCountLb;
@property (nonatomic, assign) BOOL isPlaying;
@end
