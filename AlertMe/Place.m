//
//  Place.m
//  AlertMe
//
//  Created by Reed Rosenbluth on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize name;
@synthesize longitude;
@synthesize latitude;
@synthesize address;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self) {
        // For each instance variable that is archived, we docode it, 
        // and pass it to our setters. (Where it is retained)
        [self setName:[decoder decodeObjectForKey:@"name"]];
        [self setAddress:[decoder decodeObjectForKey:@"address"]];
        [self setLatitude:[decoder decodeDoubleForKey:@"latitude"]];
        [self setLongitude:[decoder decodeDoubleForKey:@"longitude"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:address forKey:@"address"];
    [encoder encodeDouble:latitude forKey:@"latitude"];
    [encoder encodeDouble:longitude forKey:@"longitude"];
}


@end
