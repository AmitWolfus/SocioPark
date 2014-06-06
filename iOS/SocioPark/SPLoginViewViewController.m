//
//  SPLoginViewViewController.m
//  SocioPark
//
//  Created by Amit Wolfus on 1/19/13.
//  Copyright (c) 2013 Amit Wolfus. All rights reserved.
//

#import "SPLoginViewViewController.h"

@interface SPLoginViewViewController ()

@end

@implementation SPLoginViewViewController {
    UILabel *loginLabel_;
}

@synthesize loginLabel = loginLabel_;

static inline UIImage *UIImageWithSize(UIImage *image, CGSize size) {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *loginImage = [UIImage imageNamed:@"FBLogin.png"];
    loginImage = UIImageWithSize(loginImage, CGSizeMake(loginImage.size.width / 2, loginImage.size.height / 2));
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setImage:loginImage forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake((self.view.frame.size.width / 2) - (loginImage.size.width / 2),
                                     self.loginLabel.frame.origin.y + self.loginLabel.frame.size.height + 10,
                                     loginImage.size.width,
                                     loginImage.size.height)];
    [self.view addSubview:loginButton];
    NSString *loginText = NSLocalizedString(@"FacebookLoginRequired", nil);
    self.loginLabel.text = loginText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [[SPSessionHolder sharedInstance].session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView
                                             completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                                 if (error) {
                                                     NSLog(@"%@",error);
                                                 }
                                                [self handleOpenSession:session withStatus:status];
                                             }];
}

- (void)handleOpenSession:(FBSession *)session withStatus:(FBSessionState)status {
    if (FB_ISSESSIONOPENWITHSTATE(status)) {
        [self.delegate userDidLoginWithViewController:self];
    }
    else {
        // Session wasn't opened properly
        [SPSessionHolder sharedInstance].session = [[FBSession alloc] init];
    }
}

@end
