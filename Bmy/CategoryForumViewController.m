//
//  CategoryForumViewController.m
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "CategoryForumViewController.h"
#import "SubForumViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface CategoryForumViewController ()
// Private Properties:
@property (retain, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

// Private Methods:
- (IBAction)pushExample:(id)sender;
@end

@implementation CategoryForumViewController

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
    
    self.url = @"http://bmy.xjtu.edu.cn/";
    self.forumList = [NSMutableArray arrayWithCapacity:15];
    self.urlList = [NSMutableArray arrayWithCapacity:15];
    
    [self parseHTML];
    
    self.title = @"分类讨论区";
    
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
        NSStringEncoding asciiEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII);
        
        //NSString *title = @"title=";
        NSString *accesskey = @"accesskey";
        //NSData *titleData = [title dataUsingEncoding:NSASCIIStringEncoding];
        NSData *accesskeyData = [accesskey dataUsingEncoding:NSASCIIStringEncoding];
        
        //使用utf8解码网页
        NSMutableData *newSiteData = [[NSMutableData alloc] initWithCapacity:10240];
        
        //使用 ascii方式解码网页
        NSString *asciiHtml = [[NSString alloc] initWithData:siteData encoding:asciiEncode];
        NSArray *firstSplit = [asciiHtml componentsSeparatedByString:@"title="];
        NSLog(@"title split : %d", firstSplit.count);
        
        int p = 0;
        p = [[firstSplit objectAtIndex:0] length];
        
        [newSiteData appendData:[siteData subdataWithRange:NSMakeRange(0, p)]];
        
        NSLog(@"1 : %d", [[firstSplit objectAtIndex:0] length]);
        for (int i=1; i<firstSplit.count; i++) {
            p+=6; // title=
            
            NSString *subAsciiHtml = [firstSplit objectAtIndex:i];
            NSArray *secondSplit = [subAsciiHtml componentsSeparatedByString:@"accesskey"];
            
            p+=[[secondSplit objectAtIndex:0] length];
            
            [newSiteData appendData:accesskeyData];
            p+=9; //accesskey
            
            NSData *tmp3Data = [siteData subdataWithRange:NSMakeRange(p, [[secondSplit objectAtIndex:1] length])];
            [newSiteData appendData:tmp3Data];
            p += [[secondSplit objectAtIndex:1] length];
        }
        
        html = [[NSString alloc] initWithData: newSiteData encoding:utf8Encode];
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
        
        NSArray *boards = [node findChildrenWithAttribute:@"href" matchingName:@"board.php" allowPartial:YES];
        NSLog(@"children : %d", boards.count);
        for (HTMLNode *boardNode in boards) {
            if ([[boardNode getAttributeNamed:@"href"] isEqualToString:@"myboard.php?secstr=*"]) {
                continue;
            }
            NSLog(@"%@", boardNode.contents);
            [self.forumList addObject:boardNode.contents];
            NSMutableString *url = [[NSMutableString alloc]initWithCapacity:2014];
            [url appendString:self.url];
            [url appendString:@"/"];
            [url appendString:[boardNode getAttributeNamed:@"href"]];
            [self.urlList addObject:url];
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
    return [self.forumList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"category";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSInteger row = [indexPath row];
    
    /*
     NSDictionary *dict = [self.listData objectAtIndex:row];
    NSArray *list = [dict allKeys];
	cell.textLabel.text = [list objectAtIndex:0];
    */
    
    cell.textLabel.text = [self.forumList objectAtIndex:row];
    
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
    [self performSegueWithIdentifier:@"ShowSubForum" sender:self];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"in the segue category : identifier = %@", segue.identifier);
    /*if([segue.identifier isEqualToString:@"ShowSubForum"])
    {
        SubForumViewController *subForumViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSDictionary *dict = [self.listData objectAtIndex:selectedIndex];
        NSLog(@"test %@", dict);
        NSArray *list = [dict allKeys];
        NSString *selectName = [list objectAtIndex:0];
        
        
        NSLog(@"in the segue category : %ld", (long)selectedIndex);
        NSLog(@"in the segue category : %@", selectName);
        
        subForumViewController.listData = [dict objectForKey:selectName];;
        subForumViewController.title = selectName;
        NSLog(@"in the segue category : %@", selectName);
        NSLog(@"test list : %@", subForumViewController.listData);
        //if (![subForumViewController.listData objectAtIndex:0]) {
        //    NSLog(@"in the segue category : list data == nil");
        //}
    }*/
    if([segue.identifier isEqualToString:@"ShowSubForum"])
    {
        SubForumViewController *subForumViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSString *selectName = [self.forumList objectAtIndex:selectedIndex];
        
        NSLog(@"in the segue category : %ld", (long)selectedIndex);
        NSLog(@"in the segue category : %@", selectName);
        
        subForumViewController.url = [self.urlList objectAtIndex:selectedIndex];;
        subForumViewController.title = selectName;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.title = NSLocalizedString(@"分类讨论区", @"分类讨论区");
	
	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
	{
		// Check if a UIPanGestureRecognizer already sits atop our NavigationBar.
		if (![[self.navigationController.navigationBar gestureRecognizers] containsObject:self.navigationBarPanGestureRecognizer])
		{
			// If not, allocate one and add it.
			UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
			self.navigationBarPanGestureRecognizer = panGestureRecognizer;
			//[panGestureRecognizer release];
			
			[self.navigationController.navigationBar addGestureRecognizer:self.navigationBarPanGestureRecognizer];
		}
		
		// Check if we have a revealButton already.
		if (![self.navigationItem leftBarButtonItem])
		{
			// If not, allocate one and add it.
			UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"兵马俑", @"兵马俑") style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
			self.navigationItem.leftBarButtonItem = revealButton;
			//[revealButton release];
		}
	}
}




@end
