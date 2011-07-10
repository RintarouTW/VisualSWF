//
//  AnchorLayer.h
//  
//
//  Created by Rintarou on 2011/1/17.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>
#import "RootLayer.h"
#import "Link.h"



@interface LinkLayer : CALayer {
    RootLayer *rootLayer;
    NSMutableArray *linksArray;
}

@property (assign) RootLayer *rootLayer;

- (Link *)addLinkWithOwnerAnchor:(CGPoint)ownerAnchorPoint andAnchorOnTable:(CGPoint)anchorOfTable;
- (void)drawInContext:(CGContextRef)ctx;    // responsible for draw the anchors

@end
