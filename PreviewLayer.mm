//
//  PreviewLayer.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "PreviewLayer.h"

#import "VMatrix.h"
#import "VGradient.h"
#import "VFillStyle.h"

// Drawers
#import "VEdge.h"
#import "VColor.h"
#import "VShape.h"
#import "VDefineShape.h"


// Tag Drawer
#import "VDefineBitsLossless.h"
#import "VDefineBitsJPEG.h"

#import "style.h"

@implementation PreviewLayer

@synthesize previewedTable, canvasCodeViewController;

- (id) init {
    self = [super init];
    if (self) {
        // Initialization code here.
        //self.geometryFlipped = YES;
        //self.borderWidth = 1.0;
        self.shadowOpacity = 0.8;
        self.shadowOffset = CGSizeMake(0, 3.0);
        //[self setFrameSizeWidth:500 andHeight:500];
        CGRect myBounds = [self bounds];
        myBounds.origin.x = -10;
        myBounds.origin.y = -10;
        [self setBounds:myBounds];
        [self removeAllAnimations];
        self.anchorPoint = CGPointMake(0, 0.5);
    }
    return self;    
}

- (void)dealloc 
{
    [super dealloc];
}


- (void)setPreviewedTable:(TableLayer *)theTable
{
    if (previewedTable) {   // previewed table was changed
        previewedTable.previewer = nil; // not his previewer anymore.
    }
    
    previewedTable = theTable;
    previewedTable.previewer = self;    // tell previewed table that I am his previewer.
}

- (void)stepPreview
{
    if (drawer) {
        if ([drawer class] == [VShape class]) {
            VShape *shape = drawer;
            [shape startStepDrawing];
        }
    }
}

- (void)show
{
    CGRect paddedBounds = pathBounds;
    paddedBounds.origin.x    -= PREVIEWBOX_PADDING_X;
    paddedBounds.origin.y    -= PREVIEWBOX_PADDING_Y;
    paddedBounds.size.width  += PREVIEWBOX_PADDING_X * 2;
    paddedBounds.size.height += PREVIEWBOX_PADDING_Y * 2;
    [self setBounds:paddedBounds];  // focus on the previewed bounds
    [self setFrameSizeWidth:(paddedBounds.size.width) andHeight:(paddedBounds.size.height)];
}

- (void)hide
{
    if (drawer) {
        [drawer release];  // it is ok to release it.
        drawer = nil;
    }    
    [self setFrameSizeWidth:0 andHeight:0];
}

- (void)setFrame:(CGRect)rect
{
    [super setFrame:rect];
}

- (void)setFrameSizeWidth:(CGFloat)width andHeight:(CGFloat)height
{
    CGRect myFrame = [self frame];
    myFrame.size.width = width;
    myFrame.size.height = height;
    [self setFrame:myFrame];
}

- (BOOL)drawPreviewOfVObject:(VObject *)vobj
{
    if (!vobj)
        return NO;
    
    const char *type = vobj->getTypeInfo();
    
    if (!type)
        return NO;
    
    //NSLog(@"vobj typeinfo = %s", type);    
    
    if ((strcmp(type, "DefineBitsLossless") == 0) ||
        (strcmp(type, "DefineBitsLossless2") == 0) 
        )
    {
        VDefineBitsLossless *tag = [[VDefineBitsLossless alloc] initWithVObject:vobj];
        drawer = tag;
        pathBounds = [tag getPreviewBounds];
        [self setNeedsDisplay];
        return YES;
    }

    if ((strcmp(type, "DefineBits") == 0) ||
        (strcmp(type, "DefineBitsJPEG2") == 0) ||
        (strcmp(type, "DefineBitsJPEG3") == 0) ||
        (strcmp(type, "DefineBitsJPEG4") == 0) 
        )
    {
        VDefineBitsJPEG *tag = [[VDefineBitsJPEG alloc] initWithVObject:vobj];
        drawer = tag;
        pathBounds = [tag getPreviewBounds];
        [self setNeedsDisplay];
        return YES;
    }
    
    /* Preview STRAIGHTEDGERECORD */
    if (strcmp(type, "STRAIGHTEDGERECORD") == 0) {
        VEdge *edge = [[VEdge alloc] init]; // released after drawInContext.
        drawer = edge;
        
        CGFloat deltaX, deltaY;
        
        deltaX = (*vobj)["DeltaX"].asInt();
        deltaY = (*vobj)["DeltaY"].asInt();
                
        CGPoint startP = CGPointMake(0, 0);
        CGPoint endP   = CGPointMake(deltaX, deltaY);
        
        [edge asLineWithStart:startP andEnd:endP];   // startP, endP are in TWIPS
        pathBounds = [edge getPreviewBounds];
        
        [self setNeedsDisplay];
        return YES;
    }

    /* Preview CURVEDEDGERECORD */
    if (strcmp(type, "CURVEDEDGERECORD") == 0) {
        VEdge *edge = [[VEdge alloc] init]; // released after drawInContext.
        drawer = edge;
        
        CGFloat controlDeltaX, controlDeltaY, anchorDeltaX, anchorDeltaY;
        
        controlDeltaX = (*vobj)["ControlDeltaX"].asInt();
        controlDeltaY = (*vobj)["ControlDeltaY"].asInt();
        anchorDeltaX = (*vobj)["AnchorDeltaX"].asInt();
        anchorDeltaY = (*vobj)["AnchorDeltaY"].asInt();
        
        CGPoint startP = CGPointMake(0, 0);
        CGPoint controlP = CGPointMake(controlDeltaX, controlDeltaY);
        CGPoint endP   = CGPointMake(controlDeltaX + anchorDeltaX, controlDeltaY + anchorDeltaY);
        
        
        [edge asCurveWithStart:startP andControl:controlP andEnd:endP];   // startP, controlP, endP are in TWIPS
        pathBounds = [edge getPreviewBounds];
        
        [self setNeedsDisplay];
        return YES;
    }

    /* Preview SHAPE */
    if (strcmp(type, "SHAPE") == 0) {
        VShape *shape = [[VShape alloc] initWithShape:vobj];
        
        drawer = shape;
        pathBounds = [shape getPreviewBounds];
        [self setNeedsDisplay];
        return YES;
    }
    
    /* Preview SHAPEWITHSTYLE */
    if (
        //(strcmp(type, "SHAPEWITHSTYLE") == 0)   ||
        (strcmp(type, "DefineShape") == 0)      ||
        (strcmp(type, "DefineShape2") == 0)     ||
        (strcmp(type, "DefineShape3") == 0)     ||
        (strcmp(type, "DefineShape4") == 0)
        )
    {
        //VShapeWithStyle *shapeWithStyle;
        //if (strcmp(type, "SHAPEWITHSTYLE") == 0) {
        //    shapeWithStyle = [[VShapeWithStyle alloc] initWithShapeWithStyle:vobj];
        //} else {
        //    shapeWithStyle = [[VShapeWithStyle alloc] initWithShapeWithStyle:&(*vobj)["Shapes"]];
        //}
        
        VDefineShape *shape = [[VDefineShape alloc] initWithVObject:vobj];
        
        drawer = shape;
        pathBounds = [shape getPreviewBounds];
        
        //[Shared dumpRect:pathBounds andRectName:"pathBounds"];
        [self setNeedsDisplay];
        return YES;
    }
    
    /* Preview SetBackgroundColor */
    if (strcmp(type, "SetBackgroundColor") == 0) {
        VColor *color = [[VColor alloc] initWithColorString:(*vobj)["BackgroundColor"].asString()]; // released after drawInContext.
        drawer = color;
        pathBounds = [color getPreviewBounds];

        [self setNeedsDisplay];
        return YES;
    }

    /* Preview FILLSTYLE (Solid Fill) */
    if (
        (strcmp(type, "FILLSTYLE (Solid Fill)") == 0) ||
        (strcmp(type, "GRADRECORD") == 0) 
        ) 
    {
        VColor *color = [[VColor alloc] initWithColorString:(*vobj)["Color"].asString()]; // released after drawInContext.
        drawer = color;
        pathBounds = [color getPreviewBounds];
        
        [self setNeedsDisplay];
        return YES;
    }
    
    if (strcmp(type, "GRADIENT") == 0) {
        CGAffineTransform boxMatrix = [VMatrix createGradientBox:CGRectMake(0, 0, COLOR_BOX_WIDTH, COLOR_BOX_HEIGHT)];
        VGradient *gradient = [[VGradient alloc] initWithGradientVObject:vobj withGradientMatrix:boxMatrix andType:0x10];
        drawer = gradient;
        pathBounds = [gradient getPreviewBounds];
        [self setNeedsDisplay];
        return YES;                                
    }
    
    if (
        (strcmp(type, "FILLSTYLE (Linear Gradient Fill)") == 0) ||
        (strcmp(type, "FILLSTYLE (Radial Gradient Fill)") == 0)
        )
    {
        VFillStyle *fillstyle = [[VFillStyle alloc] initWithFillStyleVObject:vobj];
        drawer = fillstyle;
        pathBounds = [fillstyle getPreviewBounds];
        [self setNeedsDisplay];
        return YES;        
    }
    
    return NO;  // vobj is not supported to be previewed.
}


- (void)drawInContext:(CGContextRef)ctx
{
    //CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);  // Default Fill Color
    [VColor setContextFillColor:ctx withCSSColor:PREVIEW_DEFAULT_FILLCOLOR];
    [VColor setContextStrokeColor:ctx withCSSColor:PREVIEW_DEFAULT_STROKE_COLOR];
    
    if ([drawer class] == [VShape class]) {
        if (!((VShape *)drawer).contextLayer) {
            ((VShape *)drawer).contextLayer = self;  // for step drawing
        }
    }
    
    [drawer drawPreviewInContext:ctx];
    
    if ([drawer class] == [VDefineShape class]) {
        [canvasCodeViewController setCode:((VDefineShape *)drawer).canvasStr withSize:pathBounds.size]; // where pathBounds = VDefineShape.previewPathBounds
    }
}

@end
