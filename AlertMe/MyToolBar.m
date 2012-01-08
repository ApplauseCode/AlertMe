//
//  MyToolBar.m
//  AlertMe
//
//  Created by Reed Rosenbluth on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyToolbar.h"

@implementation MyToolbar

- (void)drawRect:(CGRect)rect {
    UIImage *backgroundImage = [UIImage imageNamed:@"AlertMeCustomNavBar2"];
    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
