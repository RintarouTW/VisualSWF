//
//  VDefineBitsLossless.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Previewable.h" // This is Previewable.

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus


@interface VDefineBitsLossless : NSObject <Previewable> {

#ifdef __cplusplus
    VObject     *vBitsLossless;
#endif // __cplusplus
    
    uint                bitmapFormat;   // 3 = 8-bit colormapped image
                                        // 4 = 15-bit RGB image
                                        // 5 = 24-bit RGB image
    
    uint                bitmapWidth;
    uint                bitmapHeight;
    void                *bitmapData;
    uint                bitmapColorTableSize;   // colormapped image only
    

    
    // Preivew
    CGRect              previewPathBounds;
    CGMutablePathRef    previewPath;
    CGImageRef          image;
    CGDataProviderRef   provider;
    // CGImage
}

//@property (readonly) CGMutablePathRef   previewPath;

#ifdef __cplusplus
- (id)initWithVObject:(VObject *)bitsLosslessVObject;
#endif // __cplusplus

- (void)drawPreviewInContext:(CGContextRef)ctx;
- (CGRect)getPreviewBounds;

- (void)parseVObject;
@end
