//
//  MessageViewController.h
//  Bmy
//
//  Created by zl on 14-1-15.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface MessageViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *mailList;
@property (strong, nonatomic) NSMutableArray *authorList;
@property (strong, nonatomic) NSMutableArray *urlList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendMailButton;

@end
