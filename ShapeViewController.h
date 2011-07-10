//
//  ShapeViewController.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>



#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus

#import "ShapeView.h"
#import "ShapeDrawer.h"

#import "VDefineShape.h"    // real drawer

@interface ShapeViewController : NSViewController <ShapeDrawer> {
    ShapeView *shapeView;
#ifdef __cplusplus
    VObject *tag;
#endif // __cplusplus
    VDefineShape *drawer;
}

@property (readonly) NSMutableString *canvasCode;
@property (readonly) NSMutableString *canvasCodeWithCast;
@property (readonly) NSMutableString *characterName;

@property (readonly) CGRect          shapeBounds;
@property (readonly) uint            shapeId;

#ifdef __cplusplus
- (id)initWithTag:(VObject *)_tag;
#endif // __cplusplus

- (void)drawInContext:(CGContextRef)context;

@end
