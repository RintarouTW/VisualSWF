//
//  F2CView.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/10.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/* 
 View Design:
 Window.contentView.F2CView
 F2CView is backed by CALayer (rootLayer which is not RootLayer), naming is refined.
 1. Using NSView instead of CALayer? (seems ok.. since F2C is not focusing on visualization)
    There is no need to deal with so many items at a time.
    Layer-Backed Views

 NSView:
 setCanDrawConcurrently:
 Sets whether the view’s drawRect: method can be invoked on a background thread.
 - (void)setCanDrawConcurrently:(BOOL)flag
 // no need to design threading traverser
 
 NSViewLayoutManager is required. 
 If window size is changed.
 Another solution:
  - One column only.
  - scroll view as a container.
  - WebView in the right side.
  - CodeView in the right side.
 
 
 2. Usability is important than visualization in F2C.
 3. CoverFlow design? (X) maybe later.
 4. draw the shapes in each view's context directly. (OK)
 5. LayoutManager? (X)
 */

// F2CView should be the document view of a scroll view

@protocol FocusChange

- (void)focusChange:(NSView *)theView;
- (void)select:(NSView *)theView;

@end


@interface F2CView : NSView {
    NSTrackingArea      *trackingArea;
    NSView              *focusedView;
    id <FocusChange>    delegate;       // the handler who want to know focus changed.
    
    NSOperationQueue    *cacheBuildQueue;   // the queue for building cached shapes (subviews)
}

@property (assign) IBOutlet id <FocusChange> delegate;

- (void)addCacheBuildOperation:(NSOperation *)op;
- (void)reset;

@end
