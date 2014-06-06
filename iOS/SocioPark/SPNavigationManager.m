//
//  SPNavigationManager.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/22/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPNavigationManager.h"

#define DetectionRadius 30
#define MaxTimeInterval 7200

NSString *const MonitoringDateKey = @"MonitoringDateKey";

@implementation SPNavigationManager {
    CLLocationManager *locationManager_;
}

- (id)init {
    if (self = [super init]) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [locationManager_ release];
    [super dealloc];
}

- (void)removeAllMonitoredRegions {
    // Remove all monitored regions with the sociopark identifier
    [locationManager_ stopMonitoringSignificantLocationChanges];
    for (CLRegion *region in [[locationManager_ monitoredRegions] allObjects]) {
        if ([region.identifier compare:@"SocioPark"] == NSOrderedSame) {
            [locationManager_ stopMonitoringForRegion:region];
        }
    }
}

- (BOOL)canLaunchApplication:(SPNavigationApps)application {
    switch (application) {
        case SPWazeApp: {
            return [[UIApplication sharedApplication]
                        canOpenURL:[NSURL URLWithString:@"waze://"]];
        }
        case SPAppleApp: {
            return YES;
        }
        default: {
            NSLog(@"canLaunchApplication(SPNavigationApps) received a non existing app");
            return NO;
        }
    }
}

+ (SPNavigationManager *)sharedInstance {
    static SPNavigationManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SPNavigationManager alloc] init];
    });
    return sharedInstance;
}

+ (void)navigateWazeToCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *urlStr =
    [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes",
     coordinate.latitude, coordinate.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

+ (void)navigateAppleMapsToCoordinate:(CLLocationCoordinate2D)coordinate
                             withName:(NSString *)placeName{
    // Create an MKMapItem to pass to the Maps app
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:placeName];
    // Pass the map item to the Maps app
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)requestPermissions {
    // Check if there is any reason to ask for permission
    if ([CLLocationManager regionMonitoringAvailable]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            // Create a fake region
            CLRegion *region =
                [[CLRegion alloc]
                    initCircularRegionWithCenter:CLLocationCoordinate2DMake(0, 0)
                                          radius:DetectionRadius
                                      identifier:@"FakeRegion"];
            // Register the region for monitoring to prompt the user
            // for permission
            [locationManager_ startMonitoringForRegion:region];
            // Remove the fake region from the monitoring
            [locationManager_ stopMonitoringForRegion:region];
            [region release];
        }
    }
}

- (void)navigateToCoordinate:(CLLocationCoordinate2D)coordinate
                    withName:(NSString *)placeName
             withApplication:(SPNavigationApps)application {
    // Check if region monitoring is available
    if ([CLLocationManager regionMonitoringAvailable]) {
        // Check if the app has the right permissions
        if ([CLLocationManager authorizationStatus] ==
                kCLAuthorizationStatusNotDetermined ||
            [CLLocationManager authorizationStatus] ==
                kCLAuthorizationStatusAuthorized) {
            CLRegion *region =
            [[CLRegion alloc] initCircularRegionWithCenter:coordinate
                                                    radius:500
                                                identifier:@"SocioPark"];
            [locationManager_ startMonitoringForRegion:region];
            [locationManager_ startMonitoringSignificantLocationChanges];
        }
    }
    // launch the navigation app
    switch (application) {
        case SPWazeApp: {
            [SPNavigationManager navigateWazeToCoordinate:coordinate];
            break;
        }
        case SPAppleApp: {
            [SPNavigationManager navigateAppleMapsToCoordinate:coordinate
                                                      withName:placeName];
            break;
        }
        default: {
            NSLog(@"Tried to navigate with a non existing application");
            [self removeAllMonitoredRegions];
        }
    }
}

- (void)navigateToParking:(SPParking *)parking
                 forPlace:(SPPlace *)place
          withApplication:(SPNavigationApps)application {
    // Make sure that the device can navigate with said applicaiton
    if (![self canLaunchApplication:application]) {
        NSLog(@"An attempt to navigate with a non existent app occured");
        return;
    }
    // Save the place and parking identifier for future user
    [[NSUserDefaults standardUserDefaults] setObject:[[place.identifier copy] autorelease]
                                              forKey:SPPlaceIdentifierKey];
    [[NSUserDefaults standardUserDefaults] setObject:parking.identifier
                                              forKey:SPParkingIdentifierKey];
    [[NSUserDefaults standardUserDefaults] setObject:place.name
                                              forKey:SPPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:MonitoringDateKey];
    [self removeAllMonitoredRegions];
    [self navigateToCoordinate:parking.coordinate
                      withName:parking.name
               withApplication:application];
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    [manager stopMonitoringForRegion:region];
    [manager stopMonitoringSignificantLocationChanges];
    // Read the id of the navigated parking and place
    NSString *placeId =
        [[NSUserDefaults standardUserDefaults] objectForKey:SPPlaceIdentifierKey];
    NSString *parkingId =
        [[NSUserDefaults standardUserDefaults] objectForKey:SPParkingIdentifierKey];
    NSString *placeName =
        [[NSUserDefaults standardUserDefaults] objectForKey:SPPlaceNameKey];
    // Remove the values
//    [[NSUserDefaults standardUserDefaults]
//        removeObjectForKey:SPPlaceIdentifierKey];
//    [[NSUserDefaults standardUserDefaults]
//        removeObjectForKey:SPParkingIdentifierKey];
    // Notify the user in order to check in and rate the parking
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObjectsAndKeys:placeId, SPPlaceIdentifierKey,
                                                   parkingId, SPParkingIdentifierKey,
                                                   placeName, SPPlaceNameKey, nil];
    notification.userInfo = userInfo;
    notification.alertAction = NSLocalizedString(@"Desitnation Reached", nil);
    notification.alertBody = NSLocalizedString(@"CheckIn and Report", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication]
            presentLocalNotificationNow:notification];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Used to remove the monitoring if enough time has elapsed an the user
    // didn't get to the destination
    NSDate *registrationDate = [[NSUserDefaults standardUserDefaults] objectForKey:MonitoringDateKey];
    if (ABS([registrationDate timeIntervalSinceNow]) >= MaxTimeInterval) {
        // Max interval has elapsed, clean the monitoring
        [manager stopMonitoringSignificantLocationChanges];
        [self removeAllMonitoredRegions];
    }
}

@end
