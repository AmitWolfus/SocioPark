//
//  SPPlacesRetreiver.h
//  SocioPark
//
//  Created by Amit Wolfus on 12/16/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPlace.h"
#import "AFJSONRequestOperation.h"
#import <FacebookSDK/FacebookSDK.h>
#include <libkern/OSAtomic.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

static NSString *const SPFacebookErrorDomain = @"com.sociopark.facebook";
static const NSInteger NoAccountsCode = 1;
static const NSInteger AppNotAuthorized = 2;

@class SPPlacesRetreiver;

@protocol SPPlacesRetreiverDelegate <NSObject>

- (void)retreiver:(SPPlacesRetreiver *)retreiver
   didFetchPlaces:(NSArray *)places
        withError:(NSError *)error;

@end

@interface SPPlacesRetreiver : NSObject {
    id <SPPlacesRetreiverDelegate> delegate_;
}

- (id)initWithDelegate:(id<SPPlacesRetreiverDelegate>)delegate;
- (void)fetchPlacesForQuery:(NSString *)query;

- (void)abort;

+ (void)placeWithIdentifier:(NSString *)identifier
                   callback:(void(^)(SPPlace *place, NSError *error))callback;

@end

@interface SPSessionHolder : NSObject {
    FBSession *session_;
}

@property (strong, nonatomic) FBSession *session;

/**
 * If a facebook account is cached a login to that account occurs,
 * if no facebook account is  available NO is returned and a user login
 * is required.
 */
- (BOOL)login;

+ (SPSessionHolder *)sharedInstance;

@end