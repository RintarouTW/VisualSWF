//
//  VDefineBitsJPEG.mm
//  VisualSWF
//
//  Created by Rintarou on 2011/2/6.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VDefineBitsJPEG.h"


@implementation VDefineBitsJPEG


- (id)initWithVObject:(VObject *)_vobject;
{
    self = [super init];
    if (self) {
        previewPath = CGPathCreateMutable();
        if (_vobject) {
            vobject = _vobject;
            
            [self parseVObject];
            
            previewPathBounds = CGRectMake(0, 0, bitmapWidth, bitmapHeight);
            
            if (bitmapWidth && bitmapHeight && (bitmapWidth < 50) && (bitmapHeight < 50)) {
                CGFloat ratio;
                if (bitmapWidth < bitmapHeight) {
                    ratio = 100 / bitmapWidth;
                } else {
                    ratio = 100 / bitmapHeight;
                }
                
                previewPathBounds = CGRectMake(0, 0, bitmapWidth * ratio, bitmapHeight * ratio);
            }
        }
    }
    return self;
}

- (void)parseVObject
{
    const char *type = vobject->getTypeInfo();
    MemoryStream *ms;
    
    if (strcmp(type, "DefineBits") == 0) {
        ms = (*vobject)["JPEGData"].asStream();
    } else {
        ms = (*vobject)["ImageData"].asStream();
    }
    
    uint alphaDataOffset;
    if (strcmp(type, "DefineBitsJPEG3") == 0) {
        alphaDataOffset = (*vobject)["AlphaDataOffset"].asUInt();       // count of bytes in ImageData.
    }
    
    imageData = [[NSData alloc] initWithBytes:ms->getStartPtr() length:ms->length()];   // copy from memory stream.
    //[imageData writeToFile:@"defineBitsJPEG3.jpg" atomically:YES];
    
    if (![NSBitmapImageRep canInitWithData:imageData]) {
        NSLog(@"non supported image format");
        return;
    }
    
    nsBitmapImageRep = [[NSBitmapImageRep alloc] initWithData:imageData];
    bitmapWidth      = [nsBitmapImageRep size].width;
    bitmapHeight     = [nsBitmapImageRep size].height;
    image            = [nsBitmapImageRep CGImage];
}

- (void)dealloc
{    
    [nsBitmapImageRep release];
    [imageData release];
    CGPathRelease(previewPath);
    //CGImageRelease(image);
    [super dealloc];
}

- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}

- (void)drawPreviewInContext:(CGContextRef)ctx
{
    if (image) {
        CGContextSaveGState (ctx);
        CGContextRotateCTM(ctx, M_PI);  // flipping the image
        CGContextTranslateCTM(ctx, -previewPathBounds.size.width, -previewPathBounds.size.height);
        CGContextDrawImage(ctx, 
                           previewPathBounds, 
                           image);
        CGContextRestoreGState (ctx);
    }
}

@end
