//
//  $Id$
//  TMModalView.mm
//  TapMania
//
//  Created by Alex Kremer on 17.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMModalView.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "EAGLView.h"
#import "Texture2D.h"

#import "TMControl.h"
#import "MenuItem.h"
#import "Label.h"
#import "TogglerItem.h"
#import "Slider.h"
#import "ImageButton.h"
#import "DisplayUtil.h"

/**
 * TMModalView is a View which intercepts all user input
 */
@implementation TMModalView

- (id)initWithShape:(CGRect)inShape
{
    self = [super initWithShape:inShape];
    if (!self)
        return nil;

    [[InputEngine sharedInstance] subscribe:self];

    return self;
}

- (id)initWithMetrics:(NSString *)inMetricsKey
{
    // A modal dialog always acts as fullscreen
    self = [self initWithShape:[DisplayUtil getDeviceDisplayBounds]];
    if (!self)
        return nil;

    // Default - full bright bg
    m_fBrightness = 1.0f;

    NSDictionary *conf = DICT_METRIC(inMetricsKey);

    // Load Background texture
    t_BG = TEXTURE( ([NSString stringWithFormat:@"%@ Background", inMetricsKey]) );
    if (!t_BG)
    {
        // Load default
        t_BG = TEXTURE(@"Common DialogBackground");
    }

    // Go through all the elements defined for the dialog and look for buttons, labels, togglers etc.
    for (NSString *element in conf)
    {

        if ([element hasSuffix:@"Button"])
        {
            TMControl *ctrl = [[MenuItem alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
            [self pushBackControl:ctrl];
        }
        else if ([element hasSuffix:@"Label"])
        {
            TMControl *ctrl = [[Label alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
            [self pushBackControl:ctrl];
        }
        else if ([element hasSuffix:@"Slider"])
        {
            TMControl *ctrl = [[Slider alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
            [self pushBackControl:ctrl];
        }
        else if ([element hasSuffix:@"Toggler"])
        {
            TMControl *ctrl = [[TogglerItem alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
            [self pushBackControl:ctrl];
        }
        else if ([element hasSuffix:@"Img"])
        {
            TMControl *ctrl = [[ImageButton alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
            [self pushBackControl:ctrl];
        }
    }

    return self;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    // Render BG
    CGRect bounds = [DisplayUtil getDeviceDisplayBounds];

    if (m_fBrightness != 1.0f)
    {
        glColor4f(m_fBrightness, m_fBrightness, m_fBrightness, m_fBrightness);
    }

    // Dialog backgrounds can/should be with alpha
    glEnable(GL_BLEND);
    [t_BG drawInRect:bounds];
    glDisable(GL_BLEND);

    if (m_fBrightness != 1.0f)
    {
        // TODO: restore color to prev. value. not just to 1111
        glColor4f(1, 1, 1, 1);
    }

    // Render children
    [super render:fDelta];
}

// Intercept all input
- (BOOL)containsPoint:(CGPoint)point
{
    return YES;
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());
    BOOL handled = NO;

    if ([self isTouchInside:touch])
    {
        // Forward to children
        if (!m_pControls->empty())
        {
            int curSize = m_pControls->size();

            for (int i = 0; i < curSize; ++i)
            {
                NSObject *obj = *(m_pControls->at(i));
                handled = handled ? handled : [(id <TMGameUIResponder>) obj tmTouchesEnded:touches withEvent:event];
                curSize = m_pControls->size();    // To be safe
            }
        }

        // Missed any child control?
        if (!handled)
        {
            [self close];
        }

        return YES;
    }

    return NO;
}


- (void)close
{
    [[InputEngine sharedInstance] unsubscribe:self];
    [[TapMania sharedInstance] performSelectorOnMainThread:@selector(removeOverlay:) withObject:self waitUntilDone:NO];
}

@end
