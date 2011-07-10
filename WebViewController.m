//
//  WebViewController.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "WebViewController.h"

#import "CodeGen.h"


@implementation WebViewController


- (void)awakeFromNib
{
    webView = (WebView *)[self view];
    [webView setUIDelegate:self];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"canvasPreview" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];    
    originX = [webView frame].origin.x;
}

- (void)Alert:(NSString *)message
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];    
    [alert runModal];
    [alert release];
}

/* Disable the right click menu */
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    return nil;
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    [self Alert:message];
}

/* 
 Implement WebUIDelegate: used for save as signal,
   JavaScript: window.confirm(exportBox.innerHTML); 
   message <= exportBox.innerHTML;
 */

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{

    int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"js"];
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setTitle:@"Exporting F2CCast to JavaScript Source File(.js)"];
    [panel setNameFieldLabel:@"Save As:"];
    [panel setCanCreateDirectories:YES];
    [panel setExtensionHidden:NO];
    [panel setAllowedFileTypes:fileTypes];
    
    result = [panel runModal];
    
    
    if (result == NSOKButton) {        
        NSURL *fileToSave = [panel URL];
        [message writeToURL:fileToSave atomically:YES encoding:NSASCIIStringEncoding error:NULL];
        return YES;
    }
    
    return NO;
}

/* 
 JavaScript: window.prompt(prompt, defaultText);
 prompt:
 1. "Export" : Save defaultText to F2CCast.js.
 2. "Import" : Load .js file and return.
  
 */

- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WebFrame *)frame
{
    int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"js"];
    
    NSArray *tokens = [prompt componentsSeparatedByString:@" "];
    
    if ([[tokens objectAtIndex:0] isEqualToString:@"Export"]) {

        NSSavePanel *panel = [NSSavePanel savePanel];

        [panel setTitle:[NSString stringWithFormat:@"Exporting %@ to JavaScript(.js)", [tokens objectAtIndex:1]]];        
        [panel setNameFieldLabel:@"Save As:"];
        [panel setCanCreateDirectories:YES];
        [panel setExtensionHidden:NO];
        [panel setAllowedFileTypes:fileTypes];
        
        result = [panel runModal];
                
        if (result == NSOKButton) {        
            NSURL *fileToSave = [panel URL];
            [defaultText writeToURL:fileToSave atomically:YES encoding:NSASCIIStringEncoding error:NULL];
        }        
    }

    if ([[tokens objectAtIndex:0] isEqualToString:@"Import"]) {    
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        
        [panel setTitle:[NSString stringWithFormat:@"Impport JavaScript(.js) to %@", [tokens objectAtIndex:1]]];
        [panel setCanCreateDirectories:NO];
        [panel setExtensionHidden:NO];
        [panel setAllowedFileTypes:fileTypes];
        
        result = [panel runModal];
            
        if (result == NSOKButton) {
            NSArray *filesToOpen = [panel URLs];
            NSURL *aFile = [filesToOpen objectAtIndex:0];
            
            NSString *jsData = [NSString stringWithContentsOfURL:aFile usedEncoding:nil error:nil];
            [self loadDataObject:jsData to:[tokens objectAtIndex:2]];
        }

        
        return [NSString string];
    }
    
    return nil;
}

- (void)drawOnCanvas:(NSString *)code
{
    id win = [webView windowScriptObject];
    
    NSArray *args = [NSArray arrayWithObjects:
                     code,
                     nil];
    
    id actorViewerController = [win evaluateWebScript:@"actorViewerController"];

    [actorViewerController callWebScriptMethod:[NSString stringWithFormat:@"%s", SCRIPT_FUNC_NAME_DRAW_ACTOR] withArguments:args];
}


- (void)loadDataObject:(NSString *)code to:(NSString *)controllerPath
{
    id win = [webView windowScriptObject];
    
    NSArray *args = [NSArray arrayWithObjects:
                     code,
                     nil];
    
    id dataController = [win evaluateWebScript:controllerPath];
    
    [dataController callWebScriptMethod:[NSString stringWithFormat:@"%s", SCRIPT_FUNC_NAME_LOAD_DATAOBJECT] withArguments:args];
}


- (void)appendToCast:(NSString *)code
{
    id win = [webView windowScriptObject];

#ifdef LITE_VERSION
    NSNumber *numActors = [win evaluateWebScript:@"castController.view.numItems"];

    if ([numActors intValue] > 4) {
        // TODO: Popup to notify user this is a lite version
        [self Alert:@"Trial Version only support 3 actors"];
        return;
    }
#endif // LITE_VERSION
    
    
    NSArray *args = [NSArray arrayWithObjects:
                     code,
                     nil];

    id castController = [win evaluateWebScript:@"castController"];
    
    [castController callWebScriptMethod:[NSString stringWithFormat:@"%s",SCRIPT_FUNC_NAME_APPEND_TO_CAST] withArguments:args];    
}


- (IBAction)switchTab:(id)sender 
{
    
    NSSegmentedControl *tab = sender;
    
    NSNumber *selectedTabNum = [NSNumber numberWithInteger:[tab selectedSegment]];
    
    id win = [webView windowScriptObject];
    
    NSArray *args = [NSArray arrayWithObjects:
                     selectedTabNum,
                     nil];
    [win callWebScriptMethod:[NSString stringWithFormat:@"%s", SCRIPT_FUNC_NAME_SWITCH_TAB] withArguments:args];
    
    NSRect frame = [webView frame];
    
    if ([selectedTabNum integerValue] == 1) {
        if (frame.origin.x != 0) {
            frame.size.width += originX;
            frame.origin.x = 0;
            [[webView animator] setFrame:frame];
        }
    } else {        
        if (frame.origin.x == 0) {
            frame.origin.x = originX;
            frame.size.width -= originX;        
            [[webView animator] setFrame:frame];
        }
    }
}


- (void)setCode:(NSString *)canvasCode withSize:(CGSize)canvasSize
{
    // modify the draw canvas function and redraw it.
    
    /* drawCanvas(canvasStr, width, height); */
    NSArray *args = [NSArray arrayWithObjects:
                     canvasCode,
                     [NSNumber numberWithInt:canvasSize.width],
                     [NSNumber numberWithInt:canvasSize.height],
                     nil];

    id win = [webView windowScriptObject];

    [win callWebScriptMethod:@"drawCanvas" withArguments:args];

}


@end
