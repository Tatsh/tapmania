//
//  $Id$
//  PadConfigRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 6/16/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "PadConfigRenderer.h"
#import "Texture2D.h"
#import "TMFramedTexture.h"
#import "InputEngine.h"
#import "ThemeManager.h"

#import "EAGLView.h"
#import "TapMania.h"
#import "MainMenuRenderer.h"
#import "OptionsMenuRenderer.h"
#import "QuadTransition.h"
#import "MenuItem.h"
#import "ZoomEffect.h"

#import "TapNote.h"
#import "ReceptorRow.h"
#import "LifeBar.h"
#import "JoyPad.h"

//#import "FlurryAPI.h"
#import "PhysicsUtil.h"

@interface PadConfigRenderer (InputHandling)
- (void)resetButtonHit;
@end

@implementation PadConfigRenderer

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];
//	[FlurryAPI logEvent:@"padconfig_screen_enter"];

    // Cache graphics
    t_FingerTap = (TMFramedTexture *) TEXTURE(@"Common FingerTapG");
    t_TapNote = (TapNote *) SKIN_TEXTURE(@"DownTapNote");

    // Cache metrics
    mt_LifeBar = RECT_METRIC(@"SongPlay LifeBar");

    // Reset the joyPad to hold currently configured locations
    [[TapMania sharedInstance].joyPad reset];

    int i;
    for (i = 0; i < kNumOfAvailableTracks; ++i)
    {
        mt_ReceptorButtons[i] = RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow %d", i]));
        m_pFingerTap[i] = [Vector vectorWithVector:[[TapMania sharedInstance].joyPad getJoyPadButton:(JPButton) i]];
    }

    // Start with no action. means we must select a receptor arrow
    m_nPadConfigAction = kPadConfigAction_None;

    // Init the receptor row
    m_pReceptorRow = [[ReceptorRow alloc] init];

    // Init the lifebar
    m_pLifeBar = [[LifeBar alloc] initWithRect:mt_LifeBar];

    // Link the reset button
    m_pResetButton = (MenuItem *) [self findControl:@"PadConfig ResetButton"];
    if (m_pResetButton != nil)
    {
        [m_pResetButton setActionHandler:@selector(resetButtonHit) receiver:self];
    }

    // Add children
    [self pushBackChild:m_pLifeBar];
    [self pushBackChild:m_pReceptorRow];

    // Remove ads for this time
    [[TapMania sharedInstance] toggleAds:NO];
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];

    // Get ads back to place
    [[TapMania sharedInstance] toggleAds:YES];
}

/* TMRenderable methods */
- (void)render:(float)fDelta
{
    CGRect bounds = [TapMania sharedInstance].glView.bounds;

    // Draw children
    [super render:fDelta];

    // Draw the fingertaps
    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        glEnable(GL_BLEND);
        if (i == m_nSelectedTrack && m_nPadConfigAction == kPadConfigAction_SelectLocation)
        {
            [t_FingerTap drawFrame:i atPoint:CGPointMake(m_pFingerTap[i].m_fX, m_pFingerTap[i].m_fY)];
        } else
        {
            [t_FingerTap drawFrame:i + kNumOfAvailableTracks atPoint:CGPointMake(m_pFingerTap[i].m_fX, m_pFingerTap[i].m_fY)];
        }
        glDisable(GL_BLEND);
    }
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{

    // Show the reset button if no track is selected
    if (m_nPadConfigAction == kPadConfigAction_None)
    {
        [m_pResetButton show];
    }

    if (m_nPadConfigAction == kPadConfigAction_Exit)
    {
        // Exit to options menu
        [[TapMania sharedInstance] switchToScreen:[OptionsMenuRenderer class] withMetrics:@"OptionsMenu" usingTransition:[QuadTransition class]];

        m_nPadConfigAction = kPadConfigAction_None;
    }

    if (m_nPadConfigAction == kPadConfigAction_SelectedTrack)
    {
        // Should explode the selected track
        [m_pReceptorRow tapNoteExplodeTrack:m_nSelectedTrack bright:true judgement:kJudgementW1];
        [m_pResetButton hide];

        m_nPadConfigAction = kPadConfigAction_SelectLocation;    // Must select a location now

    } else if (m_nPadConfigAction == kPadConfigAction_SelectLocation)
    {
        // Must light the selected receptor while user decides
        [m_pReceptorRow tapNoteExplodeTrack:m_nSelectedTrack bright:true judgement:kJudgementW1];

    } else if (m_nPadConfigAction == kPadConfigAction_Reset)
    {
        // Reset the pad to default values
        TMLog(@"Reset pad");
        [[TapMania sharedInstance].joyPad resetToDefault];

        for (int i = 0; i < kNumOfAvailableTracks; ++i)
        {
            if (m_pFingerTap[i])
            {
                [m_pFingerTap[i] release];
            }

            m_pFingerTap[i] = [Vector vectorWithVector:[[TapMania sharedInstance].joyPad getJoyPadButton:(JPButton) i]];
        }

        m_nPadConfigAction = kPadConfigAction_None;
    }

    [super update:fDelta];
}

/* TMGameUIResponder methods */
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (m_nPadConfigAction != kPadConfigAction_SelectLocation)
        return [super tmTouchesBegan:touches withEvent:event];

    if (touches.size() == 1)
    {
        TMTouch touch = touches.at(0);
        CGPoint point = CGPointMake(touch.x(), touch.y());

        m_pFingerTap[m_nSelectedTrack].m_fX = point.x;
        m_pFingerTap[m_nSelectedTrack].m_fY = point.y;
    }

    return YES;
}

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (m_nPadConfigAction != kPadConfigAction_SelectLocation)
        return [super tmTouchesMoved:touches withEvent:event];

    return [self tmTouchesBegan:touches withEvent:event];    // Do the positioning
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (touches.size() == 1)
    {
        TMTouch touch = touches.at(0);
        CGPoint point = CGPointMake(touch.x(), touch.y());

        int i;
        for (i = 0; i < kNumOfAvailableTracks; ++i)
        {
            if (CGRectContainsPoint(mt_ReceptorButtons[i], point))
            {
                m_nPadConfigAction = kPadConfigAction_SelectedTrack;
                m_nSelectedTrack = (TMAvailableTracks) i;    // Save the track number we touched

                return YES;
            }
        }

        // If none of the receptor arrows was touched
        if (CGRectContainsPoint(mt_LifeBar, point))
        {
            m_nPadConfigAction = kPadConfigAction_Exit;

        } else if (m_nPadConfigAction == kPadConfigAction_SelectLocation)
        {
            TMLog(@"Select location for track %d: x:%f y:%f", m_nSelectedTrack, point.x, point.y);
            [[TapMania sharedInstance].joyPad setJoyPadButton:(JPButton) m_nSelectedTrack onLocation:point];

            m_nPadConfigAction = kPadConfigAction_None;
        } else
        {
            return [super tmTouchesEnded:touches withEvent:event];
        }
    }

    return YES;
}

/* Input handlers */
- (void)resetButtonHit
{
    if (m_nPadConfigAction == kPadConfigAction_None)
        m_nPadConfigAction = kPadConfigAction_Reset;
}


@end
