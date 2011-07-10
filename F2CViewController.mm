//
//  F2CViewController.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/10.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "F2CViewController.h"

#import "ShapeViewController.h"
//#import "ShapeView.h"

//#ifdef __cplusplus
#import "VObject.h"
//#endif // __cplusplus


id refSelf;  // reference to [self] for the following C callback function.

// see SWFParser.h to implement the ProgressUpdateFunctionPtr
int progressUpdate(unsigned int progress)
{
    if(refSelf) {
        return [refSelf updateProgress:progress];
    }
    return NO;  // somthing wrong
}

@implementation F2CViewController


@synthesize webViewController, shapeCountLabel, filenameLabel, progressBar, parsingAlert, searchField;


///////////////////////////////////////////////////////
// The parser thread
///////////////////////////////////////////////////////
- (int)updateProgress:(unsigned int)progress
{
    //NSLog(@"progress = %d", progress);
    [progressBar incrementBy:(progress - progressBar.doubleValue)];
    return !userCancel;
}

- (void)myParserThreadMain
{
    //NSLog(@"parser thread start");
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    
    // Do some work on myData and report the results.
    parseResult = [model parseFile:[currentFilename UTF8String] withCallback:progressUpdate];
    
    // Tell the main thread, the parsing is finished (or error)
    if (!userCancel) {
        [self performSelectorOnMainThread:@selector(parseFinished) withObject:nil waitUntilDone:NO];
    }
    
    [pool release];
    //NSLog(@"parser thread exit");
}


//////////// Main Thread ///////////

- (void)awakeFromNib
{
    currentFilename         = [[NSMutableString alloc] init];
    model                   = [[Model alloc] init];
    shapeViewControllerList = [[NSMutableArray alloc] init];
    refSelf = self;
    //[progressBar setUsesThreadedAnimation:YES];
    [progressBar setStyle:NSProgressIndicatorBarStyle];
    f2cView = (F2CView *)[self view];
    
    //f2cView.delegate = self;
}

- (void)dealloc
{
    [currentFilename release];
    [shapeViewControllerList removeAllObjects];
    [shapeViewControllerList release];
    [model release];
    [super dealloc];
}


- (void)parseFinished
{
    [NSApp stopModal];
    [parsingAlert close];

    if (userCancel) {
        [filenameLabel setStringValue:[NSString stringWithFormat:@"User stopped parsing..."]];
        [progressBar stopAnimation:self];
        return;
    }
    
    
    // check the parse result
    // Following are handling after parsing done.
    
    if (parseResult) {
        uint numShapes = 0;
        
        numTags = model.numTags;
        //NSLog(@"numTags = %d", numTags);
        
        /* Taverse tags */
        VObject &tags = (*(model.root))["Tags"];
        
        
        for (int i = 0; i < numTags; i++) {
            const char *header = tags[i].getTypeInfo();
            //NSLog(@"header = %s", header);
            if ((strcmp(header, "DefineShape") != 0) &&
                (strcmp(header, "DefineShape2") != 0) &&
                (strcmp(header, "DefineShape3") != 0) &&
                (strcmp(header, "DefineShape4") != 0) 
            /*
             #ifdef DEBUG    // under development
             &&
             (strcmp(header, "SetBackgroundColor") != 0) &&
             (strcmp(header, "DefineBits") != 0) &&
             (strcmp(header, "JPEGTables") != 0) &&
             (strcmp(header, "DefineBitsJPEG2") != 0) &&
             (strcmp(header, "DefineBitsJPEG3") != 0) &&
             (strcmp(header, "DefineBitsJPEG4") != 0) &&
             (strcmp(header, "DefineBitsLossless") != 0) &&
             (strcmp(header, "DefineBitsLossless2") != 0)
             #endif // DEBUG
             */
                ) {
                continue;
            }
            
            numShapes++;
            [shapeCountLabel setStringValue:[NSString stringWithFormat:@"Shapes: %d", numShapes]];
            
            // create ShapeViewController
            ShapeViewController *svc = [[ShapeViewController alloc] initWithTag:&tags[i]];
            [shapeViewControllerList addObject:svc];
            [f2cView addSubview:svc.view];
            //[f2cView setNeedsDisplay:YES];
            [svc release];
        }
        
        [f2cView setNeedsDisplay:YES];
        [filenameLabel setStringValue:[NSString stringWithFormat:@"Filename: %@", currentFilename]];
        [progressBar stopAnimation:self];
        
        if (numShapes == 0) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:[NSString stringWithFormat:@"There is no vector shape in %@.", currentFilename]];
            [alert setAlertStyle:NSWarningAlertStyle];
            
            [alert runModal];
            [alert release];           
        }
        
        return;
    }
    
    [filenameLabel setStringValue:[NSString stringWithFormat:@"Failed to open %@", currentFilename]];
}

- (void)openFile:(const char *)filename
{
    [currentFilename setString:[NSString stringWithFormat:@"%s", filename]];

    // F2CView reset frame size and it's focus
    [f2cView reset];
    
    // Release Model & Shape Views
    [model release];
    [shapeViewControllerList removeAllObjects];


    // UI Update status
    [filenameLabel setStringValue:[NSString stringWithFormat:@"Parsing %@", currentFilename]];
    [shapeCountLabel setStringValue:@"Shape Count: 0"];    
    
    // Re-new
    model = [[Model alloc] init];
    
    
    userCancel = NO;
    [progressBar startAnimation:self];
    // run the parsing thread to prevent blocking the main UI thread.
    [self performSelectorInBackground:@selector(myParserThreadMain) withObject:nil];
    
    [NSApp runModalForWindow:parsingAlert];    
}

- (IBAction)stopParsing:(id)sender
{
    userCancel = YES;        
    [self parseFinished];   // It's main thread's job to finish.    
}

- (IBAction)openDocument:(id)sender
{
    int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"swf"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setAllowedFileTypes:fileTypes];
    [oPanel setCanCreateDirectories:NO];
    
    result = [oPanel runModal];
    
    if (result == NSOKButton) {
        
        NSArray *filesToOpen = [oPanel filenames];
        NSString *aFile = [filesToOpen objectAtIndex:0];
        [self openFile:[aFile UTF8String]];
        
    }
}

- (void)focusChange:(NSView *)theView
{
    if (theView) {
        // theView is actually a ShapeView, and it's drawer is the ShapeViewController.
        ShapeViewController *svc = (ShapeViewController *)(((ShapeView *)theView).drawer);
        [webViewController drawOnCanvas:svc.canvasCode];
    }
}

- (void)select:(NSView *)theView
{
    if (theView) {
        // theView is actually a ShapeView, and it's drawer is the ShapeViewController.
        ShapeViewController *svc = (ShapeViewController *)(((ShapeView *)theView).drawer);
        [webViewController appendToCast:svc.canvasCode];        
    }
}

- (IBAction)searchShape:(id)sender
{
    // sender is the search field
    NSView *shapeView = [f2cView viewWithTag:[searchField integerValue]];
    if (shapeView) {
        [f2cView scrollRectToVisible:[shapeView frame]];
    }
}


@end
