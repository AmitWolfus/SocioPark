//
//  SPPlacesViewController.m
//  SocioPark
//
//  Created by Amit Wolfus on 12/16/12.
//  Copyright (c) 2012 Amit Wolfus. All rights reserved.
//

#import "SPPlacesViewController.h"

#define CellIdentifier @"CellId"

@interface SPPlacesViewController ()

@end

@implementation SPPlacesViewController {
    bool showTutorial_;
    NSArray *places_;
    UIView *mask_;
    UIActivityIndicatorView *spinner_;
}

@synthesize tableView = tableView_;
@synthesize searchBar = searchBar_;
@synthesize delegate = delegate_;
@synthesize navBar = navBar_;
//@synthesize searchDisplayController = searchDisplayController_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        showTutorial_ = NO;
        retreiver_ = [[SPPlacesRetreiver alloc] initWithDelegate:self];
        [self setTitle:NSLocalizedString(@"Places", nil)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
    [searchBar setDelegate:self];

    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
    searchBarView.autoresizingMask = 0;
    searchBar.delegate = self;
    [searchBarView addSubview:searchBar];
    self.navigationItem.titleView = searchBarView;
    searchBar.placeholder = NSLocalizedString(@"SearchPlaceholder", nil);
    
    mask_ = [[UIView alloc] initWithFrame:self.view.frame];
    [mask_ setBackgroundColor:[UIColor darkGrayColor]];
    [mask_ setAlpha:0.5];
    spinner_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner_.center = CGPointMake([[UIScreen mainScreen] applicationFrame].size.width / 2,
                                  ([[UIScreen mainScreen] applicationFrame].size.height / 2) - 20);
    [mask_ addSubview:spinner_];
    // Check if the user needs to login to facebook
    if (![[SPSessionHolder sharedInstance] login]) {
        SPLoginViewViewController *loginView =
        [[SPLoginViewViewController alloc] initWithNibName:@"SPLoginViewViewController"
                                                    bundle:nil];
        loginView.delegate = self;
        [self.navigationController presentViewController:loginView animated:YES completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (!showTutorial_ && !self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancelSearch:)];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (retreiver_) {
        [retreiver_ abort];
    }
}

- (void)showTutorial {
    showTutorial_ = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [retreiver_ abort];
    [spinner_ stopAnimating];
    [mask_ removeFromSuperview];
    [searchBar setText:nil];
    [searchBar endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    showTutorial_ = NO;
    [retreiver_ abort];
    [self.view addSubview:mask_];
    [spinner_ startAnimating];
    [retreiver_ fetchPlacesForQuery:[searchBar text]];
    [searchBar endEditing:YES];
}

- (IBAction)cancelSearch:(id)sender {
    [spinner_ stopAnimating];
    [mask_ removeFromSuperview];
    [delegate_ viewControllerDidCancel:self];
}

- (void)retreiver:(SPPlacesRetreiver *)retreiver
   didFetchPlaces:(NSArray *)places
        withError:(NSError *)error {
    if (error) {
        NSLog(@"An error occured during the search for places %@",error);
        if (error.domain == SPFacebookErrorDomain && error.code == AppNotAuthorized) {
            SPLoginViewViewController *loginView =
            [[SPLoginViewViewController alloc] initWithNibName:@"SPLoginViewViewController"
                                                        bundle:nil];
            loginView.delegate = self;
            [self.navigationController presentViewController:loginView animated:YES completion:nil];
        }
        else {
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
    }
    else {
        if (places_) {
            [places_ release];
        }

        places_ = [places retain];
            [tableView_ performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:YES];
        //[[self.searchDisplayController searchResultsTableView] reloadData];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner_ stopAnimating];
        [mask_ removeFromSuperview];
    });
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![places_ count] && showTutorial_) {
        return 70.0f;
    }
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([places_ count]) {
        [tableView setAllowsSelection:YES];
        return [places_ count];
    }
    else {
        [tableView setAllowsSelection:NO];
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([places_ count]) {
        cell =
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
            NSLocaleLanguageDirection langDir =
                [NSLocale characterDirectionForLanguage:
                 [[NSLocale preferredLanguages] objectAtIndex:0]];
            NSTextAlignment alignment =
                langDir == kCFLocaleLanguageDirectionRightToLeft ?
                    NSTextAlignmentRight : NSTextAlignmentLeft;
            cell.textLabel.textAlignment = alignment;
            cell.detailTextLabel.textAlignment = alignment;
        }
        SPPlace *place = [places_ objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithString:place.name];
        cell.detailTextLabel.text = place.address;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InformationCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"InformationCell"];
            cell.textLabel.numberOfLines = 0;

        }
        if (showTutorial_) {
            cell.textLabel.text = NSLocalizedString(@"Tutorial", nil);
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"NoResults", nil);
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPPlace *place = [places_ objectAtIndex:indexPath.row];
    [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
    [delegate_ viewController:self didSelectPlace:place];
/*    SPPageInfoViewController *pageViewController = [[SPPageInfoViewController alloc] initWithNibName:@"SPPlaceInfoViewController" bundle:nil place:place];
    self.navigationItem.hidesBackButton = NO;
    [self.navigationController
        pushViewController:[pageViewController autorelease] animated:YES];*/
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    return NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return NO;
}

- (void)dealloc {
    [retreiver_ release];
    [spinner_ release];
    [mask_ release];
    [super dealloc];
}

#pragma mark Login

- (void)userDidLoginWithViewController:(SPLoginViewViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    controller.delegate = nil;
    [controller release];
    FBRequest *userInfoRequest = [FBRequest requestForMe];
    userInfoRequest.session = [[SPSessionHolder sharedInstance] session];
    [userInfoRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *json = result;
            NSString *gender = [json objectForKey:@"gender"];
            if (gender) {
                gender = [gender lowercaseString];
                [[NSUserDefaults standardUserDefaults] setObject:gender forKey:GenderKey];
            }
        }
    }];
}

@end
