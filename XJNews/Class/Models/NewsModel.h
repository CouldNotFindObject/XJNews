//
//  NewsModel.h
//  XJNews
//
//  Created by lanou3g on 15/10/6.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject
@property (nonatomic,strong)NSString *digest;
@property (nonatomic,strong)NSString *docid;
@property (nonatomic,strong)NSString *imgsrc;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSArray *imgextra;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *photosetID;
@property (nonatomic,assign)BOOL isLooked;
@end
