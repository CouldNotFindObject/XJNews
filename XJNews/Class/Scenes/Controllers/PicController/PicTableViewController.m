//
//  PicTableViewController.m
//  XJNews
//
//  Created by lanou3g on 15/10/8.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import "PicTableViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "PictureModel.h"
#import "PicBasicCell.h"
#import "PicLeftCell.h"
#import "PicRightCell.h"
#import "NewsDetailViewController.h"

typedef void(^MyBlock)();
@interface PicTableViewController ()
@property (nonatomic,strong) NSMutableArray *picArr;
@end

@implementation PicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.picArr = [NSMutableArray array];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PicBasicCell" bundle:nil] forCellReuseIdentifier:@"PicBasicCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PicRightCell" bundle:nil] forCellReuseIdentifier:@"PicRightCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PicLeftCell" bundle:nil] forCellReuseIdentifier:@"PicLeftCell"];
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestNewsData:_urlStr withBlock:^{
            [self.tableView.header endRefreshing];
        }];
        [self.tableView.footer resetNoMoreData];
    }];
    [self.tableView.header beginRefreshing];
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.footer noticeNoMoreData];
        });
        
    }];
    
}

- (void)requestNewsData:(NSString *)urlSting withBlock:(MyBlock)block
{
    
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr GET:urlSting parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        NSArray *dataArr = responseObject;
        [_picArr removeAllObjects];

        for (NSDictionary *dic in dataArr) {
            
            PictureModel *pic = [PictureModel new];
            [pic setValuesForKeysWithDictionary:dic];
            [_picArr addObject:pic];
            
            
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

    return _picArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PictureModel *p = _picArr[indexPath.row];
    
    if (indexPath.row % 3 == 0 || p.pics.count == 0) {
        PicBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PicBasicCell" forIndexPath:indexPath];
        cell.titleLb.text = p.setname;
        if (p.pics.count == 0) {
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:p.cover] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else{
           [cell.imgView sd_setImageWithURL:[NSURL URLWithString:p.pics[0]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
        cell.picNumLb.text = p.imgsum;
        cell.replynumLb.text = [NSString stringWithFormat:@"%@跟帖",p.replynum];
        return cell;
    }else if (indexPath.row%3==1){
        PicRightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PicRightCell" forIndexPath:indexPath];
        cell.titleLb.text = p.setname;
        [cell.picView1 sd_setImageWithURL:[NSURL URLWithString:p.pics[0]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.picView2 sd_setImageWithURL:[NSURL URLWithString:p.pics[1]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.picView3 sd_setImageWithURL:[NSURL URLWithString:p.pics[2]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.pivNum.text = p.imgsum;
        cell.replyLb.text = [NSString stringWithFormat:@"%@跟帖",p.replynum];
        return cell;
    }else{
        PicLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PicLeftCell" forIndexPath:indexPath];
        cell.titleLb.text = p.setname;
        [cell.picView1 sd_setImageWithURL:[NSURL URLWithString:p.pics[0]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.picView2 sd_setImageWithURL:[NSURL URLWithString:p.pics[1]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.picView3 sd_setImageWithURL:[NSURL URLWithString:p.pics[2]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.pivNum.text = p.imgsum;
        cell.replyLb.text = [NSString stringWithFormat:@"%@跟帖",p.replynum];
        return cell;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 228;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsDetailViewController *ndVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"reqVC"];
    PictureModel *pic = _picArr[indexPath.row];
    ndVC.urlStr = [NSString stringWithFormat:@"http://3g.163.com/touch/photoview.html?setid=%@",pic.setid];
    ndVC.navigationItem.title = pic.setname;
    [self.navigationController pushViewController:ndVC animated:YES];
    [tableView cellForRowAtIndexPath:indexPath].selected=NO;
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
