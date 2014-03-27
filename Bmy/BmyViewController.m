//
//  BmyViewController.m
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "BmyViewController.h"
#import "RevealController.h"
#import "CategoryForumViewController.h"
#import "Top10ViewController.h"

@interface BmyViewController ()

@property (strong, nonatomic) UINavigationController *top10NavigationController;
@property (strong, nonatomic) UINavigationController *categoryForumNavigationController;
@property (strong, nonatomic) UINavigationController *favoriteForumNavigationController;
@property (strong, nonatomic) UINavigationController *messageNavigationController;
@property (strong, nonatomic) UINavigationController *loginNavigationController;
@property (strong, nonatomic) UINavigationController *userInfoNavigationController;

@end

@implementation BmyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"bmy" ofType:@"plist"];
    
    self.dictData = [[NSDictionary  alloc] initWithContentsOfFile:path];
    
    /*
     self.listData = [self.dictData allKeys];
    NSLog(@"%@", [self.listData objectAtIndex:0]);
    NSLog(@"%@", [self.listData objectAtIndex:1]);
    */
    
    self.listData = @[@"十大", @"分类讨论区",@"收藏", @"消息", @"登录"];
    self.title = @"兵马俑";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (self.top10NavigationController == nil) {
        RevealController *revealController = [self.parentViewController.parentViewController isKindOfClass:[RevealController class]] ? (RevealController *)self.parentViewController.parentViewController : nil;
        self.top10NavigationController = revealController.frontViewController;
        // [storyboard instantiateViewControllerWithIdentifier:@"NavTop10"];
    }
    if (self.categoryForumNavigationController == nil) {
        self.categoryForumNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavCategoryForum"];
    }
    if (self.favoriteForumNavigationController == nil) {
        self.favoriteForumNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavFavoriteForum"];
    }
    if (self.messageNavigationController == nil) {
        self.messageNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavMessage"];
    }
    if (self.loginNavigationController == nil) {
        self.loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavLogin"];
    }
    if (self.userInfoNavigationController == nil) {
        //self.userInfoNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavUserInfo"];
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
    return [self.listData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@" in the bmy controller \n .");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //if (cell==nil) {
    //    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //}
    NSLog(@" after dequeue \n");
    
	NSInteger row = [indexPath row];
    NSLog(@"%ld", (long)row);
	cell.textLabel.text = [self.listData objectAtIndex:row];
    NSLog(@"%@", cell.textLabel.text);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RevealController *revealController = [self.parentViewController.parentViewController isKindOfClass:[RevealController class]] ? (RevealController *)self.parentViewController.parentViewController : nil;
    
	NSInteger index = [indexPath row];
    NSString *title = [self.listData objectAtIndex:index];
    NSLog(@"select : %@", title);
    
    UINavigationController *frontNavigationController = revealController.frontViewController;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([title isEqualToString:@"十大"])
	{
        if (![revealController.frontViewController.title isEqualToString:title])
		{
            NSLog(@"front title : %@", revealController.frontViewController.title);
            //frontNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavTop10"];
            frontNavigationController = self.top10NavigationController;
        }
        [revealController setFrontViewController:frontNavigationController animated:NO];
	}
	else if ([title isEqualToString:@"分类讨论区"])
	{
		if (![revealController.frontViewController.title isEqualToString:title])
		{
            NSLog(@"front title : %@", revealController.frontViewController.title);
			//frontNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavCategoryForum"];
            frontNavigationController = self.categoryForumNavigationController;
		}
        [revealController setFrontViewController:frontNavigationController animated:NO];
	}
    else if ([title isEqualToString:@"收藏"])
    {
        if (![revealController.frontViewController.title isEqualToString:title])
		{
            NSLog(@"front title : %@", revealController.frontViewController.title);
			//frontNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavCategoryForum"];
            frontNavigationController = self.favoriteForumNavigationController;
		}
        [revealController setFrontViewController:frontNavigationController animated:NO];
    }
    else if ([title isEqualToString:@"消息"])
    {
        if (![revealController.frontViewController.title isEqualToString:title])
		{
            NSLog(@"front title : %@", revealController.frontViewController.title);
			//frontNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavCategoryForum"];
            frontNavigationController = self.messageNavigationController;
		}
        [revealController setFrontViewController:frontNavigationController animated:NO];
    }
    else if ([title isEqualToString:@"登录"])
    {
        if (![revealController.frontViewController.title isEqualToString:title])
		{
            NSLog(@"front title : %@", revealController.frontViewController.title);
			//frontNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavCategoryForum"];
            frontNavigationController = self.loginNavigationController;
		}
        [revealController setFrontViewController:frontNavigationController animated:NO];
    }
}

//选择表视图行时候触发
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"in the segue : identifier = %@", segue.identifier);
    if([segue.identifier isEqualToString:@"ShowCategoryForum"])
    {
        CategoryForumViewController *categoryForumViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSString *selectName = [self.listData objectAtIndex:selectedIndex];
        NSLog(@"in the segue : %ld", (long)selectedIndex);
        NSLog(@"in the segue : %@", selectName);
        
        categoryForumViewController.listData = [self.dictData objectForKey:selectName];
        categoryForumViewController.title = selectName;
    }
    if([segue.identifier isEqualToString:@"ShowTop10"])
    {
        Top10ViewController *top10ViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        NSString *selectName = [self.listData objectAtIndex:selectedIndex];
        NSLog(@"in the segue : %ld", (long)selectedIndex);
        NSLog(@"in the segue : %@", selectName);
        
        //top10ViewController.listData = [self.dictData objectForKey:selectName];
        top10ViewController.title = selectName;
    }
    
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.;
}
*/
@end
