//
//  MainContainerViewController.h
//  SlideNavigate
//
//  Created by  on 15/9/21.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainContainerViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *smallScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *bigScrollView;

@end
