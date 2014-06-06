//
//  SPCheckInView.m
//  SocioPark
//
//  Created by Amit Wolfus on 2/2/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import "SPCheckInView.h"

@interface SPLinedTextView : UITextView

@end

@implementation SPLinedTextView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[[UIColor blackColor] colorWithAlphaComponent:0.3] setStroke];
    CGContextSetLineWidth(context, 1);
    
    CGFloat lineLength = self.frame.size.width + self.frame.origin.x;
    
    CGFloat rowHeight = self.font.lineHeight;
    if (rowHeight > 0) {
        for (CGFloat lineY =  rowHeight + 7; lineY < self.frame.size.height + self.contentSize.height; lineY += rowHeight) {
            CGContextMoveToPoint(context, self.frame.origin.x, lineY);
            CGContextAddLineToPoint(context, lineLength, lineY);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}

@end

@implementation SPCheckInView {
    UITextView *message_;
    UINavigationBar *navBar_;
    UIView *maskView_;
    UIBarButtonItem *doneButton_;
    UIBarButtonItem *cancelButton_;
    FBFriendPickerViewController *friendPicker_;
}

@synthesize place = place_;
@synthesize completionHandler = completionHandler_;

- (void)setPlace:(SPPlace *)place {
    [place_ release];
    if (place) {
        place_ = [place retain];
        navBar_.topItem.title = place_.name == nil ? @"Facebook" : place_.name;
    }
    else {
        navBar_.topItem.title = @"Facebook";
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        place_ = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        // Create the upper bar
        CGRect barFrame = CGRectMake(frame.origin.x - 5, frame.origin.y - 20, frame.size.width, frame.size.height / 4);
        navBar_ = [[UINavigationBar alloc] initWithFrame:barFrame];
        [self addSubview:[navBar_ autorelease]];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Facebook"];
        [navBar_ pushNavigationItem:[navItem autorelease] animated:NO];
        doneButton_ =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(doneWasPressed:)];
        [doneButton_ setEnabled:NO];
        cancelButton_ =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                          target:self
                                                          action:@selector(dismiss:)];
        navItem.rightBarButtonItem = [doneButton_ autorelease];
        navItem.leftBarButtonItem = [cancelButton_ autorelease];
        // Create and place the message text view
        CGRect messageFrame = CGRectMake(frame.origin.x - 5,
                                         frame.origin.y + (frame.size.height / 4) - 20,
                                         frame.size.width,
                                         (frame.size.height / 8) * 5);
        message_ = [[SPLinedTextView alloc] initWithFrame:messageFrame];
        message_.font = [message_.font fontWithSize:16];
        [self addSubview:[message_ autorelease]];
        // Create the tag friends button
        
    }
    return self;
}

- (void)dealloc {
    [place_ release];
    [completionHandler_ release];
    [super dealloc];
}

- (IBAction)doneWasPressed:(id)sender {
    [self dismiss:sender];
}

- (void)presentModallyFromViewController:(UIViewController *)viewController {
    CGRect maskFrame = CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.bounds.size.height);
    maskView_ = [[UIView alloc] initWithFrame:maskFrame];
    UITapGestureRecognizer *singleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [maskView_ addGestureRecognizer:[singleTap autorelease]];
    [maskView_ setBackgroundColor:[UIColor darkGrayColor]];
    [maskView_ setAlpha:0.7];
    [viewController.view addSubview:maskView_];
    [viewController.view bringSubviewToFront:maskView_];
    [viewController.view addSubview:self];
    [viewController.view bringSubviewToFront:self];
    // Bounce in the view
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.duration = 0.7;
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double value = 0;
    float e = 2.71;
    for (int t = 0; t < steps; t++) {
        value = 320 * pow(e, -0.055*t) * cos(0.08*t) + 110;
        [values addObject:[NSNumber numberWithFloat:value]];
    }
    animation.values = values;
    [self.layer setValue:[NSNumber numberWithInt:110] forKeyPath:animation.keyPath];
    [self.layer addAnimation:animation forKey:nil];
    message_.delegate = self;
    [message_ becomeFirstResponder];
}

- (void)dismiss:(id)sender {
    [message_ endEditing:YES];
    [maskView_ removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
            self.center = CGPointMake(self.center.x, self.superview.frame.size.height + self.center.y);
    } completion:^(BOOL finished) {
        BOOL wasDonePressed = sender == doneButton_;
        if (completionHandler_) {
            completionHandler_(self, wasDonePressed);
        }
        [self removeFromSuperview];
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text && textView.text.length > 0 && !doneButton_.enabled) {
        doneButton_.enabled = YES;
    }
    else if ((!textView.text || textView.text.length == 0) && doneButton_.enabled) {
        doneButton_.enabled = NO;
    }
}

+ (void)presentModallyFromViewController:(UIViewController *)viewController
                                forPlace:(SPPlace *)place
                             withSession:(FBSession *)session
                   withCompletionHandler:(SPCheckInCompletionHander)completionHandler {
    // Create the check in view at the bottom of the viewController's view
    CGRect checkInFrame = CGRectMake(viewController.view.frame.origin.x + 5,
                                     viewController.view.frame.origin.y,
                                     viewController.view.frame.size.width - 10,
                                     (viewController.view.frame.size.height / 12) * 5);
    SPCheckInView *checkInView = [[SPCheckInView alloc] initWithFrame:checkInFrame];
    checkInView.place = place;
    checkInView.completionHandler = completionHandler;
    [checkInView presentModallyFromViewController:viewController];
    [checkInView release];
}

@end
