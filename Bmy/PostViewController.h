//
//  PostViewController.h
//  Bmy
//
//  Created by zl on 14-1-29.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface PostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *postTitle;

@property (weak, nonatomic) IBOutlet UITextView *content;

@property (strong, nonatomic) NSString *postFormTitle;
@property (strong, nonatomic) NSString *postFormURL;

@end
