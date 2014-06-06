//
//  SPRateParkingViewController.h
//  SocioPark
//
//  Created by Amit Wolfus on 2/1/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SPParking.h"
#import "SPParkingsRetreiver.h"
#import "SPCheckInViewController.h"
#import "SPCheckInView.h"

@protocol SPRateParkingViewControllerDelegate;

@interface SPRateParkingViewController : UIViewController {
    UIButton *emptyStateButton_;
    UIButton *mediumStateButton_;
    UIButton *busyStateButton_;
    UIButton *fullStateButton_;
    UIButton *skipButton_;
    UILabel *rateLabel_;
    NSString *parkingId_;
    id<SPRateParkingViewControllerDelegate> delegate_;
}

@property (assign, nonatomic) IBOutlet UIButton *emptyStateButton;
@property (assign, nonatomic) IBOutlet UIButton *mediumStateButton;
@property (assign, nonatomic) IBOutlet UIButton *busyStateButton;
@property (assign, nonatomic) IBOutlet UIButton *fullStateButton;
@property (assign, nonatomic) IBOutlet UIButton *skipButton;
@property (assign, nonatomic) IBOutlet UILabel *rateLabel;
/**
 * Holds the id of the parking that the view controller reports its state
 */
@property (copy, nonatomic) NSString *parkingId;
@property (assign, nonatomic) id<SPRateParkingViewControllerDelegate> delegate;
/**
 * If the user will choose to check-in, this will be used as the place 
 * for the check-in
 */
@property (retain, nonatomic) NSString *placeName;
/**
 * The facebook id of the arrived place, this will be used for checking-in
 */
@property (retain, nonatomic) NSString *placeId;
/**
 * Occurs when one of the state buttons is pressed and
 * reports the selected state to the parkings server
 */
- (IBAction)rateParking:(id)sender;

/**
 * Occurs when the user presses the skip button and skips the rating
 */
- (IBAction)skip:(id)sender;
/**
 * Displays the facebook check-in dialog
 */
- (IBAction)checkin:(id)sender;

@end

@protocol SPRateParkingViewControllerDelegate <NSObject>

/**
 * Called when the view controller whishes to be closed like when the user rates
 * the parking or clicks the skip button
 */
- (void)viewControllerDidFinishRating:(SPRateParkingViewController *)viewController;

@end