//
//  SPAppDelegate.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/8/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPNavigationManager.h"
#import "SPPageInfoViewController.h"
#import <iAd/iAd.h>
#import "SPPlacesRetreiver.h"
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "GADRequest.h"
#import "SocioParkConsts.h"

@class SPPlacesViewController;
@class ASIdentifierManager;

@interface SPAppDelegate : UIResponder
    <UIApplicationDelegate, UINavigationControllerDelegate, ADBannerViewDelegate,
    GADBannerViewDelegate> {
    SPPageInfoViewController *rootViewController_;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (retain, nonatomic) SPPageInfoViewController *rootViewController;

@end
