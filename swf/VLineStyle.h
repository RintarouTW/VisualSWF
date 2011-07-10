//
//  VLineStyle.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/29.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus

#import "VColor.h"

@interface VLineStyle : NSObject {

#ifdef __cplusplus
    VObject         *vLineStyle;
#endif // __cplusplus
    
    uint            lineStyleType;
    CGFloat         thicness;
    VColor          *vColor;
    CGFloat         miterLimit;     // MiterLimit = MiterLimitFactor(FIXED8.8)
    CGLineCap       cap;    //  kCGLineCapButt    -> NONE
                            //  kCGLineCapRound   -> ROUND
                            //  kCGLineCapSquare  -> SQAURE
    
    CGLineJoin      join;   //  kCGLineJoinMiter  -> Need to set MiterLimit
                            //  kCGLineJoinRound
                            //  kCGLineJoinBevel
    
    BOOL            hasFillFlag;
    
    NSMutableArray  *vpaths;
    
    NSMutableString *canvasStr;
    
}

@property (readonly) NSMutableArray *vpaths;
@property (readonly) NSMutableString *canvasStr;


#ifdef __cplusplus
-(id) initWithLineStyleVObject:(VObject *)theLineStyle;
#endif // __cplusplus

- (NSString *)applyOnContext:(CGContextRef)ctx;
- (void)parse;
@end
