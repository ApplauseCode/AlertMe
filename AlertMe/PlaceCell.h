//
//  PlaceCell.h
//  AlertMe
//
//  Created by Reed Rosenbluth on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceCell : UITableViewCell
{
    UILabel *placeLabel;
    UILabel *addressLabel;
    UIButton *starButton;
}

@property (nonatomic, retain) IBOutlet UILabel *placeLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UIButton *starButton;


@end
