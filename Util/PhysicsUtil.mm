//
//  $Id$
//  PhysicsUtil.m
//  TapMania
//
//  Created by Alex Kremer on 9.1.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "PhysicsUtil.h"

#define PI 3.14159265358979323846
#define DOUBLE_PI 6.28318530717958647692    // Precomputed 2*PI

@implementation Vector

@synthesize m_fX, m_fY;

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    m_fX = 0.0f;
    m_fY = 0.0f;

    return self;
}

- (id)initWithX:(float)lx andY:(float)ly
{
    self = [super init];
    if (!self)
        return nil;

    m_fX = lx;
    m_fY = ly;

    return self;
}

- (id)initWithPoint:(CGPoint)point
{
    self = [super init];
    if (!self)
        return nil;

    m_fX = point.x;
    m_fY = point.y;

    return self;
}

+ (Vector *)vectorWithVector:(Vector *)vec
{
    return [[Vector alloc] initWithX:vec.m_fX andY:vec.m_fY];
}

- (float)norm
{
    return sqrt(m_fX * m_fX + m_fY * m_fY);
}

- (float)normSquared
{
    return (m_fX * m_fX + m_fY * m_fY);
}

- (void)sum:(Vector *)v1
{
    m_fX += v1.x;
    m_fY += v1.y;
}

- (void)sub:(Vector *)v1
{
    m_fX -= v1.x;
    m_fY -= v1.y;
}

- (void)mul:(Vector *)v1
{
    m_fX *= v1.x;
    m_fY *= v1.y;
}

- (void)div:(Vector *)v1
{
    m_fX /= v1.x;
    m_fY /= v1.y;
}

- (void)divScalar:(float)op
{
    m_fX /= op;
    m_fY /= op;
}

- (void)mulScalar:(float)op
{
    m_fX *= op;
    m_fY *= op;
}

+ (float)norm:(Vector *)v0
{
    return sqrt(v0.x * v0.x + v0.y * v0.y);
}

+ (float)normSquared:(Vector *)v0
{
    return (v0.x * v0.x + v0.y * v0.y);
}

+ (Vector *)normalize:(Vector *)v0 withTolerance:(float)tolerance
{
    float len = [Vector norm:v0];

    if (len >= tolerance)
    {
        return [[[Vector alloc] initWithX:v0.x / len andY:v0.y / len] autorelease];
    }

    return [[[Vector alloc] init] autorelease];
}

+ (float)dist:(Vector *)v0 And:(Vector *)v1
{
    return sqrt([Vector distSquared:v0 And:v1]);
}

+ (float)distSquared:(Vector *)v0 And:(Vector *)v1
{
    return (v0.x - v1.x) * (v0.x - v1.x) + (v0.y - v1.y) * (v0.y - v1.y);
}

+ (Vector *)sum:(Vector *)v0 And:(Vector *)v1
{
    return [[[Vector alloc] initWithX:v0.x + v1.x andY:v0.y + v1.y] autorelease];
}

+ (Vector *)sub:(Vector *)v0 And:(Vector *)v1
{
    return [[[Vector alloc] initWithX:v0.x - v1.x andY:v0.y - v1.y] autorelease];
}

+ (Vector *)div:(Vector *)v0 And:(Vector *)v1
{
    return [[[Vector alloc] initWithX:v0.x / v1.x andY:v0.y / v1.y] autorelease];
}

+ (Vector *)mul:(Vector *)v0 And:(Vector *)v1
{
    return [[[Vector alloc] initWithX:v0.x * v1.x andY:v0.y * v1.y] autorelease];
}

+ (Vector *)divScalar:(Vector *)v0 And:(float)op
{
    return [[[Vector alloc] initWithX:v0.x / op andY:v0.y / op] autorelease];
}

+ (Vector *)mulScalar:(Vector *)v0 And:(float)op
{
    return [[[Vector alloc] initWithX:v0.x * op andY:v0.y * op] autorelease];
}

+ (float)dot:(Vector *)v0 And:(Vector *)v1
{
    return (v0.x * v1.x + v0.y * v1.y);
}
@end

@implementation Triangle

@synthesize v0, v1, v2;

- (id)initWithV0:(Vector *)lv0 V1:(Vector *)lv1 andV2:(Vector *)lv2
{
    self = [super init];
    if (!self)
        return nil;

    v0 = lv0;
    v1 = lv1;
    v2 = lv2;

    return self;

}

- (void)dealloc
{
    [v0 release];
    [v1 release];
    [v2 release];

    [super dealloc];
}

- (BOOL)containsPoint:(CGPoint)point
{
    double dAngle;
    double epsilon = 0.01f;

    Vector *vPoint = [[Vector alloc] initWithX:point.x andY:point.y];
    Vector *vec0 = [Vector normalize:[Vector sub:vPoint And:v0] withTolerance:0.01];
    Vector *vec1 = [Vector normalize:[Vector sub:vPoint And:v1] withTolerance:0.01];
    Vector *vec2 = [Vector normalize:[Vector sub:vPoint And:v2] withTolerance:0.01];

    dAngle = acos([Vector dot:vec0 And:vec1]) +
            acos([Vector dot:vec1 And:vec2]) +
            acos([Vector dot:vec2 And:vec0]);

    if (fabs(dAngle - DOUBLE_PI) < epsilon)
        return true;
    else
        return false;
}

@end

@implementation PhysicsUtil
@end
