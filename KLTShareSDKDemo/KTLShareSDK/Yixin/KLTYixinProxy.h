//
//  YixinProxy.h
//  KLTShare
//
//  Created by 田凯 on 15/7/7.
//  Copyright (c) 2015年 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLTShareKit.h"
#import "YXApiObject.h"
@class YXMediaMessage;

extern NSString   * __nonnull  const kKLTShareTypeYixin;
extern NSString   * __nonnull  const kYixinSceneTypeKey;

@interface KLTYixinProxy : NSObject<KLTShareProxyProtocol>



@end

@interface KLTMediaMessage (Yixin)
/** @brief 生成微信的多媒体分享内容对象 */
- (YXMediaMessage * __nonnull)yixinMessage;
@end

@interface KLTImageMessage (Yixin)
@end

@interface KLTAudioMessage (Yixin)
@end

@interface KLTVideoMessage (Yixin)
@end

@interface KLTPageMessage (Yixin)
@end

@interface KLTAppContentMessage (Yixin)
@end