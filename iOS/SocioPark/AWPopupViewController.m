//
//  AWPopupViewController.m
//  SocioPark
//
//  Created by Amit Wolfus on 2/2/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import "AWPopupViewController.h"

@interface AWPopupViewController ()

@end

@implementation AWPopupViewController {
    UIView *maskView_;
}

@synthesize frame = _frame;

- (void)initWithFrame:(CGRect)frame {
    _frame = frame;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)loadView {
    self.view = [[AWPopupView alloc] initWithFrame:self.frame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentModallyFromViewController:(UIViewController *)viewController {
    CGRect maskFrame = CGRectMake(0, 0, viewController.view.bounds.size.width, viewController.view.bounds.size.height);
    maskView_ = [[UIView alloc] initWithFrame:maskFrame];
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [maskView_ addGestureRecognizer:[singleTap autorelease]];
    [maskView_ setBackgroundColor:[UIColor darkGrayColor]];
    [maskView_ setAlpha:0.7];
    [viewController.view addSubview:maskView_];
    [viewController.view bringSubviewToFront:maskView_];
    [viewController.view addSubview:self.view];
    [viewController.view bringSubviewToFront:self.view];
    // Bounce in the view
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.duration = 0.7;
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double value = 0;
    float e = 2.71;
    for (int t = 0; t < steps; t++) {
        value = 320 * pow(e, -0.055*t) * cos(0.08*t) + 110;
        [values addObject:[NSNumber numberWithFloat:value]];
    }
    animation.values = values;
    [self.view.layer setValue:[NSNumber numberWithInt:110] forKeyPath:animation.keyPath];
    [self.view.layer addAnimation:animation forKey:nil];
}

@end
