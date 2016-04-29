//
//  KLTShareSDK.h
//  KLTShare
//
//  Created by 田凯 on 15/8/3.
//  Copyright (c) 2015年 田凯. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * __nonnull const kKLTShareAppIdKey;
extern NSString * __nonnull const kKLTShareAppSecretKey;
extern NSString * __nonnull const kKLTShareAppRedirectUrlKey;
extern NSString * __nonnull const kKLTShareAppDebugModeKey;

/*! @brief 请求发送场景
 *
 */
enum KLTShareScene {
    KLTShareSceneSession  = 0,        /**< 聊天界面    */
    KLTShareSceneTimeline = 1,        /**< 朋友圈      */
    KLTShareSceneFavorite = 2,        /**< 收藏       */
};


@class KLTMessage;

typedef void (^KLTShareCompletedBlock)(id __nullable result, NSError * __nullable error);

@protocol KLTShareProxyProtocol <NSObject>

+ (id<KLTShareProxyProtocol> __nonnull)proxy;

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration;
- (BOOL)handleOpenURL:(NSURL * __nullable)url;
- (void)auth:(KLTShareCompletedBlock __nullable)completedBlock;
- (BOOL)isInstalled;
- (void)share:(KLTMessage * __nonnull)message completed:(KLTShareCompletedBlock __nullable)compltetedBlock;

@end

@interface KLTShareKit : NSObject

+ (nonnull instancetype)sharedInstance;
/**
 @brief 将第三方库的 Proxy 注册到 KLTShare 。

 @param object 实现了 KLTShareProxyProtocol 协议的对象。
 @param name Proxy 对应的第三方对象的名字。

 */
- (void)registerProxyObject:(id<KLTShareProxyProtocol> __nonnull)object withName:(NSString * __nonnull)name;

/**
 @brief 使用第三方的 AppId 或者 AppKey 和 AppSecret 来配置 KLTShare 。

 @param type 第三方的类型，必需。参见：KLTShareType 。
 @param configurations 第三方应用的相关配置, 按 KLTShare type 配置对应的 AppId, AppSecret, redirectUrl，其中 AppId 必需。
 @param secret 第三方应用的 Appsecret ，非必需。微信需要填写用来请求用户的信息。

 */
- (void)registerWithConfigurations:(NSDictionary * __nonnull)configurations;

/**
 @brief sso 跳转处理。

 @discussion 在 sso 跳转回中，为了能从授权的第三应用跳回来。需要配置好对应的 URL Schemes。

 @code 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 {
   return [[KLTShare sharedInstance] handleOpenURL:url];
 }
 @endcode

 */
- (BOOL)handleOpenURL:(NSURL * __nullable)url;

/**
 @brief 通过第三方授权登录。
 
 @discussion 通过不同的 KLTShareType 来授权不同的第三方登录。其中 QZone 统一使用 KLTShareTypeQQ 授权。
 
 @param type 第三方的类型，必需。参见：KLTShareType 。
 @param completedBlock 当登录授权过程结束后，成功或失败都会回调。 参见：KLTShareCompletedBlock
 */

- (void)authWithName:(NSString * __nonnull)name completed:(KLTShareCompletedBlock __nullable)completedBlock;

/** 
 @brief 判断对应第三方 App 是否被安装。

 @param type 第三方的类型，必需。参见：KLTShareType 。

 @return 返回值为 Yes 表示已安装此 App, NO 表示未安装此 App.
 */
- (BOOL)isInstalled:(NSString * __nonnull)name;

/**
 @brief 分享
 
 @discussion 1. 通过不同内容的 DTMessage 来达到分享文本，语音，视频，文章的目的。
 其中文本对应于 DTTextMessage ，语音对应于 DTAudioMessage ，视频对应于 DTVideoMessage ，
 文章的分享则对应于 DTPageMessage 。
 2. 当分享到微信时，有不同的分享场景可以选择：朋友圈、好友、收藏。
 
 @see setWechatScene:
 
 @param message 分享的内容，文本，多媒体 DTMessage
 @param type 第三方的类型，必需。参见：KLTShareType 。
 @param completedBlock 当分享结束后，成功或失败都会回调。参见：KLTShareCompletedBlock
 */

- (void)share:(KLTMessage * __nonnull)message name:(NSString * __nonnull)name completed:(KLTShareCompletedBlock __nullable)compltetedBlock;

@end


@interface DTUser : NSObject

@property (copy, nonatomic, nonnull) NSString * uid;
@property (copy, nonatomic, nonnull) NSString * nick;
@property (copy, nonatomic, nullable) NSString * avatar;
/** @brief 登录授权时的第三方来源，例如：weibo */
@property (copy, nonatomic, nonnull) NSString * provider;
@property (copy, nonatomic, nullable) NSString * gender;
/** @brief 获取到的完成原始的用户信息 */
@property (strong, nonatomic, nonnull) NSDictionary * rawData;

@end

// Message

@interface KLTMessage : NSObject
/** @brief 携带一些扩展信息，比如：微信分享时，选择朋友圈、收藏、好友 */
@property (strong, nonatomic, nullable) NSDictionary *userInfo;
@end

@interface KLTTextMessage : KLTMessage

@property (copy, nonatomic, nonnull) NSString *text;

@end

@interface KLTMediaMessage : KLTMessage

/** @brief 当分享微博多媒体内容时需要指定一个自己 App 的唯一 Id */
@property (copy, nonatomic, nullable) NSString *messageId;
@property (copy, nonatomic, nullable) NSString *title;
@property (copy, nonatomic, nullable) NSString *desc;

/** @brief 会根据分享到不同的第三方进行缩略图操作。 */
@property (strong, nonatomic, nullable) UIImage *thumbnailableImage;

@end

@interface KLTImageMessage  : KLTMediaMessage

/** @brief 当分享一张图片时，图片的二进制数据。与 imageUrl 二选一。 推荐使用。 */
@property (strong, nonatomic, nullable) NSData *imageData;

/** @brief 当分享一张图片时，图片的远程 URL。与 imageData 二选一。 */
@property (copy, nonatomic, nullable) NSString *imageUrl;

@end

@interface KLTAudioMessage  : KLTMediaMessage

/** @brief 语音播放页面的地址。 */
@property (copy, nonatomic, nonnull) NSString *audioUrl;

/** @brief 语音数据的地址。 */
@property (copy, nonatomic, nonnull) NSString *audioDataUrl;

@end

@interface KLTVideoMessage : KLTMediaMessage

/** @brief 视屏播放页面的地址。 */
@property (copy, nonatomic, nonnull) NSString *videoUrl;

/** @brief 视屏数据的地址。 */
@property (copy, nonatomic, nonnull) NSString *videoDataUrl;

@end

@interface KLTPageMessage : KLTMediaMessage

/** @brief 分享的文章，新闻的链接地址。 */
@property (copy, nonatomic, nonnull) NSString *webPageUrl;

@end

@interface KLTAppContentMessage : KLTMediaMessage

/** @brief 分享内容的URL。 */
@property (nonatomic, copy, nullable) NSString *url;
/** @brief 分享内容的额外信息。 */
@property (nonatomic, copy, nullable) NSString *extInfo;
/** @brief 分享内容的数据段。 */
@property (nonatomic, copy, nullable) NSData   *fileData;

@end
