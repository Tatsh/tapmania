//
//  DisplayUtil.m
//  TapMania
//
//  Created by Alex Kremer on 11/27/12.
//
//

#import "DisplayUtil.h"

@implementation DisplayUtil

+ (CGRect) getDeviceDisplayBounds {
    static CGRect res;
    static BOOL is_set = NO;
    
    // not likely to change in runtime :-)
    if(is_set)
    {
        return res;
    }
    
    res.origin = CGPointMake(0, 0);
    res.size = [DisplayUtil getDeviceDisplaySize];
    
    return res;
}

+ (CGSize) getDeviceDisplaySize {
    static CGSize res;
    static BOOL is_set = NO;
    
    // not likely to change in runtime :-)
    if(is_set)
    {
        return res;
    }
    
    // typical display size for iPhone
    float w = 320.0f;
    float h = 480.0f;
    
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 3.2f)
    {
        UIScreen* s = [UIScreen mainScreen];
        w = s.currentMode.size.width;
        h = s.currentMode.size.height;
    }
    
    // swap iPad size if mode is crazy
    if(h == 768.0f && w == 1024.0f)
    {
        h = 1024.0f;
        w = 768.0f;
    }
    else if (w == 1536.0f && h == 2048.0f)
    {
        h = 1536.0f;
        w = 2048.0f;
    }
    
    TMLog(@"Display size from iOS: %fx%f", w, h);

    res.height = h;
    res.width = w;
    is_set = YES;
    
    return res;
}


+ (NSString*) getDeviceDisplayString {
    static NSString* res = nil;
    
    // not likely to change in runtime :-)
    if(res != nil)
    {
        return res;
    }
    
    CGSize s = [DisplayUtil getDeviceDisplaySize];
    
    float w = s.width;
    float h = s.height;
    
    // check retina iPhone
    if (w == 640.0f && h == 960.0f)
    {
        res = @"iPhoneRetina";
    }
    
    // check iPhone5
    else if (w == 640.0f && h == 1136.0f)
    {
        res = @"iPhone5";
    }
    
    // check retina iPad
    else if (w == 1536.0f && h == 2048.0f)
    {
        res = @"iPadRetina";
    }
    
    // normal iPad or iPad mini
    else if (w == 768.0f && h == 1024.0f)
    {
        res = @"iPad";
    }
    
    // default basically
    else
    {
        res = @"iPhone";
    }
    
    return res;
}

+ (BOOL) isRetina {
    static BOOL res = NO;
    static BOOL is_set = NO;
    
    if(is_set)
    {
        return res;
    }
    
    if([[DisplayUtil getDeviceDisplayString] isEqualToString:@"iPhoneRetina"] ||
       [[DisplayUtil getDeviceDisplayString] isEqualToString:@"iPadRetina"] ||
       [[DisplayUtil getDeviceDisplayString] isEqualToString:@"iPhone5"])
    {
        res = YES;
    }

    return res;
}

@end
