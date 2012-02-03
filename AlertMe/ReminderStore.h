//
//  ReminderStore.h
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reminder;

@interface ReminderStore : NSObject
{
    NSMutableArray *allReminders;
}
@property (nonatomic, retain) NSMutableArray *allReminders;
@property (nonatomic, retain) NSMutableArray *favoritePlaces;

+ (ReminderStore *)defaultStore;

- (void)removeReminder:(Reminder *)r;
- (void)saveReminder:(Reminder *)r;
- (void)replaceReminder:(Reminder *)r index:(int)i;

- (BOOL)saveChanges;

@end
