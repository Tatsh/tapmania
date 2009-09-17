//
//  TMView.h
//  TapMania
//
//  Created by Alex Kremer on 17.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMGameUIResponder.h"

#ifdef __cplusplus

#include <deque>
using namespace std;

typedef deque<NSObject* > TMViewChildren;

#endif

@interface TMView : NSObject <TMRenderable, TMLogicUpdater, TMGameUIResponder> {
	CGRect		m_rShape;		// The points where the view is drawn
	BOOL		m_bEnabled;		// Whether this view is enabled for input
	BOOL		m_bVisible;		// Whether this view is visible or hidden
	
#ifdef __cplusplus
	TMViewChildren* m_pChildren;
#endif
}

- (id) initWithShape:(CGRect)inShape;

- (BOOL) containsPoint:(CGPoint)point;

- (void) disable;
- (void) enable;

- (void) show;
- (void) hide;


-(void) pushBackChild:(NSObject*)inChild;
-(void) pushChild:(NSObject*)inChild;
-(NSObject*) popBackChild;
-(NSObject*) popChild;

-(void) pushBackControl:(NSObject*)inChild;

@end
