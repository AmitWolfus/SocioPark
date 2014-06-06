//
//  SPParkingsRetreiver.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/15/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPParking.h"
#import "AFJSONRequestOperation.h"
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FBGraphPlace.h>
#import "SPPlace.h"
#include <libkern/OSAtomic.h>

@class SPParkingsRetreiver;

/**
 * Defines the delegate for a parkings retreiver
 */
@protocol SPParkingsRetreiverDelegate <NSObject>

/**
 * Provides a way for the retreiver to return
 * the fetched parkings to the delegate
 * @param retreiver: the retreiver that fetched the parkings
 * @param parkings: an NSArray containing SPParkings objects
 * @param error: an error if something bad happened
 */
- (void)retreiver:(SPParkingsRetreiver *)retreiver
 didFetchParkings:(NSArray *)parkings
        withError:(NSError *)error;

- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg waitUntilDone:(BOOL)wait;

@end

@interface SPParkingsRetreiver : NSObject {
    id <SPParkingsRetreiverDelegate> delegate_;
}

- (id)initWithDelegate:(id<SPParkingsRetreiverDelegate>)delegate;
/**
 * Starts an async operation to fetch the recommended parkings for a 
 * business
 * @param businessId The id of the business
 */
- (void)fetchParkingsForBusiness:(SPPlace *)business;
- (void)abort;

@end

@interface SPParkingsReporter : NSObject

/**
 * Reports to the parkings server the current state of a given parking
 */
- (void)reportState:(SPParkingState)state forParking:(NSString *)parkingId;

+ (SPParkingsReporter *)sharedInstance;

@end
