//
//  AWPopupViewController.h
//  SocioPark
//
//  Created by Amit Wolfus on 2/2/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AWPopupView.h"

@interface AWPopupViewController : UIViewController {
    CGRect _frame;
}

@property (readonly, nonatomic) CGRect frame;

- (void)initWithFrame:(CGRect)frame;

- (void)presentModallyFromViewController:(UIViewController *)viewController;

@end
