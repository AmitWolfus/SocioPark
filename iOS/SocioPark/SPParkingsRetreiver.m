//
//  SPParkingsRetreiver.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/15/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPParkingsRetreiver.h"

@implementation SPParkingsRetreiver {
    AFJSONRequestOperation *operation_;
    volatile u_int isAborted_;
}

static inline NSURL *urlForBusiness(NSString *businessId) {
    return
        [NSURL URLWithString:
            [NSString stringWithFormat:
             @"http://tlvpark.apphb.com/Business?businessId=%@&businessType=Facebook",
             businessId]];
}

- (id)initWithDelegate:(id<SPParkingsRetreiverDelegate>)delegate {
    if (self = [super init]) {
        delegate_ = delegate;
        isAborted_ = NO;
    }
    return self;
}

- (void)abort {
    OSAtomicTestAndSet(YES, &isAborted_);
    if (operation_) {
        [operation_ cancel];
        operation_ = nil;
    }
    [[UIApplication sharedApplication]
     setNetworkActivityIndicatorVisible:NO];
}

- (void)fetchParkingsForBusiness:(SPPlace *)business {
    NSURL *url =
        [NSURL URLWithString:
            [NSString stringWithFormat:@"http://socio-park.appspot.com/parkings?lat=%f&lon=%f",
                business.location.coordinate.latitude,
                business.location.coordinate.longitude]];
    //NSLog(@"%@",url);
    NSURLRequest *request =
    [NSURLRequest requestWithURL:url];
    operation_ =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request,
                      NSHTTPURLResponse *response,
                      id JSON) {
                NSLog(@"Success");
                operation_ = nil;
                //NSArray *jsonResponse = JSON;
                // Create the parkings from the response
                NSDictionary *jResponse = JSON;
                NSArray *results = [jResponse objectForKey:@"results"];
                NSMutableArray *parkings =
                [NSMutableArray arrayWithCapacity:[results count]];
                for (NSDictionary *p in results) {
                    SPParking *parking = [[SPParking alloc] init];
                    parking.name = [p objectForKey:@"name"];
                    parking.identifier = [p objectForKey:@"id"];
                    parking.streetName = [p objectForKey:@"street"];
                    parking.houseNumber = [p objectForKey:@"house"];
                    parking.parkingState = [(NSNumber *)[p objectForKey:@"state"] intValue];
                    NSDictionary *location = [p objectForKey:@"location"];
                    double latitude =
                    [((NSNumber *)[location objectForKey:@"latitude"]) doubleValue];
                    double longitude =
                    [(NSNumber *)[location objectForKey:@"longitude"] doubleValue];
                    // Calculate the distance to the business
                    parking.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                    CLLocation *locationPark =
                        [[CLLocation alloc] initWithLatitude:parking.coordinate.latitude
                                                   longitude:parking.coordinate.longitude];
                    CLLocation *locationPlace =
                        [[CLLocation alloc] initWithLatitude:business.location.coordinate.latitude
                                                   longitude:business.location.coordinate.longitude];
                    parking.distance = [locationPlace distanceFromLocation:locationPark];
                    [locationPark release];
                    [locationPlace release];
                    [parkings addObject:[parking autorelease]];
                }
                [[UIApplication sharedApplication]
                    setNetworkActivityIndicatorVisible:NO];
                dispatch_queue_t queue = dispatch_get_main_queue();
                dispatch_async(queue, ^{
                    if (!isAborted_) {
                        [delegate_ retreiver:self didFetchParkings:parkings withError:nil];
                    }
                });
    } failure:^(NSURLRequest *request,
                NSHTTPURLResponse *response,
                NSError *error,
                id JSON) {
        operation_ = nil;
        NSLog(@"Failure");
        NSDictionary *jsonError = JSON;
        NSDictionary *err = [jsonError objectForKey:@"error"];
        NSString *message = [err objectForKey:@"message"];
        NSLog(@"%@",message);
        [[UIApplication sharedApplication]
            setNetworkActivityIndicatorVisible:NO];
        if (!isAborted_) {
            [delegate_ retreiver:self didFetchParkings:nil withError:error];
        }
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [operation_ start];
}

@end

@implementation SPParkingsReporter

- (void)reportState:(SPParkingState)state forParking:(NSString *)parkingId {
    // Get the name of the given state
    NSString *stateName = nil;
    switch (state) {
        case SPParkingEmpty: {
            stateName = @"empty";
            break;
        }
        case SPParkingMedium: {
            stateName = @"medium";
            break;
        }
        case SPParkingBusy: {
            stateName = @"busy";
            break;
        }
        case SPParkingFull: {
            stateName = @"full";
            break;
        }
        default:
        {
            NSLog(@"Invalid state value was given to report parking state");
            return;
        }
    }
    // build the request
    NSURL *reportUrl = [NSURL URLWithString:
        [NSString stringWithFormat:@"http://socio-park.appspot.com/parking?id=%@&state=%@",
                                    parkingId, stateName]];
    NSURLRequest *request = [NSURLRequest requestWithURL:reportUrl];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"State was reported succesfully");
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if ([JSON respondsToSelector:@selector(objectForKey:)]) {
            NSDictionary *jsonErr = JSON;
            NSString *status = [jsonErr objectForKey:@"status"];
            NSLog(@"given status for error is %@", status);
            NSDictionary *err = [jsonErr objectForKey:@"error"];
            NSString *message = [err objectForKey:@"message"];
            NSLog(@"Failed reporting parking state, error message is:\"%@\"",message);
        }
        else {
            NSLog(@"An unknown error occured while reporting parking state: %@", error);
        }
    }];
    [operation start];
}

+ (SPParkingsReporter *)sharedInstance {
    static SPParkingsReporter *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SPParkingsReporter alloc] init];
    });
    return sharedInstance;
}

@end
