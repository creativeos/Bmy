//
//  DetailWebViewTableViewController.m
//  Bmy
//
//  Created by zl on 14-1-14.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "DetailWebViewTableViewController.h"

@interface DetailWebViewTableViewController ()

@end

@implementation DetailWebViewTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"int the table view");
    
    //初始化UIRefreshControl
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
}

-(void) refreshTableView
{
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"加载中..."];
        //添加新的模拟数据
        
        //模拟请求完成之后，回调方法callBackMethod
        [self performSelector:@selector(callBackMethod:) withObject:nil afterDelay:1];
    }
}

//这是一个模拟方法，请求完成之后，回调方法
-(void)callBackMethod:(id) obj
{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 实现表视图数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    //NSLog(@"test1");
    //static NSString *CellIdentifier = @"webView";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //DetailWebViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil)
    //{
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //    cell = [[DetailWebViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //}
    NSLog(@"test2");
    
    //cell.webView.delegate = cell;
    NSLog(@"test3");
    
    //NSURL * url = [NSURL URLWithString:@"http://www.baidu.com/"];
	//NSURLRequest * request2 = [NSURLRequest requestWithURL:url];
    
    
    //UIWebView *webView = [[UIWebView alloc]init];
    //[webView loadRequest:request2];
    //[cell addSubview:webView];
    
    
    //[cell.webView loadRequest:request2];
   // NSLog(@"return cell");
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*NSInteger row = [indexPath row];
    
    NSString *text = detail;
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 25000.0f);
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:FONT_SIZE] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize size = rect.size;
    
    
    CGFloat height = size.height + 20.0f;
    */
    return 300; //height + (CELL_CONTENT_MARGIN * 2);
    
}

@end
