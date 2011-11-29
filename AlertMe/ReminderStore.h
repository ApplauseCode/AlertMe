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

// Class methods are prefixed with a + instead of a -
+ (ReminderStore *)defaultStore;

- (void)removeReminder:(Reminder *)r;
- (NSMutableArray *)allReminders;
- (void)saveReminder:(Reminder *)r;
- (void)replaceReminder:(Reminder *)r index:(int)i;
- (NSString *)reminderArchivePath;
- (void)fetchRemindersIfNecessary;
- (BOOL)saveChanges;

@end
