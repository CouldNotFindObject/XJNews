//
//  VideoTableViewController.m
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//


#import "VideoTableViewController.h"
#import "VideoMainViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "VideoModel.h"
#import "VideoCell.h"
#import "MyTap.h"
#import "KrVideoPlayerController.h"

typedef void(^MyBlock)();
@interface VideoTableViewController ()
@property (nonatomic,strong) NSMutableArray *videoArr;
@property (nonatomic, strong) KrVideoPlayerController  *videoController;
@property (nonatomic,assign)NSInteger itemNum;
@end

@implementation VideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoArr = [NSMutableArray array];
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestNewsData:_urlStr withBlock:^{
            [self.tableView.header endRefreshing];
        }];
        [self.tableView.footer resetNoMoreData];
    }];
    [self.tableView.header beginRefreshing];
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self.tableView.footer noticeNoMoreData];
    }];

    
}


- (void)requestNewsData:(NSString *)urlSting withBlock:(MyBlock)block
{
    
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr GET:urlSting parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *dataArr;
        switch (_index) {
            case VideoEntertainment:dataArr =[responseObject valueForKey:@"V9LG4CHOR"] ; break;
            case VideoQuality:dataArr =[responseObject valueForKey:@"00850FRB"]; break;
            case VideoHot:dataArr = [responseObject valueForKey:@"V9LG4B3A0"]; break;
            default:
                break;
        }
        
        [_videoArr removeAllObjects];
        
        for (NSDictionary *dic in dataArr) {
            VideoModel *video = [VideoModel new];
            [video setValuesForKeysWithDictionary:dic];
            [_videoArr addObject:video];
            
        }
        
        [self.tableView reloadData];
        
        block();
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        block();
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _videoArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
    
    if (cell.isPlaying) {
        [self.videoController dismiss];
    }
    MyTap *tap = [[MyTap alloc] initWithTarget:self action:@selector(playVideo:)];
    tap.index = indexPath.row;
    VideoModel *video = _videoArr[indexPath.row];
    cell.titleLb.text = video.title;
    cell.digestLb.text = video.digest;
    if ([video.playCount integerValue] / 10000.0 >= 1) {
        cell.playCountLb.text =[NSString stringWithFormat:@"%.1f万",[video.playCount integerValue] / 10000.0];
    }else{
        cell.playCountLb.text = [NSString stringWithFormat:@"%@",video.playCount];
    }
    cell.durationLb.text = [NSString stringWithFormat:@"%02ld:%02ld",[video.length integerValue]/60,[video.length integerValue]%60];
    if (video.replyid) {
        cell.replyCountLb.text = [NSString stringWithFormat:@"%@回复",video.replyCount];
    }else{
        cell.replyCountLb.text = @"0回复";
    }
    [cell.PicCoverView sd_setImageWithURL:[NSURL URLWithString:video.cover] placeholderImage:[UIImage imageNamed:@"placeholder"]];


    cell.PicCoverView.userInteractionEnabled = YES;
    [cell.PicCoverView addGestureRecognizer:tap];
    // Configure the cell...
    cell.isPlaying = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

- (void)playVideo:(MyTap *)tap
{

    VideoModel *video = _videoArr[tap.index];
    [self playVideoWithURL:[NSURL URLWithString:video.mp4_url] tap:tap];
}
- (void)playVideoWithURL:(NSURL *)url tap:(MyTap *)tap
{
    
    VideoCell *cell = (VideoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tap.index inSection:0]];
    if (self.videoController) {
        [self.videoController dismiss];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!self.videoController){
            [cell layoutIfNeeded];
            self.videoController = [[KrVideoPlayerController alloc] initWithFrame:cell.PicCoverView.frame];
            __weak typeof(self)weakSelf = self;
            [self.videoController setDimissCompleteBlock:^{
                weakSelf.videoController = nil;
            }];
            cell.isPlaying = YES;
            [cell.contentView addSubview:self.videoController.view];
            self.videoController.view.alpha = 0.0;
            [UIView animateWithDuration:0.3f animations:^{
                self.videoController.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
        }
        self.videoController.contentURL = url;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.videoController){
            [cell layoutIfNeeded];
            self.videoController = [[KrVideoPlayerController alloc] initWithFrame:cell.PicCoverView.frame];
            __weak typeof(self)weakSelf = self;
            [self.videoController setDimissCompleteBlock:^{
                weakSelf.videoController = nil;
            }];
            cell.isPlaying = YES;
            [cell.contentView addSubview:self.videoController.view];
            self.videoController.view.alpha = 0.0;
            [UIView animateWithDuration:0.3f animations:^{
                self.videoController.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
        }
        self.videoController.contentURL = url;
    });
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
