//
//  ArticleListOfSameSubjectViewController.h
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleListOfSameSubjectViewController : UITableViewController
@property (strong, nonatomic) NSDictionary *dictData;
@property (strong, nonatomic) NSArray *listData;

@property (weak, nonatomic) NSString *url;

@property (strong, nonatomic) NSMutableArray *articleList;
@property (strong, nonatomic) NSMutableArray *authorList;
@property (strong, nonatomic) NSMutableArray *urlList;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) IBOutlet UITableView *addMoreButton;

@property (strong, nonatomic) NSString *postArticleURL;

@property (strong, nonatomic) NSMutableArray *pageURLList;
@property (strong, nonatomic) NSString * nextPageURL;

@end
