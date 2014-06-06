//
//  SPPlace.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/15/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum SPPlaceType{
    SPPlaceTypeFacebook
} SPPlaceType;

@interface SPPlace : NSObject {
    CLLocation *location_;
    NSString *identifier_;
    NSString *name_;
    NSString *address_;
}

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, assign) SPPlaceType placeType;

@end
