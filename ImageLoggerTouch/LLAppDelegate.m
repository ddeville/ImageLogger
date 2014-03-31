//
//  LLAppDelegate.m
//  ImageLoggerTouch
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLAppDelegate.h"

@implementation LLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setBackgroundColor:[UIColor whiteColor]];
	[self setWindow:window];
	
	UIViewController *viewController = [[UIViewController alloc] init];
	[window setRootViewController:viewController];
	
	[window makeKeyAndVisible];
	
	return YES;
}

@end
