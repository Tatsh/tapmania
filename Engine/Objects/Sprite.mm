//
//  Sprite.mm
//  TapMania
//
//  Created by chrisdanford on 6/17/10.
//  Copyright 2010 Chris Danford. All rights reserved.
//

#import "Sprite.h"
#import "TMFramedTexture.h"
#import <OpenGLES/ES1/glext.h>

@implementation Sprite

@synthesize texture, blendAdd, frameIndex;
@synthesize disabled;

- (id)initWithRepeating
{
    if (self = [super init])
    {
        repeatBlockOn = YES;
        m_qkf.push_back(QueuedKeyFrame(YES));
        disabled = NO;
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        repeatBlockOn = NO;
        m_qkf.push_back(QueuedKeyFrame());
        disabled = NO;
    }
    return self;
}

/*
+ (id) initWithTexture2D:(Texture2D *)texture
{
	if( self = [super init] )
	{
		self.m_texture = [texture retain];
		
	}
	return self;
}
*/
- (void)delloc
{
    [texture release];
}

- (void)startRepeatingBlock
{
    repeatBlockOn = YES;
}

- (void)stopRepeatingBlock
{
    repeatBlockOn = NO;
}

- (void)pushKeyFrame:(float)lengthSeconds
{
    QueuedKeyFrame qkf = m_qkf.back();

    if (repeatBlockOn)
        qkf.shouldRepeat = YES;
    else
        qkf.shouldRepeat = NO;

    m_qkf.back().lengthSeconds = lengthSeconds;
    m_qkf.push_back(qkf);
}

- (void)setX:(float)x
{
    m_qkf.back().kf.x = x;
}

- (void)setY:(float)y
{
    m_qkf.back().kf.y = y;
}

- (void)addX:(float)x
{
    m_qkf.back().kf.x += x;
}

- (void)addY:(float)y
{
    m_qkf.back().kf.y += y;
}

- (void)setScale:(float)scale
{
    QueuedKeyFrame &qkf = m_qkf.back();
    qkf.kf.scaleX = scale;
    qkf.kf.scaleY = scale;
    qkf.kf.scaleZ = scale;
}

- (void)setScaleX:(float)scale
{
    QueuedKeyFrame &qkf = m_qkf.back();
    qkf.kf.scaleX = scale;
}

- (void)setScaleY:(float)scale
{
    QueuedKeyFrame &qkf = m_qkf.back();
    qkf.kf.scaleY = scale;
}

- (void)setRotationX:(float)degrees
{
    m_qkf.back().kf.rotationXDegrees = degrees;
}

- (void)setRotationY:(float)degrees
{
    m_qkf.back().kf.rotationYDegrees = degrees;
}

- (void)setRotationZ:(float)degrees
{
    m_qkf.back().kf.rotationZDegrees = degrees;
}

- (void)setR:(float)r G:(float)g B:(float)b
{
    QueuedKeyFrame &qkf = m_qkf.back();
    qkf.kf.r = r;
    qkf.kf.g = g;
    qkf.kf.b = b;
}

- (void)setAlpha:(float)a
{
    m_qkf.back().kf.a = a;
}

- (void)finishKeyFrames
{
    if (m_qkf.size() > 1)
        m_qkf.erase(m_qkf.begin(), m_qkf.end() - 1);
    intoCurrentKeyFrameSeconds = 0;
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    // TODO: move keyframe updating in here
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    if (!disabled)
    {

        while (fDelta > 0 && m_qkf.size() > 1)
        {
            intoCurrentKeyFrameSeconds += fDelta;
            fDelta = intoCurrentKeyFrameSeconds - m_qkf.front().lengthSeconds;
            if (fDelta > 0)
            {
                if (m_qkf.front().shouldRepeat)
                    m_qkf.push_back(m_qkf.front());

                m_qkf.pop_front();
                intoCurrentKeyFrameSeconds = 0;
            }
        }
        KeyFrame kf;
        if (m_qkf.size() == 1)
        {
            kf = m_qkf.front().kf;
        }
        else if (m_qkf.size() > 1)
        {
            const QueuedKeyFrame &kf0 = m_qkf[0];
            const QueuedKeyFrame &kf1 = m_qkf[1];
            float percentToward2 = intoCurrentKeyFrameSeconds / kf0.lengthSeconds;
            kf = KeyFrame::WeightedAverage(kf0.kf, kf1.kf, percentToward2);
        }

        // If the end result will be no changed pixels, don't draw.
        if (kf.a <= 0)
            return;

        glPushMatrix();
        // Don't mutliply by matrices that will be identity.
        if (kf.x != 0 || kf.y != 0 || kf.z != 0)
            glTranslatef(kf.x, kf.y, kf.z);
        if (kf.scaleX != 0 || kf.scaleY != 0 || kf.scaleZ != 0)
            glScalef(kf.scaleX, kf.scaleY, kf.scaleZ);
        if (kf.rotationXDegrees != 0)
            glRotatef(kf.rotationXDegrees, 1, 0, 0);
        if (kf.rotationYDegrees != 0)
            glRotatef(kf.rotationYDegrees, 0, 1, 0);
        if (kf.rotationZDegrees != 0)
            glRotatef(kf.rotationZDegrees, 0, 0, 1);

        // TODO: Don't assume the blend function is set up for additive blending
        glEnable(GL_BLEND);
        if (blendAdd)
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        else
        {
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        }
        // TODO: Make a color stack and multiply by the top color on the stack.
        glColor4f(kf.r, kf.g, kf.b, kf.a);

        [texture drawFrame:frameIndex];

        // TODO: restore previous color, not (1,1,1,1)
        glColor4f(1, 1, 1, 1);

        // TODO: restore previous blend, not disable
        glDisable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

        glPopMatrix();
    }
}

@end
