//
//  CanvasCodeViewController.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/31.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OSAKit/OSAKit.h>
#import <WebKit/WebKit.h>

@interface CanvasCodeViewController : NSViewController {
    NSPanel *panel;
    WebView *webView;
}

@property (assign) IBOutlet NSPanel *panel;
@property (assign) IBOutlet WebView *webView;

- (void)setCode:(NSString *)canvasCode withSize:(CGSize)canvasSize;
- (void)setPanelState:(BOOL)visible;



@end
