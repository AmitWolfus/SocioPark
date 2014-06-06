//
//  SPParking.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/8/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPParking.h"

@implementation SPParking

@synthesize name = _name;
@synthesize streetName = _streetName;
@synthesize houseNumber = _houseNumber;
@synthesize parkingState = _parkingState;
@synthesize distance = _distance;
@synthesize coordinate = _coordinate;
@synthesize identifier = _identifier;

- (void)dealloc {
    [_name release];
    [_streetName release];
    [_houseNumber release];
    [_identifier release];
    [super dealloc];
}

@end
