//
//  Top10ViewController.m
//  Bmy
//
//  Created by zl on 14-1-10.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "Top10ViewController.h"
#import "DetailListViewController.h"
#import "DetailViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface Top10ViewController ()
// Private Properties:
@property (retain, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

// Private Methods:
- (IBAction)pushExample:(id)sender;
@end

@implementation Top10ViewController

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
    
    self.articleList = [NSMutableArray arrayWithCapacity:15];
    self.authorList = [NSMutableArray arrayWithCapacity:15];
    self.urlList = [NSMutableArray arrayWithCapacity:15];
    
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
        [self.articleList removeAllObjects];
        [self.authorList removeAllObjects];
        [self.urlList removeAllObjects];
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
        //NSMutableData *siteData = [[NSMutableData alloc] initWithContentsOfURL:url];
        NSData *siteData = [[NSData alloc] initWithContentsOfURL:url];
        NSLog(@"after request.");
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
    
    NSLog(@"%@", bodyNode.contents);
    
    for (HTMLNode *node in inputNodes) {
        
        HTMLNode *articleNode = [node findChildWithAttribute:@"accesskey" matchingName:@"" allowPartial:YES];
        if (!articleNode) {
            continue;
        }
        
        [self.articleList addObject:articleNode.contents];
        NSMutableString *articleURL = [[NSMutableString alloc]initWithCapacity:1024];
        [articleURL appendString:self.url];
        [articleURL appendString:[articleNode getAttributeNamed:@"href"]];
        NSMutableString *zarticleURL = [[NSMutableString alloc]initWithCapacity:1024];
        [zarticleURL appendString:self.url];
        [zarticleURL appendString:[self parseZarticleURL:articleURL]];
        [self.urlList addObject:zarticleURL];
        NSLog(@"url : %@", zarticleURL);
        NSLog(@"title : %@", articleNode.contents);
    }
}


- (NSString *)parseZarticleURL : (NSString *) srcURL {
    
    NSURL *url = [NSURL URLWithString:srcURL];
    NSLog(@"url to get zaritcle URL = %@",url);
    
    NSString *html;
    HTMLParser *parser;
    for (int i=0; i<1; i++) {
        
        html  = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];//创建字符串将其设置为url的内容
        
        if (!html) {
            NSLog(@" html == nil");
            continue;
        }
    
        html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        //NSLog(@"html = %@",html);
        
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
    
    NSLog(@"%@", bodyNode.contents);
    
    for (HTMLNode *node in inputNodes) {
        
        NSString * className = [node getAttributeNamed:@"class"];
        if (![className isEqualToString:@"section small"]) {
            continue;
        }
        
        /*HTMLNode *articleNode = [node findChildWithAttribute:@"class" matchingName:@"section small" allowPartial:NO];
        if (!articleNode) {
            continue;
        }*/
        
        HTMLNode *sameSubjectNode = [node findChildWithAttribute:@"href" matchingName:@"zarticle.php?" allowPartial:YES];
        if (!sameSubjectNode) {
            NSLog(@"sameSubjectNode = nil");
            return nil;
        }
        
        return [sameSubjectNode getAttributeNamed:@"href"];
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 实现表视图数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articleList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"top10";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	NSInteger row = [indexPath row];
    
    cell.textLabel.text = [self.articleList objectAtIndex:row];
    
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
    [self performSegueWithIdentifier:@"ShowDetailList" sender:self];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"in the segue category : identifier = %@", segue.identifier);
    if([segue.identifier isEqualToString:@"ShowDetail"])
    {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        detailViewController.url = [self.urlList objectAtIndex:selectedIndex];
        NSString *name = [self.articleList objectAtIndex:selectedIndex];
        detailViewController.title = name;
    }
    if([segue.identifier isEqualToString:@"ShowDetailList"])
    {
        DetailListViewController *detailListViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        detailListViewController.url = [self.urlList objectAtIndex:selectedIndex];
        NSString *name = [self.articleList objectAtIndex:selectedIndex];
        detailListViewController.title = name;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.title = NSLocalizedString(@"十大", @"十大");
	
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Example Code

- (void)pushExample:(id)sender
{
	UIViewController *stubController = [[UIViewController alloc] init];
	stubController.view.backgroundColor = [UIColor whiteColor];
	[self.navigationController pushViewController:stubController animated:YES];
	//[stubController release];
}

@end
