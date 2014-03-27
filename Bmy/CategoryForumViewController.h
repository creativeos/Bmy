//
//  CategoryForumViewController.h
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryForumViewController : UITableViewController

@property (weak, nonatomic) NSString *url;

@property (strong, nonatomic) NSDictionary *dictData;
@property (strong, nonatomic) NSArray *listData;

@property (strong, nonatomic) NSMutableArray *forumList;
@property (strong, nonatomic) NSMutableArray *urlList;

@end
