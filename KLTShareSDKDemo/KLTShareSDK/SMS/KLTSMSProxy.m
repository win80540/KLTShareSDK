//
//  KLTMsgProxy.m
//  KLTShareSDKDemo
//
//  Created by 田凯 on 15/8/3.
//  Copyright (c) 2015年 田凯. All rights reserved.
//
#import "KLTSMSProxy.h"

static NSString * const kSMSErrorDomain = @"SMS_error_domain";
NSString * const kKLTShareTypeSMS = @"KLTShare_SMS";
@interface KLTSMSProxy ()
@property (copy, nonatomic) KLTShareCompletedBlock block;
@end;


@implementation KLTSMSProxy
+ (id<KLTShareProxyProtocol> __nonnull)proxy{
    return [[KLTSMSProxy alloc] init];
}
+ (void)load{
    [super load];
    [[KLTShareKit sharedInstance] registerProxyObject:[self proxy] withName:kKLTShareTypeSMS];
}
- (void)auth:(KLTShareCompletedBlock __nullable)completedBlock{
    return;
}
- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration{
    return;
}
- (BOOL)handleOpenURL:(NSURL * __nullable)url{
    return YES;
}
- (BOOL)isInstalled{
    return [MFMessageComposeViewController canSendText];
}
- (void)share:(KLTMessage * __nonnull)message completed:(KLTShareCompletedBlock __nullable)compltetedBlock{
    self.block = compltetedBlock;
    KLTSMSMediaMessage *selfMsg ;
    if ([message isKindOfClass:[KLTMediaMessage class]]) {
        selfMsg = [(KLTMediaMessage *)message msgMessage];
    }
    [self sharedMsg:selfMsg];
}
- (void)sharedMsg:(KLTSMSMediaMessage *)message {
    MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
    //设置委托
    mc.messageComposeDelegate=self;
    //短信内容
    mc.body=[NSString stringWithFormat:@"%@\n%@\n%@",message.title,message.desc,message.dataUrl];
    //设置短信收件方
    //mc.recipients=[NSArray arrayWithObject:@"10010"];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    [vc presentViewController:mc animated:YES completion:nil];
}

//短信发送的处理结果
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    KLTShareCompletedBlock doneBlock = self.block;
    NSError * error = nil;
    switch (result)
    {
        case MessageComposeResultSent:
            NSLog(@"KTLShareSDK - message sended");
            break;
        case MessageComposeResultCancelled:
            NSLog(@"KTLShareSDK -  message cancelled");
            break;
        case MessageComposeResultFailed:
            error = [[NSError alloc] initWithDomain:kSMSErrorDomain code:result userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"KTLShareSDKFailedSMS", nil) }];
            break;
        default:
            error = [[NSError alloc] initWithDomain:kSMSErrorDomain code:result userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"KTLShareSDKFailedSMSUnknow", nil) }];
            break;
    }
    if (doneBlock) {
        doneBlock(nil,error);
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end


@implementation KLTSMSMediaMessage
+ (KLTSMSMediaMessage * __nonnull)message{
    return [[KLTSMSMediaMessage alloc] init];
}
@end

#pragma mark - DTMessage category

@implementation KLTMediaMessage (Yixin)
- (KLTSMSMediaMessage * __nonnull)msgMessage;
{
    KLTSMSMediaMessage *mesage = [KLTSMSMediaMessage message];
    mesage.title = self.title;
    mesage.desc = self.desc;
    return mesage;
}
@end

@implementation KLTImageMessage (Yixin)
- (KLTSMSMediaMessage * __nonnull)msgMessage;
{
    KLTSMSMediaMessage *mesage = [KLTSMSMediaMessage message];
    mesage.title = self.title;
    mesage.desc = self.desc;
//    mesage.dataUrl = self.imageUrl;
    return mesage;
}
@end

@implementation KLTAudioMessage (Yixin)
- (KLTSMSMediaMessage * __nonnull)msgMessage;
{
    KLTSMSMediaMessage *mesage = [KLTSMSMediaMessage message];
    mesage.title = self.title;
    mesage.desc = self.desc;
    mesage.dataUrl = self.audioUrl;
    return mesage;
}
@end

@implementation KLTVideoMessage (Yixin)
- (KLTSMSMediaMessage * __nonnull)msgMessage;
{
    KLTSMSMediaMessage *mesage = [KLTSMSMediaMessage message];
    mesage.title = self.title;
    mesage.desc = self.desc;
    mesage.dataUrl = self.videoUrl;
    return mesage;
}
@end

@implementation KLTPageMessage (Yixin)
- (KLTSMSMediaMessage * __nonnull)msgMessage;
{
    KLTSMSMediaMessage *mesage = [KLTSMSMediaMessage message];
    mesage.title = self.title;
    mesage.desc = self.desc;
    mesage.dataUrl = self.webPageUrl;
    return mesage;
}
@end

