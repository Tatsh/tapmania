//
//  PhysicsUtil.h
//  TapMania
//
//  Created by Alex Kremer on 9.1.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Vector : NSObject {
	float x,y;
}

@property(assign,nonatomic) float x;
@property(assign,nonatomic) float y;

- (id) initWithX:(float)lx andY:(float)ly;
- (float) norm;
- (float) normSquared;

// Static util functions
+ (float) norm:(Vector*)v0;
+ (float) normSquared:(Vector*)v0;
+ (Vector*) normalize:(Vector*)v0 withTolerance:(float)tolerance;

+ (float) dist:(Vector*)v0 and:(Vector*)v1;
+ (float) distSquared:(Vector*)v0 and:(Vector*)v1;
+ (Vector*) sum:(Vector*)v0 and:(Vector*)v1;
+ (Vector*) sub:(Vector*)v0 and:(Vector*)v1;
+ (float) dot:(Vector*)v0 and:(Vector*)v1;

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
