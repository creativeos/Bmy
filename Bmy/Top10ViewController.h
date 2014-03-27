//
//  Top10ViewController.h
//  Bmy
//
//  Created by zl on 14-1-10.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Top10ViewController : UITableViewController

@property (weak, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableArray *articleList;
@property (strong, nonatomic) NSMutableArray *authorList;
@property (strong, nonatomic) NSMutableArray *urlList;

@end
