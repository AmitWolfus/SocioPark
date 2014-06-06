//
//  SPParking.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/8/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum SPParkingState{
    SPParkingEmpty = 0,
    SPParkingMedium = 1,
    SPParkingBusy = 2,
    SPParkingFull = 3,
} SPParkingState;

typedef double SPDistance;

@interface SPParking : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (copy) NSString *name;
@property (copy) NSString *streetName;
@property (copy) NSString *houseNumber;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) SPParkingState parkingState;
@property (assign, nonatomic) SPDistance distance;

@end
