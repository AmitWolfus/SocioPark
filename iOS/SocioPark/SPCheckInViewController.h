//
//  SPCheckInViewController.h
//  SocioPark
//
//  Created by Amit Wolfus on 2/1/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/CALayer.h>

@interface SPCheckInViewController : FBViewController <FBViewControllerDelegate> {
    UITextView *message_;
}

@property (assign, nonatomic) IBOutlet UITextView *message;
/**
 * Holds the name of the place to check-in at.
 */
@property (copy, nonatomic) NSString *placeName;
/**
 * Holds the facebook id of the place
 */
@property (copy, nonatomic) NSString *placeId;

@end
