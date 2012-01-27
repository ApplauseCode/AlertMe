//
//  AppDelegate.m
//  AlertMe
//
//  Created by Jeffrey Rosenbluth on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "InboxViewController.h"
#import "EditViewController.h"
#import "ReminderStore.h"
#import "TempViewController.h"

@interface AppDelegate()

@property (nonatomic, retain) InboxViewController *inbox_vc;
@property (nonatomic, retain) UINavigationController *nav;
@property (nonatomic, retain) EditViewController *edit_vc;

-(void)plusButtonPressed:(id)sender;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize inbox_vc;
@synthesize nav;
@synthesize edit_vc;
@synthesize clloc;
@synthesize topBarView;
@synthesize bottomBarView;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    UIImage *plusButtonImage=[UIImage imageNamed:@"PlusButton2.png"]; //don't forget the non-retina image
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.bounds = CGRectMake( 0, 0, plusButtonImage.size.width, plusButtonImage.size.height );    
    [plusButton setBackgroundImage:plusButtonImage forState:UIControlStateNormal];
    [plusButton addTarget:self action:@selector(plusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];    
    UIBarButtonItem *plusButtonItem = [[UIBarButtonItem alloc] initWithCustomView:plusButton];
    [plusButton setShowsTouchWhenHighlighted:YES];

    
    inbox_vc = [[InboxViewController alloc] init];
    [[inbox_vc navigationItem] setRightBarButtonItem: plusButtonItem];
// **** Temporary
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(showLocation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *loc = [[UIBarButtonItem alloc] initWithCustomView:button];
    [[inbox_vc navigationItem] setLeftBarButtonItem:loc];
// ****

    nav = [[UINavigationController alloc] initWithRootViewController:inbox_vc];
    UIImage *customNavBarImage = [UIImage imageNamed:@"AlertMeCustomNavBar4"];
    [[UINavigationBar appearance] setBackgroundImage:customNavBarImage forBarMetrics:UIBarMetricsDefault];
    UIColor *graniteColor = [UIColor colorWithRed:.60 green:.15 blue:.15 alpha:1];
    [[UINavigationBar appearance] setTintColor:graniteColor];
    
    UIImage *topBar = [UIImage imageNamed:@"topb"];
    topBarView = [[UIImageView alloc] initWithImage:topBar];
    [topBarView setFrame:CGRectMake(0, -166, topBarView.frame.size.width, topBarView.frame.size.height)];
    [[nav view] addSubview:topBarView];
    [topBarView setHidden:YES];
    
    UIImage *bottomBar = [UIImage imageNamed:@"bottomTabb"];
    bottomBarView = [[UIImageView alloc] initWithImage:bottomBar];
    [bottomBarView setFrame:CGRectMake(0, 520, bottomBarView.frame.size.width, bottomBarView.frame.size.height)];
    [[nav view] addSubview:bottomBarView];
    
    [[self window] setRootViewController:nav];
    [inbox_vc release];
    [self.window makeKeyAndVisible];
    return YES;
}

// **** Temporary
-(void)showLocation
{
    TempViewController *temp_vc = [[TempViewController alloc] initWithNibName:nil bundle:nil];
    [[self nav] pushViewController:temp_vc animated:YES];
 
}
// ****

-(void)plusButtonPressed:(id)sender
{
    if (edit_vc) {
        [edit_vc release];
    }
    [topBarView setHidden:NO];
    edit_vc = [[EditViewController alloc] init];
    [edit_vc setIsNewReminder:YES];
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [topBarView setFrame:CGRectMake(topBarView.frame.origin.x, 20, topBarView.frame.size.width, topBarView.frame.size.height)];
         } completion:^(BOOL finished){
             [nav presentModalViewController:edit_vc animated:NO];
         }];
    
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [bottomBarView setFrame:CGRectMake(bottomBarView.frame.origin.x, 250, bottomBarView.frame.size.width, bottomBarView.frame.size.height)];
    } completion:^(BOOL finished){
    }];
    //[nav presentModalViewController:edit_vc animated:NO];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ReminderStore defaultStore] saveChanges];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		// Stop normal location updates and start significant location change updates for battery efficiency.
		[clloc stopUpdatingLocation];
		[clloc startMonitoringSignificantLocationChanges];
	}
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[inbox_vc tableView] reloadData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[inbox_vc tableView] reloadData];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		// Stop significant location updates and start normal location updates again since the app is in the forefront.
		[clloc stopMonitoringSignificantLocationChanges];
		[clloc startUpdatingLocation];
	}
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ReminderStore defaultStore] saveChanges];
}

@end
