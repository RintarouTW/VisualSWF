//
//  BackingLayer.h
//  
//
//  Created by Rintarou on 2011/1/19.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>
#import "RootLayer.h"
#import "LinkLayer.h"
#import "PreviewLayer.h"

@interface BackingLayer : CALayer {
    LinkLayer *linkLayer;
    PreviewLayer *previewLayer;
}

@property (assign) LinkLayer *linkLayer;
@property (assign) PreviewLayer *previewLayer;

@end
