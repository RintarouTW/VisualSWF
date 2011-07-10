//
//  VDefineBitsLossless.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VDefineBitsLossless.h"


@implementation VDefineBitsLossless

//@synthesize previewPath;


- (id)initWithVObject:(VObject *)bitsLosslessVObject
{
    self = [super init];
    if (self) {
        previewPath = CGPathCreateMutable();
        if (bitsLosslessVObject) {
            vBitsLossless = bitsLosslessVObject;
            
            [self parseVObject];
            
            previewPathBounds = CGRectMake(0, 0, bitmapWidth, bitmapHeight);
            
            if ((bitmapWidth < 50) && (bitmapHeight < 50)) {
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
    VObject &bit = (*vBitsLossless);
    
    unsigned int alphaSupportFlag = kCGImageAlphaNoneSkipFirst;
    
    if (strcmp(bit.getTypeInfo(), "DefineBitsLossless2") == 0) {
        alphaSupportFlag = kCGImageAlphaFirst;
    }

    bitmapFormat = bit["BitmapFormat"].asUInt();
    bitmapWidth  = bit["BitmapWidth"].asUInt();
    bitmapHeight = bit["BitmapHeight"].asUInt();
    MemoryStream *ms = bit["ZlibBitmapData"].asStream();
    bitmapData   = ms->getStartPtr();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    switch (bitmapFormat) {
        case 3: // 8 bit colormapped image
            /* TODO, not supported so far. 
               This is even hard to find a test case.
               It seems need to calculate the stride for 32-bit boundary.
             */
            /*
            bitmapColorTableSize = bit["BitmapColorTableSize"].asUInt();
            bitmapData + (bitmapColorTableSize * 3)
            //baseSpace = CGColorSpaceCreate();    // RGB888 space is used in COLORMAPDATA.ColorTableRGB
            CGColorSpaceRef CGColorSpaceCreateIndexed(
                                                      colorSpace, //CGColorSpaceRef baseSpace,
                                                      bitmapColorTableSize, // size_t lastIndex,
                                                      (const unsigned char *)bitmapData //const unsigned char *colorTable
                                                      ); 
            image = CGImageCreate (
                                   bitmapWidth,
                                   bitmapHeight,
                                   5,  // bitsPerComponent
                                   16, // bitsPerPixel
                                   bitmapWidth * 4, // bytesPerRow
                                   colorSpace,
                                   kCGImageAlphaNoneSkipFirst | !kCGBitmapFloatComponents,//CGBitmapInfo bitmapInfo,
                                   provider,
                                   NULL, //const CGFloat decode[],
                                   0, //bool shouldInterpolate,
                                   kCGRenderingIntentDefault // CGColorRenderingIntent intent
                                   ); 
            */
            NSLog(@"Not implemented");
            break;
        case 4: // 15 bit RGB image
            // Not tested yet. Hard to find a test case.
            // It seems need to calculate the stride for 32-bit boundary.
            provider = CGDataProviderCreateWithData (
                                                     NULL,          // void *info
                                                     bitmapData,
                                                     ms->length(),
                                                     NULL           //CGDataProviderReleaseDataCallback releaseData
                                                     );
            image = CGImageCreate (
                                   bitmapWidth,
                                   bitmapHeight,
                                   5,                                           // bitsPerComponent
                                   16,                                          // bitsPerPixel
                                   bitmapWidth * 2,                             // bytesPerRow
                                   colorSpace,
                                   alphaSupportFlag | !kCGBitmapFloatComponents,//CGBitmapInfo bitmapInfo,
                                   provider,
                                   NULL,                                        //const CGFloat decode[],
                                   0,                                           //bool shouldInterpolate,
                                   kCGRenderingIntentDefault                    // CGColorRenderingIntent intent
                                   ); 
            
            break;
        case 5: // 24 bit RGB  image
                // 32 bit ARGB image  
            provider = CGDataProviderCreateWithData (
                                                            NULL,           // void *info
                                                            bitmapData,
                                                            ms->length(),
                                                            NULL            //CGDataProviderReleaseDataCallback releaseData
                                                            );
            image = CGImageCreate (
                                      bitmapWidth,
                                      bitmapHeight,
                                      8,                                            // bitsPerComponent
                                      32,                                           // bitsPerPixel
                                      bitmapWidth * 4,                              // bytesPerRow
                                      colorSpace,
                                      alphaSupportFlag | !kCGBitmapFloatComponents, //CGBitmapInfo bitmapInfo,
                                      provider,
                                      NULL,                                         //const CGFloat decode[],
                                      0,                                            //bool shouldInterpolate,
                                      kCGRenderingIntentDefault                     // CGColorRenderingIntent intent
                                      ); 
            break;
        default:
            NSLog(@"ASSERT: unkonwn bitmap format %d", bitmapFormat);
            break;
    }
    
    CGColorSpaceRelease(colorSpace);
}

- (void)dealloc
{
    CGDataProviderRelease(provider);
    CGPathRelease(previewPath);
    [super dealloc];
}

- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}

- (void)drawPreviewInContext:(CGContextRef)ctx
{
    CGContextDrawImage(ctx, 
                       previewPathBounds, 
                       image);
}


@end
