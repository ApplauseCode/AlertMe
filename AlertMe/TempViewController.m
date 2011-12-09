//
//  TempViewController.m
//  AlertMe
//
//  Created by Jeffrey Rosenbluth on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TempViewController.h"
#import "Reminder.h"
#import "ReminderStore.h"

@implementation TempViewController
@synthesize reminderField;
@synthesize latitudeField;
@synthesize longitudeField;

@synthesize locationManager;
@synthesize reminderString;
@synthesize latitude;
@synthesize longitude;
@synthesize locationAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create location manager with filters set for battery efficiency.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [[[UIApplication sharedApplication] delegate] setClloc:locationManager];
	
	// Start updating location changes.
	[locationManager startUpdatingLocation];

}

- (void)viewDidUnload
{
    [self setReminderField:nil];
    [self setLatitudeField:nil];
    [self setLongitudeField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [reminderField release];
    [latitudeField release];
    [longitudeField release];
    [super dealloc];
}
- (IBAction)save {
    reminderString = [reminderField text];
    latitude = [[latitudeField text] doubleValue];
    longitude = [[longitudeField text] doubleValue];
    // add reminder to store;
    Reminder *reminder = [[Reminder alloc] init];
    ReminderStore *rs = [ReminderStore defaultStore];
    [reminder setText: reminderString];
    [reminder setLatitude:latitude];
    [reminder setLongitude:longitude];
    [reminder setIsLocationBased:YES];
    [reminder setEndDate:nil];
    [rs saveReminder:reminder];
    NSLog(@"%@", reminderString);
    NSLog(@"Lat: %8.6f", latitude);
    NSLog(@"Long: %8.6f", longitude);
    
    locationAlert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:reminderString delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    
    if ([CLLocationManager regionMonitoringAvailable]) {
		// Create a new region based on the center of the map view.
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
        NSString *regionID = [NSString stringWithFormat:@"%f, %f", latitude, longitude];
		CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord 
																	  radius:100.0 
																  identifier:regionID];
		
		// Start monitoring the newly created region.
		[locationManager startMonitoringForRegion:newRegion desiredAccuracy:kCLLocationAccuracyBest];
		
		[newRegion release];
	}
	else {
		NSLog(@"Region monitoring is not available.");
	}

}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	//NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
	//[self updateWithEvent:event];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.alertBody = reminderString;
    localNotif.alertAction = @"View";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    [localNotif release];
    
    NSLog(@"YAY! Teleporation successful");
    
    //[locationAlert show];
    //[locationAlert release];

}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
	//[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
	//[self updateWithEvent:event];
}

@end
