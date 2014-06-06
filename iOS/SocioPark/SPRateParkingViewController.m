//
//  SPRateParkingViewController.m
//  SocioPark
//
//  Created by Amit Wolfus on 2/1/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import "SPRateParkingViewController.h"

@interface SPRateParkingViewController ()

@end

@implementation SPRateParkingViewController

@synthesize emptyStateButton = emptyStateButton_;
@synthesize mediumStateButton = mediumStateButton_;
@synthesize busyStateButton = busyStateButton_;
@synthesize fullStateButton = fullStateButton_;
@synthesize skipButton = skipButton_;
@synthesize rateLabel = rateLabel_;
@synthesize parkingId = parkingId_;
@synthesize delegate = delegate_;
@synthesize placeName = _placeName;
@synthesize placeId = _placeId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        parkingId_ = nil;
    }
    return self;
}

- (void)dealloc {
    [parkingId_ release];
    [_placeName release];
    [_placeId release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Setup the localized texts of the buttons
    self.emptyStateButton.titleLabel.numberOfLines = 0;
    self.mediumStateButton.titleLabel.numberOfLines = 0;
    self.busyStateButton.titleLabel.numberOfLines = 0;
    self.fullStateButton.titleLabel.numberOfLines = 0;
    [self.emptyStateButton setTitle:NSLocalizedString(@"Empty", nil) forState:UIControlStateNormal];
    [self.mediumStateButton setTitle:NSLocalizedString(@"Medium", nil) forState:UIControlStateNormal];
    [self.busyStateButton setTitle:NSLocalizedString(@"Busy", nil) forState:UIControlStateNormal];
    [self.fullStateButton setTitle:NSLocalizedString(@"Full", nil) forState:UIControlStateNormal];
    [self.skipButton setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
    // Set the text of the explanation label
    self.rateLabel.numberOfLines = 0;
    self.rateLabel.textAlignment = NSTextAlignmentCenter;
    [self.rateLabel setText:NSLocalizedString(@"RateTitle", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skip:(id)sender {
    // Notify that the rating has ended
    [self.delegate viewControllerDidFinishRating:self];
}

- (IBAction)rateParking:(id)sender {
    if (!parkingId_) {
        [NSException raise:@"parking id is nil"
                    format:@"SPRateParkingViewController's parking id must be set before any call to rateParking"];
    }
    // Check which state was reported
    SPParkingState state = SPParkingEmpty;
    if (sender == self.emptyStateButton) {
        state = SPParkingEmpty;
    }
    else if (sender == self.mediumStateButton) {
        state = SPParkingMedium;
    }
    else if (sender == self.busyStateButton) {
        state = SPParkingBusy;
    }
    else if (sender == self.fullStateButton) {
        state = SPParkingFull;
    }
    else {
        NSLog(@"Unrecognized sender received in rateParking of SPRateParkingViewController, ignoring call");
        return;
    }
    // Report the state
    [[SPParkingsReporter sharedInstance] reportState:state forParking:self.parkingId];
    // Notify that the rating has ended
    [self.delegate viewControllerDidFinishRating:self];
}

- (IBAction)checkin:(id)sender {
    /*if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *viewController =
            [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        [self.delegate viewControllerDidFinishRating:self];
    }*/
    /*SPCheckInViewController *checkInViewController =
        [[SPCheckInViewController alloc] init];
    checkInViewController.placeId = self.placeId;
    checkInViewController.placeName = self.placeName;
    [checkInViewController presentModallyFromViewController:self animated:YES handler:nil];*/
    SPPlace *place = [[SPPlace alloc] init];
    place.name = self.placeName;
    place.identifier = self.placeId;
    [SPCheckInView presentModallyFromViewController:self
                                           forPlace:[place autorelease]
                                        withSession:nil
                              withCompletionHandler:^(SPCheckInView *sender, BOOL wasDonePressed) {
                                  NSLog(@"Completion handler was called, wasDonePressed = %@", wasDonePressed ? @"YES" : @"NO");
                              }];
}

@end
