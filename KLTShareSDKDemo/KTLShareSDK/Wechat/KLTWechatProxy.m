//
//  WechatProxy.m
//  KLTShare
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
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
    }else {
        if (resp.errCode != WXSuccess)
        {
            if (doneBlock)
            {
                doneBlock(nil, [NSError errorWithDomain:kWechatErrorDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey: resp.errStr ?: @"取消"}]);
            }
            
            return;
        }else{
            doneBlock(nil,nil);
        }
    }
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
  imageObect.imageUrl = self.imageUrl;

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
