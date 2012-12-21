//
//  $Id: Sprite.h 341 2009-11-20 00:14:40Z chrisdanford $
//  Sprite.h
//  TapMania
//
//  Created by Chris Danford on 06.17.10.
//  Copyright 2010 Chris Danford. All rights reserved.
//

@class TMFramedTexture;

#import "TMRenderable.h"
#import "TMLogicUpdater.h"

// TODO: Move all of the implementation-only stuff out of this header
#import <deque>

using namespace std;

struct KeyFrame
{
    float x, y, z;
    float scaleX, scaleY, scaleZ;
    float rotationXDegrees, rotationYDegrees, rotationZDegrees;
    float r, g, b, a;

    KeyFrame()
    {
        x = 0;
        y = 0;
        z = 0;
        scaleX = 1;
        scaleY = 1;
        scaleZ = 1;
        rotationXDegrees = 0;
        rotationYDegrees = 0;
        rotationZDegrees = 0;
        r = 1;
        g = 1;
        b = 1;
        a = 1;
    }

    static KeyFrame WeightedAverage(const KeyFrame &ss1, const KeyFrame &ss2, float percentToward2)
    {
        KeyFrame ret;
#define WEIGHTED(v) \
    ret.v = ss1.v * (1 - percentToward2) + ss2.v * percentToward2;
        WEIGHTED(x);
        WEIGHTED(y);
        WEIGHTED(z);
        WEIGHTED(scaleX);
        WEIGHTED(scaleY);
        WEIGHTED(scaleZ);
        WEIGHTED(rotationXDegrees);
        WEIGHTED(rotationYDegrees);
        WEIGHTED(rotationZDegrees);
        WEIGHTED(r);
        WEIGHTED(g);
        WEIGHTED(b);
        WEIGHTED(a);
#undef WEIGHTED
        return ret;
    }
};

struct QueuedKeyFrame
{
    KeyFrame kf;
    float lengthSeconds;
    BOOL shouldRepeat;

    QueuedKeyFrame(BOOL repeating = NO)
    {
        lengthSeconds = 0;
        shouldRepeat = repeating;
    }
};

/*
 * Hold a texture and the animation state of an on-screen object.
 */
@interface Sprite : NSObject <TMRenderable, TMLogicUpdater>
{
    TMFramedTexture *texture;
@public
    deque<QueuedKeyFrame> m_qkf;
    float intoCurrentKeyFrameSeconds;
    bool blendAdd;
    BOOL repeatBlockOn;
    int frameIndex;

    BOOL disabled;
}

@property(assign) BOOL disabled;
@property(retain) TMFramedTexture *texture;
@property(assign) bool blendAdd;
@property(assign) int frameIndex;

- (void)startRepeatingBlock;

- (void)stopRepeatingBlock;

- (void)pushKeyFrame:(float)lengthSeconds;

- (void)setX:(float)x;

- (void)setY:(float)y;

- (void)addX:(float)x;

- (void)addY:(float)y;

- (void)setScale:(float)scale;

- (void)setScaleX:(float)scale;

- (void)setScaleY:(float)scale;

- (void)setRotationX:(float)degrees;

- (void)setRotationY:(float)degrees;

- (void)setRotationZ:(float)degrees;

- (void)setR:(float)r G:(float)g B:(float)b;

- (void)setAlpha:(float)a;

- (void)finishKeyFrames;

- (id)init;

- (id)initWithRepeating;

- (void)update:(float)fDelta;

- (void)render:(float)fDelta;

@end
