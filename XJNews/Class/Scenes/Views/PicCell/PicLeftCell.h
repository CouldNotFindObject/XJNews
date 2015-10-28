//
//  PicLeftCell.h
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicLeftCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picView1;
@property (weak, nonatomic) IBOutlet UIImageView *picView2;
@property (weak, nonatomic) IBOutlet UIImageView *picView3;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *replyLb;
@property (weak, nonatomic) IBOutlet UILabel *pivNum;

@end
