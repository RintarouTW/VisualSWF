//
//  HostView.m
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "HostView.h"

@implementation HostView

@synthesize rootLayer, linkLayer, previewLayer;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    //NSLog(@"initWithFrame");
    if (self) {
        // Initialization code here.
        [[self window] setAcceptsMouseMovedEvents:YES];
        
        [self updateTrackingAreas];
        
        [self setWantsLayer:YES];
        
        backingLayer = [[BackingLayer alloc] init];
        [self setLayer:backingLayer];
        [backingLayer release]; // now backingLayer is owned by HostView
        
        rootLayer = [[RootLayer alloc] init];
        [backingLayer addSublayer:rootLayer];
        [rootLayer release];    // now rootLayer is owned by backingLayer

        linkLayer = [[LinkLayer alloc] init];
        linkLayer.rootLayer = rootLayer;
        [backingLayer insertSublayer:linkLayer below:rootLayer];
        backingLayer.linkLayer = linkLayer;
        [linkLayer release];  // now linkLayer is owned by backingLayer
        
        previewLayer = [[PreviewLayer alloc] init];
        [backingLayer addSublayer:previewLayer];
        backingLayer.previewLayer = previewLayer;
        [previewLayer release];
        
        [backingLayer setNeedsDisplay];
        [rootLayer setNeedsDisplay];
        
    }
    return self;
}

- (void)dealloc
{
    [trackingArea release];
    [self removeFromSuperview];
    [super dealloc];
}

- (BOOL)isFlipped
{
    return  YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

///////////////////// Point Conversion //////////////////

// return the point in backingLayer's coordinate of theEvent
-(CGPoint)eventLocationInBackingLayer:(NSEvent *)theEvent
{
    NSPoint evtLocationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    CGPoint evtLocationInBackingLayer = CGPointMake([backingLayer bounds].origin.x + evtLocationInView.x, 
                                                      [backingLayer bounds].origin.y + evtLocationInView.y);
    return evtLocationInBackingLayer;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// View Translation & Content Scaling
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)checkViewRange:(BOOL)disableAnimation
{

    // Try to get RootLayer.frame (real frame)
    // RootLayer.frame.origin is alway (0,0) since we are moving the view's bounds instead of moving the content.

    CGRect rootLayerBounds = CGRectMake(0, 0, rootLayer.width, rootLayer.height);
    CGRect rootLayerFrame = [rootLayer convertRect:rootLayerBounds toLayer:backingLayer];
    
    CGRect backLayerBounds = [backingLayer bounds];

#ifdef F2C
    CGFloat blankLimitWidth = 0;
    CGFloat blankLimitHeight = backLayerBounds.size.height / 2;
#else
    CGFloat blankLimitWidth = backLayerBounds.size.width / 4;
    CGFloat blankLimitHeight = backLayerBounds.size.height / 2;
#endif

    if (rootLayerFrame.size.width <= backLayerBounds.size.width) {
#ifdef F2C
        backLayerBounds.origin.x = -100;
#else
        // keep the content in the center of the view.
        backLayerBounds.origin.x = (rootLayerFrame.size.width - backLayerBounds.size.width) / 2;
#endif
    } else {
        // keep the view inside of the content
        if (backLayerBounds.origin.x < -blankLimitWidth) {
            backLayerBounds.origin.x = -blankLimitWidth;
        }
        if ((backLayerBounds.origin.x + backLayerBounds.size.width) > (rootLayerFrame.size.width + blankLimitWidth)) {
            backLayerBounds.origin.x = rootLayerFrame.size.width + blankLimitWidth - backLayerBounds.size.width;
        }
    }

    if (rootLayerFrame.size.height <= backLayerBounds.size.height) {
        // keep the content in the center of the view.
        backLayerBounds.origin.y = (rootLayerFrame.size.height - backLayerBounds.size.height) / 2;
    } else {
        // keep the view inside of the content
        if (backLayerBounds.origin.y < -blankLimitHeight) {
            backLayerBounds.origin.y = -blankLimitHeight;
        }
        if ((backLayerBounds.origin.y + backLayerBounds.size.height) > (rootLayerFrame.size.height + blankLimitHeight)) {
            backLayerBounds.origin.y = rootLayerFrame.size.height + blankLimitHeight - backLayerBounds.size.height;
        }
    }
    
    if (disableAnimation) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        [backingLayer setBounds:backLayerBounds];
        [CATransaction commit];
    } else {
        [backingLayer setBounds:backLayerBounds];
    }
    
}


-(void)scaleContent:(CGFloat) scale
{

    CGAffineTransform currTransform = [rootLayer affineTransform];
    
    // scale RootLayer with affine transformation    
    currTransform = CGAffineTransformScale(currTransform, scale, scale);
    
    if (currTransform.a > 1) {
        currTransform.a = 1;
        currTransform.d = 1;
    }
    /* temparily disable animation */
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    [rootLayer setAffineTransform:currTransform];
    [CATransaction commit];
    
    //NSLog(@"rootLayer frame (%f, %f, %f, %f)", [rootLayer frame].origin.x, [rootLayer frame].origin.y, [rootLayer frame].size.width, [rootLayer frame].size.height);
}

// Although mouse draging looks like moving the content,
// it's acutally moving the view in reversed direction.
// So the origin of the content's coordinate is never moved.
- (void)moveViewOffset:(CGPoint)offset disableAnimation:(BOOL)disabled
{
    CGRect bounds = [backingLayer bounds];
    
    // Try moving bounds instead of moving content(Root layer)    
    bounds.origin.x -= offset.x;
    bounds.origin.y -= offset.y;
    
    if (disabled) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        [backingLayer setBounds:bounds];
        [CATransaction commit];
    } else {
        [backingLayer setBounds:bounds];
    }
}

-(void)focusOnOwnerRowAnchor:(TableLayer *)table
{
    if (table.ownerTable) {
        CGPoint linkedRowAnchorInOwnerTable = [rootLayer convertPoint:table.myLink.ownerAnchorPoint toLayer:backingLayer];
        linkedRowAnchorInOwnerTable.x -= 10;
        NSPoint currentMouseLocation = [[self window] mouseLocationOutsideOfEventStream];
        NSPoint currentLocationInView = [self convertPoint:currentMouseLocation fromView:nil];
        CGPoint currentLocationInBackingLayer = CGPointMake([backingLayer bounds].origin.x + currentLocationInView.x, 
                                                            [backingLayer bounds].origin.y + currentLocationInView.y);
        
        // Shift to the ownerAnchorPoint.
        CGPoint offset = CGPointMake(currentLocationInBackingLayer.x - linkedRowAnchorInOwnerTable.x , currentLocationInBackingLayer.y - linkedRowAnchorInOwnerTable.y);
        [self moveViewOffset:offset disableAnimation:NO];
        [focusedTableLayer lostFocus];
        focusedTableLayer = table.ownerTable;
        [focusedTableLayer onFocused];
    }
}

-(void)focusOnRow:(TableLayer *)table
{
    TableLayer *tableOfRow = [table tableOfFocusedRow];
    
    if (tableOfRow) {
        CGPoint linkedAnchor = [rootLayer convertPoint:tableOfRow.myLink.anchorOfTable toLayer:backingLayer];
        linkedAnchor.x += 10;

        NSPoint currentMouseLocation = [[self window] mouseLocationOutsideOfEventStream];
        NSPoint currentLocationInView = [self convertPoint:currentMouseLocation fromView:nil];
        CGPoint currentLocationInBackingLayer = CGPointMake([backingLayer bounds].origin.x + currentLocationInView.x, 
                                                            [backingLayer bounds].origin.y + currentLocationInView.y);

        // Shift to the ownerAnchorPoint.
        CGPoint offset = CGPointMake(currentLocationInBackingLayer.x - linkedAnchor.x , currentLocationInBackingLayer.y - linkedAnchor.y);
        [self moveViewOffset:offset disableAnimation:NO];
        [focusedTableLayer lostFocus];
        focusedTableLayer = tableOfRow;
        [focusedTableLayer onFocused];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Mouse Event Handlers
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTrackingAreas
{
    [trackingArea release];
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways )
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];    
}

-(void)mouseDown:(NSEvent *)theEvent 
{
    lastDragLocation = [theEvent locationInWindow];
}

-(void)mouseUp:(NSEvent *)theEvent 
{
    [self checkViewRange:YES];    
}

- (void)mouseMoved: (NSEvent *)theEvent {

    CGPoint mouseLocationInBackingLayer = [self eventLocationInBackingLayer:theEvent];
    CALayer *hitLayer = [rootLayer hitTest:mouseLocationInBackingLayer];

    BOOL focusChanged = NO;

    // If hit TableLayer
    if (hitLayer) {
        if (focusedTableLayer) {
            if (focusedTableLayer != hitLayer) {    // focus changed
                [focusedTableLayer lostFocus];
                focusedTableLayer = (TableLayer *)hitLayer;
                [focusedTableLayer onFocused];
                focusChanged = YES;
            }
            // else do nothing, the same table still be focused.
            // notify the mouse point in it's own coordinate.
            CGPoint mouseLocationInFocusedTableLayer = [backingLayer convertPoint:mouseLocationInBackingLayer toLayer:focusedTableLayer];
            [focusedTableLayer mouseMove:mouseLocationInFocusedTableLayer];
        } else {
            // new focused table happened.
            focusedTableLayer = (TableLayer *)hitLayer;
            [focusedTableLayer onFocused];
            focusChanged = YES;
        }
    } else {    // original focused table lost focus.
        if (focusedTableLayer) {
            [focusedTableLayer lostFocus];
        }
        focusedTableLayer = nil;
        [previewLayer hide];
    }
    
    ////////////////////////////
    // Try to draw the preview
    ////////////////////////////
    
    if (focusChanged && focusedTableLayer) {
        previewLayer.previewedTable = focusedTableLayer;
        
        CGRect prevFrame = [previewLayer frame];        
        prevFrame.origin.x = mouseLocationInBackingLayer.x + 200;
        prevFrame.origin.y = mouseLocationInBackingLayer.y;
        //NSLog(@"preFrame.origin %f, %f, %f, %f", preFrame.origin.x, preFrame.origin.y, preFrame.size.width, preFrame.size.height);
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        [previewLayer setFrame:prevFrame];
        [CATransaction commit];
        
        BOOL canBePreview = [previewLayer drawPreviewOfVObject:focusedTableLayer.vobject];
        if (canBePreview) {
            [previewLayer show];
        } else {
            [previewLayer hide];
        }
    }

}





-(void)scrollWheel:(NSEvent *)theEvent {
    
    
    CGFloat deltaY = [theEvent deltaY];
    if (deltaY == 0)
        return;
    
    if (deltaY > 0) {
        [self scaleContent:1.0/0.9];
    } else {
        [self scaleContent:0.9];
    }
    
    [self checkViewRange:YES];
}


-(void)magnifyWithEvent:(NSEvent *)event {
    //NSLog(@"mganifyWithEvent");
}


-(void)rightMouseDown:(NSEvent *)theEvent
{
    lastDragLocation = [theEvent locationInWindow];
    if (focusedTableLayer) {    // dispatch the rightMouseDown event to the focused table.        
        CGPoint mouseLocationInBackingLayer = [self eventLocationInBackingLayer:theEvent];
        CGPoint mouseLocationInFocusedTableLayer = [backingLayer convertPoint:mouseLocationInBackingLayer toLayer:focusedTableLayer];
        [focusedTableLayer rightMouseDown:mouseLocationInFocusedTableLayer];
    }
}


-(void)rightMouseDragged:(NSEvent *)theEvent {
}


-(void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint newDragLocation = [theEvent locationInWindow];
    
    // offset the pill by the change in mouse movement
        
    float offsetX = (newDragLocation.x - lastDragLocation.x);

#ifdef F2C
    offsetX = 0;
#endif // F2C
    
    //float offsetY = (newDragLocation.y - lastDragLocation.y);
    float offsetY = (lastDragLocation.y - newDragLocation.y);   // convert to flipped coordinate.

    //NSLog(@"(%f, %f) => (%f, %f), offset (%f, %f)", lastDragLocation.x, lastDragLocation.y, newDragLocation.x, newDragLocation.y, offsetX, offsetY);

    lastDragLocation = newDragLocation;

    [self moveViewOffset:CGPointMake(offsetX, offsetY) disableAnimation:YES];
}


-(void)keyDown:(NSEvent *)theEvent
{
    NSString *chars = [theEvent characters];
    unsigned int length = [chars length];
    for (int i = 0; i < length; ++i)
    {
        switch ([chars characterAtIndex:i]) {
            case NSLeftArrowFunctionKey:
                if (focusedTableLayer) {
                    [self focusOnOwnerRowAnchor:focusedTableLayer];
                    focusedTableLayer = focusedTableLayer.ownerTable;
                }
                break;
            case NSRightArrowFunctionKey:
                if (focusedTableLayer) {
                    [self focusOnRow:focusedTableLayer];
                }
                break;
            default:
                break;
        }
    }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////