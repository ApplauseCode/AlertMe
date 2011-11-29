//
//  Reminder.h
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reminder : NSObject


@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, retain) NSString *locationString;
@property (nonatomic) BOOL isLocationBased;

- (NSString *) timeToExpiration;

@end
