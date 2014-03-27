//
//  DetailViewController.m
//  TreeNavigationStoryborad
//
//  Created by 关东升 on 12-9-19.
//  本书网站：http://www.iosbook1.com
//  智捷iOS课堂：http://www.51work6.com
//  智捷iOS课堂在线课堂：http://v.51work6.com
//  智捷iOS课堂新浪微博：http://weibo.com/u/3215753973
//  作者微博：http://weibo.com/516inc
//  官方csdn博客：http://blog.csdn.net/tonny_guan
//  QQ：1575716557 邮箱：jylong06@163.com
//

#import "DetailViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    
    /*
     NSURL *aUrl = [NSURL URLWithString:@"http://bmy.xjtu.edu.cn/index.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = @"id=liusm&pw=890212&autologin=true";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView loadRequest:request];
    */
    
    //[self login];
    /*
    self.webViewHtml = [[NSMutableString alloc]initWithCapacity:10240];
    [self.webViewHtml appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title>交大兵马俑BBS(wap)</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><link rel=\"stylesheet\" href=\"css/main.css\" type=\"text/css\"/>"];
    [self.webViewHtml appendString:[self requestHTML:self.url]];
    
    
    
    [self.webView loadHTMLString:self.webViewHtml baseURL:self.url];
    */
    
    NSURL * url = [NSURL URLWithString: self.url];
	 NSURLRequest * request2 = [NSURLRequest requestWithURL:url];
     [self.webView loadRequest:request2];
     NSLog(@"finish did load url %@", url);
    /*
    NSString *html;
    for (int i=0; i<10; i++) {
        html  = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];//创建字符串将其设置为url的内容
        if (html == nil) {
            continue;
        }
    }
    [self.webView loadHTMLString:html baseURL:self.url];
*/
}

-(NSString *)requestHTML:(NSString *)suburl{
    NSURL * url = [NSURL URLWithString: suburl];
	/*NSURLRequest * request2 = [NSURLRequest requestWithURL:url];
     [self.webView loadRequest:request2];
     NSLog(@"finish did load url %@", url);
     */
    
    NSString *html;
    for (int i=0; i<10; i++) {
        html  = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];//创建字符串将其设置为url的内容
        if (html == nil) {
            continue;
        }
    }
    NSMutableString *contentHtml = [[NSMutableString alloc]initWithCapacity:1024];
    
    NSArray *headArray = [html componentsSeparatedByString:@"<body>"];
    
    [contentHtml appendString:[headArray objectAtIndex:0]];
    [contentHtml appendString:@"<body>"];
    
    NSArray *contentArray = [[headArray objectAtIndex:1] componentsSeparatedByString:@"<div class=\"divider_line\"></div>"];
    
    [contentHtml appendString:[contentArray objectAtIndex:1]];
    [contentHtml appendString:@"<div class=\"divider_line\"></div>"];
    [contentHtml appendString:[contentArray objectAtIndex:2]];
    [contentHtml appendString:@"</font></font></body><br><br><br><br><br><br><br></html>"];
    
    return contentHtml;
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
