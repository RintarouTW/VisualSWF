//
//  Model.h
//  
//
//  Created by Rintarou on 2011/1/3.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//
///

#import "Share.h"

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus

#include "VObject.h"
#include "SWFParser.h"

#endif // __cplusplus


@interface Model : NSObject {

    // C++ Classes
#ifdef __cplusplus
    SWFParser *parser;
    VObject *root;
#endif  // __cplusplus

    uint    numVObjects;
    uint    numObjects;
    uint    numArrays;
    uint    numTags;
}

#ifdef __cplusplus
@property (readonly) VObject *root;
#endif // __cplusplus

@property (readonly) uint numVObjects;
@property (readonly) uint numObjects;
@property (readonly) uint numArrays;
@property (readonly) uint numTags;

- (BOOL)parseFile:(const char *)filename;

#ifdef __cplusplus
- (BOOL)parseFile:(const char *)filename withCallback:(ProgressUpdateFunctionPtr)progressUpdate;
#endif // __cplusplus

@end
