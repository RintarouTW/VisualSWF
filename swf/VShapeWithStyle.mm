//
//  VShapeWithStyle.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/29.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VShapeWithStyle.h"


@implementation VShapeWithStyle

@synthesize canvasStr, numShapeRecords;

- (id) initWithShapeWithStyle:(VObject *)theShapeWithStyleVObject
{
    self = [super init];
    if (self) {
        vShapeWithFillStyle = theShapeWithStyleVObject;
        canvasStr = [[NSMutableString alloc] init];
        
        f0Edges = [[NSMutableArray alloc] init];
        f1Edges = [[NSMutableArray alloc] init];
        lineEdges = [[NSMutableArray alloc] init];
        
        emptyFillStyle = [[VFillStyle alloc] initWithFillStyleVObject:nil];
        emptyLineStyle = [[VLineStyle alloc] initWithLineStyleVObject:nil];
        
        numShapeRecords = (*vShapeWithFillStyle)["Shape"]["ShapeRecords"].length();
    }
    return self;
}

- (void)initForDrawing
{
    /* get a new string */
    [canvasStr release];
    canvasStr = [[NSMutableString alloc] init];
    
    //previewPath = CGPathCreateMutable();
    
    vFillStyles   = &(*vShapeWithFillStyle)["FillStyles"]["FillStyles"];
    vLineStyles   = &(*vShapeWithFillStyle)["LineStyles"]["LineStyles"];
    
    fillStyles = [[NSMutableArray alloc] initWithCapacity:vFillStyles->length()];
    [self readFillStyles];
    
    lineStyles = [[NSMutableArray alloc] initWithCapacity:vLineStyles->length()];
    [self readLineStyles];
    
    vShapeRecords = &(*vShapeWithFillStyle)["Shape"]["ShapeRecords"];
    
    currLineStyle  = 0;
    currFileStyle0 = 0;
    currFileStyle1 = 0;
    
    //[self readRecordsForBounds];    
}


- (void)dealloc
{
    [emptyFillStyle release];
    [emptyLineStyle release];
    [f0Edges removeAllObjects];
    [f0Edges release];
    [f1Edges removeAllObjects];
    [f1Edges release];
    [lineEdges removeAllObjects];
    [lineEdges release];
    [fillStyles removeAllObjects];
    [fillStyles release];
    [lineStyles removeAllObjects];
    [lineStyles release];
    //CGPathRelease(previewPath);
    [canvasStr release];
    [super dealloc];
}

/*
- (void)readRecordsForBounds
{    
    for (uint i = 0; i < vShapeRecords->length(); i++) {
        
        VObject &record = (*vShapeRecords)[i];
        
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
                //NSLog(@"not move record");
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
        }
    }
    
    previewPathBounds  = CGPathGetBoundingBox(previewPath);
}
 */
/////////////////////////////////////////////////////////////////////////////////////////////

- (void)genLinePath
{
    if (currLineStyle > 0) {
        if ([lineEdges count] > 0) {
            VLineStyle *ls = [lineStyles objectAtIndex:currLineStyle];
            
            VPath *v = [[[VPath alloc] initWithEdges:lineEdges withRightFill:YES] autorelease]; // right fill is don't cared in line path.
            [ls.vpaths addObject:v];
            lineEdges = [[NSMutableArray alloc] init];
        }
    }
}


- (void)genFillPath:(BOOL)isRightFill
{
    if (!isRightFill) {
        if (currFileStyle0) {
            if ([f0Edges count]) {
                VFillStyle *fs = [fillStyles objectAtIndex:currFileStyle0];
        
                VPath *v = [[[VPath alloc] initWithEdges:f0Edges withRightFill:isRightFill] autorelease];
                [fs.vpaths addObject:v];
                f0Edges = [[NSMutableArray alloc] init];
            }
        }
    } else {
        if (currFileStyle1) {
                if ([f1Edges count]) {
                VFillStyle *fs = [fillStyles objectAtIndex:currFileStyle1];
            
                VPath *v = [[[VPath alloc] initWithEdges:f1Edges withRightFill:isRightFill] autorelease];
                [fs.vpaths addObject:v];
                f1Edges = [[NSMutableArray alloc] init];
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

- (void)drawPathsOfLineStyles
{
    if ([lineStyles count]) {
        for (uint i = 1; i < [lineStyles count]; i++) {
            
            VLineStyle *ls = [lineStyles objectAtIndex:i];
            
            if ([ls.vpaths count]) {

                [canvasStr appendString:@"beginPath();\n"];
                // ask each vpath to draw in context
                for (uint j = 0; j < [ls.vpaths count]; j++) {
                    VPath *v = [ls.vpaths objectAtIndex:j];
                    [canvasStr appendString:[v drawInContext:myContext]];
                }

                // How to deal with gradient fill of line style? (TODO)
                // canvas did support "strokeStyle = gradient".
                // apply line style on context                
                [canvasStr appendString:[ls applyOnContext:myContext]];
                
                [canvasStr appendString:@"stroke();\n"];
                
                // time to clear vpaths.
                [ls.vpaths removeAllObjects];
            }
            
            
        } // end of for
    } // end of if
}

- (VPath *)getConnectedPath:(CGPoint)endPoint inPathArray:(NSMutableArray *)pathArray
{
    //NSLog(@"getConnectedPath");
    for (uint k = 0; k < [pathArray count]; k++) {
        VPath *v2 = [pathArray objectAtIndex:k];
        if (CGPointEqualToPoint(endPoint, v2.startPoint)) {            
            // NSLog(@"endPoint (%.3f, %.3f)", endPoint.x, endPoint.y);
            // NSLog(@"v (%.3f, %.3f) -> (%.3f, %.3f)", v.startPoint.x, v.startPoint.y, v.endPoint.x, v.endPoint.y);
            [pathArray removeObject:v2];
            return v2;
        }
    }
    return nil;
}

- (void)drawClosedPathsOfFillStyles
{
    if (![fillStyles count]) 
        return;
    
    for (uint i = 1; i < [fillStyles count]; i++) { // draw the vpaths of each fill style.
        
        VFillStyle *fs = [fillStyles objectAtIndex:i];
        
        if ([fs.vpaths count]) {
            
            [canvasStr appendString:@"beginPath();\n"];
            
            // ask each vpath to draw in context
            while ([fs.vpaths count]) { // until all paths are drawn and removed from vpaths.
                VPath *v = [fs.vpaths objectAtIndex:0];
                [fs.vpaths removeObject:v]; // remove it.
                
                CGPoint startPoint = v.startPoint;
                CGContextMoveToPoint(myContext, startPoint.x, startPoint.y);
                [canvasStr appendFormat:@"moveTo(%.3f, %.3f);\n", startPoint.x, startPoint.y];
                [canvasStr appendString:[v draw2InContext:myContext]];
                                    
                // Find connected path and check if the path is closed.
                while (!CGPointEqualToPoint(startPoint, v.endPoint)) {
                    BOOL found = NO;
                    
                    // Trying to find the one who is connected to the last one(v).
                    for (int k = 0; k < [fs.vpaths count]; k++) {
                        VPath *v2 = [fs.vpaths objectAtIndex:k];
                        if (CGPointEqualToPoint(v.endPoint, v2.startPoint)) {
                            // v2 is the connected one.
                            found = YES;
                            [fs.vpaths removeObject:v2];
                            v = v2;
                            [canvasStr appendString:[v draw2InContext:myContext]];
                            break;
                        }
                    }
                    
                    if (!found) {
                        NSLog(@"ALERT: not closed path, something wrong..");
                        break;
                    }
                } // end of finding connected path.
                
            } // end of all vpath of this fill style

            // apply fill style on context
            [canvasStr appendString:[fs applyOnContext:myContext]];
            
            [canvasStr appendString:@"fill();\n"];
            
            // time to clear vpaths.
            [fs.vpaths removeAllObjects];                
        }
        
    } // end of for

}

/////////////////////////////////////////////////////////////////////////////////////////////

- (void)readFillStyles
{
    [fillStyles removeAllObjects];  // ensure it's empty.
    [fillStyles addObject:emptyFillStyle];     // index 0 is draw nothing.
    for (uint i = 0; i < vFillStyles->length(); i++) {
        VFillStyle *fs = [[VFillStyle alloc] initWithFillStyleVObject:&(*vFillStyles)[i]];
        [fillStyles addObject:fs];
        [fs release];
    }
    //NSLog(@"fillStyles count = %d", [fillStyles count]);
}

- (void)readLineStyles
{
    [lineStyles removeAllObjects];  // ensure it's empty.
    [lineStyles addObject:emptyLineStyle];     // index 0 is draw nothing.
    for (uint i = 0; i < vLineStyles->length(); i++) {
        VLineStyle *ls = [[VLineStyle alloc] initWithLineStyleVObject:&(*vLineStyles)[i]];
        [lineStyles addObject:ls];
        [ls release];
    }
    //NSLog(@"lineStyles count = %d", [lineStyles count]);
}


- (void)readCurvedEdgeRecord:(VObject *)theRecord
{
    VObject &record = (*theRecord);
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
    
    // push into each edge list according current fillstyles and linestyle.
    if (currFileStyle0) {
        [f0Edges addObject:edge];
        //NSLog(@"f0Edges count = %d", [f0Edges count]);
    }
    if (currFileStyle1) {
        [f1Edges addObject:edge];
        //NSLog(@"f1Edges count = %d", [f1Edges count]);
    }
    if (currLineStyle) {
        [lineEdges addObject:edge];
        //NSLog(@"lineEdges count = %d", [lineEdges count]);
    }    
}


- (void)readStraightEdgeRecord:(VObject *)theRecord
{
    VObject &record = (*theRecord);
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
    
    if (currFileStyle0) {
        [f0Edges addObject:edge];
    }
    if (currFileStyle1) {
        [f1Edges addObject:edge];
    }
    if (currLineStyle) {
        [lineEdges addObject:edge];
    }
    
}

- (void)readStyleChangeRecord:(VObject *)theRecord
{
    VObject &record = (*theRecord);
    
    // move delta
    if (record["StateMoveTo"].asUInt()) {
        // gen the vpath and push into each style's link list.
        [self genFillPath:YES];
        [self genFillPath:NO];
        [self genLinePath];
        
        pen.x = record["MoveDeltaX"].asInt();
        pen.y = record["MoveDeltaY"].asInt();
    }
    
    // line style changed
    if (record["StateLineStyle"].asUInt()) {
        [self genLinePath];
        currLineStyle = record["LineStyle"].asUInt();
    }
    
    // f0 style changed
    if (record["StateFillStyle0"].asUInt()) {
        [self genFillPath:NO];
        currFileStyle0 = record["FillStyle0"].asUInt();
    }
    
    // f1 style changed
    if (record["StateFillStyle1"].asUInt()) {
        [self genFillPath:YES];
        currFileStyle1 = record["FillStyle1"].asUInt();
    }
    
    // new fillstyles changed
    if (record["StateNewStyles"].asUInt()) {
        [self genFillPath:YES];
        [self genFillPath:NO];
        [self genLinePath];
        
        // It's time to draw it before we switch to the new fillstyles and linestyles
        [self drawClosedPathsOfFillStyles];
        [self drawPathsOfLineStyles];
        
        vFillStyles = &record["FillStyles"]["FillStyles"];
        vLineStyles = &record["LineStyles"]["LineStyles"];
        [self readFillStyles];
        [self readLineStyles];
    }
}

- (void)readRecords
{
    VObject &shapeRecords = (*vShapeRecords);
    //unsigned int numShapeRecords = vShapeRecords->length();
    //NSLog(@"num shape records = %d", numShapeRecords);
    
    const char *typeOfshapeRecord = NULL;
    
    for (uint j = 0; j < numShapeRecords; j++) {
        typeOfshapeRecord = shapeRecords[j].getTypeInfo();
        //NSLog(@"%d) type of shape reocrd = %s", j, typeOfshapeRecord);
        
        if (strcmp(typeOfshapeRecord, "CURVEDEDGERECORD") == 0) {
            [self readCurvedEdgeRecord:&(shapeRecords[j])];
            continue;
        }
        if (strcmp(typeOfshapeRecord, "STRAIGHTEDGERECORD") == 0) {
            [self readStraightEdgeRecord:&(shapeRecords[j])];
            continue;
        }
        if (strcmp(typeOfshapeRecord, "STYLECHANGERECORD") == 0) {
            VObject *s = &(shapeRecords[j]);
            [self readStyleChangeRecord:s];
            continue;
        }
    }
    
    [self genFillPath:YES];
    [self genFillPath:NO];
    [self genLinePath];
    [self drawClosedPathsOfFillStyles];
    [self drawPathsOfLineStyles];
}

/////////////////////////////////////////////////////////////////////////////////
/*
- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}
*/

- (void)drawPreviewInContext:(CGContextRef)ctx
{
 //////// TODO
    // Refine this object to support drawPreviewInContext more time.
    [self initForDrawing];
    
    
    //NSLog(@"drawPreview of shape with style");
    myContext = ctx;    // remember the context for drawing procedures.
    
    [self readRecords];
    
    myContext = nil;    // reset mycontext before we return.
    
}

@end
