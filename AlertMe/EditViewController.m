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

@interface EditViewController()

@property (nonatomic, retain) UILocalNotification *reminderNotification;

@end

@implementation EditViewController

@synthesize isNewReminder;
@synthesize reminder;
@synthesize reminderIndex;
@synthesize datePicker;
@synthesize reminderField;
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
@synthesize segmentedControl;
@synthesize latitude;
@synthesize longitude;
@synthesize fetchedPlaces;


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
        [reminderField becomeFirstResponder];
        datePicker.date = [NSDate date];
        datePicker.minimumDate = [NSDate date];
        datePicker.maximumDate = nil;
        
    } else {
        [datePicker setMinimumDate:[reminder endDate]];
        [datePicker setDate:[reminder endDate]];
        [reminderField setText:[reminder text]];
    }
    locationField.enabled = NO;
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
            [self displayError:error];
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
    
    if (!isNewReminder) {        
        NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *notification in allNotifications) {
            if (([reminder.text isEqual:notification.alertBody]) && ([reminder.endDate isEqual:notification.fireDate])) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                NSLog(@"found notification to delete %@", reminder.text);
            }
        }
        reminder.endDate = datePicker.date;
        reminder.text = reminderField.text;
        [rs replaceReminder:reminder index:reminderIndex];
    }
    else {
        //reminder.startDate = [NSDate date];
        reminder.endDate = datePicker.date;
        reminder.text = reminderField.text;
        [reminder setIsLocationBased:NO];
        [reminder setLatitude:0.0];
        [reminder setLongitude:0.0];
        [rs saveReminder:reminder];
    }
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    
    if (![reminder isLocationBased]) {
        reminderNotification = [[UILocalNotification alloc] init];
        reminderNotification.fireDate = reminder.endDate;
        reminderNotification.timeZone = [NSTimeZone defaultTimeZone];
        reminderNotification.alertBody = reminder.text;
        reminderNotification.alertAction = @"View";
        reminderNotification.soundName = UILocalNotificationDefaultSoundName;
        reminderNotification.applicationIconBadgeNumber = -1;
    }
    else {
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
        [rs saveReminder:reminder];
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:reminderNotification];

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
    
    //[locationAlert show];
    //[locationAlert release];
    
}

- (IBAction)dismissEditView:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)textFieldDidEndEditing:(UITextField *)field
{
    [doneButton setEnabled:YES];
    [field resignFirstResponder];
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
    [super dealloc];
}
@end
