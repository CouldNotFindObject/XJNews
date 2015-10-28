//
//  NewsModel.m
//  XJNews
//
//  Created by lanou3g on 15/10/6.
//  Copyright © 2015年 佟锡杰. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"imgextra"]) {
        _imgextra = [NSArray arrayWithObjects:[value[0] valueForKey:@"imgsrc"],[value[1] valueForKey:@"imgsrc"], nil];
    }
}
@end
