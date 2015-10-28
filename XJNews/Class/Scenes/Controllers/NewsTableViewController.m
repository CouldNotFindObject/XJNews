//
//  NewsTableViewController.m
//  XJNews
//
//  Created by lanou3g on 15/10/6.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import "NewsModel.h"
#import "NewsTableViewController.h"
#import "MainTableViewCell.h"
#import "SDCycleScrollView.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "BannerModel.h"
#import "PicNewsCell.h"
#import "MJRefresh.h"
#import "NewsDetailViewController.h"
#import "DataBaseHandle.h"

typedef void(^MyBlock)();
@interface NewsTableViewController ()<SDCycleScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SDCycleScrollView *scrollNews;
@property (nonatomic,strong) NSMutableArray *newsArr;
@property (nonatomic,strong) NSMutableArray *bannerArr;
@property (nonatomic,assign) NSInteger itemNum;

@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsArr = [NSMutableArray arrayWithArray:[[DataBaseHandle sharedDataBase] getNewsArrayWithTypeIndex:_index]];
    self.bannerArr = [NSMutableArray array];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"MainTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PicNewsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"picNewsCell"];
    //通过标签传过来的标识，请求数据数组并加载,建议使用AFNetworking

    _itemNum=25;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestNewsData:_urlStr withBlock:^{
            [self.tableView.header endRefreshing];
        }];
    }];
    
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"上拉刷新");
        
        _itemNum+=25;
        NSString *newUrl = [NSString stringWithFormat:@"%@%ld.html",[_urlStr substringToIndex:_urlStr.length-7],_itemNum];
        NSLog(@"%@",newUrl);
        [self requestNewsData:newUrl withBlock:^{
            [self.tableView.footer endRefreshing];
        }];
    }];
    
    if (_newsArr.count == 0) {
        [self.tableView.header beginRefreshing];
    }else{
        self.bannerArr = [NSMutableArray arrayWithArray:[[DataBaseHandle sharedDataBase] getBannerArrayWithTypeIndex:_index]];
        [self layoutScrollNews];
        [self updateNewsArrLookInfo];
        [self.tableView reloadData];
    }
    
}



- (void)requestNewsData:(NSString *)urlSting withBlock:(MyBlock)block
{
    
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    
    [mgr GET:urlSting parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        NSArray *dataArr ;
        switch (_index) {
            case 0:
                dataArr = [responseObject valueForKey:@"T1348647853363"];
                break;
            case 1:
                dataArr = [responseObject valueForKey:@"T1348648517839"];
                break;
            case 2:
                dataArr = [responseObject valueForKey:@"T1348649079062"];
                break;
            case 3:
                dataArr = [responseObject valueForKey:@"T1348649580692"];
                break;
            case 4:
                dataArr = [responseObject valueForKey:@"T1348648756099"];
                break;
            case 5:
                dataArr = [responseObject valueForKey:@"T1348648037603"];
                break;
                
            default:
                break;
        }
        [_newsArr removeAllObjects];
        [_bannerArr removeAllObjects];
        for (NSDictionary *dic in dataArr) {
            NSArray *adsArr = [dic valueForKey:@"ads"];
            
            NewsModel *news = [NewsModel new];
            [news setValuesForKeysWithDictionary:dic];
            [_newsArr addObject:news];
            
            
            if (adsArr) {
                for (NSDictionary *dic in adsArr) {
                    BannerModel *banner = [BannerModel new];
                    [banner setValuesForKeysWithDictionary:dic];
                    [_bannerArr addObject:banner];
                }
                [[DataBaseHandle sharedDataBase] insertBannerArray:_bannerArr typeIndex:_index];
            }
        }
        [self layoutScrollNews];
        if (_newsArr.count!=0) {
            [self.tableView reloadData];
        }
        [[DataBaseHandle sharedDataBase] insertNewsArray:_newsArr typeIndex:_index];
        
        [self updateNewsArrLookInfo];
        block();
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        block();
    }];
}

- (void)layoutScrollNews
{
    
    NSMutableArray *imagesURLStrings = [NSMutableArray array];
    
    NSMutableArray *titles = [NSMutableArray array];
    NewsModel *news =[_newsArr firstObject];
    [imagesURLStrings addObject:news.imgsrc];
    [titles addObject:news.title];
    for (BannerModel *banner in _bannerArr) {
        [imagesURLStrings addObject:banner.imgsrc];
        [titles addObject:banner.title];
    }
    self.scrollNews.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    self.scrollNews.delegate = self;
    self.scrollNews.titlesGroup = titles;
    self.scrollNews.placeholderImage = [UIImage imageNamed:@"placeholder"];
    self.scrollNews.imageURLStringsGroup = imagesURLStrings;
    self.scrollNews.autoScroll = NO;
    [self.scrollNews.mainView setContentOffset:CGPointMake(0, 0) animated:NO];
    if (titles.count == 1) {
        self.scrollNews.showPageControl = NO;
    }else{
        self.scrollNews.showPageControl = YES;
    }
    

}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NewsDetailViewController *ndVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"reqVC"];
    if (index==0) {
        
        NewsModel *news = _newsArr[0];
        if ([news.photosetID isEqual:[NSNull null]]) {
            news.photosetID = nil;
        }
        if (news.photosetID) {
            ndVC.urlStr=[NSString stringWithFormat:@"http://3g.163.com/touch/photoview.html?setid=%@",[news.photosetID substringFromIndex:9]];
            NSLog(@"%@",ndVC);
        }else{
            ndVC.urlStr = news.url;
        }
        
       
        ndVC.navigationItem.title = news.title;
    }else{
        BannerModel *baner = _bannerArr[index-1];
        ndVC.urlStr = [NSString stringWithFormat:@"http://3g.163.com/touch/photoview.html?setid=%@",[baner.url substringFromIndex:9]];
        ndVC.navigationItem.title = baner.title;
    }
     [self.navigationController pushViewController:ndVC animated:YES];
    
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

    return _newsArr.count-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NewsModel *news = _newsArr[indexPath.row+1];
    if (news.imgextra == nil) {
        MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
        
        cell.titleLb.text = news.title;
        if (news.isLooked) {
            cell.titleLb.textColor = [UIColor grayColor];
        }else{
            cell.titleLb.textColor = [UIColor blackColor];
        }
        cell.digestLb.text = news.digest;
        [cell.newsImgView sd_setImageWithURL:[NSURL URLWithString:news.imgsrc] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        // Configure the cell...
        //cell.label.text = self.testString;
        return cell;
    }else{
       PicNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"picNewsCell" forIndexPath:indexPath];
        if (news.isLooked) {
            cell.titleLb.textColor = [UIColor grayColor];
        }else{
            cell.titleLb.textColor = [UIColor blackColor];
        }
        cell.titleLb.text = news.title;
        [cell.imgView1 sd_setImageWithURL:[NSURL URLWithString:news.imgsrc] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.imgView2 sd_setImageWithURL:[NSURL URLWithString:news.imgextra[0]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.imgView3 sd_setImageWithURL:[NSURL URLWithString:news.imgextra[1]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_newsArr[indexPath.row+1] imgextra] == nil) {
        return 100.f;
    }else{
        return 130;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsDetailViewController *ndVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"reqVC"];
    NewsModel *news = _newsArr[indexPath.row+1];
    news.isLooked = YES;
    if ([news.photosetID isEqual:[NSNull null]]) {
        news.photosetID = nil;
    }
    if ([news.url isEqual:[NSNull null]]) {
        news.url = nil;
    }
    if (news.photosetID) {
        ndVC.urlStr=[NSString stringWithFormat:@"http://3g.163.com/touch/photoview.html?setid=%@",[news.photosetID substringFromIndex:9]];
        NSLog(@"%@",ndVC);
    }else{
        ndVC.urlStr = news.url;
    }
    [[DataBaseHandle sharedDataBase] insertLookedNews:news withIndex:_index];
    [self.navigationController pushViewController:ndVC animated:YES];
    ndVC.navigationItem.title = news.title;
}

- (void)updateNewsArrLookInfo
{
    NSArray *lookdTitle = [[DataBaseHandle sharedDataBase] getLookedNewsWithIndex:_index];
    for (int i = 0; i<lookdTitle.count; i++) {
        for (int j = 0; j<_newsArr.count; j++) {
            NewsModel *news = _newsArr[j];
            if ([lookdTitle[i] isEqualToString:news.title]) {
                news.isLooked = YES;
            }
        }
    }
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
