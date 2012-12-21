//
//  $Id$
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
#import "ObjCPtr.h"

using namespace std;
@class TMView, TMControl;

typedef ObjCPtr<NSObject> TMViewChildPtr;
typedef deque<TMViewChildPtr> TMViewChildren;

#endif

@interface TMView : NSObject <TMRenderable, TMLogicUpdater, TMGameUIResponder>
{
    CGRect m_rShape;            // The points where the view is drawn
    CGRect m_rOriginalShape;    // A copy of rShape
    BOOL m_bEnabled;            // Whether this view is enabled for input
    BOOL m_bVisible;            // Whether this view is visible or hidden

#ifdef __cplusplus
    TMViewChildren *m_pChildren;    // All children
    TMViewChildren *m_pControls;    // Input delegation
#endif
}

- (id)initWithShape:(CGRect)inShape;

- (BOOL)containsPoint:(CGPoint)point;

- (BOOL)isTouchInside:(const TMTouch&)touch;

- (void)disable;

- (void)enable;

- (void)show;

- (void)hide;

- (void)pushBackChild:(NSObject *)inChild;

- (void)pushChild:(NSObject *)inChild;

- (NSObject *)popBackChild;

- (NSObject *)popChild;

- (TMControl *)findControl:(NSString *)inPath;

- (void)pushBackControl:(TMControl *)inChild;

- (void)pushControl:(TMControl *)inChild;

@end
