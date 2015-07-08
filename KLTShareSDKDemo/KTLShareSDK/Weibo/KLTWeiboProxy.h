//
//  WeiboProxy.h
//  KLTShare
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WeiboSDK.h"
#import "KLTShareKit.h"

extern NSString * __nonnull const kKLTShareTypeWeibo;

@interface KLTWeiboProxy : NSObject <KLTShareProxyProtocol>

@end

@interface KLTMessage (Weibo)

/** @brief 生成微博对应的分享的内容对象。 */
- (WBMessageObject * __nonnull)weiboMessage;

@end

@interface KLTTextMessage (Weibo)
@end

@interface KLTMediaMessage (Weibo)
@end

@interface KLTImageMessage (Weibo)
@end

@interface KLTAudioMessage (Weibo)
@end

@interface KLTVideoMessage (Weibo)
@end

@interface KLTPageMessage (Weibo)
@end