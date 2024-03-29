//
//  EditViewController.h
//  AlertMe
//
//  Created by Jeffrey Rosenbluth on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Addressbook/Addressbook.h>
#import <FactualSDK/FactualAPI.h>

@class Reminder;

@interface EditViewController : UIViewController <CLLocationManagerDelegate, UIScrollViewDelegate, UITextViewDelegate, FactualAPIDelegate>
{
    NSString *street;
    NSString *city;
    NSString *zipCode;
    NSString *address;
    NSString *locationString;
    FactualAPI *apiObject;
    
}

@property (nonatomic, assign) BOOL isNewReminder;
@property (nonatomic, retain) Reminder *reminder;
@property (nonatomic, assign) int reminderIndex;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;
@property (nonatomic, retain) NSArray *fetchedPlaces;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (retain, nonatomic) NSMutableSet *factualSet;

@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UITextView *reminderTextView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (retain, nonatomic) IBOutlet UIView *locationView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIImageView *segImage;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *locationActivityIndicator;
@property (retain, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (retain, nonatomic) IBOutlet UISearchBar *placeSearchBar;
@property (retain, nonatomic) IBOutlet UITextField *locationField;
@property (retain, nonatomic) IBOutlet UISwitch *currentLocationSwitch;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIView *dateButtonView;
@property (retain, nonatomic) IBOutlet UITableView *favoriteTableView;

- (IBAction)addReminder:(id)sender;
- (IBAction)dismissEditView:(id)sender;
- (IBAction)timeOrLocationChanged:(id)sender;
- (IBAction)useLocationSwitched:(id)sender;
- (IBAction)popDatePicker:(id)sender;
- (IBAction)dateChanged:(id)sender;

- (void)buttonPressed:(id)sender;
- (void)createFactualSet;

@end
