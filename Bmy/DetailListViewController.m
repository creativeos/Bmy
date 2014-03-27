//
//  DetailListViewController.m
//  Bmy
//
//  Created by zl on 14-1-7.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "DetailListViewController.h"
#import "PostViewController.h"
#import "UserInfoViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface DetailListViewController ()
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f



@end

@implementation DetailListViewController

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

    self.selectedRow = -1;
    self.detailTitleList = [NSMutableArray arrayWithCapacity:15];
    self.detailList = [NSMutableArray arrayWithCapacity:15];
    self.detailReplyURLList = [NSMutableArray arrayWithCapacity:15];
    self.detailWebViewHtmlList = [NSMutableArray arrayWithCapacity:15];
    self.pageURLList = [NSMutableArray arrayWithCapacity:15];
    self.nextPageURL = nil;
    
    self.authorIdList = [NSMutableArray arrayWithCapacity:15];
    self.authorNameList = [NSMutableArray arrayWithCapacity:15];
    self.timeList = [NSMutableArray arrayWithCapacity:15];
    
    for (int i=0; i<10; i++) {
        if ([self retrAtricleDetail:self.url]) {
            break;
        }
    }
    if (self.detailList.count == 0) {
        [self testConnectionFailAlertView];
    }
    
    //[self parseHTML];
    [self setNeedsStatusBarAppearanceUpdate];
    //self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
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
        self.selectedRow = -1;
        [self.detailTitleList removeAllObjects];
        [self.detailList removeAllObjects];
        [self.detailReplyURLList removeAllObjects];
        [self.detailWebViewHtmlList removeAllObjects];
        
        [self.authorIdList removeAllObjects];
        [self.authorNameList removeAllObjects];
        [self.timeList removeAllObjects];
        
        for (int i=0; i<10; i++) {
            if ([self retrAtricleDetail:self.url]) {
                break;
            }
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

-(BOOL)retrAtricleDetail:(NSString *)retrURL
{
    NSLog(@"retr from url : %@", retrURL);
    NSURL *url = [NSURL URLWithString:retrURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error) {
        NSLog(@"error == nil");
        
        NSString * responseStr = [request responseString];
        //NSLog(@"======================>%@", [responseStr substringWithRange:NSMakeRange(0, 1000)]);
        
        //responseStr = [responseStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        //responseStr = [responseStr stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        
        NSArray *dividerSections = [responseStr componentsSeparatedByString:@"<div class=\"divider_line\"></div>"];
        NSString *bodyString = [dividerSections objectAtIndex:1];
        NSString *pageString = [dividerSections objectAtIndex:2];
        NSLog(@"pagestring : %@", pageString);
        // 获取下一页的链接
        BOOL hasNextPage =FALSE;
        NSMutableString *section_html = [[NSMutableString alloc]initWithCapacity:1024];
        [section_html appendString:@"<html><head></head><body>"];
        [section_html appendString:pageString];
        [section_html appendString:@"</body></html>"];
        NSLog(@"section_html: %@", section_html);
        HTMLParser *parser = [[HTMLParser alloc] initWithString:section_html error:&error];
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode children];
        for (HTMLNode *n in inputNodes) {
            NSArray *b = [n children];
            for (HTMLNode *subnode in b) {
                NSLog(@"subnode : %@",subnode.rawContents);
                if ([subnode.contents isEqualToString:@"下页"]) {
                    NSMutableString *nextPageURL = [[NSMutableString alloc]initWithCapacity:1024];
                    [nextPageURL appendString:@"http://bmy.xjtu.edu.cn/"];
                    [nextPageURL appendString:[subnode getAttributeNamed:@"href"]];
                    [self.pageURLList addObject:nextPageURL];
                    self.nextPageURL = nextPageURL;
                    hasNextPage = TRUE;
                    NSLog(@"next page url : %@", nextPageURL);
                    NSLog(@"count : %d", self.pageURLList.count);
                    break;
                }
            }
        }
        if (!hasNextPage) {
            self.nextPageURL = nil;
        }
        
        
        
        
        NSArray *sectionBlocks = [bodyString componentsSeparatedByString:@"<div class=\"section block_head\">"];
        for (int i=1; i<sectionBlocks.count; i++) {
            NSString *sectionContent = [sectionBlocks objectAtIndex:i];
            NSArray *contentBlocks = [sectionContent componentsSeparatedByString:@"</div>"];
            NSString *title = [contentBlocks objectAtIndex:0];
            [self.detailTitleList addObject:title];
            
            NSMutableString *section_html = [[NSMutableString alloc]initWithCapacity:1024];
            [section_html appendString:@"<html><head></head><body>"];
            [section_html appendString:@"<div class=\"section block_head\">"];
            [section_html appendString:title];
            [section_html appendString:@"</div>"];
            [section_html appendString:[contentBlocks objectAtIndex:1]];
            [section_html appendString:@"</body></html>"];
            [self.detailWebViewHtmlList addObject:section_html];
            
            
            HTMLParser *parser = [[HTMLParser alloc] initWithString:section_html error:&error];
            HTMLNode *bodyNode = [parser body];
            NSArray *inputNodes = [bodyNode children];
            
            NSLog(@"%@", bodyNode.contents);
            NSMutableString *detailContent = [[NSMutableString alloc]initWithCapacity:1024];
            for (HTMLNode *node in inputNodes)
            {
                //NSLog(@"content : %@", node.rawContents);
                if (node.nodetype == HTMLSpanNode)
                {
                    HTMLNode *authorNode = [node findChildWithAttribute:@"href" matchingName:@"friend.php?u=" allowPartial:YES];
                    NSArray *authorList = [[authorNode getAttributeNamed:@"href"] componentsSeparatedByString:@"="];
                    [self.authorIdList addObject: [authorList objectAtIndex:1]];
                    [self.authorNameList addObject:authorNode.contents];
                    
                    NSArray *spanChildrenNode = [node children];
                    HTMLNode *timeNode = [spanChildrenNode objectAtIndex:2];
                    [self.timeList addObject:timeNode.rawContents];
                    
                    HTMLNode *replayNode = [node findChildWithAttribute:@"href" matchingName:@"article.php?" allowPartial:YES];
                    if ([replayNode.contents isEqualToString:@"回复"]) {
                        [self.detailReplyURLList addObject:[replayNode getAttributeNamed:@"href"]];
                    }
                }
                else
                {
                    [detailContent appendString:node.rawContents];
                }
            }
            NSString *detail = [detailContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
            
            [self.detailList addObject:detail];
        }
        
    }
    else {
        /*
        for (int i=0; i<10; i++) {
            if([self retrAtricleDetail:retrURL])
            {
                break;
            }
        }
        */
        
        return FALSE;
    }
    return TRUE;

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
- (IBAction)addMoreButtonPressed:(id)sender
{
    NSLog(@"to load more");
    //[self retrAtricleDetail:[self.pageURLList objectAtIndex:(self.pageURLList.count-1)]];
    
    if (!self.nextPageURL) {
        [self.addMoreButton setAlpha:0];
        return ;
    }
    
    NSString *nextPageURL = [self.pageURLList objectAtIndex:(self.pageURLList.count-1)];
    NSLog(@"next page url : %@", nextPageURL);
    
    for (int i=0; i<10; i++) {
        if ([self retrAtricleDetail:nextPageURL]) {
            break;
        }
    }
    [self.tableView reloadData];
    NSLog(@"to load more end");

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
        if (!siteData) {
            NSLog(@"siteData == nil");
            return;
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
    
    if (1) {
        //html = [html stringByReplacingOccurrencesOfString:@"<a target=_blank href='http://bbs.xjtu.edu.cn" withString:@""];
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode children];
    
    NSLog(@"%@", bodyNode.contents);
    
    for (HTMLNode *node in inputNodes) {
        
        NSString *nodeClass = [node getAttributeNamed:@"class"];
        if ([nodeClass isEqualToString:@"section block_head"]) {
            [self.detailTitleList addObject:node.contents];
        } else {
            if (self.detailTitleList.count == 0) {
                continue;
            } else {
                if (node.nodetype == HTMLSpanNode) {
                    if ([nodeClass isEqualToString:@"small"]) {
                        HTMLNode *authorNode = [node findChildWithAttribute:@"href" matchingName:@"friend.php?u=" allowPartial:YES];
                        [self.authorNameList addObject:authorNode.contents];
                        NSLog(@"author : %@", authorNode.contents);
                       
                        int timeNodeIndex = 1;
                        
                        for (HTMLNode *cNode in node.children) {
                            NSLog(@"%@", cNode.rawContents);
                        }
                        HTMLNode *timeNode = [node.children objectAtIndex:timeNodeIndex];
                        
                        [self.timeList addObject:timeNode.rawContents];
                        NSLog(@"time : %@", timeNode.rawContents);
                    }
                } else if (! [nodeClass isEqualToString:@"h36"]) {
                    [self.detailList addObject:node.rawContents];
                } else if (node.nodetype == HTMLFontNode) {
                    NSArray *childNodes = [node children];
                    for (HTMLNode *cNode in childNodes) {
                        NSString *nodeClass = [node getAttributeNamed:@"class"];
                        if ([nodeClass isEqualToString:@"section block_head"]) {
                            [self.detailTitleList addObject:node.contents];
                        }
                        
                        
                        
                        
                        NSLog(@"%d", childNodes.count);
                        NSLog(@"%@\n\n", [cNode rawContents]);
                        
                        /*
                        HTMLNode *authorNode = [node findChildWithAttribute:@"href" matchingName:@"friend.php?u=" allowPartial:YES];
                        [self.authorList addObject:authorNode.contents];
                        NSLog(@"author : %@", authorNode.contents);
                        
                        HTMLNode *timeNode = [childNodes objectAtIndex:3];
                        [self.timeList addObject:timeNode.rawContents];
                        NSLog(@"time : %@", timeNode.rawContents);
                        
                        HTMLNode *detailNode = [childNodes objectAtIndex:5];
                        [self.detailList addObject:detailNode.rawContents];
                        NSLog(@"detail : %@", detailNode.rawContents);
                        */

                    }
                }
            }
            
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
    return [self.detailList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    NSMutableString *detail = [[NSMutableString alloc]initWithCapacity:2014];
    [detail appendString:[self.detailTitleList objectAtIndex:row]];
    [detail appendString:@"\n\n"];
    [detail appendString:[self.authorNameList objectAtIndex: row]];
    [detail appendString:@"\t"];
    [detail appendString:[self.timeList objectAtIndex:row]];
    [detail appendString:@"\n\n"];
    [detail appendString:[self.detailList objectAtIndex:row]];
    
    NSString *text = detail;
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 25000.0f);
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:FONT_SIZE] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize size = rect.size;
    
    
    CGFloat height = size.height + 20.0f;
    
    return height + (CELL_CONTENT_MARGIN * 2);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"detail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
	NSInteger row = [indexPath row];
    
    NSMutableString *detail = [[NSMutableString alloc]initWithCapacity:2014];
    [detail appendString:[self.detailTitleList objectAtIndex:row]];
    [detail appendString:@"\n\n"];
    [detail appendString:[self.authorNameList objectAtIndex: row]];
    [detail appendString:@"\n"];
    [detail appendString:[self.timeList objectAtIndex:row]];
    [detail appendString:@"\n\n"];
    [detail appendString:[self.detailList objectAtIndex:row]];
    
    
//    cell.textLabel.text = [self.detailList objectAtIndex:row];
    //cell.textLabel.text = detail;// [self.detailList objectAtIndex:row];
    
    
    UIWebView *shopWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0.0, 30.0, 320.0, 3320)];
    shopWebView.backgroundColor = [UIColor clearColor];
    shopWebView.opaque = NO;
    shopWebView.delegate = self;
    //禁止UIWebView拖动
    [(UIScrollView *)[[shopWebView subviews] objectAtIndex:0] setBounces:NO];
    //设置UIWebView是按 WebView自适应大小显示,还是按正文内容的大小来显示,YES:表示WebView自适应大小,NO:表示按正文内容的大小来显示
    [shopWebView setScalesPageToFit:NO];
    
    NSString *strURL = [[NSString alloc]initWithFormat:@"http://bmy.xjtu.edu.cn/"];
    NSURL *url = [NSURL URLWithString:strURL];
    
    [shopWebView loadHTMLString:[self.detailWebViewHtmlList objectAtIndex:row] baseURL:url];
    NSLog(@"%@", [self.detailWebViewHtmlList objectAtIndex:row]);
    shopWebView.userInteractionEnabled = NO;
    [cell.contentView addSubview:shopWebView];
    
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
    
    self.selectedRow = index;
    
    //[self performSegueWithIdentifier:@"ShowDetail" sender:self];
    //[self performSegueWithIdentifier:@"ShowDetailList" sender:self];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"回复"
                                  otherButtonTitles:@"查看作者",nil];//otherButtonTitles:@"查看作者",@"新浪微博",nil];
	
	actionSheet.actionSheetStyle =  UIActionSheetStyleAutomatic;
	[actionSheet showInView:self.view];
}

#pragma  mark-- 实现UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex = %i",buttonIndex);
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"ReplyArticle" sender:self];
    }
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"ShowUserInfo" sender:self];
    }
    
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"in the segue category : identifier = %@", segue.identifier);
    if([segue.identifier isEqualToString:@"ReplyArticle"])
    {
        PostViewController *postViewController = segue.destinationViewController;
        NSString *replyURL = [self.detailReplyURLList objectAtIndex:self.selectedRow];
        replyURL = [replyURL stringByReplacingOccurrencesOfString:@"harticle.php?" withString:@"harticle_do.php?"];
        
        //postViewController.postFormTitle = [self.detailTitleList objectAtIndex:self.selectedRow];
        postViewController.postFormTitle = [[NSString alloc]initWithFormat:@"Re: %@", [self.detailTitleList objectAtIndex:0]];
        postViewController.postFormURL = replyURL;
        
        //    postlViewController.url = [self.urlList objectAtIndex:selectedIndex];
    }
    if([segue.identifier isEqualToString:@"ShowUserInfo"])
    {
        UserInfoViewController *userInfoViewController = segue.destinationViewController;
    
        NSLog(@"author : %d", self.selectedRow);
        NSLog(@"author : %d,%@", self.selectedRow, [self.authorIdList objectAtIndex:self.selectedRow]);
        userInfoViewController.userid = [self.authorIdList objectAtIndex:self.selectedRow];
    }
}

/*
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, [UIColor color colorWithHexString:@"ffffff"].CGColor);
    CGContextStrokeRect(context, CGRectMake(5, -1, rect.size.width - 10, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"e2e2e2"].CGColor);
    CGContextStrokeRect(context, CGRectMake(5, rect.size.height, rect.size.width - 10, 1));
}*/


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xF1/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
}

@end
