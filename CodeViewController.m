//
//  CodeViewController.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "CodeViewController.h"


@implementation CodeViewController

- (void)awakeFromNib
{
    codeView = (OSAScriptView *)[self view];
}    

- (void)setCode:(NSString *)canvasCode;
{
    [codeView selectAll:self];
    [codeView insertText:canvasCode];
    [codeView selectAll:self];    
}

@end
