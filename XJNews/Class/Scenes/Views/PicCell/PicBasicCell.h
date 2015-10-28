//
//  PicBasicCell.h
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicBasicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *picNumLb;
@property (weak, nonatomic) IBOutlet UILabel *replynumLb;

@end
