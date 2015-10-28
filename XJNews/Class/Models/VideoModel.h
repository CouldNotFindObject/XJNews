//
//  VideoModel.h
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

@property (nonatomic,strong) NSString *cover;
@property (nonatomic,strong) NSString *mp4_url;
@property (nonatomic,strong) NSString *mp4Hd_url;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *replyid;
@property (nonatomic,strong) NSString *vid;
@property (nonatomic,strong) NSString *digest;
@property (nonatomic,strong) NSNumber *playCount;
@property (nonatomic,strong) NSNumber *length;
@property (nonatomic,strong) NSNumber *replyCount;
@end
