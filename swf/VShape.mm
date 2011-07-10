//
//  VShape.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VShape.h"

#import "VColor.h"
#import "style.h"

@implementation VShape

@synthesize contextLayer;

- (id) initWithShape : (VObject *)theShapeVObject
{
    self = [super init];
    if (self) {
        // init
        shapeRecords = &((*theShapeVObject)["ShapeRecords"]);
        
        // TODO : error handling
        
        vpaths = [[NSMutableArray alloc] init];
        previewPath = CGPathCreateMutable();
        [self parseShapeRecords];
        stepCounter = [vpaths count] + 1;   // init to show all
        //stepCounter = 0;
    }
    return self;
}

- (void)dealloc
{
    CGPathRelease(previewPath);
    [vpaths release];
    [super dealloc];
}

- (void)parseShapeRecords
{
    /* draw origin (0, 0) */
    CGPathAddArc(previewPath, nil, 0, 0, ORIGIN_RADIUS, 0, M_PI * 2, 0);
    
    for (uint i = 0; i < shapeRecords->length(); i++) {

        VObject &record = (*shapeRecords)[i];
        
        const char *typeOfshapeRecord = record.getTypeInfo();
        //NSLog(@"type of shape reocrd = %s", typeOfshapeRecord);
        
        if (strcmp(typeOfshapeRecord, "CURVEDEDGERECORD") == 0) {
            CGPoint sp, cp, ep;
            
            sp = pen;
            cp.x = pen.x + record["ControlDeltaX"].asInt();
            cp.y = pen.y + record["ControlDeltaY"].asInt();
            ep.x = cp.x  + record["AnchorDeltaX"].asInt();
            ep.y = cp.y  + record["AnchorDeltaY"].asInt();
            pen = ep;
            
            //NSLog(@"%d) curve (%.3f, %.3f, %.3f, %.3f, %.3f, %.3f) pen (%.3f, %.3f)", i, sp.x, sp.y, cp.x, cp.y, ep.x, ep.y, pen.x, pen.y);
            
            VEdge *edge = [[[VEdge alloc] init] autorelease];
            [edge asCurveWithStart:sp andControl:cp andEnd:ep];
            
            [vpaths addObject:edge];
            [edge drawInPath:previewPath withTransform:nil withReversed:NO];
            //[VArrow drawInPath:path withVector:edge.delta];
        }
        if (strcmp(typeOfshapeRecord, "STYLECHANGERECORD") == 0) {
            // Deal with MoveDeltaX and MoveDeltaY only. 
            // TODO: SHAPE has fill style changes?? (seems so..wird)
            if (record["StateMoveTo"].asUInt()) {
                pen.x = record["MoveDeltaX"].asInt();
                pen.y = record["MoveDeltaY"].asInt();                
                
                VMoveToPoint *mp = [[[VMoveToPoint alloc] initWithMoveToPoint:pen] autorelease];
                [vpaths addObject:mp];
                [mp drawInPath:previewPath withTransform:nil];
                
            } else {
                //NSLog(@"no move record");
            }
        }
        if (strcmp(typeOfshapeRecord, "STRAIGHTEDGERECORD") == 0) {
            CGPoint delta, sp, ep;
            
            delta.x = record["DeltaX"].asInt();
            delta.y = record["DeltaY"].asInt();
            
            sp = pen;
            ep.x = sp.x  + delta.x;
            ep.y = sp.y  + delta.y;
            pen = ep;

            //NSLog(@"%d) line (%.3f, %.3f, %.3f, %.3f) pen (%.3f, %.3f)", i, sp.x, sp.y, ep.x, ep.y, pen.x, pen.y);

            VEdge *edge = [[[VEdge alloc] init] autorelease];
            [edge asLineWithStart:sp andEnd:ep];
            
            [vpaths addObject:edge];
            [edge drawInPath:previewPath withTransform:nil withReversed:NO];
            //[VArrow drawInPath:path withVector:delta];
        }
    }
    
    previewPathBounds  = CGPathGetBoundingBox(previewPath);
}


- (void)startStepDrawing
{
    stepCounter = 0;
    [contextLayer setNeedsDisplay];
}

- (void)startStepTimer
{
    // timer to call traverseList
    if (contextLayer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:SHAPE_STEP_DRAW_TIMER_INTERVAL target:self selector:@selector(stepDraw:) userInfo:nil repeats: NO];
        //NSLog(@"timer started");
    }
}

- (void)stepDraw:(NSTimer *)theTimer
{
    stepCounter++;
    //NSLog(@"stepCounter = %d", stepCounter);

    // ask previewLayer to setNeedsDisplay
    [contextLayer setNeedsDisplay];
}

// Tring to draw the all preview by myself with CGPath
// Show more detail
- (void)drawStepPreviewInContext:(CGContextRef)ctx
{
    //NSLog(@"draw preview - stepCounter = %d", stepCounter);
    // draw origin
    CGContextAddArc(ctx, 0, 0, ORIGIN_RADIUS, 0, M_PI * 2, NO);
    CGContextStrokePath(ctx);
    
    for (int i = 0; i < [vpaths count]; i++) {
        
        if (i == stepCounter) {
            break;
        }
        
        id obj = [vpaths objectAtIndex:i];
        
        if ([obj class] == [VEdge class]) {
            VEdge *edge = (VEdge *)obj;
            [VColor setContextStrokeColor:ctx withCSSColor:SHAPE_STEP_DRAW_EDGE_STROKE_COLOR];
            CGContextSetLineDash(ctx, 1, nil, 0);
            [edge drawInContext:ctx withReversed:NO];
            
            CGPoint cp = CGContextGetPathCurrentPoint(ctx);
            
            [VArrow drawInContext:ctx withVector:edge.delta];
            CGContextStrokePath(ctx);
            CGContextMoveToPoint(ctx, cp.x, cp.y);
        }
        
        if ([obj class] == [VMoveToPoint class]) {
            VMoveToPoint *mp = (VMoveToPoint *)obj;
            
            // drawing in the context directly to draw the aditional notations.
            
            // setup the fill style.
            [VColor setContextStrokeColor:ctx withCSSColor:SHAPE_STEP_DRAW_MOVE_POINT_STROKE_COLOR];
            
            CGFloat lengths[2] = {4.0,4.0}; 
            CGContextSetLineDash(ctx, 0, lengths, 1);
            
            // draw the dash line as a delta.
            CGContextMoveToPoint(ctx, mp.from.x, mp.from.y);    // move back to from point.
            CGContextAddLineToPoint(ctx, mp.moveTo.x, mp.moveTo.y);
            CGContextStrokePath(ctx);
            
            // draw the arrow in context.
            CGContextSetLineDash(ctx, 1, nil, 0);
            CGContextMoveToPoint(ctx, mp.moveTo.x, mp.moveTo.y);    // move back to from point.
            [VArrow drawInContext:ctx withVector:mp.delta];
            CGContextStrokePath(ctx);
            CGContextMoveToPoint(ctx, mp.moveTo.x, mp.moveTo.y);    // move back to from point.
        }
    }
    
    if ((contextLayer) && 
        (stepCounter < [vpaths count])) {
        [self startStepTimer];
    }
}


- (void)drawPreviewInContext:(CGContextRef)ctx
{   
    if (stepCounter <= [vpaths count]) {
        [self drawStepPreviewInContext:ctx];
    } else {
        [VColor setContextStrokeColor:ctx withCSSColor:SHAPE_PREVIEW_STROKE_COLOR];
        CGContextAddPath(ctx, previewPath);
        CGContextStrokePath(ctx);
    }
}

- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}


@end
