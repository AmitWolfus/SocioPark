//
//  SPPageInfoViewController.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/8/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPPageInfoViewController.h"


#define ParkingIdentifier @"Parking"
#define PlaceIdentifier @"Place"
#define WazeTitle @"Waze"
#define AppleMapsTitle @"Apple Maps"

@interface AddressAnnotation : NSObject <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c;
-(void)setTitle:(NSString *)title;
-(void)setSubtitle:(NSString *)title;

@end

@interface SPParkingAnnotation : AddressAnnotation {
    SPParking *parking_;
}
- (id)initWithParking:(SPParking *)parking;

@property (retain, nonatomic) SPParking *parking;

@end

@interface SPParkingAnnotationView : MKAnnotationView {
    SPParkingAnnotation *annotation_;
}

- (id)initWithParkingAnnotation:(SPParkingAnnotation *)annotation;

@end

@implementation SPPageInfoViewController{
    SPPlacesViewController *placesViewController_;
    UIView *mask_;
    UIActivityIndicatorView *spinner_;
    SPPlace *_place;
    SPParkingsRetreiver *retreiver_;
    NSString *rateParkingId_;
}

@synthesize mapView = mapView_;

-(id)initWithNibName:(NSString *)nibNameOrNil
              bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
            [self setTitle:NSLocalizedString(@"Places", nil)];
            placesViewController_ = [[SPPlacesViewController alloc] initWithNibName:@"SPPlacesSearchViewController"
                                                                         bundle:nil];
            placesViewController_.delegate = self;
            rateParkingId_ = nil;
        }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add the navigation button to the navigation bar
    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigate", nil)
                                          style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(navigate:)] autorelease];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:
        @{UITextAttributeTextColor : [UIColor grayColor]}
                                                          forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                       target:self
                                                       action:@selector(searchPlace:)] autorelease];
    [[SPNavigationManager sharedInstance] requestPermissions];
    mask_ = [[UIView alloc] initWithFrame:self.view.frame];
    [mask_ setBackgroundColor:[UIColor darkGrayColor]];
    [mask_ setAlpha:0.7];
    spinner_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner_.center = CGPointMake([[UIScreen mainScreen] applicationFrame].size.width / 2,
                                  ([[UIScreen mainScreen] applicationFrame].size.height / 2) - 20);
    [mask_ addSubview:spinner_];
    NSString *loadingText = NSLocalizedString(@"SearchParkings", nil);
    CGSize stringSize = [loadingText sizeWithFont:[UIFont systemFontOfSize:13]];
    CGRect labelFrame = CGRectMake(spinner_.center.x - (stringSize.width / 2),
                                   spinner_.frame.origin.y + 5 + spinner_.frame.size.height,
                                   stringSize.width,
                                   stringSize.height);
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:labelFrame];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    loadingLabel.font = [UIFont systemFontOfSize:13];
    loadingLabel.text = loadingText;
    [mask_ addSubview:loadingLabel];
    NSString *lastSearch = [[NSUserDefaults standardUserDefaults] objectForKey:LastSearchKey];
    if (lastSearch) {
        [SPPlacesRetreiver placeWithIdentifier:lastSearch callback:^(SPPlace * place, NSError * error) {
            if (error) {
                NSLog(@"%@",error);
                NSString *errMsg = nil;
                if (error.domain == NSURLErrorDomain) {
                    if (error.code == NSURLErrorNotConnectedToInternet) {
                        errMsg = NSLocalizedString(@"NotConnected", nil);
                    }
                }
                if (!errMsg) {
                    errMsg = NSLocalizedString(@"ErrorFetchPlaces", nil);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert =
                    [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                               message:errMsg
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                });
            }
         else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self setPlace:place];
             });
         }
         }];
    }
    // There wasn't a last search, which means that this is the first time
    // the application is opened, hence the tutorial should be shown
    else {
        [placesViewController_ showTutorial];
        [self searchPlace:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (rateParkingId_) {
        // Display the rate parking view, the place name and id isn't being used yet
        [self displayRateForParking:[rateParkingId_ autorelease]
                    atPlaceWithName:nil
                            placeId:nil];
        rateParkingId_ = nil;
    }
}

- (void)setPlace:(SPPlace *)place {
    [_place release];
    [mapView_ removeAnnotations:[mapView_ annotations]];
    [self setTitle:NSLocalizedString(@"Places", nil)];
    if (place) {
        [self.view addSubview:mask_];
        [spinner_ startAnimating];
        _place = [place retain];
        [self setTitle:_place.name];
        // Disable the map until the parkings are fetched
        [mapView_ setUserInteractionEnabled:NO];
        // Create the region for the map to show
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = _place.location.coordinate.latitude;
        coordinate.longitude = _place.location.coordinate.longitude;
        MKCoordinateRegion region;
        region.center = coordinate;
        region.span.latitudeDelta = 0.007;
        region.span.longitudeDelta = 0.007;
        // Show the map with the given area
        [mapView_ setRegion:region animated:YES];
        // Initialize the annotation for the selected place
        AddressAnnotation *annotation =
        [[AddressAnnotation alloc] initWithCoordinate:coordinate];
        [annotation setTitle:_place.name];
        [annotation setSubtitle:_place.address];
        // Show the annotation on the map
        [mapView_ addAnnotation:annotation];
        // Start fetching the recommended parkings
        retreiver_ =
        [[SPParkingsRetreiver alloc] initWithDelegate:self];
        [retreiver_ fetchParkingsForBusiness:_place];
    }
}

- (IBAction)searchPlace:(id)sender {
    //[retreiver_ abort];
    [self.navigationController pushViewController:placesViewController_ animated:YES];
}

- (void)viewController:(SPPlacesViewController *)viewController didSelectPlace:(SPPlace *)place {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:place.identifier forKey:LastSearchKey];
    [self setPlace:place];
}

- (void)viewControllerDidCancel:(SPPlacesViewController *)viewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [retreiver_ abort];
}

- (void)retreiver:(SPParkingsRetreiver *)retreiver
 didFetchParkings:(NSArray *)parkings
        withError:(NSError *)error {
    if (error) {
        // An error occured
        NSLog(@"%@",error);
        NSString *errMsg = nil;
        if (error.domain == NSURLErrorDomain) {
            if (error.code == NSURLErrorNotConnectedToInternet) {
                errMsg = NSLocalizedString(@"NotConnected", nil);
            }
        }
        if (!errMsg) {
            errMsg = NSLocalizedString(@"ErrorFetchParkings", nil);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *serverError =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                       message:errMsg
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                             otherButtonTitles: nil];
            [serverError show];
            [serverError release];
            [self searchPlace:nil];
        });
    }
    else {
        // Add all the parkings to the map
        for (SPParking *parking in parkings) {
            SPParkingAnnotation *annotation =
                [[SPParkingAnnotation alloc] initWithParking:parking];
            [mapView_ addAnnotation:[annotation autorelease]];
        }
        [mapView_ setUserInteractionEnabled:YES];
        if (![parkings count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *noParkings = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:NSLocalizedString(@"NoParkingsFound", nil)
                                                                    delegate:nil
                                                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                           otherButtonTitles: nil];
                [noParkings show];
                [noParkings release];
                [self searchPlace:nil];
            });
        }
    }
    [retreiver release];
    [spinner_ stopAnimating];
    [mask_ removeFromSuperview];
    retreiver_ = nil;

}

- (IBAction)navigate:(id)sender {
    UIActionSheet *navigationSheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Navigate Using",
                                                               nil)
                                    delegate:self
                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                      destructiveButtonTitle:nil
                           otherButtonTitles:WazeTitle,AppleMapsTitle, nil];
    NSArray *subviews = [navigationSheet subviews];
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            NSString *title = [view performSelector:@selector(title)];
            if ([title compare:WazeTitle] == NSOrderedSame) {
                [(UIButton *)view setTitleColor:[UIColor grayColor]
                           forState:UIControlStateDisabled];
                [(UIButton *)view setEnabled:[[SPNavigationManager sharedInstance]
                                    canLaunchApplication:SPWazeApp]];
            }
        }
    }
    [navigationSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        // Check which navigation app was chosen
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        SPNavigationApps chosenApp = SPAppleApp;
        if ([title compare:WazeTitle] == NSOrderedSame) {
            chosenApp = SPWazeApp;
        }
        else if ([title compare:AppleMapsTitle] == NSOrderedSame) {
            chosenApp = SPAppleApp;
        }
        else {
            NSLog(@"Selected button at navigation wasn't something known");
        }
        // Get the selected parking
        SPParking *parking =
        [[_selectedAnnotationView annotation] performSelector:@selector(parking)];
        // Start navigation to the selected parking
        [[SPNavigationManager sharedInstance]   navigateToParking:parking
                                                         forPlace:_place
                                                  withApplication:chosenApp];
    }
    actionSheet.delegate = nil;
    [actionSheet release];
}

- (void)displayRateForParking:(NSString *)parkingId
              atPlaceWithName:(NSString *)placeName
                      placeId:(NSString *)placeId {
    if (self.isViewLoaded && self.view.window) {
        SPRateParkingViewController *rateViewController =
        [[SPRateParkingViewController alloc] initWithNibName:@"SPRateParkingViewController"
                                                      bundle:nil];
        rateViewController.delegate = self;
        rateViewController.parkingId = parkingId;
        rateViewController.placeName = placeName;
        rateViewController.placeId = placeId;
        [self.navigationController presentViewController:rateViewController
                                                animated:YES
                                              completion:nil];
    }
    else {
        // The view isn't displayed yet, save the id to display it later
        rateParkingId_ = [parkingId copy];
    }
}

- (void)viewControllerDidFinishRating:(SPRateParkingViewController *)viewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [viewController release];
}

- (void)dealloc{
    if (_place) {
        [_place release];
    }
    if (retreiver_) {
        [retreiver_ release];
    }
    [placesViewController_ release];
    [spinner_ release];
    [mask_ release];
    [rateParkingId_ release];
    [super dealloc];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    // Check if the annotation is for a place or a parking
    if (annotation == _calloutAnnotation) {
		CalloutMapAnnotationView *calloutMapAnnotationView = (CalloutMapAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:@"CalloutAnnotation"];
		if (!calloutMapAnnotationView) {
			calloutMapAnnotationView = [[[CalloutMapAnnotationView alloc] initWithAnnotation:annotation
																			 reuseIdentifier:@"CalloutAnnotation"] autorelease];
			calloutMapAnnotationView.contentHeight = 65.0f;
		}
		calloutMapAnnotationView.parentAnnotationView = _selectedAnnotationView;
		calloutMapAnnotationView.mapView = mapView_;
        calloutMapAnnotationView.parking = [(SPParkingAnnotation *)annotation parking];
		return calloutMapAnnotationView;
	}
    MKAnnotationView *view;
    if ([annotation respondsToSelector:@selector(parking)]) {
        view = [mapView
                dequeueReusableAnnotationViewWithIdentifier:ParkingIdentifier];
        if (!view) {
            view =
                [[SPParkingAnnotationView alloc] initWithParkingAnnotation:annotation];
        }
        [view setCanShowCallout:NO];
    }
    else {
        view =
        [mapView_ dequeueReusableAnnotationViewWithIdentifier:PlaceIdentifier];
        if (!view) {
            view =
                [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                 reuseIdentifier:PlaceIdentifier]
                    autorelease];
            view.canShowCallout = YES;
        }
        [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorPurple];
    }
    [view setAnnotation:annotation];
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Check if the annotation isn't a regular annotation
	if ([view.annotation respondsToSelector:@selector(parking)]) {
        [mapView_ bringSubviewToFront:view];
        SPParking *parking = (SPParking *)[view.annotation performSelector:@selector(parking)];
        [self.mapView setCenterCoordinate:parking.coordinate animated:YES];
        if (_calloutAnnotation == nil) {
			_calloutAnnotation =
                [[CalloutMapAnnotation alloc]
                    initWithLatitude:view.annotation.coordinate.latitude
                        andLongitude:view.annotation.coordinate.longitude];
		}
        else {
			_calloutAnnotation.latitude = view.annotation.coordinate.latitude;
			_calloutAnnotation.longitude = view.annotation.coordinate.longitude;
		}
        // Set the callout to the current parking
        _calloutAnnotation.parking = [(SPParkingAnnotation *)[view annotation] parking];
		// Show the callout on the map
        [mapView_ addAnnotation:_calloutAnnotation];
		_selectedAnnotationView = view;
        MKAnnotationView* callout = [mapView_ dequeueReusableAnnotationViewWithIdentifier:@"CalloutAnnotation"];
        if (callout) {
            [mapView_ bringSubviewToFront:callout];
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	if (_calloutAnnotation &&
        [view.annotation respondsToSelector:@selector(parking)]) {
		[self.mapView removeAnnotation: _calloutAnnotation];
        self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *annotationView in views) {
        if ([annotationView isKindOfClass:[CalloutMapAnnotationView class]]) {
            [[annotationView superview] bringSubviewToFront:annotationView];
        }
    }
}

@end


@implementation AddressAnnotation

@synthesize coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	if (self = [super init]) {
        coordinate = c;
    }
    return self;
}
-(void)setTitle:(NSString *)title{
    _title = [title copy];
}
-(void)setSubtitle:(NSString *)title{
    _subtitle = [title copy];
}

@end

@implementation SPParkingAnnotation

@synthesize parking = parking_;


- (id)initWithParking:(SPParking *)parking {
    if (self = [super initWithCoordinate:parking.coordinate]) {
        parking_ = [parking retain];
        self.title = [parking_ name];
        self.subtitle = [NSString stringWithFormat:@"%@ %@",
                         [parking_ streetName],
                         [parking_ houseNumber]];
    }
    return self;
}

- (void)dealloc {
    [parking_ release];
    parking_ = nil;
    [super dealloc];
}

- (void)setParking:(SPParking *)parking {
    if (parking) {
        [parking release];
    }
    parking_ = [parking retain];
}

@end

@implementation SPParkingAnnotationView

static inline UIImage *UIImageWithSize(UIImage *image, CGSize size) {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)initWithParkingAnnotation:(SPParkingAnnotation *)annotation {
    if (self = [super initWithAnnotation:annotation
                         reuseIdentifier:ParkingIdentifier]) {
        annotation_ = [annotation retain];
        UIImage *bubble = nil;
        switch (annotation.parking.parkingState) {
            case SPParkingEmpty:
            {
                bubble = [UIImage imageNamed:@"FreeParkingBubble.tif"];
                break;
            }
            case SPParkingMedium:
            {
                bubble = [UIImage imageNamed:@"SlightBusyParkingBubble.tif"];
                break;
            }
            case SPParkingBusy:
            {
                bubble = [UIImage imageNamed:@"MediumParkingBubble.tif"];
                break;
            }
            case SPParkingFull:
            {
                bubble = [UIImage imageNamed:@"BusyParkingBubble.tif"];
                break;
            }
        }

        [super setImage:UIImageWithSize(bubble, CGSizeMake(35, 57))];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    if ([annotation isKindOfClass:[SPParkingAnnotation class]]) {
        UIImage *bubble = nil;
        switch (((SPParkingAnnotation *)annotation).parking.parkingState) {
            case SPParkingEmpty:
            {
                bubble = [UIImage imageNamed:@"FreeParkingBubble.tif"];
                break;
            }
            case SPParkingMedium:
            {
                bubble = [UIImage imageNamed:@"SlightBusyParkingBubble.tif"];
                break;
            }
            case SPParkingBusy:
            {
                bubble = [UIImage imageNamed:@"MediumParkingBubble.tif"];
                break;
            }
            case SPParkingFull:
            {
                bubble = [UIImage imageNamed:@"BusyParkingBubble.tif"];
                break;
            }
        }
        
        [super setImage:UIImageWithSize(bubble, CGSizeMake(35, 57))];
    }
}

@end

