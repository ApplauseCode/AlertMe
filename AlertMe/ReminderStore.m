//
//  ReminderStore.m
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReminderStore.h"
#import "Reminder.h"

@interface ReminderStore ()
@property (nonatomic, retain) NSArray *archiveArray;

- (NSString *)reminderArchivePath;

@end

@implementation ReminderStore

@synthesize archiveArray;
@synthesize allReminders;
@synthesize favoritePlaces;

+ (ReminderStore *)defaultStore 
{
    static ReminderStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[ReminderStore alloc] init];
    });
    return defaultStore;
}

- (id) init 
{
    self = [super init];
    if (self) {
        NSString *path = [self reminderArchivePath];
        archiveArray = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
        if (archiveArray) {
            allReminders = [archiveArray objectAtIndex:0];
            favoritePlaces = [archiveArray objectAtIndex:1];
        }
        else {
            allReminders = [[NSMutableArray alloc] initWithCapacity:10];
            favoritePlaces = [[NSMutableArray alloc] initWithCapacity:10];
            archiveArray = [[NSArray alloc] initWithObjects:allReminders, favoritePlaces, nil];
        }
    }
    return self; 
}

- (void)saveReminder:(Reminder *)r {
    [allReminders addObject:r];
}

- (void)removeReminder:(Reminder *)r {
    [allReminders removeObjectIdenticalTo:r];
}

- (void)replaceReminder:(Reminder *)r index:(int)i {
    [allReminders replaceObjectAtIndex:i withObject:r];
}

- (NSString *)reminderArchivePath {
    return pathInDocumentDirectory(@"reminders.data");
}

- (BOOL)saveChanges {
    return [NSKeyedArchiver archiveRootObject:archiveArray toFile:[self reminderArchivePath]];
}

@end
