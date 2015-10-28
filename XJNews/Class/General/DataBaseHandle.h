//
//  DataBase.h
//  XJNews
//
//  Created by lanou3g on 15/10/10.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewsModel;
@interface DataBaseHandle : NSObject

+ (DataBaseHandle *)sharedDataBase;

- (void)insertNewsArray:(NSArray *)newsArray typeIndex:(NSInteger)index;

- (NSArray *)getNewsArrayWithTypeIndex:(NSInteger)index;

- (void)insertLookedNews:(NewsModel *)news withIndex:(NSInteger)index;
- (NSArray *)getLookedNewsWithIndex:(NSInteger)index;


- (void)insertBannerArray:(NSArray *)bannerArray typeIndex:(NSInteger)index;
- (NSArray *)getBannerArrayWithTypeIndex:(NSInteger)index;

- (void)clearDatabaseCache;
@end
