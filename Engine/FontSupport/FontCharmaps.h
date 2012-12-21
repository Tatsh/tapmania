//
//  $Id$
//  FontCharmaps.h
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

/*
 * This code is pretty much a copy of StepMania's FontCharmaps.cpp file. Credit goes to Glenn Maynard
 */

#import <Foundation/Foundation.h>

@interface FontCharmaps : NSObject
{
    NSMutableDictionary *m_pCharmaps;    // The charmaps map
}

- (NSString *)getCharMap:(NSString *)name;

+ (FontCharmaps *)sharedInstance;

@end
