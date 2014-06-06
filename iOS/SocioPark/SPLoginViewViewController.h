//
//  SPLoginViewViewController.h
//  SocioPark
//
//  Created by Amit Wolfus on 1/19/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SPPlacesRetreiver.h"
@protocol SPLoginViewViewControllerDelegate;

@interface SPLoginViewViewController : UIViewController {
    id <SPLoginViewViewControllerDelegate> delegate_;
}

@property (assign, nonatomic) id<SPLoginViewViewControllerDelegate> delegate;
@property (assign, nonatomic) IBOutlet UILabel *loginLabel;

@end

@protocol SPLoginViewViewControllerDelegate <NSObject>

- (void)userDidLoginWithViewController:(SPLoginViewViewController *)controller;

@end