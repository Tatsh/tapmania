//
//  $Id$
//  PhysicsUtil.h
//  TapMania
//
//  Created by Alex Kremer on 9.1.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kGravity -9.8f

@interface Vector : NSObject {
	float m_fX, m_fY;
}

@property(setter = setX:, getter = x, assign) float m_fX;
@property(setter = y:, getter = y, assign) float m_fY;

- (id) initWithX:(float)lx andY:(float)ly;
- (float) norm;
- (float) normSquared;
- (void) sum:(Vector*)v1;
- (void) sub:(Vector*)v1;
- (void) div:(Vector*)v1;
- (void) mul:(Vector*)v1;
- (void) divScalar:(float)op;
- (void) mulScalar:(float)op;

// Copy vector
+ (Vector*) vectorWithVector:(Vector*)vec;

// Static util functions. They all return autoreleased stuff
+ (float) norm:(Vector*)v0;
+ (float) normSquared:(Vector*)v0;
+ (Vector*) normalize:(Vector*)v0 withTolerance:(float)tolerance;

+ (float) dist:(Vector*)v0 And:(Vector*)v1;
+ (float) distSquared:(Vector*)v0 And:(Vector*)v1;
+ (Vector*) sum:(Vector*)v0 And:(Vector*)v1;
+ (Vector*) sub:(Vector*)v0 And:(Vector*)v1;
+ (Vector*) div:(Vector*)v0 And:(Vector*)v1;
+ (Vector*) mul:(Vector*)v0 And:(Vector*)v1;
+ (Vector*) divScalar:(Vector*)v0 And:(float)op;
+ (Vector*) mulScalar:(Vector*)v0 And:(float)op;
+ (float) dot:(Vector*)v0 And:(Vector*)v1;

@end

@interface Triangle : NSObject {
	Vector *v0, *v1, *v2;
}

@property(retain,nonatomic)	Vector* v0;
@property(retain,nonatomic)	Vector* v1;
@property(retain,nonatomic)	Vector* v2;

- (id) initWithV0:(Vector*)lv0 V1:(Vector*)lv1 andV2:(Vector*)lv2;
- (BOOL) containsPoint:(CGPoint)point;

@end

@interface PhysicsUtil : NSObject {
}
@end
