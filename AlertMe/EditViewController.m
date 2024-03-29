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
#import "Place.h"

@interface EditViewController()

@property (nonatomic, retain) UILocalNotification *reminderNotification;
@property (nonatomic, retain) UIImageView *topBarView2;
@property (nonatomic, retain) UIImageView *bottomBarView2;
@property (nonatomic, retain) NSMutableArray *favorites;
@property (retain) NSIndexPath *lastIndexPath;
@property (nonatomic) BOOL isSearchTable;

@end

@implementation EditViewController

@synthesize isNewReminder;
@synthesize reminder;
@synthesize reminderIndex;
@synthesize datePicker;
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
@synthesize favoriteTableView;
@synthesize segmentedControl;
@synthesize latitude;
@synthesize longitude;
@synthesize fetchedPlaces;
@synthesize topBarView2;
@synthesize bottomBarView2;
@synthesize currentLocation;
@synthesize favorites;
@synthesize lastIndexPath;
@synthesize factualSet;
@synthesize isSearchTable;
@synthesize segImage;


- (id) init
{
    self = [super initWithNibName:@"EditViewController" bundle:nil];
    if (self) {
        favorites = [[NSMutableArray alloc] initWithCapacity:1];
        [self createFactualSet];
        [self setIsSearchTable:NO];
    }
    return self;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)createFactualSet
{
    factualSet = [[NSMutableSet alloc] init];
    ReminderStore *rs = [ReminderStore defaultStore];
    for (Place *p in rs.favoritePlaces) {
        [factualSet addObject:p];
    }
}

#pragma mark - View lifecycle
- (IBAction)timeOrLocationChanged:(id)sender 
{
    //[locationView setHidden:![sender selectedSegmentIndex]];
    //[dateButtonView setHidden:[sender selectedSegmentIndex]];
    //[datePicker setHidden:[sender selectedSegmentIndex]];
    //[locationField enabled: [sender selectedSegmentIndex]];
    
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
        
        [segImage setImage:[UIImage imageNamed:@"AlertMeBottomBarR.png"]];
        
        CGFloat datePickerX = [datePicker center].x - 320;
        CGPoint datePickerCenter = CGPointMake(datePickerX, [datePicker center].y);
        [UIView animateWithDuration:.3 animations:^(void){
            [datePicker setCenter:datePickerCenter];
        }];
        
        CGFloat dateButtonViewX = [dateButtonView center].x - 320;
        CGPoint dateButtonViewCenter = CGPointMake(dateButtonViewX, [dateButtonView center].y);
        [UIView animateWithDuration:.3 animations:^(void){
            [dateButtonView setCenter:dateButtonViewCenter];
        }];
        
        CGFloat lvX = [locationView center].x - 320;
        CGPoint lvCenter = CGPointMake(lvX, [locationView center].y);
        [UIView animateWithDuration:.3 animations:^(void){
            [locationView setCenter:lvCenter];
        }];
    }
    else {
        [segImage setImage:[UIImage imageNamed:@"AlertMeBottomBarL3.png"]];
        
        CGFloat datePickerX = [datePicker center].x + 320;
        CGPoint datePickerCenter = CGPointMake(datePickerX, [datePicker center].y);
        [UIView animateWithDuration:.3 animations:^(void){
            [datePicker setCenter:datePickerCenter];
        }];
        
        CGFloat dateButtonViewX = [dateButtonView center].x + 320;
        CGPoint dateButtonViewCenter = CGPointMake(dateButtonViewX, [dateButtonView center].y);
        [UIView animateWithDuration:.3 animations:^(void){
            [dateButtonView setCenter:dateButtonViewCenter];
        }];
        
        CGFloat lvX = [locationView center].x + 320;
        CGPoint lvCenter = CGPointMake(lvX, [locationView center].y);
        [UIView animateWithDuration:.3 animations:^(void){
            [locationView setCenter:lvCenter];
        }];
    }

}

- (IBAction)useLocation:(id)sender {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[locationView  setHidden:YES];
    [locationView setFrame:CGRectMake(320, 96, 320, 321)];
    [[self view] addSubview:locationView];
    apiObject = [[FactualAPI alloc] initWithAPIKey:@"StOUMfxOlEXf4zEHwFACUAFVAPnKHNc8itqyuGOsMMTK9NDFfVwujzTeIOzlAsCT"];
}

- (void)viewDidUnload
{
    [self setDatePicker:nil];
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
    [self setFavoriteTableView:nil];
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
    if (![reminder isLocationBased]) {
        if(!reminder) {
            reminder = [[Reminder alloc] init];        
            datePicker.date = [NSDate date];
            datePicker.minimumDate = [NSDate date];
            datePicker.maximumDate = nil;
            
        } else {
            [datePicker setMinimumDate:[reminder endDate]];
            [datePicker setDate:[reminder endDate]];
        }
    }
    else {
        if(!reminder) {
            reminder = [[Reminder alloc] init];
        }
    }
    [reminderTextView setText:[reminder text]];
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
    UIImage *topBar = [UIImage imageNamed:@"topb"];
    topBarView2 = [[UIImageView alloc] initWithImage:topBar];
    [topBarView2 setFrame:CGRectMake(0, 0, topBarView2.frame.size.width, topBarView2.frame.size.height)];
    [[self view] addSubview:topBarView2];
    
    UIImage *bottomBar = [UIImage imageNamed:@"bottomTabb"];
    bottomBarView2 = [[UIImageView alloc] initWithImage:bottomBar];
    [bottomBarView2 setFrame:CGRectMake(0, 230, bottomBarView2.frame.size.width, bottomBarView2.frame.size.height)];
    [[self view] addSubview:bottomBarView2];

    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [bottomBarView2 setFrame:CGRectMake(bottomBarView2.frame.origin.x, 416, bottomBarView2.frame.size.width, bottomBarView2.frame.size.height)];
    } completion:^(BOOL finished){
        [bottomBarView2 setHidden:YES];
    }];
    
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        [topBarView2 setFrame:CGRectMake(topBarView2.frame.origin.x, -186, topBarView2.frame.size.width, topBarView2.frame.size.height)];
    } completion:^(BOOL finished){
        [topBarView2 setHidden:YES];
    }];
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geoCoder = [[[CLGeocoder alloc] init] autorelease];
    
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            //NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        //NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *topResult = [placemarks objectAtIndex:0];
        
        city = topResult.subLocality;
        street = topResult.subThoroughfare;
        zipCode = topResult.postalCode;
        
        currentLocation = newLocation.coordinate;
        
        [currentLocationLabel setText:city];
        [locationActivityIndicator setHidden:YES];
        [locationManager stopUpdatingLocation];
    }];
}

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error
{
    //NSLog(@"Could not find location: %@", error);
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
    
    FactualQuery* queryObject = [FactualQuery query];
    
    // set geo filter
    [queryObject setGeoFilter:currentLocation radiusInMeters:8000.00];
    
    // set full text term
    [queryObject addFullTextQueryTerm:placeSearchBar.text];
    
    // create individual row filters
    //FactualRowFilter* postcodeFilter = [FactualRowFilter fieldName:@"postcode" beginsWith:zipCode];
    //FactualRowFilter* telephoneFilter = [FactualRowFilter fieldName:@"telephone" beginsWith:@"(310)"];
    //FactualRowFilter *nameFilter = [FactualRowFilter fieldName:@"name" In:<#(id), ...#>, nil
    
    // add them to the query object using an AND predicate
    //[queryObject addRowFilter: [FactualRowFilter andFilter:postcodeFilter,nil]];
    
    queryObject.limit = 20;

    // run query against the US-POI table
    [[apiObject queryTable:@"bi0eJZ" optionalQueryParams:queryObject withDelegate:self] retain];
    
}

- (void)requestComplete:(FactualAPIRequest*) request receivedQueryResult:(FactualQueryResult*) queryResult; {
    self.fetchedPlaces = queryResult.rows;
    [[searchDisplayController searchResultsTableView] reloadData];
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
    [doneButton setEnabled:YES];
    [reminderTextView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat datePickerY = [datePicker center].y + 50;
    CGPoint datePickerCenter = CGPointMake([datePicker center].x, datePickerY);
    [UIView animateWithDuration:.3 animations:^(void){
        [datePicker setCenter:datePickerCenter];
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    CGFloat datePickerY = [datePicker center].y - 50;
    CGPoint datePickerCenter = CGPointMake([datePicker center].x, datePickerY);
    [UIView animateWithDuration:.3 animations:^(void){
        [datePicker setCenter:datePickerCenter];
    }];
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
    if (tableView == favoriteTableView) {
        ReminderStore *rs = [ReminderStore defaultStore];
        //NSLog(@"Favorites: %i", [rs.favoritePlaces count]);
        return [rs.favoritePlaces count];
    }
        
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
        [[cell starButton] addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    if (tableView == favoriteTableView) {
        ReminderStore *rs = [ReminderStore defaultStore];
        cell.placeLabel.text = [[[rs favoritePlaces] objectAtIndex:[indexPath row]] name];
        cell.addressLabel.text = [[[rs favoritePlaces] objectAtIndex:[indexPath row]] address];
        [[cell starButton] setHighlighted:YES];
    }
    else {
        [[cell placeLabel] setText:[[fetchedPlaces objectAtIndex:[indexPath row]] valueForName:@"name"]];
        [[cell addressLabel] setText:[[fetchedPlaces objectAtIndex:[indexPath row]] valueForName:@"address"]];
        NSString *fID = [[fetchedPlaces objectAtIndex:[indexPath row]] valueForName:@"factual_id"];
        Place *p = [[Place alloc] init];
        [p setFactualID:fID];
        if ([factualSet containsObject:p]) {
            [[cell starButton] setHighlighted:YES];
        }
    }
    if ([indexPath compare:self.lastIndexPath] == NSOrderedSame) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } 
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[cell starButton] setTag:[indexPath row]];
    return cell;
    
}

- (void)buttonPressed:(id)sender
{
    int rowOfButton = [sender tag];
    NSIndexPath *path = [NSIndexPath indexPathForRow:rowOfButton inSection:0];
    NSArray *rowsToDelete;
    ReminderStore *rs = [ReminderStore defaultStore];
    Place *newFavorite = [[Place alloc] init];
    [newFavorite setName:[[fetchedPlaces objectAtIndex:rowOfButton] valueForName:@"name"]];
    [newFavorite setAddress:[[fetchedPlaces objectAtIndex:rowOfButton] valueForName:@"address"]];
    [newFavorite setLatitude:[[[fetchedPlaces objectAtIndex:rowOfButton] valueForName:@"latitude"] floatValue]];
    [newFavorite setLongitude:[[[fetchedPlaces objectAtIndex:rowOfButton] valueForName:@"longitude"] floatValue]];
    [newFavorite setFactualID:[[fetchedPlaces objectAtIndex:rowOfButton] valueForName:@"factual_id"]];
    Place *selectedFavorite;
//    if ([[rs favoritePlaces] count] > rowOfButton) {
//        selectedFavorite = [[rs favoritePlaces] objectAtIndex:rowOfButton];
//    }
//    if ([factualSet containsObject:newFavorite]) {
//        [rs.favoritePlaces removeObject:newFavorite];
//    }
//    else if ([factualSet containsObject:selectedFavorite]) {
//        [rs.favoritePlaces removeObject:selectedFavorite];
//    }
//    else {
//        [rs.favoritePlaces addObject:newFavorite];
//    }
    
    ///
    if ([self isSearchTable]) {
        if ([factualSet containsObject:newFavorite]) {
            [rs.favoritePlaces removeObject:newFavorite];
        }
        else {
            [rs.favoritePlaces addObject:newFavorite];
        }
    }
    else {
        selectedFavorite = [[rs favoritePlaces] objectAtIndex:rowOfButton];
        [rs.favoritePlaces removeObject:selectedFavorite];
        rowsToDelete = [NSArray arrayWithObject:path];
        [favoriteTableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    int i = 0;
    for (PlaceCell *c in [favoriteTableView visibleCells]) {
        [[c starButton] setTag:i];
        i++;
    }
    for (PlaceCell *c in [favoriteTableView visibleCells]) {
        NSLog(@"Tag: %i", c.starButton.tag);
    }
    [self createFactualSet];
    [[searchDisplayController searchResultsTableView] reloadData];
    //[favoriteTableView reloadData];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [doneButton setEnabled:YES];
    
    ReminderStore *rs = [ReminderStore defaultStore];
    
    self.lastIndexPath = indexPath;
    
    if (tableView == favoriteTableView) {
        latitude = [[[rs favoritePlaces] objectAtIndex:[indexPath row]] latitude];
        longitude = [[[rs favoritePlaces] objectAtIndex:[indexPath row]] longitude];
        [reminder setLocationString:[[[rs favoritePlaces] objectAtIndex:[indexPath row]] name]];
    }
    else {
        latitude = [[[fetchedPlaces objectAtIndex:[indexPath row]] valueForName:@"latitude"] floatValue];
        longitude = [[[fetchedPlaces objectAtIndex:[indexPath row]] valueForName:@"longitude"] floatValue];
        [reminder setLocationString:[[fetchedPlaces objectAtIndex:[indexPath row]] valueForName:@"name"]];
    }
    
    [reminder setLatitude:latitude];
    [reminder setLongitude:longitude];
    [reminder setIsLocationBased:YES];
    [reminder setEndDate:nil];
    
    [tableView reloadData];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    // Load new info if the search term has changed
    [self loadInfoForLocation:nil];
    [self setIsSearchTable:YES];
    [aSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setIsSearchTable:NO];
    [favoriteTableView reloadData];
}

- (IBAction)addReminder:(id)sender 
{
    ReminderStore *rs = [ReminderStore defaultStore];
    
    if (!isNewReminder) {        
        NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        if (![reminder isLocationBased]) {
            for (UILocalNotification *notification in allNotifications) {
                if (([reminder.text isEqual:notification.alertBody]) && ([reminder.endDate isEqual:notification.fireDate])) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                }
            }
            reminder.endDate = datePicker.date;
        }
        else {
            [locationManager stopMonitoringForRegion:[reminder aRegion]];
            
        }
        reminder.text = reminderTextView.text;
        [rs replaceReminder:reminder index:reminderIndex];
    }
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
            //NSLog(@"Region monitoring is not available.");
        }
    }
    if (isNewReminder) {
        [rs saveReminder:reminder];
    }
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
}

- (IBAction)dismissEditView:(id)sender 
{
    [topBarView2 setHidden:NO];
    [bottomBarView2 setHidden:NO];
    [reminderTextView resignFirstResponder];
    [placeSearchBar resignFirstResponder];
    [searchDisplayController setActive:FALSE animated:TRUE];
    
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
    [favoriteTableView release];
    [super dealloc];
}
@end
