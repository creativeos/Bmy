//
//  SubForumViewController.m
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "SubForumViewController.h"
#import "DetailViewController.h"
#import "ArticleListOfSameSubjectViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface SubForumViewController ()

@end

@implementation SubForumViewController

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
    self.rootURL = @"http://bmy.xjtu.edu.cn/";
    self.subForumList = [NSMutableArray arrayWithCapacity:15];
    self.subForumURLList = [NSMutableArray arrayWithCapacity:15];
    
    [self parseHTML];
    
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
        [self parseHTML];
        
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


- (void)parseHTML {
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSLog(@"url = %@",url);
    
    NSString *html;
    HTMLParser *parser;
    for (int i=0; i<10; i++) {
        NSLog(@"i = %d\n",i);
        NSData *siteData = [[NSData alloc] initWithContentsOfURL:url];
        if (!siteData) {
            NSLog(@"siteData == nil");
            continue;
        }
        
        NSStringEncoding utf8Encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
        
        html = [[NSString alloc] initWithData:siteData encoding:utf8Encode];
        NSLog(@"newSiteData : %@", html);
        
        if (!html) {
            NSLog(@" html == nil");
            return;
        }
        
        html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        NSLog(@"html = %@",html);
        
        NSError *error = nil;
        parser = [[HTMLParser alloc] initWithString:html error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
            continue;
        } else {
            break;
        }
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode children];
    
    NSLog(@" body : %d", inputNodes.count);
    
    for (HTMLNode *node in inputNodes) {
        
        NSArray *boards = [node findChildrenWithAttribute:@"href" matchingName:@"alist.php?" allowPartial:YES];
        NSLog(@"children : %d", boards.count);
        for (HTMLNode *boardNode in boards) {
            if ([[boardNode getAttributeNamed:@"href"] isEqualToString:@"myboard.php?secstr=*"]) {
                continue;
            }
            NSLog(@"%@", boardNode.contents);
            [self.subForumList addObject:boardNode.contents];
            NSMutableString *url = [[NSMutableString alloc]initWithCapacity:2014];
            [url appendString:self.rootURL];
            [url appendString:[boardNode getAttributeNamed:@"href"]];
            [url appendString:@"&S=&j=1#n"];
            
            NSString *zAlistURL = [url stringByReplacingOccurrencesOfString:@"alist.php?B=" withString:@"zalist.php?board="];
            
            [self.subForumURLList addObject:zAlistURL];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 实现表视图数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subForumList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"sub";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSInteger row = [indexPath row];
    
	cell.textLabel.text = [self.subForumList objectAtIndex:row];
    
    if (cell != nil) {
        // 用何種字體進行顯示
        UIFont *font = [UIFont systemFontOfSize:14];
        // 設置自動換行(重要)
        cell.textLabel.numberOfLines = 0;
        // 設置顯示字體(一定要和之前計算時使用字體一至)
        cell.textLabel.font = font;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath row];
    NSLog(@"number is %d", index);
    //[self performSegueWithIdentifier:@"ShowDetail" sender:self];
    
    [self performSegueWithIdentifier:@"ShowArticleList" sender:self];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowDetail"])
    {
        DetailViewController *detailViewController = segue.destinationViewController;
        
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSDictionary *dict = [self.listData objectAtIndex:selectedIndex];
        
        //detailViewController.url = [dict objectForKey:@"url"];
        detailViewController.url = @"http://bmy.xjtu.edu.cn/zalist.php?board=XJTUnews&S=&j=1#n";
        
        NSString *name = [dict objectForKey:@"name"];
        detailViewController.title = name;
    } else if ([segue.identifier isEqualToString:@"ShowArticleList"])
    {
        ArticleListOfSameSubjectViewController *articleListOfSameSubjectViewController = segue.destinationViewController;
        
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSDictionary *dict = [self.listData objectAtIndex:selectedIndex];
        
        //detailViewController.url = [dict objectForKey:@"url"];
        articleListOfSameSubjectViewController.url = [self.subForumURLList objectAtIndex:selectedIndex];
        
        //articleListOfSameSubjectViewController.url = @"http://bmy.xjtu.edu.cn/zalist.php?board=XJTUnews&S=&j=1#n";

        
        NSString *name = [self.subForumList objectAtIndex:selectedIndex];
        articleListOfSameSubjectViewController.title = name;
    }

}



@end
