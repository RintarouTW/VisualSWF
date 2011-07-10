//
//  WebViewController.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>


@interface WebViewController : NSViewController {
    WebView *webView;
    CGFloat originX;
}

- (IBAction)switchTab:(id)sender;

- (void)setCode:(NSString *)canvasCode withSize:(CGSize)canvasSize;
- (void)drawOnCanvas:(NSString *)code;
- (void)appendToCast:(NSString *)code;
- (void)loadDataObject:(NSString *)code to:(NSString *)controllerPath;

@end
