//
//  TempViewController.h
//  AlertMe
//
//  Created by Jeffrey Rosenbluth on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface TempViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate>
@property (retain, nonatomic) IBOutlet UITextField *reminderField;
@property (retain, nonatomic) IBOutlet UITextField *latitudeField;
@property (retain, nonatomic) IBOutlet UITextField *longitudeField;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (copy, nonatomic) NSString *reminderString;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;
@property (retain, nonatomic) UIAlertView *locationAlert;


- (IBAction)save;

@end
