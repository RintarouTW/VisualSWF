//
//  VDefineBitsJPEG.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/6.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Previewable.h" // This is Previewable.

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus

/* support DefineBits, DefineBitsJPEG, DefineBitsJPEG2 */
// Let NSImage & NSBitmapImageRep to choose?

@interface VDefineBitsJPEG : NSObject <Previewable> {

#ifdef __cplusplus
    VObject     *vobject;
#endif // __cplusplus
    
    //uint                bitmapFormat;   // 3 = 8-bit colormapped image
    // 4 = 15-bit RGB image
    // 5 = 24-bit RGB image
    
    uint                bitmapWidth;
    uint                bitmapHeight;
    NSData              *imageData;
    //uint                bitmapColorTableSize;   // colormapped image only
    
    
    
    // Preivew
    CGRect              previewPathBounds;
    CGMutablePathRef    previewPath;

    NSBitmapImageRep    *nsBitmapImageRep;
    CGImageRef          image;
    //CGDataProviderRef   provider; // now CGImageRef from NSImage
}

#ifdef __cplusplus
- (id)initWithVObject:(VObject *)_vobject;
#endif // __cplusplus

- (void)drawPreviewInContext:(CGContextRef)ctx;
- (CGRect)getPreviewBounds;

- (void)parseVObject;

@end
