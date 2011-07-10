//
//  PreviewLayer.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//


#import "Share.h"
#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus

#import "Previewable.h"
// Previewable (Previewed)
#import "TableLayer.h"

#import "CanvasCodeViewController.h"

@interface PreviewLayer : CALayer <StepPreviewer> {
    id <Previewable> drawer;        // The drawer object which draw the paths described in the previewedTable.
    TableLayer *previewedTable;     // The table was previewed.
    CGRect pathBounds;
    
    CanvasCodeViewController *canvasCodeViewController; // ************* Bad Design *********** TODO (Must be refined)
}

@property (assign) CanvasCodeViewController *canvasCodeViewController;
@property (assign) TableLayer *previewedTable;

#ifdef __cplusplus
- (BOOL)drawPreviewOfVObject:(VObject *)vobj; // If vobj can be previewed, create the corresponding Vxxxx and return YES.
#endif // __cplusplus

- (void)stepPreview;                // for SHAPE drawing step by step.

- (void)show;
- (void)hide;
- (void)setFrameSizeWidth:(CGFloat)width andHeight:(CGFloat)height;

@end
