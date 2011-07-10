/*
 *  common.c
 *  
 *
 *  Created by Rintarou on 2010/12/28.
 *  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
 *
 */

#import "Share.h"

/*
CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGFloat comps[] = {w, a};
    CGColorRef color = CGColorCreate(gray, comps);
    CGColorSpaceRelease(gray);
    return color;
}
 */


@implementation Shared


+ (uint)string2uint:(const char *)colorStr
{
    unsigned int i = 0;
    
    NSString *str = [NSString stringWithUTF8String:colorStr];
    
    [[NSScanner scannerWithString: str] scanHexInt: &i];
    
    return i;
    
}

+ (void)dumpRect:(CGRect)rect andRectName:(const char *)rectName;
{
    NSLog(@"%s = (%f, %f, %f, %f)", rectName, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

+ (void)dumpPoint:(CGPoint)p andPointName:(const char *)pointName;
{
    NSLog(@"%s = (%f, %f)", pointName, p.x, p.y);
}

+ (CGPoint)normalizeVector:(CGPoint)vec withLength:(CGFloat)length
{
    CGPoint np = CGPointMake(0, 0);
    CGFloat l = sqrt((vec.x) * (vec.x) + (vec.y) * (vec.y));
    if (l > 0) {
        np.x = vec.x / l * length;
        np.y = vec.y / l * length;
    }
    return np;
}
@end

