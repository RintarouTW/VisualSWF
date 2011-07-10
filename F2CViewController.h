//
//  F2CViewController.h
//  F2C
//
//  Created by Rintarou on 2011/2/10.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "F2CView.h"
#import "Model.h"

//#import "CodeViewController.h"
#import "WebViewController.h"


@interface F2CViewController : NSViewController <FocusChange> {
    NSMutableString *currentFilename;
    BOOL            parseResult;
    BOOL            userCancel;
    Model           *model;
    
    
    NSProgressIndicator *progressBar;   // for Model's parsing progress
    NSPanel         *parsingAlert;
    
    
    F2CView         *f2cView;
    
    
    NSTextField     *shapeCountLabel;
    NSTextField     *filenameLabel;

    NSMutableArray  *shapeViewControllerList;
    
    uint    numTables;
    uint    numTags;
    
    NSSearchField *searchField;
    WebViewController  *webViewController;
}

@property (assign) IBOutlet NSProgressIndicator *progressBar;
@property (assign) IBOutlet NSPanel             *parsingAlert;

@property (assign) IBOutlet WebViewController   *webViewController;
@property (assign) IBOutlet NSTextField         *shapeCountLabel;
@property (assign) IBOutlet NSTextField         *filenameLabel;

@property (assign) IBOutlet NSSearchField       *searchField;

- (IBAction)searchShape:(id)sender;

- (IBAction)openDocument:(id)sender;
- (IBAction)stopParsing:(id)sender;

- (void)openFile:(const char *)filename;

- (void)focusChange:(NSView *)theView;
- (void)select:(NSView *)theView;

- (int)updateProgress:(unsigned int)progress;

@end
