//
//  AWPopupView.m
//  SocioPark
//
//  Created by Amit Wolfus on 2/2/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import "AWPopupView.h"

@implementation AWPopupView {
    UINavigationItem *navItem_;
    UIView *contentView_;
}

@synthesize delegate = _delegate;
@synthesize contentView = contentView_;

- (void)setContentView:(UIView *)contentView {

    [contentView_ removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10;
        CGRect navFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 20);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navFrame];
        [self addSubview:[navBar autorelease]];
        navItem_ = [[UINavigationItem alloc] initWithTitle:@""];
        navItem_.leftBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                           target:self
                                                           action:@selector(cancelWasPressed:)] autorelease];
        navItem_.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                           target:self
                                                           action:@selector(doneWasPressed:)] autorelease];
        [navBar pushNavigationItem:[navItem_ autorelease] animated:NO];
    }
    return self;
}

- (void)cancelWasPressed:(id)sender {
    [self.delegate cancelWasPressed];
}

- (void)doneWasPressed:(id)sender {
    [self.delegate doneWasPressed];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
