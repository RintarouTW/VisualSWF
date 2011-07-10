//
//  Model.m
//  
//
//  Created by Rintarou on 2011/1/3.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Model.h"

@implementation Model

#ifdef __cplusplus
@synthesize root;
#endif // __cplusplus

@synthesize numObjects, numVObjects, numArrays, numTags;

- (id) init
{
    self = [super init];
    if (self) {
        parser = new SWFParser();
        numObjects = 0;
    }
    return self;
}

- (void) dealloc
{
    //NSLog(@"model dealloc");
    delete parser;
    [super dealloc];
}

- (BOOL)parseFile:(const char *)filename
{
    return [self parseFile:filename withCallback:NULL];
}

- (BOOL)parseFile:(const char *)filename withCallback:(ProgressUpdateFunctionPtr)progressUpdate
{
    //NSLog(@"-- Parsing start --");

    root = parser->parseWithCallback(filename, progressUpdate);
    
    if (!root) {    // not complete parsing
        return NO;
    }
    
    // override the root getTypeInfo() to filename.
    NSString *baseFilename = [[NSString stringWithUTF8String:filename] lastPathComponent];
    root->setTypeInfo([baseFilename UTF8String]);
    if (root) {
        //NSLog(@"numVObjects = %d", root->numVObjects());
        //NSLog(@"numObjects = %d", root->numObjects());
        //NSLog(@"numArrays = %d", root->numArrays());
        //NSLog(@"-- Parsing done --");
        numVObjects = root->numVObjects();
        numObjects  = root->numObjects();
        numArrays   = root->numArrays();
        numTags     = (*root)["Tags"].length();
        return YES;
    }
    
    NSLog(@"Failed to parse the swf file!!");
    return NO;
}

@end
