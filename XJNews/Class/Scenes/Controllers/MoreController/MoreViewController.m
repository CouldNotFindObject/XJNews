//
//  MoreViewController.m
//  XJNews
//
//  Created by lanou3g on 15/10/12.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import "MoreViewController.h"
#import "SDImageCache.h"
#import "MBProgressHUD.h"
#import "DataBaseHandle.h"


@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet UIView *daymodeView;
@property (weak, nonatomic) IBOutlet UIView *clearCacheView;
@property (weak, nonatomic) IBOutlet UIView *aboutUsView;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLb;
@property (nonatomic,assign) BOOL isDayMode;
@end

@implementation MoreViewController


- (void)clearCache:(id)sender {
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.labelText=@"loading";
    [hud show:YES];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, 50)];
    lab.backgroundColor=[UIColor blackColor];
    hud.userInteractionEnabled = NO;
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        
        
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] ;
        
        // Set custom view mode
        hud.mode = MBProgressHUDModeCustomView;
        
        hud.labelText = @"Completed";
        
        [hud show:YES];
        [hud hide:YES afterDelay:10.6];
        CGFloat size =[[SDImageCache sharedImageCache] getSize]/1024.0;
        NSString *str = nil;
        if (size>1024) {
            
            str = [NSString stringWithFormat:@"%.2fMB",size/1024.0];
        }else {
            str = [NSString stringWithFormat:@"%.2fKB",size];
        }
        _cacheSizeLb.text = str;
    }];
    
    [[DataBaseHandle sharedDataBase] clearDatabaseCache];
}

- (void)daymode:(id)sender {
    if (_isDayMode) {
        self.view.window.alpha = 0.5;
    }else{
        self.view.window.alpha = 1;
    }
    _isDayMode = !_isDayMode;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    _isDayMode = YES;
    // Do any additional setup after loading the view.
   
    UITapGestureRecognizer *clearCacheTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearCache:)];
    UITapGestureRecognizer *daymodeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(daymode:)];

    
    [_clearCacheView addGestureRecognizer:clearCacheTap];
    [_daymodeView addGestureRecognizer:daymodeTap];



    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat size =[[SDImageCache sharedImageCache] getSize]/1024.0;
    NSString *str = nil;
    if (size>1024) {
        
        str = [NSString stringWithFormat:@"%.2fMB",size/1024.0];
    }else {
        str = [NSString stringWithFormat:@"%.2fKB",size];
    }
    _cacheSizeLb.text = str;
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

@end
