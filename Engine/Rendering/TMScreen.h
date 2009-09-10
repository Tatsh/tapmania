//
//  TMScreen.h
//  TapMania
//
//  Created by Alex Kremer on 10.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMTransitionSupport.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

#define INT_METRIC(key) [[ThemeManager sharedInstance] intMetric:key]
#define FLOAT_METRIC(key) [[ThemeManager sharedInstance] floatMetric:key]
#define STR_METRIC(key) [[ThemeManager sharedInstance] stringMetric:key]
#define RECT_METRIC(key) [[ThemeManager sharedInstance] rectMetric:key]
#define POINT_METRIC(key) [[ThemeManager sharedInstance] pointMetric:key]
#define SIZE_METRIC(key) [[ThemeManager sharedInstance] sizeMetric:key]

#define TEXTURE(key) [[ThemeManager sharedInstance] texture:key]
#define SKIN_TEXTURE(key) [[ThemeManager sharedInstance] skinTexture:key]
#define SOUND(key) [[ThemeManager sharedInstance] sound:key]

#ifdef __cplusplus

#include <deque>
// #include <memory>
using namespace std;

typedef deque<NSObject* > TMScreenChildren;
// typedef auto_ptr<TMScreenChildren > TMScreenChildrenPtr;

#endif

@interface TMScreen : NSObject <TMRenderable, TMLogicUpdater, TMTransitionSupport> {
	#ifdef __cplusplus
	@protected TMScreenChildren* m_pChildren;
	#endif
}

-(void) pushBackChild:(NSObject*)inChild;
-(void) pushChild:(NSObject*)inChild;
-(NSObject*) popBackChild;
-(NSObject*) popChild;

-(void) pushBackControl:(NSObject*)inChild;

@end
