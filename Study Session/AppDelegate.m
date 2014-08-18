//
//  AppDelegate.m
//  Study Session
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "AppDelegate.h"
#import "WallViewController.h"
#import "LoginViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [Parse setApplicationId:@"eggJRLEMENAakXsnDYZMS5xVC0i32P9ZeLi57i8s"
                  clientKey:@"9JNS74soBu3Gkz5MTcVZmHZhMtyWzK7dcmMCy2Yc"];
    
    [PFTwitterUtils initializeWithConsumerKey:@"iV4HDt3vwy1C2l1GO9xb7J4U7"
                               consumerSecret:@"Hrl2E1aUVKiuP2Y8m02E2XLaV8140YXJ0BScXh8CYVa8YFvxbe"];
    
    PFACL *defaultACL = [PFACL ACL];

    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [FBLoginView class];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    if (application.applicationState != UIApplicationStateBackground)
    {

        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // If we have a cached user, we'll get it back here
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *wallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MapNavBar"];
        
		self.viewController = wallNavigationController;
		self.window.rootViewController = self.viewController;
    }
    else
    {
        [self presentLoginViewController];
    }


    return YES;
}

- (void)presentLoginViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

	LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navController.navigationBarHidden = YES;
    
	self.viewController = loginViewController;
	self.window.rootViewController = self.viewController;

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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
}

//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    if (error.code == 3010) {
//        NSLog(@"Push notifications are not supported in the iOS Simulator.");
//    } else {
//        // show some alert or otherwise handle the failure to register.
//        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
//	}
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (application.applicationState == UIApplicationStateInactive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//}

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}

@end
