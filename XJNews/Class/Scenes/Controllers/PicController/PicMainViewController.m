//
//  PicMainViewController.m
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import "PicMainViewController.h"
#import "CategoryLabel.h"
#import "PicTableViewController.h"

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
@interface PicMainViewController ()
@property (strong, nonatomic) NSArray *categories;
@property (strong,nonatomic) PicTableViewController *NVC;
@end

@implementation PicMainViewController
#pragma mark Private Methods
//模拟数据
- (void)simulateData{
    self.categories = [[NSArray alloc]initWithObjects:@"热点",@"独家",@"明星",@"体坛",@"美图", nil];
}

//添加子视图控制器
- (void)addChildViewController{
    for(int i=0 ; i<self.categories.count; i++)
    {
        NSString *title = [self.categories objectAtIndex:i];
        //循环创建子vc
        PicTableViewController *mvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"picTVC"];
        mvc.title = title;
        //传给下面的子vc标识，根据该标示做请求，获取数据
        
        mvc.index = i;
        switch (i) {
            case PicHotspot:mvc.urlStr = @"http://c.m.163.com/photo/api/list/0096/54GI0096.json"; break;
            case PicExclusive:mvc.urlStr = @"http://c.m.163.com/photo/api/list/0096/54GJ0096.json"; break;
            case PicStars:mvc.urlStr = @"http://c.m.163.com/photo/api/list/0096/54GK0096.json"; break;
            case PicSports:mvc.urlStr = @"http://c.m.163.com/photo/api/list/0096/54GM0096.json"; break;
            case PicBeauty:mvc.urlStr = @"http://c.m.163.com/photo/api/list/0096/54GN0096.json"; break;
            
            default:
                break;
        }
        [self addChildViewController:mvc];
    }
}

//添加上方标签
- (void)addNavigateLable{
    for (int i = 0; i < self.categories.count; i++) {
        CGFloat lblW = 70;
        CGFloat lblX = i * lblW +10;
        CategoryLabel *lbl1 = [[CategoryLabel alloc]init];
        UIViewController *vc = self.childViewControllers[i];
        lbl1.content = vc.title;
        lbl1.frame = CGRectMake(lblX, 0 , lblW, self.smallScrollView.frame.size.height);
        lbl1.tag = i;
        [self.smallScrollView addSubview:lbl1];
        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
        self.smallScrollView.contentSize = CGSizeMake(70 * (i+1) , 0);
    }
}

//标题栏label的点击事件
- (void)lblClick:(UITapGestureRecognizer *)recognizer{
    CategoryLabel *titlelable = (CategoryLabel *)recognizer.view;
    CGFloat offsetX = titlelable.tag * self.bigScrollView.frame.size.width;
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    [self.bigScrollView setContentOffset:offset animated:YES];
}

//加载页面
- (void)loadSubViews{
    [self addChildViewController];
    [self addNavigateLable];
    CGFloat contentX = self.childViewControllers.count * ScreenWidth;
    self.bigScrollView.contentSize = CGSizeMake(contentX, 0);
    //设置默认状态控制器
    self.NVC = [self.childViewControllers firstObject];
    self.NVC.view.frame = self.bigScrollView.bounds;
    [self.bigScrollView addSubview:self.NVC.view];
    CategoryLabel *lable = [self.smallScrollView.subviews firstObject];
    lable.scale = 1.0;
}

#pragma mark UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.bigScrollView.scrollsToTop = NO;
    self.smallScrollView.scrollsToTop = NO;
    [self simulateData];
    [self loadSubViews];
}

#pragma mark - UIScrollView Delegat Methods
//滚动结束后调用（代码导致）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.bigScrollView.frame.size.width;
    // 滚动标题栏
//    CategoryLabel *titleLable = (CategoryLabel *)self.smallScrollView.subviews[index];
//    CGFloat offsetx = titleLable.center.x - self.smallScrollView.frame.size.width * 0.5;
//    CGFloat offsetMax = self.smallScrollView.contentSize.width - self.smallScrollView.frame.size.width;
//    if (offsetx < 0) {
//        offsetx = 0;
//    }else if (offsetx > offsetMax){
//        offsetx = offsetMax;
//    }
//    CGPoint offset = CGPointMake(offsetx, self.smallScrollView.contentOffset.y);
//    [self.smallScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    self.NVC.tableView.scrollsToTop = NO;
    self.NVC = self.childViewControllers[index];
    self.NVC.tableView.scrollsToTop = YES;
    //两页面所经过的标签setScale动画
    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            CategoryLabel *temlabel = self.smallScrollView.subviews[idx];
            temlabel.scale = 0.0;
        }
    }];
    //如果nvc已经存在了，不作处理
    if (self.NVC.view.superview) return;
    self.NVC.view.frame = scrollView.bounds;
    [self.bigScrollView addSubview:self.NVC.view];
}

//正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    CategoryLabel *labelLeft = self.smallScrollView.subviews[leftIndex];
    labelLeft.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < self.smallScrollView.subviews.count) {
        CategoryLabel *labelRight = self.smallScrollView.subviews[rightIndex];
        labelRight.scale = scaleRight;
    }
}

//滚动结束（手势导致）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

@end
