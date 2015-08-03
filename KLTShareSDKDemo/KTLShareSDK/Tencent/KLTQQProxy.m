//
//  QQProxy.m
//  KLTShare
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "KLTQQProxy.h"

#import "UIImage+ResizeMagick.h"

static NSString * const kQQErrorDomain = @"qq_error_domain";
NSString * const kKLTShareTypeQQ = @"KLTShare_qq";
NSString * const kTencentQQSceneTypeKey = @"KLTShare_tencent_qq_scene_type";

@interface KLTQQProxy () <QQApiInterfaceDelegate, TencentSessionDelegate>
@property (copy, nonatomic) KLTShareCompletedBlock block;
@property (strong, nonatomic) TencentOAuth *tencentOAuth;
@end

@implementation KLTQQProxy

+ (id<KLTShareProxyProtocol> __nonnull)proxy
{
  return [[KLTQQProxy alloc] init];
}

+ (void)load
{
  [[KLTShareKit sharedInstance] registerProxyObject:[self proxy] withName:kKLTShareTypeQQ];
}

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration
{
  self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:configuration[kKLTShareAppIdKey] andDelegate:self];
}

- (BOOL)handleOpenURL:(NSURL * __nullable)url
{
  BOOL qq = [QQApiInterface handleOpenURL:url delegate:self];
  BOOL tencent = [TencentOAuth HandleOpenURL:url];

  return qq || tencent;
}

- (void)auth:(KLTShareCompletedBlock __nullable)completedBlock
{
  self.block = completedBlock;

  [self.tencentOAuth authorize:@[kOPEN_PERMISSION_GET_USER_INFO,
                                 kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                 kOPEN_PERMISSION_ADD_ALBUM,
                                 kOPEN_PERMISSION_ADD_IDOL,
                                 kOPEN_PERMISSION_ADD_ONE_BLOG,
                                 kOPEN_PERMISSION_ADD_PIC_T,
                                 kOPEN_PERMISSION_ADD_SHARE,
                                 kOPEN_PERMISSION_ADD_TOPIC,
                                 kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                 kOPEN_PERMISSION_DEL_IDOL,
                                 kOPEN_PERMISSION_DEL_T,
                                 kOPEN_PERMISSION_GET_FANSLIST,
                                 kOPEN_PERMISSION_GET_IDOLLIST,
                                 kOPEN_PERMISSION_GET_INFO,
                                 kOPEN_PERMISSION_GET_OTHER_INFO,
                                 kOPEN_PERMISSION_GET_REPOST_LIST,
                                 kOPEN_PERMISSION_LIST_ALBUM,
                                 kOPEN_PERMISSION_UPLOAD_PIC,
                                 kOPEN_PERMISSION_GET_VIP_INFO,
                                 kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                                 kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                                 kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO]
                      inSafari:YES];
}

- (void)share:(KLTMessage * __nonnull)message completed:(KLTShareCompletedBlock __nullable)compltetedBlock
{
    self.block = compltetedBlock;
    
    QQApiObject *apiObject = [message qqMessage];
    apiObject.cflag = kQQAPICtrlFlagQQShare;
    SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:apiObject];
    
    //区别手机QQ和QZone请求
    QQApiSendResultCode status;
    if (message.userInfo &&
        message.userInfo[kTencentQQSceneTypeKey] &&
        [message.userInfo[kTencentQQSceneTypeKey] intValue] == TencentSceneZone
        )
    {
        status = [QQApiInterface SendReqToQZone:request];
    }
    else
    {
        status = [QQApiInterface sendReq:request];
    }
    
    NSString *errorMessage = [self handleQQSendResult:status];
    
    if (errorMessage)
    {
        self.block = nil;
        compltetedBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: errorMessage}]);
    }
}


- (BOOL)isInstalled
{
  return [TencentOAuth iphoneQQInstalled]; // 只判断 QQ 没有安装，不判断 QQZone 因为 QQZone 没有支持 SSO 。
}

#pragma mark - QQ SDK Delegate

- (NSString *)handleQQSendResult:(QQApiSendResultCode)sendResult
{
    NSString *errorMessage = nil;
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            errorMessage = @"App 未注册";
            
            break;
        }
            
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            errorMessage = @"发送参数错误";
            
            break;
        }
            
        case EQQAPIQQNOTINSTALLED:
        {
            errorMessage = @"未安装手机 QQ";
            
            break;
        }
            
        case EQQAPIQQNOTSUPPORTAPI:
        {
            errorMessage = @"API 接口不支持";
            
            break;
        }
            
        case EQQAPISENDFAILD:
        {
            errorMessage = @"发送失败";
            
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:{
            errorMessage= @"qzone分享不支持text类型分享";
            
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:{
            errorMessage= @"qzone分享不支持image类型分享";
            
            break;
        }
        default:
        {
            break;
        }
    }
    
    return errorMessage;
}


- (void)tencentDidLogin
{
  [self.tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
  KLTShareCompletedBlock doneBlock = self.block;
  self.block = nil;
  if (doneBlock)
  {
    doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"QQ 登录被取消"}]);
  }
}

- (void)tencentDidNotNetWork
{
  KLTShareCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (doneBlock)
  {
    doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"网络链接错误"}]);
  }
}

- (void)getUserInfoResponse:(APIResponse *)response
{
  KLTShareCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (doneBlock)
  {
    if (response.retCode == URLREQUEST_SUCCEED)
    {
      NSDictionary *userInfo = response.jsonResponse;
      DTUser *dtUser = nil;
      if (self.tencentOAuth.openId && userInfo[@"nickname"])
      {
        dtUser = [[DTUser alloc] init];
        dtUser.uid = self.tencentOAuth.openId;
        dtUser.nick = userInfo[@"nickname"];
        dtUser.gender = [userInfo[@"gender"] isEqualToString:@"男"] ? @"male" : @"female";
        dtUser.avatar = userInfo[@"figureurl_qq_2"];
        dtUser.provider = @"qqspace";
        dtUser.rawData = userInfo;

        doneBlock(dtUser, nil);
      }
      else
      {
        doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"获取的授权数据错误"}]);
      }
    }
    else
    {
      doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: response.errorMsg}]);
    }
  }
}

- (void)onReq:(QQBaseReq *)req
{
  // ...
}

- (void)onResp:(QQBaseResp *)resp
{
  KLTShareCompletedBlock completedBlock = self.block;
  self.block = nil;

  if (completedBlock)
  {
    if (resp.errorDescription)
    {
      completedBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: resp.errorDescription}]);
    }
    else
    {
      completedBlock(resp.result, nil);
    }
  }
}

- (void)isOnlineResponse:(NSDictionary *)response
{
  
}

@end

@implementation KLTTextMessage (QQ)
- (QQApiObject *)qqMessage
{
  QQApiTextObject *textObject = [QQApiTextObject objectWithText:self.text];

  return textObject;
}
@end


@implementation KLTMediaMessage (QQ)
- (QQApiObject *)qqMessage
{
  NSAssert(false, @"Should implement this method.");

  return nil;
}
@end


@implementation KLTImageMessage (QQ)
- (QQApiObject *)qqMessage
{
  NSData *imageData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:120], 0.75);

  return [QQApiImageObject objectWithData:self.imageData
                         previewImageData:imageData
                                    title:self.title
                              description:self.desc];
}
@end


@implementation KLTAudioMessage (QQ)
- (QQApiObject *)qqMessage
{
  NSData *imageData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:120], 0.75);
  QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.audioUrl]
                                                         title:self.title
                                                   description:self.desc
                                              previewImageData:imageData];

  return newsObject;
}
@end


@implementation KLTVideoMessage (QQ)
- (QQApiObject *)qqMessage
{
  NSData *imageData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:120], 0.75);

  QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.videoUrl]
                                                         title:self.title
                                                   description:self.desc
                                              previewImageData:imageData];

  return newsObject;
}
@end


@implementation KLTPageMessage (QQ)
- (QQApiObject *)qqMessage
{
  NSData *imageData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:120], 0.75);

  QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.webPageUrl]
                                                         title:self.title
                                                   description:self.desc
                                              previewImageData:imageData];
  return newsObject;
}

@end
