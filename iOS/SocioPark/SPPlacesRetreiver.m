//
//  SPPlacesRetreiver.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/16/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPPlacesRetreiver.h"

@interface SPPlaceRetreiverDelegateWithCallback : NSObject <SPPlacesRetreiverDelegate>

@end

@implementation SPPlaceRetreiverDelegateWithCallback {
    void (^callback)(SPPlace *, NSError *);
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)fetchParkingById:(NSString *)identifier withCallback:(void(^)(SPPlace *,NSError *))call {
    callback = Block_copy(call);
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@",identifier];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request =
    [NSURLRequest requestWithURL:
     [NSURL URLWithString:urlString]];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request,
                                                              NSHTTPURLResponse *response,
                                                              id JSON) {
                                                        NSDictionary *jsonResponse = JSON;
                                                            SPPlace *place = [[SPPlace alloc] init];
                                                            place.identifier = [jsonResponse objectForKey:@"id"];
                                                            place.name = [jsonResponse objectForKey:@"name"];
                                                            NSDictionary *location = [jsonResponse objectForKey:@"location"];
                                                            NSNumber *lat = [location objectForKey:@"latitude"];
                                                            NSNumber *lon = [location objectForKey:@"longitude"];
                                                            place.location =
                                                            [[[CLLocation alloc] initWithLatitude:[lat doubleValue]
                                                                                        longitude:[lon doubleValue]]
                                                             autorelease];
                                                            place.address = [location objectForKey:@"street"];
                                                            place.placeType = SPPlaceTypeFacebook;
                                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                        callback([place autorelease], nil);
                                                    } failure:^(NSURLRequest *request,
                                                                NSHTTPURLResponse *response,
                                                                NSError *error,
                                                                id JSON) {
                                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                        callback(nil, error);
                                                    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [operation start];

    
}

- (void)retreiver:(SPPlacesRetreiver *)retreiver didFetchPlaces:(NSArray *)places withError:(NSError *)error {
    if (error) {
        callback(nil, error);
    }
    else if([places count] > 0) {
        callback([places objectAtIndex:0], error);
    }
    else {
        callback(nil, nil);
    }
    [retreiver release];
}

@end

@implementation SPPlacesRetreiver {
    AFJSONRequestOperation *operation_;
    volatile u_int isAborted_;
}

static inline NSString *urlForQuery(NSString *query, NSString *accessToken) {
    return
        [[NSString stringWithFormat:
         @"https://graph.facebook.com/search?q=Tel-aviv-%@&type=place&center=32.0833,34.8000&distance=30000&access_token=%@",
         query, accessToken] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (id)initWithDelegate:(id<SPPlacesRetreiverDelegate>)delegate {
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

- (void)fetchPlacesForQuery:(NSString *)query {
    isAborted_ = NO;
/*    [self requestPlace:query FromFacebookWithCallback:nil];
    return;
    if (![FBSession activeSession] ||![[FBSession activeSession] isOpen]) {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:NO completionHandler:nil];
    }*/
    NSString *urlString = urlForQuery(query,
                                      [[SPSessionHolder sharedInstance].session accessToken]);
    urlString = [urlString stringByReplacingOccurrencesOfString:@" "
                                                     withString:@"-"];
    NSURLRequest *request =
        [NSURLRequest requestWithURL:
            [NSURL URLWithString:urlString]];
    operation_ =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request,
                  NSHTTPURLResponse *response,
                  id JSON) {
            operation_ = nil;
        NSDictionary *jsonResponse = JSON;
        NSArray *data = [jsonResponse objectForKey:@"data"];
        NSMutableArray *places =
            [NSMutableArray arrayWithCapacity:[data count]];
        for (NSDictionary *dictPlace in data) {
            NSDictionary *location = [dictPlace objectForKey:@"location"];
            if ([SPPlacesRetreiver allowPlace:location]) {
                SPPlace *place = [[SPPlace alloc] init];
                place.identifier = [dictPlace objectForKey:@"id"];
                place.name = [dictPlace objectForKey:@"name"];
                
                NSNumber *lat = [location objectForKey:@"latitude"];
                NSNumber *lon = [location objectForKey:@"longitude"];
                place.location =
                [[[CLLocation alloc] initWithLatitude:[lat doubleValue]
                                            longitude:[lon doubleValue]]
                 autorelease];
                place.address = [location objectForKey:@"street"];
                place.placeType = SPPlaceTypeFacebook;
                [places addObject:[place autorelease]];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!isAborted_) {
                if (delegate_) {
                    [delegate_ retreiver:self didFetchPlaces:places withError:nil];
                }
            }
    } failure:^(NSURLRequest *request,
                NSHTTPURLResponse *response,
                NSError *error,
                id JSON) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        operation_ = nil;
        if (!isAborted_) {
            if (delegate_) {
                NSDictionary *jsonResponse = JSON;
                NSDictionary *jsonError = [jsonResponse objectForKey:@"error"];
                if (jsonError) {
                    for (id key in [[jsonError keyEnumerator] allObjects]) {
                        NSLog(@"%@ - %@", key, [jsonError objectForKey:key]);
                    }
                    NSString *message = [jsonError objectForKey:@"message"];
                    if ([message rangeOfString:@"not authorized" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        error = [NSError errorWithDomain:SPFacebookErrorDomain code:AppNotAuthorized userInfo:nil];
                        [[SPSessionHolder sharedInstance].session closeAndClearTokenInformation];
                        [[SPSessionHolder sharedInstance] login];
                    }
                }
                [delegate_ retreiver:self didFetchPlaces:nil withError:error];
            }
        }
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [operation_ start];
}

+ (BOOL)allowPlace:(NSDictionary *)jsonPlace {
    NSString *city = [jsonPlace objectForKey:@"city"];
    if (!city) {
        return NO;
    }
    if ([[city stringByReplacingOccurrencesOfString:@" " withString:@"-"] rangeOfString:@"Tel-Aviv" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (void)placeWithIdentifier:(NSString *)identifier
                   callback:(void(^)(SPPlace *, NSError *))callback {
    SPPlaceRetreiverDelegateWithCallback *ret = [[SPPlaceRetreiverDelegateWithCallback alloc] init];
    [ret fetchParkingById:identifier withCallback:^(SPPlace *place, NSError *error) {
        [ret autorelease];
        callback(place,error);
    }];
}

@end

@implementation SPSessionHolder

@synthesize session = session_;

+ (SPSessionHolder *)sharedInstance {
    static SPSessionHolder *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SPSessionHolder alloc] init];
    });
    return sharedInstance;
}

- (BOOL)login {
    if (!self.session.isOpen) {
        // create a fresh session object
        self.session = [[FBSession alloc] init];
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                
            }];
            return YES;
        }
        // No token is cached therefore a user login is required
        else {
            return NO;
        }
    }
    else {
        return YES;
    }
}

@end
