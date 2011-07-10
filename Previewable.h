//
//  Previewable.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol Previewable <NSObject>

- (void)drawPreviewInContext:(CGContextRef)ctx;
- (CGRect)getPreviewBounds;

@end

// for TableLayer callback.
@protocol StepPreviewer <NSObject>

- (void)stepPreview;

@end