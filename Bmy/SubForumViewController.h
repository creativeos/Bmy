//
//  SubForumViewController.h
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubForumViewController : UITableViewController

@property (strong, nonatomic) NSString *rootURL;
@property (weak, nonatomic) NSString *url;

@property (strong, nonatomic) NSDictionary *dictData;
@property (strong, nonatomic) NSArray *listData;

@property (strong, nonatomic) NSMutableArray *subForumList;
@property (strong, nonatomic) NSMutableArray *subForumURLList;


@end
