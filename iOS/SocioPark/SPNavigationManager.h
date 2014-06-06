//
//  SPNavigationManager.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/22/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SPParking.h"
#import "SPPlace.h"

#define SPParkingIdentifierKey @"SPParkingIdentifierKey"
#define SPPlaceIdentifierKey @"SPPlaceIdentifierKey"
#define SPPlaceNameKey @"SPPlaceNameKey"

extern NSString *const MonitoringDateKey;

typedef enum SPNavigationApps {
    SPWazeApp,
    SPAppleApp,
} SPNavigationApps;

@interface SPNavigationManager : NSObject <CLLocationManagerDelegate>

- (BOOL)canLaunchApplication:(SPNavigationApps)application;

/**
 * Navigates to a coordinate using a different application
 * 
 * @param coordinate the coordinate to navigate to
 *
 * @param application the application to navigate with
 *
 * @param completionBlock the block that will be called when the user
 * reaches the desired coordinate, the callback is not guarnteed to be called
 */
- (void)navigateToCoordinate:(CLLocationCoordinate2D)coordinate
                    withName:(NSString *)placeName
             withApplication:(SPNavigationApps)application;

- (void)navigateToParking:(SPParking *)parking
                 forPlace:(SPPlace *)place
          withApplication:(SPNavigationApps)application;

- (void)requestPermissions;

+ (SPNavigationManager *)sharedInstance;

@end
