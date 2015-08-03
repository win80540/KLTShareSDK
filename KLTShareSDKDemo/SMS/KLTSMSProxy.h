//
//  KLTMsgProxy.h
//  KLTShareSDKDemo
//
//  Created by 田凯 on 15/8/3.
//  Copyright (c) 2015年 田凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "KLTShareKit.h"


extern NSString   * __nonnull  const kKLTShareTypeSMS;

@interface KLTSMSProxy : NSObject<KLTShareProxyProtocol,MFMessageComposeViewControllerDelegate>


@end


@interface KLTSMSMediaMessage : NSObject
/** 返回一个KLTMsgMediaMessage对象
 * @note 返回的对象是自动释放的
 */
+(KLTSMSMediaMessage * __nonnull) message;

/** 标题
 * @note 长度不能超过512字节
 */
@property (nonatomic, strong ,nonnull) NSString *title;

/** 描述内容
 * @note 长度不能超过1K
 */
@property (nonatomic, strong ,nullable) NSString *desc;


/** 多媒体数据对象的url

 */
@property (nonatomic, strong ,nullable) NSString *dataUrl;

@end

@interface KLTMediaMessage (Msg)
/** @brief 生成微信的多媒体分享内容对象 */
- ( KLTSMSMediaMessage * __nonnull )msgMessage;
+ ( KLTMediaMessage * __nonnull )message;
@end

@interface KLTImageMessage (Msg)
@end

@interface KLTAudioMessage (Msg)
@end

@interface KLTVideoMessage (Msg)
@end

@interface KLTPageMessage (Msg)
@end

