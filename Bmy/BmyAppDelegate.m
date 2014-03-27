//
//  BmyAppDelegate.m
//  Bmy
//
//  Created by zl on 14-1-5.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import "BmyAppDelegate.h"

#import "RevealController.h"
#import "Top10ViewController.h"
#import "BmyViewController.h"

@implementation BmyAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
     //new
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *frontNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavTop10"];
    UINavigationController *rearNavigationContorller = [storyboard instantiateViewControllerWithIdentifier:@"NavBmy"];
	//BmyViewController *bmyViewController = [storyboard instantiateViewControllerWithIdentifier:@"BmyViewController"];
    
    NSLog(@"test");
    if (!frontNavigationController) {
        NSLog(@" navigationController == nil");
    }
    
    
    RevealController *revealController = [[RevealController alloc] initWithFrontViewController:frontNavigationController rearViewController:rearNavigationContorller];
    revealController.currentTitle = @"十大";
	self.viewController = revealController;
    self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
    
    
    /*
    Top10ViewController *top10ViewController = [[Top10ViewController alloc] initWithStyle:UITableViewStylePlain];
    BmyViewController *bmyViewController = [[BmyViewController alloc]initWithStyle:UITableViewStylePlain];
    
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:top10ViewController];
    UINavigationController *navigationController = self.window.rootViewController;
    
    RevealController *revealController = [[RevealController alloc] initWithFrontViewController:navigationController rearViewController:bmyViewController];
	self.viewController = revealController;
	
	//[navigationController release];
	//[frontViewController release];
	//[rearViewController release];
	//[revealController release];
	
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
    */
	return YES;

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
