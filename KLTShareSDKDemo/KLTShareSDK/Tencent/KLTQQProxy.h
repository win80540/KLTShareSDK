//
//  QQProxy.h
//  KLTShare
//
//  Created by 田凯 on 15/8/3.
//  Copyright (c) 2015年 田凯. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KLTShareKit.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>


//#import "TencentOAuth.h"
//#import "QQApiInterface.h"

extern NSString * __nonnull const kKLTShareTypeQQ;
extern NSString * __nonnull const kTencentQQSceneTypeKey;

/**
 *   分享请求发送场景
 */
typedef NS_ENUM(NSUInteger, TencentShareScene)
{
    /**
     *  QQ 分享类型（默认）。
     */
    TencentSceneQQ = 1,
    /**
     *  QZone 分享类型。
     */
    TencentSceneZone
};

@interface KLTQQProxy : NSObject <KLTShareProxyProtocol>
@end

@interface KLTMessage (QQ)
/** @brief 生成 QQ 或 QZone 对应的分享对象。  */
- (QQApiObject * __nonnull)qqMessage;
@end

@interface KLTTextMessage (QQ)
@end

@interface KLTMediaMessage (QQ)
@end

@interface KLTImageMessage (QQ)
@end

@interface KLTAudioMessage (QQ)
@end

@interface KLTVideoMessage (QQ)
@end

@interface KLTPageMessage (QQ)
@end
