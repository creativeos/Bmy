//
//  MailDetailViewController.m
//  Bmy
//
//  Created by zl on 14-1-19.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "MailDetailViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"
#import "ReplyMailViewController.h"

@interface MailDetailViewController ()

@end

@implementation MailDetailViewController

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
    self.mailHtml = [[NSMutableString alloc]initWithCapacity:1024];
    self.webView.delegate = self;
    
    /*
    NSURL * url = [NSURL URLWithString: self.url];
    NSURLRequest * request2 = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request2];
    NSLog(@"finish did load url %@", url);
    */
    
    for (int i=0; i<10; i++) {
        if([self startRequest:self.url]) {
            break;
        }
    }
    //self.webView.userInteractionEnabled = NO;
    [self.webView loadHTMLString:self.mailHtml baseURL:nil];
    
}

-(BOOL)startRequest:(NSString *)mailURL
{
    NSURL *url = [NSURL URLWithString:mailURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error) {
        NSLog(@"error == nil");
        
        NSString * responseStr = [request responseString];
        
        NSArray *dividerSections = [responseStr componentsSeparatedByString:@"<div class=\"divider_line\"></div>"];
        NSString *bodyString = [dividerSections objectAtIndex:1];
        
        NSArray *sectionBlocks = [bodyString componentsSeparatedByString:@"<div class=\"section block_head\">"];
        
        [self.mailHtml appendString:@"<html><head></head><link rel=\"stylesheet\" href=\"http://bmy.xjtu.edu.cn/css/main.css\" type=\"text/css\"/><body>"];
        [self.mailHtml appendString:@"<div class=\"section block_head\">"];
        [self.mailHtml appendString:[sectionBlocks objectAtIndex:1]];
        [self.mailHtml appendString:@"</body></html>"];
        
        NSLog(@"mail : %@", self.mailHtml);
       
        HTMLParser *parser = [[HTMLParser alloc] initWithString:responseStr error:&error];
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode children];
            
        for (HTMLNode *node in inputNodes)
        {
            NSString *nodeClass = [node getAttributeNamed:@"class"];
            if ([nodeClass isEqualToString:@"small padtop"])
            {
                HTMLNode *replyNode = [node findChildWithAttribute:@"href" matchingName:@"hmail.php?" allowPartial:YES];
                if (replyNode) {
                    self.replyURL = [replyNode getAttributeNamed:@"href"];
                }
            }
        }
        return TRUE;
    }
    else
    {
        return FALSE;
    }
    return TRUE;
}

- (IBAction)replyButtonPressed:(id)sender
{
    NSArray *emailAddresseslist = [NSArray arrayWithObjects:
                      @"macbeth@example.com", @"ladymacbeth@example.com", @"duncan@example.com",
                      @"banquo@example.com", @"lennox@example.com", @"macduff@example.com", nil];
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if (controller == nil) {
        return;
    }
    
    
    controller.mailComposeDelegate = self;
    NSString *emailAddress = @"test-emailaddress";
    [controller setToRecipients:[NSArray arrayWithObject:emailAddress]];
    
    ReplyMailViewController *replyMailViewController = [[ReplyMailViewController alloc]init];
    if (replyMailViewController == nil) {
        return;
    }
    
    
    //[self presentModalViewController:replyMailViewController animated:YES];
    //[self presentModalViewController:controller animated:YES];
    [self performSegueWithIdentifier:@"ReplyMail" sender:self];
}
#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        
        
        [self testSuccessAlertView];
        NSLog(@"Mail sent successfully.");
    }
    else if (result == MFMailComposeResultFailed) {
        //NSLog(@"%@",controller)
        [self testFailAlertView];
        NSLog(@"Mail could not be sent: %@", [error description]);
    }
    [self dismissModalViewControllerAnimated:YES];
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
- (IBAction)testSuccessAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"通知"
                              message:@"登录成功"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ReplyMail"])
    {
        ReplyMailViewController *replyMailViewController = segue.destinationViewController;
        replyMailViewController.url = self.replyURL;
        replyMailViewController.replyPostURL = [replyMailViewController.url stringByReplacingOccurrencesOfString:@"hmail.php?" withString:@"nmail_do.php"];
        replyMailViewController.segueMailTitle = [[NSString alloc]initWithFormat:@"Re: %@", self.mailTitle];
        replyMailViewController.segueMailUserid = self.mailUserid;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.mutabledata appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"postData finished");
}


#pragma mark WebView 委托
#pragma mark --
- (void)webViewDidFinishLoad: (UIWebView *) webView {
	NSLog(@"finish");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"ERROR : %@", [error description]);
    [webView reload];
}


@end
