//
//  MailDetailViewController.h
//  Bmy
//
//  Created by zl on 14-1-19.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface MailDetailViewController : UIViewController<UIWebViewDelegate,MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSMutableString *mailHtml;
@property (strong, nonatomic) NSString *replyURL;
@property (strong, nonatomic) NSString *replyPostURL;

@property (weak, nonatomic) NSString *url;

@property(weak,nonatomic) NSMutableData *mutabledata;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *replyButton;

@property (strong, nonatomic) NSString *mailTitle;
@property (strong, nonatomic) NSString *mailUserid;

@end
