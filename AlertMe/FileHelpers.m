//
//  FileHelpers.m
//  AlertMe
//
//  Created by Reed Rosenbluth on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileHelpers.h"

NSString *pathInDocumentDirectory(NSString *fileName)
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:fileName];
}
