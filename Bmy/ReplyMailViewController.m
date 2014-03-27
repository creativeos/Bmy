//
//  ReplyMailViewController.m
//  Bmy
//
//  Created by zl on 14-1-22.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "ReplyMailViewController.h"

@interface ReplyMailViewController ()

@end

@implementation ReplyMailViewController

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
    if (self.segueMailUserid) {
        self.mailReciever.text = self.segueMailUserid;
    }
    if (self.segueMailTitle) {
        self.mailTitle.text = self.segueMailTitle;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancleButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
    //[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendButtonPressed:(id)sender
{
    NSString *strURL = [[NSString alloc]initWithFormat:@"http://bmy.xjtu.edu.cn/%@", self.replyPostURL];
    //NSString *strURL = [[NSString alloc]initWithFormat:@"http://bmy.xjtu.edu.cn/nmail_do.php?f=M.1391396003.A&n=155"];
    
    NSURL *url = [NSURL URLWithString:strURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:self.mailTitle.text forKey:@"title"];
    [request setPostValue:self.mailReciever.text forKey:@"userid"];
    [request setPostValue:self.mailContent.text forKey:@"text"];
    [request setValidatesSecureCertificate:NO];
    
    NSLog(@"%@\n%@\n%@\n%@", strURL, self.mailTitle.text, self.mailReciever.text, self.mailContent.text);
    
    [request startSynchronous];
    NSLog(@"请求完成...");
    NSError *error = [request error];
    if (!error) {
        NSLog(@"error == nil");
        NSString * responseStr = [request responseString];
        NSLog(@"======================>%@", [responseStr substringWithRange:NSMakeRange(0, 1000)]);
        
        NSRange range = [responseStr rangeOfString:@"<span class=\"red small\">发送成功</span>"];
                         //could be a bug!
        if (range.location != NSNotFound) {
            NSLog(@"1");
            [self testSuccessAlertView];
        }
        else {
            NSLog(@"3");
            [self testFailAlertView];
        }   //以前不是可以匿名发文的吗
    }
    else {
        NSLog(@"error : %@", [error description]);
        [self testFailAlertView];
    }
}

- (IBAction)testFailAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"通知"
                              message:@"发送失败"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
}
- (IBAction)testSuccessAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"通知"
                              message:@"发送成功"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

@end
