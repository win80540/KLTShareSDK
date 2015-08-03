//
//  ViewController.m
//  KLTShareKit
//
//  Created by Cloud Dai on 11/5/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "ViewController.h"

#import "KLTShareSDK.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}





- (IBAction)shareTextToWeiboAction:(id)sender
{
  [self shareMessage:[self generateImageMessage] type:kKLTShareTypeWeibo];
}

- (IBAction)shareToWeiboAudioAction:(id)sender
{
  [self shareMessage:[self generateMusicMessage] type:kKLTShareTypeWeibo];
}

- (void)shareMessage:(KLTMessage *)message type:(NSString *)name
{
  [[KLTShareKit sharedInstance] share:message
                              name:name
                         completed:^(id result, NSError *error) {
                           [self showText:result];
                         }];
}

- (IBAction)shareVideoToWeiboAction:(id)sender
{
  [self shareMessage:[self generateVideoMessage] type:kKLTShareTypeWeibo];
}

- (void)showText:(id)result
{
  NSString *text = [NSString stringWithFormat:@"%@", result];
  self.contentLabel.text = text;
}

- (IBAction)shareTextToWechat:(id)sender
{
  [self shareMessage:[self generateTextMessage] type:kKLTShareTypeWechat];
}

- (IBAction)sharePictureToWechat:(id)sender
{
  [self shareMessage:[self generateImageMessage] type:kKLTShareTypeWechat];
}

- (IBAction)shareMusicToWechat:(id)sender
{
  [self shareMessage:[self generateMusicMessage] type:kKLTShareTypeWechat];
}

- (IBAction)shareVideoToWechat:(id)sender
{
  [self shareMessage:[self generateVideoMessage] type:kKLTShareTypeWechat];
}

- (IBAction)shareTextToQQAction:(id)sender
{
  [self shareMessage:[self generateTextMessage] type:kKLTShareTypeQQ];
}

- (IBAction)shareImageToQQAction:(id)sender
{
  [self shareMessage:[self generateImageMessage] type:kKLTShareTypeQQ];
}

- (IBAction)shareMusicToQQAction:(id)sender
{
  [self shareMessage:[self generateMusicMessage] type:kKLTShareTypeQQ];
}

- (IBAction)shareVideoToQQAction:(id)sender
{
  [self shareMessage:[self generateVideoMessage] type:kKLTShareTypeQQ];
}

- (IBAction)shareNewsToQQAction:(id)sender
{
  [self shareMessage:[self generateWebPageMessage] type:kKLTShareTypeQQ];
}


- (IBAction)sharePageToSMS:(id)sender {
    [self shareMessage:[self generateWebPageMessage] type:kKLTShareTypeSMS];
}

#pragma mark - Yixin

- (IBAction)shareTextToYixin:(id)sender
{
    [self shareMessage:[self generateTextMessage] type:kKLTShareTypeYixin];
}

- (IBAction)sharePictureToYixin:(id)sender
{
    [self shareMessage:[self generateImageMessage] type:kKLTShareTypeYixin];
}

- (IBAction)shareMusicToYixin:(id)sender
{
    [self shareMessage:[self generateMusicMessage] type:kKLTShareTypeYixin];
}

- (IBAction)shareVideoToYixin:(id)sender
{
    [self shareMessage:[self generateVideoMessage] type:kKLTShareTypeYixin];
}

- (KLTMessage *)generateTextMessage
{
  KLTTextMessage *message = [[KLTTextMessage alloc] init];
  message.text = @"Hello world!";
  message.userInfo = @{kWechatSceneTypeKey: @(KLTShareSceneSession),
                       kYixinSceneTypeKey:@(KLTShareSceneSession)};

  return message;
}

- (KLTMessage *)generateImageMessage
{
  KLTImageMessage *message = [[KLTImageMessage alloc] init];
  message.title = @"Share my cat";
  message.desc = @"I share my cat for test!";
  message.imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"IMG_Cat.jpg"], 0.75);;
  message.thumbnailableImage = [UIImage imageNamed:@"IMG_Cat_thumb.png"];
  message.userInfo = @{kWechatSceneTypeKey: @(KLTShareSceneSession),
                         kYixinSceneTypeKey:@(KLTShareSceneSession)};

  return message;
}

- (KLTMessage *)generateMusicMessage
{
  KLTAudioMessage *message = [[KLTAudioMessage alloc] init];
  message.messageId = @"79jklfdja89u8klmkl98";
  message.title = @"成功闯关";
  message.desc = @"成功过关！我在玩#英语流利说#闯关之#逛超市#，每次说完英语都有种欲言又止、意犹未尽的感觉，小宇宙马上就要爆发啦。来听听我的伦敦郊区音";
  message.audioUrl = @"http://share.liulishuo.com/v2/share/8a6d90f0dcfa013245d752540071c562";
  message.audioDataUrl = @"http://cdn.llsapp.com/54251c18636d734cc90b4900_Zjk0MWQwMDAwMDBiODdlNQ==_1431672097.mp3";
  message.thumbnailableImage = [UIImage imageNamed:@"IMG_Cat_thumb.png"];
  message.userInfo = @{kWechatSceneTypeKey: @(WXSceneTimeline), kTencentQQSceneTypeKey: @(TencentSceneZone)};

  return message;
}

- (KLTMessage *)generateVideoMessage
{
  KLTVideoMessage *message = [[KLTVideoMessage alloc] init];
  message.messageId = @"79jklfdja89u8klmkl98";
  message.title = @"奥迪Audi Q7全方位展示 Ara Blue";
  message.desc = @"奥迪Audi Q7全方位展示 Ara Blue 奥迪Audi Q7全方位展示 Ara Blue 奥迪Audi Q7全方位展示 Ara Blue。";
  message.videoUrl = @"http://v.youku.com/v_show/id_XOTU0NzkzMDM2.html";
  message.videoDataUrl = @"http://player.youku.com/embed/XOTU0NzkzMDM2";
  message.thumbnailableImage = [UIImage imageNamed:@"IMG_Cat_thumb.png"];
  message.userInfo = @{kWechatSceneTypeKey: @(WXSceneTimeline)};

  return message;
}

- (KLTMessage *)generateWebPageMessage
{
  KLTPageMessage *message = [[KLTPageMessage alloc] init];
  message.title = @"一段新闻";
  message.desc = @"一段新闻的描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述.";
  message.webPageUrl = @"http://www.pingwest.com/can-machine-replace-sense-of-touch/";
  message.userInfo = @{kWechatSceneTypeKey: @(WXSceneTimeline)};

  return message;
}
@end
