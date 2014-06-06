//
//  SPCheckInView.h
//  SocioPark
//
//  Created by Amit Wolfus on 2/2/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <FacebookSDK/FacebookSDK.h>
#import "SPPlace.h"

@class SPCheckInView;

typedef void (^SPCheckInCompletionHander)(SPCheckInView *sender, BOOL wasDonePressed);

@interface SPCheckInView : UIView <UITextViewDelegate> {
    SPPlace *place_;
    SPCheckInCompletionHander completionHandler_;
}

@property (retain, nonatomic) SPPlace *place;
@property (copy, nonatomic) SPCheckInCompletionHander completionHandler;

+ (void)presentModallyFromViewController:(UIViewController *)viewController
                                forPlace:(SPPlace *)place
                             withSession:(FBSession *)session
                   withCompletionHandler:(SPCheckInCompletionHander)completionHandler;

@end
