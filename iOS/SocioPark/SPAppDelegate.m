//
//  SPAppDelegate.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/8/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPAppDelegate.h"



@implementation SPAppDelegate {
    ADBannerView *bannerView_;
    GADBannerView *adMobView_;
    BOOL isAdVisible_;
}

@synthesize rootViewController = rootViewController_;

- (void)dealloc
{
    adMobView_.delegate = nil;
    [adMobView_ release];
    [_window release];
    [_navController release];
    [rootViewController_ release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Set the root view controller to the page info view controller
    self.rootViewController =
        [[[SPPageInfoViewController alloc] initWithNibName:@"SPPlaceInfoViewController"
                                                  bundle:nil] autorelease];
    GADRequest *adRequest = [GADRequest request];
    adRequest.testDevices = [NSArray arrayWithObjects:@"58929DC4-99B6-4493-B239-D41D674F56F4", nil];
    adMobView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner
                                                origin:CGPointMake(0, self.window.frame.size.height)];
    adMobView_.delegate = self;
    adMobView_.adUnitID = @"a151116c571cefa";
    [adMobView_ setRootViewController:self.rootViewController];
    // Check if the user's gender is known
    NSString *genderString = [[NSUserDefaults standardUserDefaults] objectForKey:GenderKey];
    GADGender gender = kGADGenderUnknown;
    if ([genderString isEqualToString:GenderStringMale]) {
        gender = kGADGenderMale;
    }
    else if ([genderString isEqualToString:GenderStringFemale]) {
        gender = kGADGenderFemale;
    }
    adRequest.gender = gender;
    [adMobView_ loadRequest:adRequest];
    self.navController =
    [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    self.navController.delegate = self;
    [[self window] setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    // Check if the app launched from a notification
    UILocalNotification *arrivedNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (arrivedNotif) {
        // Get the destination and the parking from the notification
        NSString *placeId =
            [[arrivedNotif userInfo] objectForKey:SPPlaceIdentifierKey];
        NSString *parkingId =
            [[arrivedNotif userInfo] objectForKey:SPParkingIdentifierKey];
        NSString *placeName =
            [[arrivedNotif userInfo] objectForKey:SPPlaceNameKey];
        // Display the rating view
        [self.rootViewController displayRateForParking:parkingId
                                       atPlaceWithName:placeName
                                               placeId:placeId];
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSString *placeId =
        [[notification userInfo] objectForKey:SPPlaceIdentifierKey];
    NSString *parkingId =
    [[notification userInfo] objectForKey:SPParkingIdentifierKey];
    NSString *placeName =
        [[notification userInfo] objectForKey:SPPlaceNameKey];
    [self.rootViewController displayRateForParking:parkingId
                                   atPlaceWithName:placeName
                                           placeId:placeId];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [[SPSessionHolder sharedInstance].session handleOpenURL:url];
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
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SPSessionHolder sharedInstance].session close];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [viewController.view addSubview:adMobView_];
    [viewController.view bringSubviewToFront:adMobView_];
}

- (void)navigationController:(UINavigationController *)navigationController
       willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [adMobView_ removeFromSuperview];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
    // Get the delta between the bars
    CGFloat dy =
        [application statusBarFrame].size.height - oldStatusBarFrame.size.height;
    if (isAdVisible_) {
        [UIView beginAnimations:@"animatedMoveBanner" context:NULL];
    }
    adMobView_.frame = CGRectMake(0,
                                  adMobView_.frame.origin.y - dy,
                                  adMobView_.frame.size.width,
                                  adMobView_.frame.size.height);
    if (isAdVisible_) {
        [UIView commitAnimations];
    }
}

#pragma mark iAd implementations - NOT SUPPORTED IN ISRAEL HECNE NOT USED...

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!isAdVisible_) {
        NSLog(@"Showing ADBanner");
        [UIView beginAnimations:@"animatedAdBannerOn" context:NULL];
        bannerView_.frame = CGRectOffset(bannerView_.frame, 0, -92);
        [UIView commitAnimations];
        isAdVisible_ = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (isAdVisible_) {
        NSLog(@"Removing ADBanner");
        [UIView beginAnimations:@"aniamtedAdBannerOff" context:NULL];
        bannerView_.frame = CGRectOffset(bannerView_.frame, 0, 92);
        [UIView commitAnimations];
        isAdVisible_ = NO;
    }
}

#pragma mark GoogleAds implementation

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    if (!isAdVisible_) {
        [UIView beginAnimations:@"BannerSlide" context:nil];
        bannerView.frame = CGRectMake(0.0,
                                      self.navController.topViewController.view.frame.size.height -
                                      bannerView.frame.size.height,
                                      bannerView.frame.size.width,
                                      bannerView.frame.size.height);
        [UIView commitAnimations];
        isAdVisible_ = YES;
    }
}
- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
    if (isAdVisible_) {
        [UIView beginAnimations:@"BannerSlideOut" context:nil];
        bannerView.frame = CGRectMake(0.0,
                                      self.navController.topViewController.view.frame.size.height,
                                      bannerView.frame.size.width,
                                      bannerView.frame.size.height);
        [UIView commitAnimations];
        isAdVisible_ = NO;
    }
}
@end
