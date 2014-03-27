//
//  ReplyMailViewController.h
//  Bmy
//
//  Created by zl on 14-1-22.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface ReplyMailViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *replyPostURL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *mailTitle;
@property (weak, nonatomic) IBOutlet UITextField *mailReciever;
@property (weak, nonatomic) IBOutlet UITextView *mailContent;

@property (strong, nonatomic) NSString *segueMailTitle;
@property (strong, nonatomic) NSString *segueMailUserid;

@end
