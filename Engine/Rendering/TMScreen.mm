//
//  $Id$
//  TMScreen.m
//  TapMania
//
//  Created by Alex Kremer on 10.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "Texture2D.h"

#import "TMControl.h"
#import "MenuItem.h"
#import "Label.h"
#import "TogglerItem.h"
#import "Slider.h"
#import "ImageButton.h"
#import "DisplayUtil.h"
#import "GLUtil.h"

@implementation TMScreen

@synthesize brightness = m_fBrightness;

- (void)fade
{
    CGRect rect = [DisplayUtil getDeviceDisplayBounds];
    GLfloat vertices[] = {
            rect.origin.x, rect.origin.y,
            rect.origin.x + rect.size.width, rect.origin.y,
            rect.origin.x, rect.origin.y + rect.size.height,
            rect.origin.x + rect.size.width, rect.origin.y + rect.size.height
    };

    glColor4f(0, 0, 0, m_fBrightness);
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glColor4f(1, 1, 1, 1);
    TMBindTexture(0);
}

- (id)initWithMetrics:(NSString *)inMetricsKey
{
    // A screen is always fullscreen :P
    self = [super initWithShape:[DisplayUtil getDeviceDisplayBounds]];
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
        t_BG = TEXTURE(@"Common SharedBackground");
    }

    // Go through all the elements defined for the screen and look for buttons, labels, togglers etc.
    for (NSString *element in conf)
    {
        TMLog(@"Got elem: %@", element);
        //
//		NSArray* arr = [element componentsSeparatedByString:@"_"];
//		if([arr count] > 1) {
//			for(int i=1; i<[arr count]; ++i) {
//				if(i!=1) {
//					element = [element stringByAppendingString:@"_"];					
//				}
//				
//				element = [element stringByAppendingString:[arr objectAtIndex:i]];
//			}
//		}

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
    CGSize sz = [DisplayUtil getDeviceDisplaySize];
    CGRect bounds = CGRectMake(0, 0, sz.width, sz.height);

    [t_BG drawInRect:bounds];
    if (m_fBrightness != 1.0f)
    {
        [self fade];
    }

    // Render children
    [super render:fDelta];
}

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [[InputEngine sharedInstance] subscribe:self];
}

- (void)deinitOnTransition
{
//	// Disable all controls
//	for (TMViewChildren::iterator it = m_pChildren->begin(); it != m_pChildren->end(); ++it) {
//		[(TMView*)it->get() disable];
//	}

    [[InputEngine sharedInstance] unsubscribe:self];
}

@end

