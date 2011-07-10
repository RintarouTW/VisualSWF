/*
 *  common.h
 *  
 *
 *  Created by Rintarou on 2010/12/28.
 *  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
 *
 */

#import "build.h"

#ifndef _SHARE_H_
#define _SHARE_H_

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif


//#define ABS(v)  ((v < 0) ? -(v) : v)

#endif // _SHARE_H_


CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);

@interface Shared : NSObject {
}

/* Useful Utility Functions */

+ (uint)string2uint:(const char *)colorStr;

+ (void)dumpRect:(CGRect)rect andRectName:(const char *)rectName;
+ (void)dumpPoint:(CGPoint)p andPointName:(const char *)pointName;
+ (CGPoint)normalizeVector:(CGPoint)vec withLength:(CGFloat)length;
@end
