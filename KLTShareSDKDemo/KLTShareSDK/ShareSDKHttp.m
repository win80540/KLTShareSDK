//
//  ShareSDKHttp.m
//  KLTShare
//
//  Created by 田凯 on 15/7/7.
//  Copyright (c) 2015年 Cloud Dai. All rights reserved.
//

#import "ShareSDKHttp.h"

@implementation ShareSDKHttp
+ (void)requestWithUrl:(NSURL *)url
                mehtod:(NSString *)method
                params:(NSDictionary *)params
             complated:(KLTShareCompletedBlock)completedBlock
{
    NSURL *completedURL = url;
    if (params && ![@[@"PUT", @"POST"] containsObject:method])
    {
        completedURL = [self url:url appendWithQueryDictionary:params];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:completedURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json; charset=utf8" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    if (params && [@[@"PUT", @"POST"] containsObject:method])
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        if (data)
        {
            [request setHTTPBody:data];
        }
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     id result = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                 options:NSJSONReadingAllowFragments
                                                                                                                   error:&error];
                                                                     if (completedBlock)
                                                                     {
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             completedBlock(result, error);
                                                                         });
                                                                     }
                                                                 }];
        
        [task resume];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                NSError *error;
                NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                id result = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
                if (completedBlock)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completedBlock(result, error);
                    });
                }
            }
        });
    }
    return ;
}

static NSString *urlEncode(id object)
{
    return [[NSString stringWithFormat:@"%@", object] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSURL *)url:(NSURL *)url appendWithQueryDictionary:(NSDictionary *)params;
{
    if (params.count <= 0)
    {
        return url;
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params)
    {
        id value = params[key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    
    NSString *queryString = [parts componentsJoinedByString: @"&"];
    NSString *sep = @"?";
    if (url.query)
    {
        sep = @"&";
    }
    
    return [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"%@%@", sep, queryString]];
}
@end
