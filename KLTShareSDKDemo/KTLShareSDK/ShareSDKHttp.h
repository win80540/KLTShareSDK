//
//  ShareSDKHttp.h
//  KLTShare
//
//  Created by 田凯 on 15/7/7.
//  Copyright (c) 2015年 Cloud Dai. All rights reserved.
//
#import "KLTShareKit.h"
#import <Foundation/Foundation.h>

@interface ShareSDKHttp : NSObject

+ (void)requestWithUrl:(NSURL *)url
                mehtod:(NSString *)method
                params:(NSDictionary *)params
             complated:(KLTShareCompletedBlock)completedBlock;

+ (NSURL *)url:(NSURL *)url appendWithQueryDictionary:(NSDictionary *)params;
@end
