//
//  EditViewController.m
//  AlertMe
//
//  Created by Jeffrey Rosenbluth on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "ReminderStore.h"
#import "Reminder.h"
#import "TempViewController.h"
#import "PlaceCell.h"
#import "AppDelegate.h"

@interface EditViewController()

@property (nonatomic, retain) UILocalNotification *reminderNotification;
@property (nonatomic, retain) UIImageView *topBarView2;
@property (nonatomic, retain) UIImageView *bottomBarView2;

@end

@implementation EditViewController

@synthesize isNewReminder;
@synthesize reminder;
@synthesize reminderIndex;
@synthesize datePicker;
@synthesize reminderField;
@synthesize reminderTextView;
@synthesize doneButton;
@synthesize locationView;
@synthesize reminderNotification;
@synthesize locationManager;
@synthesize currentLocationLabel;
@synthesize locationActivityIndicator;
@synthesize searchDisplayController;
@synthesize placeSearchBar;
@synthesize locationField;
@synthesize currentLocationSwitch;
@synthesize dateLabel;
@synthesize dateButtonView;
@synthesize segmentedControl;
@synthesize latitude;
@synthesize longitude;
@synthesize fetchedPlaces;
@synthesize topBarView2;
@synthesize bottomBarView2;


- (id) init
{
    self = [super initWithNibName:@"EditViewController" bundle:nil];
    if (self) {
        simpleGeoController = [[SGController alloc] init];
    }
    return self;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

#pragma mark - View lifecycle
- (IBAction)timeOrLocationChanged:(id)sender 
{
    [locationView setHidden:![sender selectedSegmentIndex]];
    [dateButtonView setHidden:[sender selectedSegmentIndex]];
    [datePicker setHidden:[sender selectedSegmentIndex]];
   // [locationField enabled: [sender selectedSegmentIndex]];
    
    if ([segmentedControl selectedSegmentIndex]) {
        
        // Create location manager object
        locationManager = [[CLLocationManager alloc] init];
        
        [locationManager setDelegate:self];
        
        // We want all results from the location manager
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        
        // And we want it to be as accurate as possible
        // regardless of how much time/power it takes
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        // Tell our manager to start looking for its location immediately
        [locationManager startUpdatingLocation];
        
    }

}

- (IBAction)useLocation:(id)sender {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [locationView  setHidden:YES];
    [locationView setFrame:CGRectMake(0, 96, 320, 150)];
    [[self view] addSubview:locationView];
}

- (void)viewDidUnload
{
    [self setDatePicker:nil];
    [self setReminderField:nil];
    [self setDoneButton:nil];
    [self setLocationView:nil];
    [self setCurrentLocationLabel:nil];
    [self setSearchDisplayController:nil];
    [self setPlaceSearchBar:nil];
    [self setLocationField:nil];
    [self setCurrentLocationSwitch:nil];
    [self setDateLabel:nil];
    [self setReminderTextView:nil];
    [self setDateButtonView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!isNewReminder) {
        [doneButton setEnabled:YES];
    }
    else
        [doneButton setEnabled:NO];
    if(!reminder) {
        reminder = [[Reminder alloc] init];        
        //[reminderField becomeFirstResponder];
        datePicker.date = [NSDate date];
        datePicker.minimumDate = [NSDate date];
        datePicker.maximumDate = nil;
        
    } else {
        [datePicker setMinimumDate:[reminder endDate]];
        [datePicker setDate:[reminder endDate]];
        [reminderField setText:[reminder text]];
        [reminderTextView setText:[reminder text]];
    }
    locationField.enabled = NO;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSString *dateString = [format stringFromDate:[NSDate date]];
    [dateLabel setText:dateString];
    [format release];
    
    reminderTextView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    UIImage *topBar = [UIImage imageNamed:@"top"];
    topBarView2 = [[UIImageView alloc] initWithImage:topBar];
    [topBarView2 setFrame:CGRectMake(0, 0, topBarView2.frame.size.width, topBarView2.frame.size.height)];
    [[self view] addSubview:topBarView2];
    
    UIImage *bottomBar = [UIImage imageNamed:@"bottomTab"];
    bottomBarView2 = [[UIImageView alloc] initWithImage:bottomBar];
    [bottomBarView2 setFrame:CGRectMake(0, 230, bottomBarView2.frame.size.width, bottomBarView2.frame.size.height)];
    [[self view] addSubview:bottomBarView2];
    
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [bottomBarView2 setFrame:CGRectMake(bottomBarView2.frame.origin.x, 416, bottomBarView2.frame.size.width, bottomBarView2.frame.size.height)];
    } completion:^(BOOL finished){
        [topBarView2 setHidden:YES];
    }];
    
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [topBarView2 setFrame:CGRectMake(topBarView2.frame.origin.x, -186, topBarView2.frame.size.width, topBarView2.frame.size.height)];
    } completion:^(BOOL finished){
    }];
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geoCoder = [[[CLGeocoder alloc] init] autorelease];
    
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *topResult = [placemarks objectAtIndex:0];
        
        city = topResult.subLocality;
        street = topResult.subThoroughfare;
        zipCode = topResult.postalCode;
        
        [currentLocationLabel setText:city];
        [locationActivityIndicator setHidden:YES];
        [locationManager stopUpdatingLocation];
    }];
}

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Location Services Not Available." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [errorAlert show];
    [locationActivityIndicator setHidden:YES];
    [currentLocationLabel setText:@"Location Not Found"];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loadInfoForLocation:(id)sender
{
    if ([currentLocationSwitch isOn]) {
        address = [NSString stringWithFormat:@"%@, %@", street, zipCode];
    }
    else {
        address = locationField.text;
    }
    SGPlacesQuery *query = [SGPlacesQuery queryWithAddress:address];
    [query setSearchString:placeSearchBar.text];
    [query setRadius:20.0];
    [query setLimit:20];
    
    [simpleGeoController.client getPlacesForQuery:query
                                         callback:[SGCallback callbackWithSuccessBlock:
                                                   ^(id response) {
                                                       // you've got Places!
                                                       // to create an array of SGPlace objects...
                                                       NSArray *places = [NSArray arrayWithSGCollection:response type:SGCollectionTypePlaces];
                                                       self.fetchedPlaces = places;
                                                       
                                                       NSLog(@"%@",fetchedPlaces);
                                                       [[[self searchDisplayController] searchResultsTableView] reloadData];
                                                   } 
                                                                          failureBlock:^(NSError *error) {
                                                                              NSLog(@"SimpleGeo failed to retrieve places");
                                                                          }]];
}

- (IBAction)useLocationSwitched:(id)sender {
    
    if ([sender isOn]) {
        locationField.enabled = NO;
    }
    else
        locationField.enabled = YES;  
}

- (IBAction)popDatePicker:(id)sender {
    [datePicker setHidden:NO];
    [reminderField resignFirstResponder];
    [reminderTextView resignFirstResponder];
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    [datePicker setHidden:YES];
}

- (IBAction)dateChanged:(id)sender {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSString *dateString = [format stringFromDate:datePicker.date];
    [dateLabel setText:dateString];
    [format release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), fetchedPlaces);
    return [fetchedPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCellIdentifier";
    PlaceCell *cell = (PlaceCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaceCell" owner:self options:nil];
        for (id oneObject in nib) 
            if ([oneObject isKindOfClass:[PlaceCell class]]) 
                cell = (PlaceCell *)oneObject;
    }
    [[cell placeLabel] setText:[[fetchedPlaces objectAtIndex:[indexPath row]] name]];
    //[[cell detailTextLabel] setText:[(SGAddress *)[[fetchedPlaces objectAtIndex:[indexPath row]] address] street]];
    [[cell addressLabel] setText:[(SGAddress *)[[fetchedPlaces objectAtIndex:[indexPath row]] address] street]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [doneButton setEnabled:YES];
    NSLog(@"%@", [[fetchedPlaces objectAtIndex:[indexPath row]] point]);
    
    latitude = [[[fetchedPlaces objectAtIndex:[indexPath row]] point] latitude];
    longitude = [[[fetchedPlaces objectAtIndex:[indexPath row]] point] longitude];
    
    NSLog(@"%f", latitude);
    NSLog(@"%f", longitude);
    
    [reminder setLatitude:latitude];
    [reminder setLongitude:longitude];
    [reminder setIsLocationBased:YES];
    [reminder setEndDate:nil];
    [reminder setLocationString:[[fetchedPlaces objectAtIndex:[indexPath row]] name]];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    // Load new info if the search term has changed
    [self loadInfoForLocation:nil];
    [aSearchBar resignFirstResponder];
}

- (IBAction)addReminder:(id)sender 
{
    ReminderStore *rs = [ReminderStore defaultStore];
    //[reminder setIsLocationBased:NO];
    
    if (!isNewReminder) {        
        NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *notification in allNotifications) {
            if (([reminder.text isEqual:notification.alertBody]) && ([reminder.endDate isEqual:notification.fireDate])) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                NSLog(@"found notification to delete %@", reminder.text);
            }
        }
        reminder.endDate = datePicker.date;
        reminder.text = reminderTextView.text;
        [rs replaceReminder:reminder index:reminderIndex];
    } /*else {
        //reminder.startDate = [NSDate date];
        reminder.endDate = datePicker.date;
        reminder.text = reminderField.text;
        [reminder setIsLocationBased:NO];
        [reminder setLatitude:0.0];
        [reminder setLongitude:0.0];
        [rs saveReminder:reminder];
    }*/
    
    //[self.navigationController popViewControllerAnimated:YES];
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissEditView:nil];
    reminder.text = reminderTextView.text;
    
    if (![reminder isLocationBased]) {
        reminder.endDate = datePicker.date;
        reminderNotification = [[UILocalNotification alloc] init];
        reminderNotification.fireDate = reminder.endDate;
        reminderNotification.timeZone = [NSTimeZone defaultTimeZone];
        reminderNotification.alertBody = reminder.text;
        reminderNotification.alertAction = @"View";
        reminderNotification.soundName = UILocalNotificationDefaultSoundName;
        reminderNotification.applicationIconBadgeNumber = -1;
        NSLog(@"notification registered");
    
        [reminder setLatitude:0.0];
        [reminder setLongitude:0.0];
        [[UIApplication sharedApplication] scheduleLocalNotification:reminderNotification];
    } else {
        if ([CLLocationManager regionMonitoringAvailable]) {
            // Create a new region based on the center of the map view.
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
            NSString *regionID = [NSString stringWithFormat:@"%f, %f", latitude, longitude];
            CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord 
                                                                          radius:100.0 
                                                                      identifier:regionID];
            
            // Start monitoring the newly created region.
            [locationManager startMonitoringForRegion:newRegion desiredAccuracy:kCLLocationAccuracyBest];
            [reminder setARegion:newRegion];
            [newRegion release];
        } else {
            NSLog(@"Region monitoring is not available.");
        }
    }
    [rs saveReminder:reminder];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	//NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
	//[self updateWithEvent:event];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.alertBody = reminder.text;
    localNotif.alertAction = @"View";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    [localNotif release];
    
    NSLog(@"YAY! Teleporation successful");
    
    //[locationAlert show];
    //[locationAlert release];
    
}

- (IBAction)dismissEditView:(id)sender 
{
    [topBarView2 setHidden:NO];
    
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [topBarView2 setFrame:CGRectMake(topBarView2.frame.origin.x, 0, topBarView2.frame.size.width, topBarView2.frame.size.height)];
    } completion:^(BOOL finished){
        [self dismissModalViewControllerAnimated:NO];
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
            [delegate.topBarView setFrame:CGRectMake(delegate.topBarView.frame.origin.x, -166, delegate.topBarView.frame.size.width, delegate.topBarView.frame.size.height)];
        } completion:^(BOOL finished){
            [delegate.topBarView setHidden:YES];
        }];
        [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
            [delegate.bottomBarView setFrame:CGRectMake(delegate.bottomBarView.frame.origin.x, 520, delegate.bottomBarView.frame.size.width, delegate.bottomBarView.frame.size.height)];
        } completion:^(BOOL finished){
        }];
    }];
    
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [bottomBarView2 setFrame:CGRectMake(bottomBarView2.frame.origin.x, 230, bottomBarView2.frame.size.width, bottomBarView2.frame.size.height)];
    } completion:^(BOOL finished){
    }];

}

/*
- (IBAction)textFieldDidEndEditing:(UITextField *)field
{
    [doneButton setEnabled:YES];
    [field resignFirstResponder];
}
*/

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [doneButton setEnabled:YES];
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}


- (void)dealloc {
    [datePicker release];
    [reminderField release];
    [doneButton release];
    [locationView release];
    [currentLocationLabel release];
    [searchDisplayController release];
    [placeSearchBar release];
    [locationField release];
    [currentLocationSwitch release];
    [dateLabel release];
    [reminderTextView release];
    [dateButtonView release];
    [super dealloc];
}
@end
