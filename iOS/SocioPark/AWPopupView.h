//
//  AWPopupView.h
//  SocioPark
//
//  Created by Amit Wolfus on 2/2/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class AWPopupView;

@protocol AWPopupViewDelegate <NSObject>

- (void)cancelWasPressed;

- (void)doneWasPressed;

@optional
/**
 * @discussion
 * Called when the popup is about to dismiss
 *
 * @param popup The popupView that sent the message
 *
 * @param done YES if the reason for dissmision is the press of the done button
 * and NO otherwise
 *
 * @return should the popup be dismissed
 */
- (BOOL)willDismissPopup:(AWPopupView *)popup doneWasPressed:(BOOL)done;
/**
 * @discussion
 * called after the popup is dismissed
 *
 * @param popup The popupView that was dismissed
 *
 * @param done YES if the reason for dissmision is the press of the done button
 * and NO otherwise
 */
- (void)didDismissPopUp:(AWPopupView *)popup doneWasPressed:(BOOL)done;

@end

@interface AWPopupView : UIView

@property (assign, nonatomic) id<AWPopupViewDelegate> delegate;

@property (retain, nonatomic) UIView *contentView;

@end
