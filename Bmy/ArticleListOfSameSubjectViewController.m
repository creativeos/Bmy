//
//  ArticleListOfSameSubjectViewController.m
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "ArticleListOfSameSubjectViewController.h"
#import "DetailViewController.h"
#import "DetailListViewController.h"
#import "DetailWebViewTableViewController.h"
#import "PostViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface ArticleListOfSameSubjectViewController ()

@end

@implementation ArticleListOfSameSubjectViewController

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
    
    self.articleList = [NSMutableArray arrayWithCapacity:15];
    self.authorList = [NSMutableArray arrayWithCapacity:15];
    self.urlList = [NSMutableArray arrayWithCapacity:15];
    
    self.postArticleURL = [[NSString alloc]init];
    self.nextPageURL = [[NSString alloc]init];
    self.pageURLList = [NSMutableArray arrayWithCapacity:15];
    
    [self parseHTML:self.url];
    
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
        [self parseHTML:self.url];
        
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


- (BOOL)parseHTML:(NSString *)url_str {
    
    NSURL *url = [NSURL URLWithString:url_str];
    NSLog(@"url = %@",url);
    
    NSString *html;
    HTMLParser *parser;
    for (int i=0; i<10; i++) {
        //NSString *html  = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:NULL];//创建字符串将其设置为url的内容
        html  = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];//创建字符串将其设置为url的内容
        //NSASCIIStringEncoding error:nil];//创建字符串将其设置为url的内容
        
        //NSString *readmePath = [[NSBundle mainBundle] pathForResource:@"XJTUnews" ofType:@"htm"];
        //NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
        
        NSLog(@"html = %@",html);
        
        //NSString *html=[NSString stringWithContentsOfURL:[NSURL URLWithString:[_array objectAtIndex:0]] encoding:NSUTF8StringEncoding
        //*CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)*/error:nil];
        
        html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        NSError *error = nil;
        parser = [[HTMLParser alloc] initWithString:html error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
            //return FALSE;
        } else {
            break;
        }
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode children];
    
    self.nextPageURL = nil;
    for (HTMLNode *node in inputNodes)
    {
        /*
        if (![node getAttributeNamed:@"name"])
        {
            if ([[node getAttributeNamed:@"name"] isEqualToString:@"n"])
            {
                continue;
            }
        }*/
        
        NSString *nodeClass = [node getAttributeNamed:@"class"];
        if (!nodeClass) {
            //NSLog(@"Error: nodeClass == nil");
            continue;
        } else if ([nodeClass isEqual: @"small padtop"]) {
            NSLog(@"log: nodeClass == small padtop");
            
            HTMLNode * postArticleNode = [node findChildWithAttribute:@"href" matchingName:@"narticle.php?B=" allowPartial:YES];
            if (postArticleNode) {
                self.postArticleURL = [postArticleNode getAttributeNamed:@"href"];
                self.postArticleURL = [self.postArticleURL stringByReplacingOccurrencesOfString:@"narticle.php?" withString:@"narticle_do.php?"];
                NSLog(@"post url : %@", self.postArticleURL);
                continue;
            }
            
            HTMLNode *pageNode = [node findChildWithAttribute:@"href" matchingName:@"zalist.php?" allowPartial:YES];
            if ([pageNode.contents isEqualToString:@"上一页"]) {
                NSLog(@"\n\n\ntest----\n\n\n");
                [self.pageURLList addObject:[pageNode getAttributeNamed:@"href"]];
                self.nextPageURL = [pageNode getAttributeNamed:@"href"];
            }
            
            NSArray *childNodes = [node children];
            int hrefNodeCount = 0;
            
            if (childNodes.count >= 2) {
                NSLog(@"log: childNodes.count >= 2");
                for (HTMLNode *cNode in childNodes) {
                    if (cNode.nodetype == HTMLHrefNode) {
                        hrefNodeCount += 1;
                        //NSLog(@"href of <a> : %@", [cNode getAttributeNamed:@"href"]);
                    };
                }
                if (hrefNodeCount == 2) {
                    NSLog(@"hrefNodeCount == 2");
                    for (HTMLNode *cNode in childNodes) {
                        if (cNode.nodetype == HTMLHrefNode) {
                            NSString *articleURL = [cNode getAttributeNamed:@"href"];
                            if (articleURL) {
                                NSRange articleRange = [articleURL rangeOfString:@"zarticle.php?"];
                                NSRange authorRange = [articleURL rangeOfString:@"friend.php?u="];
                                if (articleRange.location != NSNotFound) {
                                    [self.articleList addObject:cNode.contents];
                                    NSMutableString *url = [[NSMutableString alloc]initWithCapacity:1024];
                                    [url appendString:@"http://bmy.xjtu.edu.cn/"];
                                    [url appendString:[cNode getAttributeNamed:@"href"]];
                                    [self.urlList addObject:url];
                                    
                                    NSLog(@"title : %@", cNode.contents);
                                    NSLog(@"href of <a> : %@", [cNode getAttributeNamed:@"href"]);
                                } else if (authorRange.location != NSNotFound){
                                    [self.authorList addObject:cNode.contents];
                                }
                            }
                            else{
                                NSLog(@"articleURL == nil");
                            }
                        };
                    }
                }
            } else {
                NSLog(@"child Node count = %d", childNodes.count);
                NSLog(@"child Node = %@", [node allContents ]);
            }
        } else {
            NSLog(@"log: nodeClass == %@", nodeClass);
        }
    }
    return TRUE;
}

- (IBAction)addMoreButtonPressed:(id)sender
{
    if (!self.nextPageURL) {
    //    [self.addMoreButton setAlpha:0];
        return ;
    }
    NSLog(@"test");
    NSMutableString *url_str = [[NSMutableString alloc]initWithCapacity:1024];
    [url_str appendString:@"http://bmy.xjtu.edu.cn/"];
    [url_str appendString:self.nextPageURL];
    for (int i=0; i<10; i++) {
        if ([self parseHTML:url_str]) {
            NSLog(@"test1");
            break;
        }
    }
    [self.tableView reloadData];
    NSLog(@"to load more end");
    
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
    
    static NSString *CellIdentifier = @"article";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    //[self performSegueWithIdentifier:@"ShowDetailListTable" sender:self];
}

- (IBAction)postButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"PostArticle" sender:self];
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"in the segue category : identifier = %@", segue.identifier);
    if([segue.identifier isEqualToString:@"ShowDetail"])
    {
        DetailViewController *detailViewController = segue.destinationViewController;
        
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSDictionary *dict = [self.listData objectAtIndex:selectedIndex];
        
        //detailViewController.url = [dict objectForKey:@"url"];
        //detailViewController.url = [self.urlList objectAtIndex:selectedIndex];
        detailViewController.url = [self.urlList objectAtIndex:selectedIndex]; //  @"http://bmy.xjtu.edu.cn/zarticle.php?board=XJTUnews&start=46512&th=1389080970&S=";
        //detailViewController.url =  @"http://bmy.xjtu.edu.cn";
        //detailViewController.url = @"http://bmy.xjtu.edu.cn/article.php?B=Picture&F=M.1388989055.A&S=";
        
        NSString *name = [dict objectForKey:@"name"];
        detailViewController.title = name;
    }
    if([segue.identifier isEqualToString:@"ShowDetailList"])
    {
        DetailListViewController *detailListViewController = segue.destinationViewController;
        
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSDictionary *dict = [self.listData objectAtIndex:selectedIndex];
        
        detailListViewController.url = [self.urlList objectAtIndex:selectedIndex]; //@"http://bmy.xjtu.edu.cn/zarticle.php?board=XJTUnews&start=46416&th=1389061781&S=";
        
        NSString *name = [dict objectForKey:@"name"];
        detailListViewController.title = name;
    }
    if([segue.identifier isEqualToString:@"ShowDetailListTable"])
    {
        DetailWebViewTableViewController *detailViewController = segue.destinationViewController;
        
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSDictionary *dict = [self.listData objectAtIndex:selectedIndex];
        
        detailViewController.url = [self.urlList objectAtIndex:selectedIndex];
        
        NSString *name = [self.articleList  objectAtIndex:selectedIndex];
        detailViewController.title = name;
    }
    if([segue.identifier isEqualToString:@"PostArticle"])
    {
        PostViewController *postlViewController = segue.destinationViewController;
        
        postlViewController.postFormURL = self.postArticleURL;
        
        NSLog(@"post url segue : %@", self.postArticleURL);
    //    postlViewController.url = [self.urlList objectAtIndex:selectedIndex];
    }
}


@end
