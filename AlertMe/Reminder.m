//
//  Reminder.m
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Reminder.h"

@implementation Reminder

@synthesize text;
@synthesize endDate;
@synthesize isLocationBased;
@synthesize latitude;
@synthesize longitude;
@synthesize locationString;
@synthesize aRegion;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self) {
        // For each instance variable that is archived, we docode it, 
        // and pass it to our setters. (Where it is retained)
        [self setText:[decoder decodeObjectForKey:@"text"]];
        [self setEndDate:[decoder decodeObjectForKey:@"endDate"]];
        [self setIsLocationBased:[decoder decodeBoolForKey:@"isLocationBased"]];
        [self setLatitude:[decoder decodeDoubleForKey:@"latitude"]];
        [self setLongitude:[decoder decodeDoubleForKey:@"longitude"]];
        [self setLocationString:[decoder decodeObjectForKey:@"locationString"]];
        [self setARegion:[decoder decodeObjectForKey:@"aRegion"]];
    }
    return self;
}

- (NSString *) timeToExpiration
{
    double seconds = [endDate timeIntervalSinceNow];
    if (seconds < 60) 
        return @"Launches in less than 1 minute";
    int days = (int) (seconds / (3600 * 24));
    seconds = seconds - (days * 3600 * 24);
    int hours = (int) (seconds / 3600);
    seconds = seconds - (hours * 3600);
    int minutes = (int) (seconds / 60);
    NSString *dayString = (days == 1) ? @"day" : @"days";
    NSString *hourString = (hours == 1) ? @"hour" : @"hours";
    NSString *minuteString = (minutes == 1) ? @"minute" : @"minutes";
    if (days == 0 && hours == 0)
        return [NSString stringWithFormat:@"Launches in %i %@", minutes, minuteString];
    if (days == 0)
        return [NSString stringWithFormat:@"Launches in %i %@", hours, hourString];
    if (days != 0)
        return [NSString stringWithFormat:@"Launches in %i %@", days, dayString];
    else
        return @"";
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:text forKey:@"text"];
    [encoder encodeObject:endDate forKey:@"endDate"];
    [encoder encodeBool:isLocationBased forKey:@"isLocationBased"];
    [encoder encodeDouble:latitude forKey:@"latitude"];
    [encoder encodeDouble:longitude forKey:@"longitude"];
    [encoder encodeObject:locationString forKey:@"locationString"];
    [encoder encodeObject:aRegion forKey:@"aRegion"];
}

@end
