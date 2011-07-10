//
//  CATableLayerDelegate.m
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "TableLayer.h"

#import "VColor.h"
#import "style.h"


@implementation TableRow

@synthesize value, prev;

- (void)setName:(const char *)theName
{
    if (myName) {
        [myName release];
    }
    myName = [[NSString alloc] initWithUTF8String:theName];
}

- (const char *)name
{
    return [myName UTF8String];
}

- (void)dealloc
{
    [myName release];
    [super dealloc];
}

@end


@implementation TableLayer

static BOOL headerOnly = NO;


@synthesize ownerTable, rowInOwnerTable, myLink, nextTable, vobject, previewer;

@synthesize header, numRows;

- (id) init {
    self = [super init];
    if (self) {
        // Initialization code here.
        children = [[NSMutableArray alloc] init];
        
        self.geometryFlipped = YES;
        self.borderWidth = 1.0;
        //self.cornerRadius = 7.0;
        //self.opaque = TRUE;
        //self.shadowOpacity = 0.5;
        self.shadowOffset = CGSizeMake(0.0, -5.0);
        //self.zPosition = 0;
        
        focusedRowNum = -1;
    }
    return self;    
}

- (void)dealloc {
    
    //NSLog(@"Table Layer was deallocated");
    
    // release the list
    TableRow *currentRow = lastRow;
    for (uint i = 0; i < numRows; i++) {
        TableRow *prev = currentRow.prev;
        [currentRow release];
        currentRow = prev;
    }
    
    [children removeAllObjects];
    [children release];
    
    [super dealloc];
}

+ (void)setHeaderOnly:(BOOL)flag {
    headerOnly = flag;
}

- (void)setHeader:(const char *)theHeader
{
    header = theHeader;
    // update bounds.width and height
    CGRect new_bound = [self bounds];
    new_bound.size.width = strlen(header) * TABLE_GLYPH_WIDTH + TABLE_ROW_PADDING_X * 2;
    new_bound.size.height = TABLE_CELL_HEIGHT + TABLE_ROW_PADDING_Y * 2;
    
    [self setBounds:new_bound];    
}

- (uint)appendRow:(const char *)pName andValue:(const char *)pValue {
    
    TableRow *newRow = [[TableRow alloc] init];
    if (strlen(pName) > maxNameLength) {
        maxNameLength = strlen(pName);
        if (maxNameLength > TABLE_MAX_TEXT_LENGTH) {
            maxNameLength = TABLE_MAX_TEXT_LENGTH;
        }
    }

    if (strlen(pValue) > maxValueLength) {
        maxValueLength = strlen(pValue);
        if (maxValueLength > TABLE_MAX_TEXT_LENGTH) {
            maxValueLength = TABLE_MAX_TEXT_LENGTH;
        }
    }
    
    newRow.name  = pName;
    newRow.value = pValue;
    
    if (lastRow) {
        newRow.prev = lastRow;
        lastRow = newRow;
    } else {
        lastRow = newRow;
    }
    
    //[rows addObject:newRow];
    //NSLog(@"rows count = %d", [rows count]);
    numRows++;
    
    if (!headerOnly) {
        // update bounds.width and height
        CGRect new_bound = [self bounds];
        new_bound.size.width = (maxNameLength + maxValueLength) * TABLE_GLYPH_WIDTH + TABLE_ROW_PADDING_X * 2;
        new_bound.size.height = (numRows + 1) * TABLE_CELL_HEIGHT + TABLE_ROW_PADDING_Y * 2;
        [self setBounds:new_bound];
    }
    return (numRows - 1);
}

- (void)setOwnerTable:(TableLayer *)parent
{
    [parent addChild:self]; // ask parent to add self as one of it's child.
    ownerTable = parent;
}

- (void)addChild:(TableLayer *)child
{
    [children addObject:child];
}


- (TableLayer *)tableOfFocusedRow
{
    
    if (focusedRowNum >= 0) {
        int rowNum = numRows - focusedRowNum - 1;
        
        for (int i = 0; i < [children count]; i++) {
            TableLayer *tbl = [children objectAtIndex:i];
            if (tbl.rowInOwnerTable == rowNum) {
                return tbl;
            }
        }
    }
    return nil;
}
/*
- (void)updateLink
{
    myLink.anchorOfTable = [self getAnchorPoint];
    myLink.ownerAnchorPoint = [ownerTable getAnchorPointOnRow:rowInOwnerTable];
}
*/


////////////////////////// Event Handling //////////////////////////////

- (void)mouseMove:(CGPoint)mouseLocation
{
    // mouseLocation is converted to my coordinate already.
    int newfocusedRowNum = int(mouseLocation.y / TABLE_CELL_HEIGHT);
    if (newfocusedRowNum != focusedRowNum) {
        focusedRowNum = newfocusedRowNum;
        [self setNeedsDisplay];
    }
    
    if (focusedRowNum >= numRows) {
        focusedRowNum = -1;
    }
}

- (void)rightMouseDown:(CGPoint)mouseLocation
{
    if (strcmp("SHAPE", header) == 0) {
        if (previewer) {
            [previewer stepPreview];
        }
    }
}

- (void)onFocused
{
    // scale up my self
    CGAffineTransform rootLayerTransform = [[self superlayer] affineTransform];
    CGAffineTransform myTransform = [self affineTransform];
    myTransform.a = myTransform.d = (1/rootLayerTransform.a);
    [self setAffineTransform:myTransform];
    self.zPosition = 1;
    self.shadowOpacity = 0.5;
    //[self updateLink];
}

- (void)lostFocus
{
    // scale back to normal
    CGAffineTransform myTransform = [self affineTransform];
    myTransform.a = myTransform.d = 1;
    [self setAffineTransform:myTransform];
    self.zPosition = 0;
    self.shadowOpacity = 0;
    
    focusedRowNum = -1;
    [self setNeedsDisplay];
}



////////////////////////// Drawing //////////////////////////////

// The anchor point of the row in RootLayer's coordinate.
//          +------------+
//          |            | <--- row 0
//          |            | <--- row 1
//          |            |       .
//          |            |       .
//          |            |       .
//          +------------+
//        (0,0)
//
- (CGPoint)getAnchorPointOnRow:(uint)rowNum
{
    uint pX = [self bounds].size.width;
    uint pY;
    
    if (!headerOnly) {
        pY = TABLE_ROW_PADDING_Y + (numRows - rowNum) * TABLE_CELL_HEIGHT - (TABLE_CELL_HEIGHT / 2);  // since TableLayer was not flipped.
    } else {
        pY = TABLE_CELL_HEIGHT/2;
    }
    
    CGPoint anchorOnRow = CGPointMake(pX, pY);
    return [self convertPoint:anchorOnRow toLayer:self.superlayer];
}

// The anchor point of this table in RootLayer's coordinate.
//          +------------+
//          |            |
//          |            |
//  here -->|            |
//          |            |
//          |            |
//          +------------+
//
- (CGPoint)getAnchorPoint
{
    /*
    CGRect mybounds = [self bounds];
    
    CGPoint aPoint = CGPointMake(mybounds.origin.x, 
                                (mybounds.origin.y + mybounds.size.height)/2);
    
    return [self convertPoint:aPoint toLayer:self.superlayer];
     */
    CGRect myframe = [self frame];
    CGPoint anchorP = CGPointMake(myframe.origin.x, myframe.origin.y + myframe.size.height/2);
    return anchorP;
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSelectFont(ctx, "Arno Pro", TABLE_CELL_HEIGHT, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing(ctx, 0);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);

    /* Table Background Color */
    [VColor setContextFillColor:ctx withCSSColor:TABLE_BACKGROUND_COLOR];
    
    CGContextFillRect(ctx, [self bounds]);  // draw background of the table.
    
    
    if (focusedRowNum >= 0) {
        // draw the background of focused row. TODO:
        /* Table Focused Row Background Color */
        [VColor setContextFillColor:ctx withCSSColor:TABLE_FOCUSED_ROW_BACKGROUND_COLOR];

        CGContextFillRect(ctx, CGRectMake(0, TABLE_CELL_HEIGHT * focusedRowNum, [self bounds].size.width, TABLE_CELL_HEIGHT));
    }

    CGFloat rowY = TABLE_ROW_PADDING_Y;    
    CGFloat valueStartX = maxNameLength * TABLE_GLYPH_WIDTH + TABLE_ROW_PADDING_X;
    
    if (!headerOnly) {        
        TableRow *row = lastRow;
        
        // draw names, values
        for (uint i = 0; i < numRows; i++) {
            
            if (i == focusedRowNum) {
                /* Table Focused Row Text Color */
                [VColor setContextFillColor:ctx withCSSColor:TABLE_FOCUSED_ROW_TEXT_COLOR];
                
            } else {
                /* Table Normal Row Text Color */
                [VColor setContextFillColor:ctx withCSSColor:TABLE_NORMAL_ROW_TEXT_COLOR];
            }
            
            uint visibleLength = strlen(row.name);
            if (visibleLength > TABLE_MAX_TEXT_LENGTH) {
                visibleLength = TABLE_MAX_TEXT_LENGTH;
            }
            CGContextShowTextAtPoint(ctx, TABLE_ROW_PADDING_X, rowY, row.name, visibleLength);
            
            visibleLength = strlen(row.value);
            if (visibleLength > TABLE_MAX_TEXT_LENGTH) {
                visibleLength = TABLE_MAX_TEXT_LENGTH;
            }
            CGContextShowTextAtPoint(ctx, valueStartX, rowY, row.value, visibleLength);
            
            rowY += TABLE_CELL_HEIGHT;
            row = row.prev;
        }
    }
    
    // draw header
    if (header) {
        /* Table Header Background Color */
        [VColor setContextFillColor:ctx withCSSColor:TABLE_HEADER_BACKGROUND_COLOR];
        CGContextFillRect(ctx, CGRectMake(0, rowY, [self bounds].size.width, [self bounds].size.height - rowY));
        
        /* Table Header Text Color */        
        if ((strcmp(header, "DefineShape") != 0) &&
            (strcmp(header, "DefineShape2") != 0) &&
            (strcmp(header, "DefineShape3") != 0) &&
            (strcmp(header, "DefineShape4") != 0) &&
            (strcmp(header, "DefineBitsLossless") != 0) &&
            (strcmp(header, "DefineBitsLossless2") != 0) &&
            (strcmp(header, "DefineBits") != 0) &&
            (strcmp(header, "DefineBitsJPEG2") != 0) &&
            (strcmp(header, "DefineBitsJPEG3") != 0) &&
            (strcmp(header, "DefineBitsJPEG4") != 0) &&
            
            (strcmp(header, "SHAPE") != 0) &&
            (strcmp(header, "STRAIGHTEDGERECORD") != 0) &&
            (strcmp(header, "CURVEDEDGERECORD") != 0) &&
            (strcmp(header, "SetBackgroundColor") != 0) &&
            (strcmp(header, "FILLSTYLE (Solid Fill)") != 0) &&
            (strcmp(header, "GRADRECORD") != 0) &&
            (strcmp(header, "GRADIENT") != 0) &&
            (strcmp(header, "FILLSTYLE (Linear Gradient Fill)") != 0) &&
            (strcmp(header, "FILLSTYLE (Radial Gradient Fill)") != 0)
            ) {
            [VColor setContextFillColor:ctx withCSSColor:TABLE_HEADER_TEXT_COLOR];            
        } else {
            [VColor setContextFillColor:ctx withCSSColor:TABLE_HEADER_PREVIEWABLE_TEXT_COLOR];
        }
        
        CGContextShowTextAtPoint(ctx, TABLE_ROW_PADDING_X, rowY + 5, header, strlen(header));
    }
    
    //CGContextStrokeRect(ctx, [self bounds]);
    //NSLog(@"root layer bounds = %f, %f, %f, %f", [layer bounds].origin.x, [layer bounds].origin.y, [layer bounds].size.width, [layer bounds].size.height);
}

@end
