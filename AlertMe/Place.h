//
//  Place.h
//  AlertMe
//
//  Created by Reed Rosenbluth on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *factualID;

@end
