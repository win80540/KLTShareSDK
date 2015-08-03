//
//  YixinProxy.m
//  KLTShare
//
//  Created by 田凯 on 15/7/7.
//  Copyright (c) 2015年 Cloud Dai. All rights reserved.
//
#import "YXApi.h"
#import "YXApiObject.h"
#import "KLTYixinProxy.h"
#import "UIImage+ResizeMagick.h"
#import "ShareSDKHttp.h"

static NSString  * const kYixinErrorDomain = @"Yixin_error_domain";
NSString * const kKLTShareTypeYixin = @"KLTShare_Yixin";
NSString * const kYixinSceneTypeKey = @"Yixin_scene_type_key";

@interface KLTYixinProxy() <YXApiDelegate>
@property (copy, nonatomic) NSString *yixinAppId;
@property (copy, nonatomic) NSString *yixinAppSecret;
@property (copy, nonatomic) KLTShareCompletedBlock block;
@end

@implementation KLTYixinProxy

+ (id<KLTShareProxyProtocol> __nonnull)proxy{
    return [[KLTYixinProxy alloc] init];
}

+ (void)load{
    [super load];
    [[KLTShareKit sharedInstance] registerProxyObject:[self proxy] withName:kKLTShareTypeYixin];
}

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration{
    self.yixinAppId = configuration[kKLTShareAppIdKey];
    self.yixinAppSecret = configuration[kKLTShareAppIdKey];
    [YXApi registerApp:_yixinAppId];
}
- (BOOL)handleOpenURL:(NSURL * __nullable)url{
    return [YXApi handleOpenURL:url delegate:self];
}

- (BOOL)isInstalled{
   return [YXApi isYXAppInstalled];
}
- (void)share:(KLTMessage * __nonnull)message completed:(KLTShareCompletedBlock __nullable)compltetedBlock{
    self.block = compltetedBlock;
    SendMessageToYXReq *req = [[SendMessageToYXReq alloc] init];
    if ([message isKindOfClass:[KLTMediaMessage class]]) {
        req.bText = NO;
        req.text = nil;
        req.message = [(KLTMediaMessage *)message yixinMessage];
    }else{
        req.bText = YES;
        req.text = @"http://img5.cache.netease.com/photo/ 童鞋，我想跟你说个事呀！童鞋，童鞋，我想跟你说个事呀！";
    }
    
    req.scene = kYXSceneTimeline;
    if (message.userInfo && message.userInfo[kYixinSceneTypeKey]
        && ![message.userInfo[kYixinSceneTypeKey] isKindOfClass:[NSNull class]]) {
        int scence = [message.userInfo[kYixinSceneTypeKey] intValue];
        if(scence >= 0 && scence <=2){
            req.scene = scence;
        }
    }
    [YXApi sendReq:req];

}




#pragma mark - YXApiDelegate method
- (void)onReceiveRequest: (YXBaseReq *)req {
    if ([req isKindOfClass:[ShowMessageFromYXReq class]]) {
        ShowMessageFromYXReq* reciveReq = (ShowMessageFromYXReq*)req;
        if(reciveReq.message != nil && [reciveReq.message.mediaObject isKindOfClass:[YXAppExtendObject class]]){
            YXAppExtendObject* msg = (YXAppExtendObject*)reciveReq.message.mediaObject;
            NSLog(@"%@",msg);
        }
        NSLog(@"%ld", (long)reciveReq.type);
    }
    
}

- (void)onReceiveResponse: (YXBaseResp *)resp {
    KLTShareCompletedBlock doneBlock = self.block;
    self.block = nil;
    if([resp isKindOfClass:[SendMessageToYXResp class]])
    {
        SendMessageToYXResp *sendResp = (SendMessageToYXResp *)resp;
        NSLog(@"%ld, %@", (long)sendResp.code, sendResp.errDescription);
        if (sendResp.code != kYXRespSuccess) {
            doneBlock(nil, [NSError errorWithDomain:kYixinErrorDomain code:sendResp.code userInfo:@{NSLocalizedDescriptionKey: sendResp.errDescription ?: @"分享失败"}]);
        }else{
            doneBlock(nil,nil);
        }
    }else if([resp isKindOfClass:[SendOAuthToYXResp class]]){//kYXOAuthMessageResp
        if(resp.code == kYXRespSuccess){
            SendOAuthToYXResp *oauthresp = (SendOAuthToYXResp *)resp;
            [self getYixinUserInfoWithCode:oauthresp.authCode completed:doneBlock];
            //          NSString *oauthcode = [NSString stringWithFormat:@"code:%@\nstate:%@\nexpireseconds:%lldl", oauthresp.authCode, oauthresp.state, oauthresp.exprieSeonds];
            
        }else{
            doneBlock(nil,nil);
        }
    }else{
        if (resp.code != kYXRespSuccess) {
            doneBlock(nil, [NSError errorWithDomain:kYixinErrorDomain code:resp.code userInfo:@{NSLocalizedDescriptionKey: resp.errDescription ?: @"分享失败"}]);
        }else{
            doneBlock(nil,nil);
        }
    }
    
    
}


@end




#pragma mark - DTMessage category

@implementation KLTMediaMessage (Yixin)
- (YXMediaMessage *)yixinMessage
{
    YXMediaMessage *mesage = [YXMediaMessage message];
    mesage.title = self.title;
    mesage.description = self.desc;
    mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:200], 0.75);

    return mesage;
}
@end

@implementation KLTImageMessage (Yixin)
- (YXMediaMessage *)yixinMessage
{
    YXMediaMessage *mesage = [YXMediaMessage message];
    mesage.title = self.title;
    mesage.description = self.desc;
    mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:200], 0.75);
    {
        YXImageObject *obj = [[YXImageObject alloc] init];
        obj.imageData = self.imageData;
        obj.imageUrl = self.imageUrl;
        mesage.mediaObject = obj;
    }
    return mesage;
}
@end

@implementation KLTAudioMessage (Yixin)
- (YXMediaMessage *)yixinMessage
{
    YXMediaMessage *mesage = [YXMediaMessage message];
    mesage.title = self.title;
    mesage.description = self.desc;
    mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:200], 0.75);
    {
        YXMusicObject *obj = [[YXMusicObject alloc] init];
        obj.musicUrl = self.audioUrl;
        obj.musicDataUrl = self.audioDataUrl;
        mesage.mediaObject = obj;
    }
    return mesage;
}
@end

@implementation KLTVideoMessage (Yixin)
- (YXMediaMessage *)yixinMessage
{
    YXMediaMessage *mesage = [YXMediaMessage message];
    mesage.title = self.title;
    mesage.description = self.desc;
    mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:200], 0.75);
    {
        YXVideoObject *obj = [[YXVideoObject alloc] init];
        obj.videoUrl = self.videoUrl;

        mesage.mediaObject = obj;
    }
    return mesage;
}
@end

@implementation KLTPageMessage (Yixin)
- (YXMediaMessage *)yixinMessage
{
    YXMediaMessage *mesage = [YXMediaMessage message];
    mesage.title = self.title;
    mesage.description = self.desc;
    mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:200], 0.75);
    {
        YXWebpageObject *obj = [[YXWebpageObject alloc] init];
        obj.webpageUrl = self.webPageUrl;
        
        mesage.mediaObject = obj;
    }
    return mesage;
}
@end


@implementation KLTAppContentMessage (Yixin)
- (YXMediaMessage *)yixinMessage
{
    YXMediaMessage *mesage = [YXMediaMessage message];
    mesage.title = self.title;
    mesage.description = self.desc;
    mesage.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImageByWidth:200], 0.75);
    {
        YXAppExtendObject *obj = [[YXAppExtendObject alloc] init];
        obj.url = self.url;
        obj.extInfo = self.extInfo;
        obj.fileData = self.fileData;
        mesage.mediaObject = obj;
    }
    return mesage;
}
@end




