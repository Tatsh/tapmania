//
//  DisplayUtil.h
//  TapMania
//
//  Created by Alex Kremer on 11/27/12.
//
//

#import <Foundation/Foundation.h>

@interface DisplayUtil : NSObject

+ (CGRect)getDeviceDisplayBounds;

+ (CGSize)getDeviceDisplaySize;

+ (NSString *)getDeviceDisplayString;

+ (BOOL)isRetina;

+ (NSString *)getDefaultPngName;

+ (NSString *)getDeviceTypeString;
@end
