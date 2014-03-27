//
//  UserInfoViewController.h
//  Bmy
//
//  Created by zl on 14-1-18.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface UserInfoViewController : UIViewController

@property (weak, nonatomic) NSString *userid;
@property (weak, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet UILabel *userInfo;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendMailButton;

@end
