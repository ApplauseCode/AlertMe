//
//  ReminderStore.m
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReminderStore.h"
#import "Reminder.h"

static ReminderStore *defaultStore = nil;

@implementation ReminderStore

+ (ReminderStore *)defaultStore
{
    if (!defaultStore) {
        // Create the singleton
        defaultStore = [[super allocWithZone:NULL] init];
    }
    return defaultStore;
}

// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

- (id)init
{
    // If we already have an instance of PossessionStore...
    if (defaultStore) {
        // Return the old one
        return defaultStore;
    }
    
    self = [super init];
    if (self) {
        //allReminders = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)allReminders
{
    [self fetchRemindersIfNecessary];
    return allReminders;
}

- (void)saveReminder:(Reminder *)r
{
    [allReminders addObject:r];
}

- (void)removeReminder:(Reminder *)r
{
    [allReminders removeObjectIdenticalTo:r];
}

- (void)replaceReminder:(Reminder *)r index:(int)i
{
    [allReminders replaceObjectAtIndex:i withObject:r];
}

- (NSString *)reminderArchivePath
{
    return pathInDocumentDirectory(@"reminders.data");
}

- (BOOL)saveChanges;
{
    return [NSKeyedArchiver archiveRootObject:allReminders toFile:[self reminderArchivePath]];
}

- (void)fetchRemindersIfNecessary
{
    // If we don't currently have an allReminders array, try to read one from the disk
    if (!allReminders) {
        NSString *path = [self reminderArchivePath];
        allReminders = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
    }
    
    //If we tried to read one from the disk but it does not exist (first time starting up), then create a new one
    if (!allReminders) {
        allReminders = [[NSMutableArray alloc] init];
    }
}

- (id)retain
{
    return self;
}

- (oneway void)release
{
    // Do Nothing
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

@end
