//
//  SPParkingView.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/14/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPParkingView.h"

@implementation SPParkingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
}


@end
