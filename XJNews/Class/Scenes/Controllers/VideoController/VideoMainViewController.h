//
//  VideoMainViewController.h
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <UIKit/UIKit.h>

enum VideoType{
    VideoEntertainment,
    VideoQuality,
    VideoHot
};

@interface VideoMainViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *smallScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *bigScrollView;


@end
