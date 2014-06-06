//
//  SPPageInfoViewController.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/8/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CalloutMapAnnotation.h"
#import "SPParkingsRetreiver.h"
#import "CalloutMapAnnotationView.h"
#import "SPPlace.h"
#import "SPNavigationManager.h"
#import "SPPlacesViewController.h"
#import "SPRateParkingViewController.h"

static  NSString *const LastSearchKey = @"LastSearchKey";

@interface SPPageInfoViewController : UIViewController <MKMapViewDelegate,
                                                SPParkingsRetreiverDelegate,
UIActionSheetDelegate, CLLocationManagerDelegate, SPPlacesViewControllerDelegate,
SPRateParkingViewControllerDelegate> {
    MKMapView *mapView_;
    CalloutMapAnnotation *_calloutAnnotation;
	MKAnnotationView *_selectedAnnotationView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
              bundle:(NSBundle *)nibBundleOrNil
               place:(SPPlace *)place;

- (IBAction)navigate:(id)sender;
/**
 * Displays the rating view controller for a given parking
 */
- (void)displayRateForParking:(NSString *)parkingId
              atPlaceWithName:(NSString *)placeName
                      placeId:(NSString *)placeId;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

