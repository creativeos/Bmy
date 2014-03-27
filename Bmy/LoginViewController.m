//
//  LoginViewController.m
//  Bmy
//
//  Created by zl on 14-1-14.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "RevealController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface LoginViewController ()
// Private Properties:
@property (retain, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

// Private Methods:
- (IBAction)pushExample:(id)sender;
@end

@implementation LoginViewController

- (IBAction)loginButton1Pressed:(id)sender
{
    NSString *username = self.username1.text;
    NSString *password = self.password1.text;
    
    if (username.length==0 || password.length==0 ) {
        return ;
    }
    
    NSLog(@"login pressed : username[%@],password=[%@]", username, password);
    
    [self startRequest];
}
- (IBAction)cancleButton1Pressed:(id)sender
{
    [self logout];
}

-(BOOL)logout
{
    NSString *strURL = @"http://bmy.xjtu.edu.cn/index.php?action=logout";
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error) {
        NSString * responseStr = [request responseString];
        NSLog(@"======================>%@", responseStr);
        
        
        [self.userInfoView setAlpha:0];
        [self.loginView setAlpha:1];
        [self.username1 resignFirstResponder];
        [self.password1 resignFirstResponder];
        return TRUE;
    }
    else {
        NSLog(@"error : %@", [error description]);
        [self testConnectionFailAlertView];
        return FALSE;
    }
    return TRUE;
}


-(BOOL)testIfLogined
{
    NSString *strURL = @"http://bmy.xjtu.edu.cn/index.php";
    NSURL *url = [NSURL URLWithString:strURL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request startSynchronous];
    NSLog(@"testIfLogined 请求完成...");
    
    NSError *error = [request error];
    if (!error) {
        NSLog(@" testIfLogined error == nil");
        NSString * responseStr = [request responseString];
        NSLog(@"testIfLogined ======================>%@\n\n", [responseStr substringWithRange:NSMakeRange(0, 1000)]);
        
        NSRange range = [responseStr rangeOfString:@"index.php?action=logout"];  //could be a bug!
        if (range.location != NSNotFound) {
            [self requestUserInfo];
            [self.userInfoView setAlpha:1];
        }
        else {
            [self.loginView setAlpha:1];
            [self.userInfoView setAlpha:0];
        }
        return TRUE;
    }
    else {
        //[self testConnectionFailAlertView];
        [self.loginView setAlpha:1];
        [self.userInfoView setAlpha:0];
        return FALSE;
    }
    return FALSE;
}

/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    NSString *strURL = @"http://bmy.xjtu.edu.cn/index.php";
    
	NSURL *url = [NSURL URLWithString:strURL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:self.username1.text forKey:@"id"];
    [request setPostValue:self.password1.text forKey:@"pw"];
    [request setPostValue:@"true" forKey:@"autologin"];
    
    [request startSynchronous];
    NSLog(@"请求完成...");
    
    NSError *error = [request error];
    
    if (!error) {
        NSLog(@"error == nil");

        
        NSString * responseStr = [request responseString];
        NSLog(@"======================>%@", [responseStr substringWithRange:NSMakeRange(0, 1000)]);
        
        NSRange range = [responseStr rangeOfString:@"index.php?action=logout"];  //could be a bug!
        if (range.location != NSNotFound) {
            NSLog(@"1");
            [self requestUserInfo];
            NSLog(@"2");
            [self.userInfoView setAlpha:1];
            [self.username1 resignFirstResponder];
            [self.password1 resignFirstResponder];
        }
        else {
            NSLog(@"3");
            [self testFailAlertView];
            NSLog(@"4");
            [self.userInfoView setAlpha:0];
        }
    }
    else {
        NSLog(@"error : %@", [error description]);
        [self testFailAlertView];
    }
}

/*
 * 开始请求Web Service
 */
-(BOOL)requestUserInfo
{
    NSString *strURL = [[NSString alloc]initWithFormat:@"http://bmy.xjtu.edu.cn/friend.php?u=liusm"];
    
	NSURL *url = [NSURL URLWithString:strURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request startSynchronous];
    NSError *error = [request error];
    
    if (!error) {
        NSLog(@"error == nil");
        
        NSString * responseStr = [request responseString];
        NSLog(@"======================>%@", [responseStr substringWithRange:NSMakeRange(0, 1000)]);
        
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        HTMLParser *parser = [[HTMLParser alloc] initWithString:responseStr error:&error];
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode children];
        NSMutableString *userInfo = [[NSMutableString alloc]initWithCapacity:1024];
        for (HTMLNode *node in inputNodes)
        {
            NSString *nodeClass = [node getAttributeNamed:@"class"];
            if ([nodeClass isEqualToString:@"small padtop"]) {
                for (HTMLNode *subNode in [node children]) {
                    if (subNode.nodetype == HTMLFontNode) {
                        [userInfo appendString:subNode.contents];
                    }
                    else {
                        [userInfo appendString:subNode.rawContents];
                    }
                }
                break;
            }
        }
        NSLog(@"\nuserinfo: %@\n\n", userInfo);
        //self.userInfoLabel.numberOfLines = 0;
        //[self.userInfoLabel sizeToFit];
        self.userInfoLabel.text = userInfo;
        
        
    }
    else {
        for (int i=0; i<10; i++) {
            if([self requestUserInfo])
            {
                break;
            }
        }
        //[self testConnectionFailAlertView];
        return FALSE;
        
    }
    return TRUE;
}

- (IBAction)testSuccessAlertView {
    //[self.loginView setAlpha:0];
    [self.userInfoView setAlpha:1];
    [self.username1 resignFirstResponder];
    [self.password1 resignFirstResponder];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowUserInfo"])
    {
        UserInfoViewController *userInfoViewController = segue.destinationViewController;
        userInfoViewController.username = self.username1.text;
    }
}

- (IBAction)testFailAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"通知"
                              message:@"登录失败"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
}
- (IBAction)testConnectionFailAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"通知"
                              message:@"连接失败"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.mutabledata appendData:data];
    NSLog(@"%@", data);
    NSStringEncoding utf8Encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSStringEncoding asciiEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII);
    NSString * html = [[NSString alloc] initWithData:self.mutabledata encoding:asciiEncode];
    NSLog(@"newSiteData : %@", html);

}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"postData finished");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    for (int i=0; i<10; i++) {
        if ([self testIfLogined]) {
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
	[super viewWillAppear:animated];
	
	self.title = NSLocalizedString(@"登录", @"登录");
	
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
