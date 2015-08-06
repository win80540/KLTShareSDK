//
//  WechatProxy.h
//  KLTShare
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WXApi.h"
#import "KLTShareKit.h"

extern NSString * __nonnull const kKLTShareTypeWechat;
extern NSString * __nonnull const kWechatSceneTypeKey;

@interface KLTWechatProxy : NSObject <KLTShareProxyProtocol>

@end

@interface KLTMediaMessage (Wechat)
/** @brief 生成微信的多媒体分享内容对象 */
- (WXMediaMessage * __nonnull)wechatMessage;
@end

@interface KLTImageMessage (Wechat)
@end

@interface KLTAudioMessage (Wechat)
@end

@interface KLTVideoMessage (Wechat)
@end

@interface KLTPageMessage (Wechat)
@end