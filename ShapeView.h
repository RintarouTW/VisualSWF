//
//  ShapeView.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShapeDrawer.h"

@interface ShapeView : NSView {
    id <ShapeDrawer> drawer;
    NSInteger       viewTag;
    BOOL            isFocused;
    BOOL            drawn;
    BOOL            needCache;
    BOOL            isCacheReady;
    BOOL            nonFirst;
    CGLayerRef      cgCache;
}

@property (assign) id <ShapeDrawer> drawer;
@property (assign) BOOL             isFocused;
@property (assign) BOOL             needCache;

- (void)setTag:(NSInteger)_tag;

@end
