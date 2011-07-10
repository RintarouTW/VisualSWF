//
//  CodeGen.h
//  F2C
//
//  Created by Rintarou on 2011/2/15.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VDefineShape.h"

#define F2C_DICTIONARY_NAME                 "F2CCast"                  // provide a understand-able model for the users(maybe designers).
#define F2C_CHARACTER_NAME_PREFIX           "F2CActor"

#define SCRIPT_FUNC_NAME_LOAD_DATAOBJECT    "loadDataObjectByJSON"     // function name of load data object from .js
#define SCRIPT_FUNC_NAME_APPEND_TO_CAST     "addItemByJSON"            // function name of append into the dictionary in JavaScript
#define SCRIPT_FUNC_NAME_DRAW_ACTOR         "drawActorByJSON"          // draw the character in the dictionary
#define SCRIPT_FUNC_NAME_SWITCH_TAB         "switchTab"                // swtich the active tab.

@interface CodeGen : NSObject {
}

+ (NSMutableString *)genCharacterName:(VDefineShape *)shape;

+ (NSMutableString *)genCodeOfShapes:(NSArray *)arrayOfshapes;

/* Gen a single character code, Not used so far. */
+ (NSMutableString *)genCodeOfShape:(VDefineShape *)shape;

@end
