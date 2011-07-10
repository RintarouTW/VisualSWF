//
//  CanvasCodeViewController.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/31.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "CanvasCodeViewController.h"


@implementation CanvasCodeViewController

@synthesize panel, webView;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"canvasPreview" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];    
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    //[panel makeFirstResponder:self.view];
}

- (void)setCode:(NSString *)canvasCode withSize:(CGSize)canvasSize
{
    [(NSTextView *)self.view selectAll:self];
    [(NSTextView *)self.view insertText:canvasCode];
    [(NSTextView *)self.view selectAll:self];
    
    // modify the draw canvas function and redraw it.

    /* drawCanvas(canvasStr, width, height); */
    NSArray *args = [NSArray arrayWithObjects:
                     canvasCode,
                     [NSNumber numberWithInt:canvasSize.width],
                     [NSNumber numberWithInt:canvasSize.height],
                     nil];
    
    id win = [webView windowScriptObject];
        
    [win callWebScriptMethod:@"drawCanvas" withArguments:args];
    /* [win evaluateWebScript: @"addImage(’sample_graphic.jpg’, ‘320’, ‘240’)"]; */
}

- (void)setPanelState:(BOOL)visible
{
    [panel setIsVisible:visible];
}

- (void) dealloc
{
    [super dealloc];
}

@end
