//
//  $Id$
//  TMEffectSupport.h
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

/* 
 * Effects can be used to do any transformations on the original object.
 * This means that we will need accessor methods to tune the position/shape of the object we apply the effect to.
 */

@protocol TMEffectSupport

- (CGPoint)getPosition;

- (void)updatePosition:(CGPoint)point;

- (CGRect)getShape;

- (CGRect)getOriginalShape;

- (void)updateShape:(CGRect)shape;

@end