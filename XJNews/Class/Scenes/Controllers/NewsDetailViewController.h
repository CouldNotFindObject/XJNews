//
//  NewsDetailViewController.h
//  XJNews
//
//  Created by lanou3g on 15/10/9.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *newsWebView;
@property (nonatomic, strong) NSString *urlStr;
@end
