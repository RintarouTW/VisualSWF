//
//  VPlayer.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/27.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VPlayer : NSObject {
    //////////////////////////////////////    
    // Used by Define Tags
    //////////////////////////////////////
    
    // FillStyleArray   *fillStyleArray;     // current fill styles can be used(indexed by style changed record)
    // LineStyleArray   *lineStylesArray;    // current line styles can be used(indexed by style changed record)
    // Dictionary       *dictionary;
    
    // JPEGTable        *jpegTable;
    
    //////////////////////////////////////
    // Used by Control Tags
    //////////////////////////////////////
    
    // DisplayList      *displayList;
    // Stage            *stage;
    
    
    //////////////////////////////////////
    // Action releated Tags
    //////////////////////////////////////
    // AVM1             *avm1;
        // 1. stack based vm
        // 2. extend to 
    // AVM2             *avm2;
    // int              frameNum;
    
    //////////////////////////////////////
    // Platform related
    //////////////////////////////////////
    
    // OS?
    // Browser?
    // Hardware?
    
    //////////////////////////////////////
    // Event Control
    //////////////////////////////////////
    
    // UI Events
    // Network Events
    // System Events
    
}

@end
