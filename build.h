//
//  build.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/23.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#ifndef _VISUALSWF_BUILD_H_
#define _VISUALSWF_BUILD_H_
 
#define ORIGIN_RADIUS               4       // in pixel

#define SWF_GRADIENT_SQAURE         16384   // in twips


// PreviewLayer Box Padding
#define PREVIEWBOX_PADDING_X        20
#define PREVIEWBOX_PADDING_Y        20

// VShape
#define SHAPE_STEP_DRAW_TIMER_INTERVAL  0.2 // in seconds


// VEdge
#define TURN_TWIPS_TO_PIXEL                 // do we need this? so far, to make it simple.

#define TWIPS_PER_PIXEL             20
#define ARROW_WIDTH                 4
#define ARROW_LENGTH                10

// VColor
#define COLOR_BOX_WIDTH             100
#define COLOR_BOX_HEIGHT            100

// TableLayer
#define TABLE_MAX_TEXT_LENGTH       40
#define TABLE_CELL_HEIGHT           16
#define TABLE_GLYPH_WIDTH           11
#define TABLE_MAX_WIDTH             (TABLE_GLYPH_WIDTH * TABLE_MAX_TEXT_LENGTH * 2) // + padding (TODO)
#define TABLE_ROW_PADDING_X         2
#define TABLE_ROW_PADDING_Y         5



// for Traverser
#define TRAVERSER_PREVIEWABLE_ONLY   YES        // Show the previewable tags only. (DEFAULT enabled)
#define TRAVERSER_TABLE_LIMIT        4000       // max tables colud be generated. (memory concern)
#define TRAVERSER_TIMER_INTERVAL     0.2        // in seconds
#define TRAVERSER_PARSE_TIME_SLICE   6000       // in us
#define TRAVERSER_MAX_DEPTH          8


#endif  // _VISUALSWF_BUILD_H_