//
//  CodeViewController.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OSAKit/OSAKit.h>

@interface CodeViewController : NSViewController {
    OSAScriptView *codeView;
}

- (void)setCode:(NSString *)canvasCode;

@end
