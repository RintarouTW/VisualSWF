//
//  CodeGen.m
//  F2C
//
//  Created by Rintarou on 2011/2/15.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "CodeGen.h"

@implementation CodeGen

+ (NSMutableString *)genCharacterName:(VDefineShape *)shape
{
    NSMutableString *canvasStr = [NSMutableString string];  // autoreleased string
    [canvasStr appendFormat:@"%s%d", F2C_CHARACTER_NAME_PREFIX, shape.shapeId];
    return canvasStr;
}

/* Gen a single character code */
+ (NSMutableString *)genCodeOfShape:(VDefineShape *)shape
{
    NSMutableString *canvasStr = [NSMutableString string];  // autoreleased string
    
    /* New Hollywood JSON Template */
    /* Usage: $(CharacterName).draw(ctx); */
    [canvasStr appendFormat:@"  %s%d : {\n", F2C_CHARACTER_NAME_PREFIX, shape.shapeId];
    [canvasStr appendFormat:@"    width   : %d,\n", (uint)shape.getPreviewBounds.size.width];
    [canvasStr appendFormat:@"    height  : %d,\n", (uint)shape.getPreviewBounds.size.height];
    [canvasStr appendFormat:@"    shapeOriginX : %.3f,\n", -shape.getPreviewBounds.origin.x];
    [canvasStr appendFormat:@"    shapeOriginY : %.3f,\n", -shape.getPreviewBounds.origin.y];
    
    [canvasStr appendString:@"    draw : function(ctx, anchorX, anchorY) {\n\n"];
    [canvasStr appendString:@"        if (!anchorX) anchorX = 0;\n        if (!anchorY) anchorY = 0;\n"];
    [canvasStr appendString:@"with(ctx) { /* ---- Canvas Drawing Start ---- */\n"];
    [canvasStr appendString:@"save();\n"];
    [canvasStr appendFormat:@"translate(this.shapeOriginX - anchorX, this.shapeOriginY - anchorY);\n"];
    [canvasStr appendString:shape.canvasStr];
    [canvasStr appendString:@"restore();\n"];
    [canvasStr appendString:@"} /* ---- Canvas Drawing End ---- */\n"];
    [canvasStr appendString:@"\n      return this;\n"];
    [canvasStr appendString:@"    } /* End of draw() */\n"];
    
    [canvasStr appendFormat:@"  }\n"];
    return canvasStr;    
}

+ (NSMutableString *)genCodeOfShapes:(NSArray *)arrayOfshapes
{
    NSMutableString *canvasStr = [NSMutableString string];  // autoreleased string
    VDefineShape *shape;
    
    /* New Hollywood JSON Template */
    /* Usage: F2CHollywood["F2CActor"].draw(ctx); */
    [canvasStr appendFormat:@"%s = {\n", F2C_DICTIONARY_NAME];
    
    for (uint i = 0; i < [arrayOfshapes count]; i++) {
        
        shape = [arrayOfshapes objectAtIndex:i];
        
        [canvasStr appendFormat:@"  %s%d : {\n", F2C_CHARACTER_NAME_PREFIX, shape.shapeId];
        [canvasStr appendFormat:@"    width   : %d,\n", (uint)shape.getPreviewBounds.size.width];
        [canvasStr appendFormat:@"    height  : %d,\n", (uint)shape.getPreviewBounds.size.height];
        [canvasStr appendFormat:@"    shapeOriginX : %.3f,\n", -shape.getPreviewBounds.origin.x];
        [canvasStr appendFormat:@"    shapeOriginY : %.3f,\n", -shape.getPreviewBounds.origin.y];
        
        [canvasStr appendString:@"    draw : function(ctx, anchorX, anchorY) {\n\n"];
        [canvasStr appendString:@"        if (!anchorX) anchorX = 0;\n        if (!anchorY) anchorY = 0;\n"];
        [canvasStr appendString:@"with(ctx) { /* ---- Canvas Drawing Start ---- */\n"];
        [canvasStr appendString:@"save();\n"];
        [canvasStr appendFormat:@"translate(this.shapeOriginX, this.shapeOriginY);\n"];
        [canvasStr appendString:shape.canvasStr];
        [canvasStr appendString:@"restore();\n"];        
        [canvasStr appendString:@"} /* ---- Canvas Drawing End ---- */\n"];
        [canvasStr appendString:@"        return this; /* for chain rule */\n"];
        [canvasStr appendString:@"    } /* End of draw() */\n"];
    
        if ([arrayOfshapes count] > (i+1)) {
            [canvasStr appendFormat:@"  },\n"];
        } else {
            [canvasStr appendFormat:@"  }\n"];
        }
    }    

    [canvasStr appendFormat:@"} /* End of %s */\n", F2C_DICTIONARY_NAME];
    return canvasStr;
}

@end
