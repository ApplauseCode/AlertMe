//
//  CustomCell.h
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
{
    UILabel *reminderLabel;
    UILabel *detailLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *reminderLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;

@end
