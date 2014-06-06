//
//  SPPlacesViewController.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/16/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPlace.h"
#import "SPPlacesRetreiver.h"
#import <iAd/iAd.h>
#import "SPNavigationManager.h"
#import "SPLoginViewViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SocioParkConsts.h"

@protocol SPPlacesViewControllerDelegate;

@interface SPPlacesViewController : UIViewController <UISearchBarDelegate,
    UISearchDisplayDelegate,
    SPPlacesRetreiverDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    ADBannerViewDelegate,
    SPLoginViewViewControllerDelegate> {
        SPPlacesRetreiver *retreiver_;
        UITableView *tableView_;
        id<SPPlacesViewControllerDelegate> delegate_;
        UINavigationBar *navBar_;
}

@property (nonatomic, assign) IBOutlet UITableView *tableView;

@property (nonatomic, assign) IBOutlet UISearchBar *searchBar;

@property (nonatomic, assign) IBOutlet UINavigationBar *navBar;

@property (nonatomic, assign) id<SPPlacesViewControllerDelegate> delegate;

- (IBAction)cancelSearch:(id)sender;

- (void)showTutorial;

@end

@protocol SPPlacesViewControllerDelegate <NSObject>

- (void)viewController:(SPPlacesViewController *)viewController didSelectPlace:(SPPlace *)place;

- (void)viewControllerDidCancel:(SPPlacesViewController *)viewController;

@end
