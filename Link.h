//
//  Link.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/21.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

@interface Link : NSObject
{
    CGPoint ownerAnchorPoint;
    CGPoint anchorOfTable;
}

@property (assign) CGPoint ownerAnchorPoint;
@property (assign) CGPoint anchorOfTable;

@end
