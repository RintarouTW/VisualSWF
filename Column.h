//
//  ColumnView.h
//  
//
//  Created by Rintarou on 2010/12/19.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>
#import "TableLayer.h"

/*
 Grid Layout is to use position instead of table width.
 Caller:
 1. column = [[Column alloc] init];
 2. column.centerX = ?
 3. [column addTable:table];
 */

@interface Column : NSObject {
    NSMutableArray *rows;
    float frameX;
    uint maxTableWidth;
    uint lastTableBottom;
}

@property (assign) float frameX;
@property (readonly) uint lastTableBottom;

- (void)addTable:(TableLayer *)table;

@end
