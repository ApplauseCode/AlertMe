//
//  InboxViewController.m
//  AlertMe
//
//  Created by Jeffrey Rosenbluth on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InboxViewController.h"
#import "EditViewController.h"
#import "ReminderStore.h"
#import "Reminder.h"
#import "CustomCell.h"
#import "AppDelegate.h"

@interface InboxViewController() 

@property (retain, nonatomic) IBOutlet UIView *noReminderView;
@property (retain, nonatomic) IBOutlet UIView *bgView;

@property (assign, nonatomic) BOOL editing;

@end

@implementation InboxViewController

@synthesize noReminderView;
@synthesize bgView;
@synthesize edit_vc2;
@synthesize editing;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"NoRemindersView" owner:self options:nil];
        [[NSBundle mainBundle] loadNibNamed:@"BGView" owner:self options:nil];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES]; 
    }
    return self;
}
 
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void) update: (NSTimer *) timer;
{
    if (editing) return;
    ReminderStore *rs = [ReminderStore defaultStore];
    NSMutableSet *remindersToDelete = [[NSMutableSet alloc] initWithCapacity:1];
    for (Reminder *r in [rs allReminders]) 
        if ([[r endDate] compare:[NSDate date]] == NSOrderedAscending) 
            [remindersToDelete addObject:r];
    for (Reminder *r in remindersToDelete)
        [rs removeReminder:r];
    [remindersToDelete release];
    [[self tableView] reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setNoReminderView: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [[self tableView] setRowHeight:58];
    UIView *footer =
    [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    [footer release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ReminderStore *rs = [ReminderStore defaultStore];
    int numberOfCells = [[rs allReminders] count];
    if (numberOfCells == 0) {
        [self.view addSubview:noReminderView];
        [self.tableView setScrollEnabled:NO];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    else if (noReminderView) { 
        [noReminderView removeFromSuperview];
        [self.tableView setScrollEnabled:YES];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        tableView.separatorColor = [UIColor blackColor];
        [[self tableView] setBackgroundView:bgView];
    }
    return [[rs allReminders] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderStore *rs = [ReminderStore defaultStore];
    static NSString *CellIdentifier = @"CustomCellIdentifier";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[CustomCell class]]) 
                cell = (CustomCell *)oneObject;
    }
    cell.reminderLabel.text = [[[rs allReminders] objectAtIndex:[indexPath row]] text];
    cell.detailLabel.text = [[[rs allReminders] objectAtIndex:[indexPath row]] timeToExpiration];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLLocationManager *locationManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] clloc];
    ReminderStore *rs = [ReminderStore defaultStore];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Reminder *r = [[rs allReminders] objectAtIndex:[indexPath row]];
        NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *notification in allNotifications) {
            if (([r.text isEqual:notification.alertBody]) && ([r.endDate isEqual:notification.fireDate])) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }
        [[rs allReminders] removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        if ([r isLocationBased])
             [locationManager stopMonitoringForRegion:[r aRegion]];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    } 
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (edit_vc2) {
        [edit_vc2 release];
    }
    edit_vc2 = [[EditViewController alloc] init];
    [edit_vc2 setIsNewReminder:NO];
    [edit_vc2 setReminderIndex:[indexPath row]];
    ReminderStore *rs = [ReminderStore defaultStore];
    NSArray *a = [rs allReminders];
    Reminder *reminder = [a objectAtIndex:[indexPath row]];
    [edit_vc2 setReminder:reminder];
    [self presentModalViewController:edit_vc2 animated:YES];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setEditing:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setEditing:NO];
}
@end
