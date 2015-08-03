//
//  KLTShare.m
//  KLTShare
//
//  Created by Cloud Dai on 11/5/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "KLTShareKit.h"

NSString * __nonnull const kKLTShareAppIdKey = @"KLTShare_app_id";
NSString * __nonnull const kKLTShareAppSecretKey = @"KLTShare_app_secret";
NSString * __nonnull const kKLTShareAppRedirectUrlKey = @"KLTShare_app_redirect_url";
NSString * __nonnull const kKLTShareAppDebugModeKey = @"KLTShare_app_debug_mode";

static NSString * __nonnull const kKLTShareAppErrorDomainKey = @"com.netease.KLTShare.error";
static NSString * __nonnull const kKLTShareErrorKeyUnKnowApp = @"未知应用";

@interface KLTShareKit ()

@property (strong, nonatomic) NSMutableDictionary *proxyObjects;

@end

@implementation KLTShareKit

+ (instancetype)sharedInstance
{
  static KLTShareKit * _KLTShareInstance = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _KLTShareInstance = [[KLTShareKit alloc] init];
  });

  return _KLTShareInstance;
}

- (instancetype)init
{
  self = [super init];

  if (self)
  {
    self.proxyObjects = [NSMutableDictionary dictionary];
  }

  return self;
}

- (void)registerProxyObject:(id<KLTShareProxyProtocol> __nonnull)object withName:(NSString * __nonnull)name
{
  self.proxyObjects[name] = object;
}

- (void)registerWithConfigurations:(NSDictionary * __nonnull)configurations
{
  [configurations enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSDictionary *configuration, BOOL *stop) {
    id<KLTShareProxyProtocol> proxy = self.proxyObjects[name];
    [proxy registerWithConfiguration:configuration];
  }];
}

- (BOOL)isInstalled:(NSString * __nonnull)name
{
  id<KLTShareProxyProtocol> proxy = self.proxyObjects[name];
  return [proxy isInstalled];
}

- (BOOL)handleOpenURL:(NSURL * __nullable)url
{
  BOOL success = NO;
  for (id<KLTShareProxyProtocol> proxy in self.proxyObjects.allValues)
  {
    success = success || [proxy handleOpenURL:url];
  }

  return success;
}



- (void)share:(KLTMessage * __nonnull)message name:(NSString * __nonnull)name completed:(KLTShareCompletedBlock __nullable)completedBlock
{
  id<KLTShareProxyProtocol> proxy = self.proxyObjects[name];
  if (proxy)
  {
    [proxy share:message completed:completedBlock];
  }
  else
  {
    if (completedBlock)
    {
      completedBlock(nil, [NSError errorWithDomain:kKLTShareAppErrorDomainKey code:-1024 userInfo:@{NSLocalizedDescriptionKey: kKLTShareErrorKeyUnKnowApp}]);
    }
  }
}

@end


@implementation DTUser
- (NSString *)description
{
  return [NSString stringWithFormat:@"uid: %@ \n nick: %@ \n avatar: %@ \n gender: %@ \n provider: %@", self.uid, self.nick, self.avatar, self.gender, self.provider];
}

@end

#pragma mark - Message

@implementation KLTMessage
- (NSString *)description
{
  return @"No custom property.";
}
@end


@implementation KLTTextMessage
- (NSString *)description
{
  return [NSString stringWithFormat:@"text: %@ \n", self.text];
}
@end


@implementation KLTMediaMessage
- (NSString *)description
{
  return [NSString stringWithFormat:@"message Id: %@ \n title: %@ \n desc: %@ \n thumb data: %@ \n", self.messageId, self.title, self.desc, self.thumbnailableImage];
}
@end

@implementation KLTImageMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"image url: %@ \n image data: %@ \n", self.imageUrl, self.imageData];
}
@end


@implementation KLTAudioMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"audio url: %@ \n audio data url: %@ \n", self.audioUrl, self.audioDataUrl];
}
@end


@implementation KLTVideoMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"video url: %@ \n video data url: %@ \n", self.videoUrl, self.videoDataUrl];
}
@end


@implementation KLTPageMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"web page url: %@", self.webPageUrl];
}

@end


@implementation KLTAppContentMessage
- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"app content  url: %@  extInfo: %@  fileData: %@", self.url,self.extInfo,self.fileData];
}

@end
