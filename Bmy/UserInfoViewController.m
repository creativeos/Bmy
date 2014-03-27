//
//  UserInfoViewController.m
//  Bmy
//
//  Created by zl on 14-1-18.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ReplyMailViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

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

    for (int i=0; i<10; i++) {
        if ([self requestUserInfo:self.userid]){
            break;
        }
    }
    
}

- (IBAction)logoutPressed:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)sendMailButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"SendMail" sender:self];
}
//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SendMail"])
    {
        ReplyMailViewController *mailViewController = segue.destinationViewController;
        mailViewController.segueMailUserid = self.userid;
        mailViewController.replyPostURL = @"nmail_do.php";
    }
}

/*
 * 开始请求Web Service
 */
-(BOOL)requestUserInfo:(NSString *)userid
{
    NSString *strURL = [[NSString alloc]initWithFormat:@"http://bmy.xjtu.edu.cn/friend.php?u=%@", userid];
    
	NSURL *url = [NSURL URLWithString:strURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request startSynchronous];
    NSError *error = [request error];
    
    if (!error) {
        NSLog(@"error == nil");
        
        NSString * responseStr = [request responseString];
        
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
                        if (subNode.contents) {
                            [userInfo appendString:subNode.contents];
                        }
                    }
                    else {
                        [userInfo appendString:subNode.rawContents];
                    }
                }
                break;
            }
        }
        NSLog(@"\nuserinfo: %@\n\n", userInfo);
        self.userInfo.text = userInfo;
    }
    else {
        return FALSE;
    }
    return TRUE;
}

@end
