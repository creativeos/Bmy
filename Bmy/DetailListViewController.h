//
//  DetailListViewController.h
//  Bmy
//
//  Created by zl on 14-1-7.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface DetailListViewController : UITableViewController<UIActionSheetDelegate>

@property (weak, nonatomic) NSString *url;
@property (weak, nonatomic) NSString *title;

@property (strong, nonatomic) NSMutableArray *detailTitleList;
@property (strong, nonatomic) NSMutableArray *detailList;
@property (strong, nonatomic) NSMutableArray *detailReplyURLList;
@property (strong, nonatomic) NSMutableArray *detailWebViewHtmlList;
@property (strong, nonatomic) NSMutableArray *detailWebViewHtmlHeightList;

@property (strong, nonatomic) NSMutableArray *pageURLList;
@property (strong, nonatomic) NSString * nextPageURL;


@property (strong, nonatomic) NSMutableArray *authorIdList;
@property (strong, nonatomic) NSMutableArray *authorNameList;

@property (strong, nonatomic) NSMutableArray *timeList;

@property int selectedRow;
@property (weak, nonatomic) IBOutlet UIButton *addMoreButton;

@end
