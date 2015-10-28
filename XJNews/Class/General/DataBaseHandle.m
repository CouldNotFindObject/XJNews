//
//  DataBase.m
//  XJNews
//
//  Created by lanou3g on 15/10/10.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import "DataBaseHandle.h"
#import "FMDatabase.h"
#import "NewsModel.h"
#import "BannerModel.h"


static DataBaseHandle *db = nil;

@interface DataBaseHandle ()
@property (nonatomic,strong) FMDatabase *db;
@end

@implementation DataBaseHandle

+ (DataBaseHandle *)sharedDataBase
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db = [[DataBaseHandle alloc] init];
        [db initMyDb];
    });
    return db;
}

- (void)insertNewsArray:(NSArray *)newsArray typeIndex:(NSInteger)index
{
    if ([_db open]) {
        [_db executeUpdate:@"delete from t_news where type = ?",@(index)];
        for (NewsModel *news in newsArray) {
            
            [_db executeUpdate:@"INSERT INTO t_news (digest, docid, imgsrc, title, imgextra, url, photosetID, type) VALUES (?,?,?,?,?,?,?,?);",news.digest,news.docid,news.imgsrc,news.title,[NSKeyedArchiver archivedDataWithRootObject:news.imgextra],news.url,news.photosetID,@(index)];
        }
        NSLog(@"添加成功!");
        [_db close];
    }
}

- (NSArray *)getNewsArrayWithTypeIndex:(NSInteger)index
{
    if ([_db open]) {
        NSMutableArray *arr = [NSMutableArray array];
        FMResultSet *resultSet = [_db executeQuery:@"SELECT * From t_news where type = ?",@(index)];
        while ([resultSet next]) {
            NewsModel *news = [NewsModel new];
            news.digest = [resultSet objectForColumnName:@"digest"];
            news.docid = [resultSet objectForColumnName:@"docid"];
            news.imgsrc = [resultSet objectForColumnName:@"imgsrc"];
            news.title = [resultSet objectForColumnName:@"title"];
            news.imgextra = [NSKeyedUnarchiver unarchiveObjectWithData:[resultSet dataForColumn:@"imgextra"]];
            news.url = [resultSet objectForColumnName:@"url"];
            news.photosetID =[resultSet objectForColumnName:@"photosetID"];
            [arr addObject:news];
        }
        [_db close];
        return arr;
    }
    return nil;
}


- (void)insertBannerArray:(NSArray *)bannerArray typeIndex:(NSInteger)index
{
    if ([_db open]) {
        [_db executeUpdate:@"delete from t_banner where type = ?",@(index)];
        for (BannerModel *banner in bannerArray) {
            
            [_db executeUpdate:@"INSERT INTO t_banner (title, imgsrc, url, type) VALUES (?,?,?,?);",banner.title,banner.imgsrc,banner.url,@(index)];
        }
        NSLog(@"添加成功!");
        [_db close];
    }
}
- (NSArray *)getBannerArrayWithTypeIndex:(NSInteger)index
{
    if ([_db open]) {
        NSMutableArray *arr = [NSMutableArray array];
        FMResultSet *resultSet = [_db executeQuery:@"SELECT * From t_banner where type = ?",@(index)];
        while ([resultSet next]) {
            BannerModel *banner = [BannerModel new];
            banner.title = [resultSet objectForColumnName:@"title"];
            banner.imgsrc = [resultSet objectForColumnName:@"imgsrc"];
            banner.url = [resultSet objectForColumnName:@"url"];
            [arr addObject:banner];
        }
        [_db close];
        return arr;
    }
    return nil;
}




- (void)insertLookedNews:(NewsModel *)news withIndex:(NSInteger)index
{
    if ([_db open]) {
        FMResultSet *resultSet = [_db executeQuery:@"SELECT * From t_lookednews WHERE title =? AND type = ?",news.title ,@(index)];
        
        while ([resultSet next]) {
            [_db close];
            return;
        }
        
        [_db executeUpdate:@"INSERT INTO t_lookednews (title, type) VALUES (?,?)",news.title,@(index)];
        [_db close];
    }
}

- (NSArray *)getLookedNewsWithIndex:(NSInteger)index
{
    NSMutableArray *arr=[NSMutableArray array];
    if ([_db open]) {
        
        FMResultSet *resultSet = [_db executeQuery:@"SELECT * From t_lookednews WHERE type = ?",@(index)];
        while ([resultSet next]) {
            NSString *title = [resultSet objectForColumnName:@"title"];
            [arr addObject:title];
        }
    }
    
    return arr;
}

- (void)initMyDb
{
    //1.获得数据库文件的路径
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"MyApp.sqlite"];
    
    //2.获得数据库
    self.db = [FMDatabase databaseWithPath:fileName];
    
    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互 之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([_db open])
    {
        //4.创表
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_news (id integer PRIMARY KEY AUTOINCREMENT, digest text NOT NULL, docid text NOT NULL, imgsrc text NOT NULL, title text NOT NULL, imgextra blob NOT NULL, url text , photosetID text , type integer NOT NULL);"];
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_banner (id integer PRIMARY KEY AUTOINCREMENT, title text NOT NULL, imgsrc text NOT NULL, url text NOT NULL, type integer NOT NULL);"];
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_lookednews(id integer PRIMARY KEY AUTOINCREMENT,title text NOT NULL, type integer NOT NULL);"];
        [_db close];
    }
}

- (void)clearDatabaseCache
{
    if ([_db open]) {
        [_db executeUpdate:@"delete from t_banner"];
        [_db executeUpdate:@"delete from t_lookednews"];
        [_db executeUpdate:@"delete from t_news"];
        [_db close];
    }
}
@end
