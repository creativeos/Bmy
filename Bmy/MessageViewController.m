//
//  MessageViewController.m
//  Bmy
//
//  Created by zl on 14-1-15.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "MessageViewController.h"
#import "MailDetailViewController.h"
#import "ReplyMailViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface MessageViewController ()
// Private Properties:
@property (retain, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

// Private Methods:
- (IBAction)pushExample:(id)sender;
@end

@implementation MessageViewController

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
    self.mailList = [NSMutableArray arrayWithCapacity:15];
    self.authorList = [NSMutableArray arrayWithCapacity:15];
    self.urlList = [NSMutableArray arrayWithCapacity:15];
    
    for (int i=0; i<10; i++) {
        if ([self requestMail:@""]){
            break;
        };
    }
    
    //初始化UIRefreshControl
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
}

-(BOOL)requestMail:(NSString *)_url
{
    NSString *strURL = @"http://bmy.xjtu.edu.cn/maillist.php";
    NSURL *url = [NSURL URLWithString:strURL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request startSynchronous];
    NSLog(@"请求完成...");
    
    NSError *error = [request error];
    if (!error) {
        NSString * responseStr = [request responseString];
        NSLog(@"testIfLogined ======================>%@\n\n", responseStr);
        
        HTMLParser *parser = [[HTMLParser alloc] initWithString:responseStr error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
            return FALSE;
        }
        BOOL start = FALSE;
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode children];
        for (HTMLNode *node in inputNodes) {
            NSString *nodeClass = [node getAttributeNamed:@"class"];
            NSLog(@"class : %@", node.rawContents);
            if ([nodeClass isEqualToString:@"small padtop"])
            {
                start = TRUE;
                NSLog(@"%@", node.rawContents);
                NSArray *subNodes = [node findChildrenWithAttribute:@"href" matchingName:@"php?" allowPartial:YES];
                for (HTMLNode *subnode in subNodes) {
                    if ([[subnode getAttributeNamed:@"href"] rangeOfString:@"mail.php?"].location != NSNotFound) {
                        [self.mailList addObject:subnode.contents];
                        NSMutableString *mailURL = [[NSMutableString alloc]initWithCapacity:1024];
                        [mailURL appendString:@"http://bmy.xjtu.edu.cn/"];
                        [mailURL appendString:[subnode getAttributeNamed:@"href"]];
                        [self.urlList addObject:mailURL];
                    }
                    else if ([[subnode getAttributeNamed:@"href"] rangeOfString:@"friend.php?u="].location != NSNotFound) {
                        [self.authorList addObject:subnode.contents];
                    }
                }
            }
            else if ([nodeClass isEqualToString:@"divider_line"])
            {
                if (start) {
                    break;
                }
            }
        }
        return TRUE;
    }
    else {
        return FALSE;
    }
    return FALSE;

}

- (IBAction)testConnectionFailAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"通知"
                              message:@"连接失败,下拉刷新"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

-(void) refreshTableView
{
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"加载中..."];
        //添加新的模拟数据
        [self.mailList removeAllObjects];
        [self.authorList removeAllObjects];
        [self.urlList removeAllObjects];
        
        for (int i=0; i<10; i++) {
            if ([self requestMail:@""]){
                break;
            };
        }
        
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - 实现表视图数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count = %d", [self.mailList count]);
    return [self.mailList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"mail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSInteger row = [indexPath row];
    
    cell.textLabel.text = [self.mailList objectAtIndex:(row)];
    
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
    [self performSegueWithIdentifier:@"ShowMailDetail" sender:self];
}
- (IBAction)sendMailButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"NewMail" sender:self];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowMailDetail"])
    {
        MailDetailViewController *mailDetailViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        mailDetailViewController.url = [self.urlList objectAtIndex:selectedIndex];
        mailDetailViewController.mailTitle = [self.mailList objectAtIndex:selectedIndex];
        mailDetailViewController.mailUserid = [self.authorList objectAtIndex:selectedIndex];
    }
    if([segue.identifier isEqualToString:@"NewMail"])
    {
        ReplyMailViewController *maillViewController = segue.destinationViewController;
        maillViewController.replyPostURL = @"nmail_do.php";
    }
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.title = NSLocalizedString(@"消息", @"消息");
	
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
