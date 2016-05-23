//
//  WechatProxy.m
//  KLTShare
//
//  Created by 田凯 on 15/8/1.
//  Copyright (c) 2015年 田凯. All rights reserved.
//

#import "KLTWechatProxy.h"
#import "ShareSDKHttp.h"
#import <UIKit/UIKit.h>
#import "UIImage+ResizeMagick.h"

static NSString * const kWechatErrorDomain = @"wechat_error_domain";
NSString * const kKLTShareTypeWechat = @"KLTShare_wechat";
NSString * const kWechatSceneTypeKey = @"wechat_scene_type_key";

@interface KLTWechatProxy () <WXApiDelegate>
@property (copy, nonatomic) NSString *wechatAppId;
@property (copy, nonatomic) NSString *wechatSecret;
@property (copy, nonatomic) KLTShareCompletedBlock block;
@end

@implementation KLTWechatProxy

+ (id<KLTShareProxyProtocol> __nonnull)proxy
{
  return [[KLTWechatProxy alloc] init];
}

+ (void)load
{
  [super load];
  [[KLTShareKit sharedInstance] registerProxyObject:[self proxy] withName:kKLTShareTypeWechat];
}

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration
{
  self.wechatAppId = configuration[kKLTShareAppIdKey];
  self.wechatSecret = configuration[kKLTShareAppSecretKey];
  [WXApi registerApp:self.wechatAppId];
}

- (void)auth:(KLTShareCompletedBlock __nullable)completedBlock
{
  self.block = completedBlock;

  SendAuthReq *request = [[SendAuthReq alloc] init];
  request.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
  request.state = @"wechat_auth_login_liulishuo";

  [WXApi sendReq:request];
}

- (void)share:(KLTMessage * __nonnull)message completed:(KLTShareCompletedBlock __nullable)compltetedBlock
{
  self.block = compltetedBlock;
  
  SendMessageToWXReq *wxReq = [[SendMessageToWXReq alloc] init];
  if ([message isKindOfClass:[KLTMediaMessage class]])
  {
    wxReq.text = nil;
    wxReq.bText = NO;
    wxReq.message = [(KLTMediaMessage *)message wechatMessage];
  }
  else
  {
    wxReq.text = [(KLTTextMessage *)message text];
    wxReq.bText = YES;
  }

  // 微信分享场景的选择：朋友圈（WXSceneTimeline）、好友（WXSceneSession）、收藏（WXSceneFavorite）
  wxReq.scene = WXSceneTimeline;
  if (message.userInfo)
  {
    if (message.userInfo[kWechatSceneTypeKey])
    {
      int scence = [message.userInfo[kWechatSceneTypeKey] intValue];
      if (scence >= 0 && scence <= 2)
      {
        wxReq.scene = scence;
      }
    }
  }

  [WXApi sendReq:wxReq];
}

- (BOOL)isInstalled
{
  return [WXApi isWXAppInstalled];
}

- (BOOL)handleOpenURL:(NSURL * __nullable)url
{
  return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - Wechat SDK Delegate

- (void)onReq:(BaseReq*)req
{
  // TODO: wechat request
}

- (void)onResp:(BaseResp*)resp
{
  KLTShareCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (resp.errCode != WXSuccess)
  {
    if (doneBlock)
    {
      doneBlock(nil, [NSError errorWithDomain:kWechatErrorDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey: resp.errStr ?: @"取消"}]);
    }

    return;
  }

  if([resp isKindOfClass:[SendMessageToWXResp class]])
  {
    if (doneBlock)
    {
      if (resp.errCode != WXSuccess)
      {
        doneBlock(nil, [NSError errorWithDomain:kWechatErrorDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey: resp.errStr ?: @"分享失败"}]);
      }
      else
      {
        doneBlock(nil, nil);
      }
    }
  }
  else if([resp isKindOfClass:[SendAuthResp class]])
  {
    SendAuthResp *temp = (SendAuthResp*)resp;
    if (temp.code)
    {
      [self getWechatUserInfoWithCode:temp.code completed:doneBlock];
    }
    else
    {
      if (doneBlock)
      {
        doneBlock(nil, [NSError errorWithDomain:kWechatErrorDomain
                                           code:temp.errCode
                                       userInfo:@{NSLocalizedDescriptionKey: @"微信授权失败"}]);
      }
    }

  }
}

- (void)getWechatUserInfoWithCode:(NSString *)code completed:(KLTShareCompletedBlock)completedBlock
{
  [self wechatAuthRequestWithPath:@"oauth2/access_token"
                           params:@{@"appid": self.wechatAppId,
                                    @"secret": self.wechatSecret,
                                    @"code": code,
                                    @"grant_type": @"authorization_code"}
                        complated:^(NSDictionary *result, NSError *error) {
                          if (result)
                          {
                            NSString *openId = result[@"openid"];
                            NSString *accessToken = result[@"access_token"];
                            if (openId && accessToken)
                            {
                              [self wechatAuthRequestWithPath:@"userinfo"
                                                       params:@{@"openid": openId,
                                                                @"access_token": accessToken}
                                                    complated:^(NSDictionary *result, NSError *error) {
                                                      DTUser *dtUser = nil;
                                                      if (result[@"unionid"])
                                                      {
                                                        dtUser = [[DTUser alloc] init];
                                                        dtUser.uid = result[@"unionid"];
                                                        dtUser.gender = [result[@"sex"] integerValue] == 1 ? @"male" : @"female";
                                                        dtUser.nick = result[@"nickname"];
                                                        dtUser.avatar = result[@"headimgurl"];
                                                        dtUser.provider = @"wechat";
                                                        dtUser.rawData = result;
                                                      }

                                                      if (completedBlock)
                                                      {
                                                        completedBlock(dtUser, error);
                                                      }
                                                    }];
                              return;
                            }
                          }

                          if (completedBlock)
                          {
                            completedBlock(result, error);
                          }
                        }];
}

#pragma mark - Http Request

- (void)wechatAuthRequestWithPath:(NSString *)path
                           params:(NSDictionary *)params
                        complated:(KLTShareCompletedBlock)completedBlock
{
  NSURL *baseURL = [NSURL URLWithString:@"https://api.weixin.qq.com/sns"];
  [ShareSDKHttp requestWithUrl:[baseURL URLByAppendingPathComponent:path]
                mehtod:@"GET"
                params:params
             complated:completedBlock];
}



@end


@implementation KLTMediaMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *mesage = [WXMediaMessage message];
  mesage.title = self.title;
  mesage.description = self.desc;
  mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:120], 0.75);

  return mesage;
}
@end


@implementation KLTImageMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [super wechatMessage];

  WXImageObject *imageObect = [WXImageObject object];
  imageObect.imageData = self.imageData;

  message.mediaObject = imageObect;

  return message;
}
@end


@implementation KLTAudioMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *mesage = [super wechatMessage];

  WXMusicObject *musicObject = [WXMusicObject object];
  musicObject.musicUrl = self.audioUrl;
  musicObject.musicDataUrl = self.audioDataUrl;

  mesage.mediaObject = musicObject;

  return mesage;
}
@end


@implementation KLTVideoMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [super wechatMessage];

  WXVideoObject *videoObject = [WXVideoObject object];
  videoObject.videoUrl = self.videoUrl;
  videoObject.videoLowBandUrl = self.videoDataUrl;

  message.mediaObject = videoObject;

  return message;
}
@end


@implementation KLTPageMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [super wechatMessage];

  WXWebpageObject *webPageObject = [WXWebpageObject object];
  webPageObject.webpageUrl = self.webPageUrl;

  message.mediaObject = webPageObject;
  
  return message;
}

@end
