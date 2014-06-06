//
//  SPCheckInViewController.m
//  SocioPark
//
//  Created by Amit Wolfus on 2/1/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import "SPCheckInViewController.h"

@interface SPCheckInViewController ()

@end

@implementation SPCheckInViewController {
}

@synthesize placeId = _placeId;
@synthesize placeName = _placeName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        super.delegate = self;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)dealloc {
    [_placeName release];
    [_placeId release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.message.layer.cornerRadius = 5;
    self.message.clipsToBounds = YES;
    self.title = self.placeName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    
}

@end
