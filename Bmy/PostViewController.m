//
//  PostViewController.m
//  Bmy
//
//  Created by zl on 14-1-29.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "PostViewController.h"
#import "HTMLParser.h"
#import "FDLabelView.h"
#import "TFHpple.h"

@interface PostViewController ()

@end

@implementation PostViewController

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
    NSLog(@"%@", self.postFormURL);
    if (self.postFormTitle) {
        self.postTitle.text = self.postFormTitle;
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
}
- (IBAction)saveButtonPressed:(id)sender
{
    NSArray *param = [self.postFormURL componentsSeparatedByString:@"&"];
    for (NSString *para in param) {
        NSRange range = [para rangeOfString:@"t="];
        if (range.location == 0) {
            self.postFormURL = [self.postFormURL stringByReplacingOccurrencesOfString:[[NSString alloc]initWithFormat:@"&%@", para] withString:@""];
            break;
        }
    }
    
    NSString *strURL = [[NSString alloc]initWithFormat:@"http://bmy.xjtu.edu.cn/%@", self.postFormURL];
    
    NSURL *url = [NSURL URLWithString:strURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:self.postTitle.text forKey:@"title"];
    [request setPostValue:self.content.text forKey:@"text"];
    
    NSLog(@"%@\n%@\n%@", strURL, self.postTitle.text, self.content.text);
    
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
            NSLog(@"2");
            [self testSuccessAlertView];
            //[self dismissViewControllerAnimated:YES completion:^{
                //code
            //}];
        }
        else {
            NSLog(@"3");
            [self testFailAlertView];
            NSLog(@"4");
        }//以前不是可以匿名发文的吗
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
