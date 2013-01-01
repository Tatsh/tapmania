//
//  $Id$
//  SongPickerWheel.mm
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SongPickerWheel.h"
#import "SongPickerMenuItem.h"

#import "SettingsEngine.h"
#import "ThemeManager.h"
#import "PhysicsUtil.h"
#import "Texture2D.h"
#import "GameState.h"
#import "FontString.h"
#import "DisplayUtil.h"
#import "TimingUtil.h"
#import "SongPickerMenuRenderer.h"

extern TMGameState *g_pGameState;

enum TMWheelAnimationState
{
    IDLE,
    ANIMATING_UP,
    ANIMATING_DOWN,
    ANIMATING_BACK,
};

@interface SongPickerWheel ()
- (void)scrollWheelUp:(float)animSpeed;

- (void)scrollWheelDown:(float)animSpeed;

- (void)scrollWheelBack:(float)animSpeed;

@end

@implementation SongPickerWheel
{
    float m_lastTouchY;
    double m_scrollAnimationStartTime;
    float m_scrollAnimationSpeed;
    CGFloat m_scrollAnimationStartOffset;
    TMWheelAnimationState m_state;
    BOOL m_allowPreviewMusic;
    BOOL m_shouldPlayMusicOnRequest;
    Sprite *m_HighlightSprite;
    float currentBeat;
    float currentBps;
    CGRect mt_Scissor;
}

@synthesize songChanged;

- (id)init
{
    // FIXME: metrics please!
    self = [super initWithShape:CGRectMake(160, 0, 320, 320)];
    if ( !self )
    {
        return nil;
    }

    m_state = IDLE;
    currentBeat = 0.0f;
    currentBps = 1.0f;

    m_pWheelItems = new TMWheelItems();
    NSArray *songList = [[SongsDirectoryCache sharedInstance] getSongList];

    mt_SelectedWheelItemId = INT_METRIC(@"SongPickerMenu Wheel SelectedWheelItemId");
    mt_NumWheelItems = INT_METRIC(@"SongPickerMenu Wheel NumberOfWheelItems");
    mt_SelectedItemCenterY = FLOAT_METRIC(@"SongPickerMenu Wheel SelectedItemCenterY");

    // Lookup the index of the latest song played/selected
    int selectedIndex = [[SongsDirectoryCache sharedInstance] songIndex:
            [[SettingsEngine sharedInstance] getStringValue:@"lastsong"]];

    // Cache metrics
    mt_Scissor = RECT_METRIC(@"SongPickerMenu Wheel Scissor");
    mt_DistanceBetweenItems = FLOAT_METRIC(@"SongPickerMenu Wheel DistanceBetweenItems");
    mt_ItemSong = RECT_METRIC(@"SongPickerMenu Wheel ItemSong");
    mt_ItemSongHalfHeight = (int) (mt_DistanceBetweenItems / 2.0f);

    mt_HighlightCenter = CGRectMake(mt_ItemSong.origin.x, mt_SelectedItemCenterY,
            mt_ItemSong.size.width, mt_ItemSong.size.height);

    mt_ScoreDisplay = POINT_METRIC(@"SongPickerMenu Wheel Score");
    mt_ScoreFrame = POINT_METRIC(@"SongPickerMenu Wheel ScoreFrame");

    mt_wheelTopTouchZone = FLOAT_METRIC(@"SongPickerMenu Wheel TopTouchZone");

    mt_Highlight = RECT_METRIC(@"SongPickerMenu Wheel Highlight");
    mt_Highlight.origin.x = mt_HighlightCenter.origin.x - mt_Highlight.size.width / 2;
    mt_Highlight.origin.y = mt_HighlightCenter.origin.y - mt_Highlight.size.height / 2;
    mt_HighlightHalfHeight = (int) (mt_Highlight.size.height / 2);

    // Cache graphics
    t_Highlight = (TMFramedTexture *) TEXTURE(@"SongPickerMenu Wheel Highlight");
    t_ScoreFrame = TEXTURE(@"SongPickerMenu Wheel ScoreFrame");
    m_pScoreStr = [[FontString alloc] initWithFont:@"SongPickerMenu WheelScoreDisplay" andText:@"       0"];

    m_HighlightSprite = [[Sprite alloc] initWithRepeating];
    [m_HighlightSprite setTexture:t_Highlight];
    [m_HighlightSprite setX:mt_HighlightCenter.origin.x];
    [m_HighlightSprite setY:mt_HighlightCenter.origin.y];
    [m_HighlightSprite setFrameIndex:0];

    // Find the song index for the first wheel item
    if ( selectedIndex == -1 )
    {
        selectedIndex = 0;
    }
    else
    {
        for ( int wIdx = mt_SelectedWheelItemId; wIdx > 0; --wIdx )
        {
            if ( selectedIndex == 0 )
            {
                selectedIndex = [songList count] - 1;
            }
            else
            {
                --selectedIndex;
            }
        }
    }

    float curYOffset = mt_SelectedItemCenterY + (mt_SelectedWheelItemId * mt_DistanceBetweenItems);

    for ( int i = 0, j = selectedIndex; i < mt_NumWheelItems; ++i )
    {
        if ( j == [songList count] )
        {
            j = 0;
        }

        TMSong *song = [songList objectAtIndex:j++];
        TMWheelItemPtr ptr = TMWheelItemPtr([[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, curYOffset)]);
        [*ptr updateWithDifficulty:g_pGameState->m_nSelectedDifficulty];

        m_pWheelItems->push_back(ptr);
        curYOffset -= mt_DistanceBetweenItems;
    }

    m_nCurrentScoreDisplayed = 0;

    return self;
}

- (void)dealloc
{
    delete m_pWheelItems;
    [m_HighlightSprite release];
    [super dealloc];
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    CGRect bounds = [DisplayUtil getDeviceDisplayBounds];

    // Setup glScissor
    glScissor((GLint) mt_Scissor.origin.x,
            (GLint) mt_Scissor.origin.y,
            (GLsizei) mt_Scissor.size.width,
            (GLsizei) mt_Scissor.size.height);
    glEnable(GL_SCISSOR_TEST);

    int i;
    for ( i = 0; i < m_pWheelItems->size(); i++ )
    {
        [m_pWheelItems->at(i).get() render:fDelta];
    }

    // Highlight selection and draw top element
    glEnable(GL_BLEND);
    float beatFraction = currentBeat - floorf(currentBeat);
    float brightness = (beatFraction > 0.9 || beatFraction < 0.1) ? 1.0f : 0.5f;
    
    [m_HighlightSprite setR:brightness G:brightness B:brightness];
    [m_HighlightSprite render:fDelta];

    // Score frame
    [t_ScoreFrame drawAtPoint:mt_ScoreFrame];

    // Draw the score for the selected song
    [m_pScoreStr drawAtPoint:mt_ScoreDisplay];
    glDisable(GL_BLEND);

    glDisable(GL_SCISSOR_TEST);
    glScissor(0, 0, bounds.size.width, bounds.size.height);
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    [super update:fDelta];
    currentBeat += currentBps*fDelta;

    if ( m_state != IDLE )
    {
        float progress = ([TimingUtil getCurrentTime] - m_scrollAnimationStartTime) / m_scrollAnimationSpeed;
        if ( progress >= 1.0f )
        {
            progress = 1.0f;
        }

        // first calculate the offset at which the Y position should be atm.
        float offset;
        if ( m_state == ANIMATING_BACK )
        {
            offset = (1.0f - progress) * m_scrollAnimationStartOffset;
        }
        else
        {
            offset = progress * (mt_DistanceBetweenItems - m_scrollAnimationStartOffset) + m_scrollAnimationStartOffset;
        }

        float firstItemOffset = mt_SelectedItemCenterY + (mt_SelectedWheelItemId * mt_DistanceBetweenItems);

        for ( int i = 0; i < m_pWheelItems->size(); ++i )
        {
            SongPickerMenuItem *item = m_pWheelItems->at(i).get();
            float orig = firstItemOffset - (i * mt_DistanceBetweenItems);
            [item updateYPosition:orig + (m_state == ANIMATING_UP ? -offset : offset)];
        }

        if ( progress >= 1.0f )
        {
            if ( m_state == ANIMATING_UP )
            {
                TMWheelItemPtr frontItem = m_pWheelItems->front();
                TMWheelItemPtr backItem = m_pWheelItems->back();
                TMSong *song = [[SongsDirectoryCache sharedInstance] getSongPrevFrom:[frontItem.get() song]];

                // remove bottom item
                m_pWheelItems->pop_back();

                // reuse the wheel item
                [backItem.get() updateWithSong:song atPoint:
                        CGPointMake(mt_ItemSong.origin.x,
                                mt_SelectedItemCenterY + (mt_SelectedWheelItemId * mt_DistanceBetweenItems))];
                [backItem.get() updateWithDifficulty:g_pGameState->m_nSelectedDifficulty];

                // add one item to the top
                m_pWheelItems->push_front(backItem);

                self.songChanged = YES;
                m_shouldPlayMusicOnRequest = YES;
            }
            else if ( m_state == ANIMATING_DOWN )
            {
                TMWheelItemPtr frontItem = m_pWheelItems->front();
                TMWheelItemPtr backItem = m_pWheelItems->back();
                TMSong *song = [[SongsDirectoryCache sharedInstance] getSongNextTo:[backItem.get() song]];

                // remove top item
                m_pWheelItems->pop_front();

                // reuse the wheel item
                [frontItem.get() updateWithSong:song atPoint:
                        CGPointMake(mt_ItemSong.origin.x,
                                mt_SelectedItemCenterY - ((mt_NumWheelItems - mt_SelectedWheelItemId - 1) * mt_DistanceBetweenItems))];
                [frontItem.get() updateWithDifficulty:g_pGameState->m_nSelectedDifficulty];

                // add one item to the bottom
                m_pWheelItems->push_back(frontItem);

                self.songChanged = YES;
                m_shouldPlayMusicOnRequest = YES;
            }

            m_state = IDLE;
        }
    }

    if ( self.songChanged )
    {
        self.songChanged = NO;

        if ( m_bEnabled && m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler] )
        {
            [m_idChangedDelegate performSelector:m_oChangedActionHandler];
        }
    }

    if ( m_allowPreviewMusic && m_shouldPlayMusicOnRequest )
    {
        m_shouldPlayMusicOnRequest = NO;

        // send delegate a notification that it can play the preview music
        if ( m_idMusicPlaybackDelegate != nil && [m_idMusicPlaybackDelegate respondsToSelector:m_oMusicPlaybackHandler] )
        {
            [m_idMusicPlaybackDelegate performSelector:m_oMusicPlaybackHandler];
        }
    }
}

- (void)setCurrentBps:(float)bps
{
    currentBeat = 0.0f;
    currentBps = bps;
}

- (void)updateScore
{
    // Update the score of the selected
    TMSongSavedScore *score = m_pWheelItems->at(mt_SelectedWheelItemId).get().m_pSavedScore;
    if ( score )
    {
        m_nCurrentScoreDisplayed = [score.bestScore intValue];
    }
    else
    {
        m_nCurrentScoreDisplayed = 0;
    }

    // Update the fontstring
    [m_pScoreStr updateText:[NSString stringWithFormat:@"%8d", m_nCurrentScoreDisplayed]];
}

/* TMGameUIResponder methods */
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if ( !m_bEnabled )
    {
        return NO;
    }

    if ( touches.size() == 1 )
    {
        TMTouch touch = touches.at(0);
        m_lastTouchY = touch.y();
    }

    m_allowPreviewMusic = NO;
    return YES;
}

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if ( !m_bEnabled )
    {
        return NO;
    }

    if ( touches.size() == 1 )
    {
        TMTouch touch = touches.at(0);

        if ( m_state == IDLE )
        {
            float delta = m_lastTouchY - touch.y();

            for ( int i = 0; i < m_pWheelItems->size(); ++i )
            {
                SongPickerMenuItem *item = m_pWheelItems->at(i).get();
                [item updateYPositionWith:-delta];
            }

            // check if it's time to animate to the next item
            float dist = mt_SelectedItemCenterY - [m_pWheelItems->at(mt_SelectedWheelItemId).get() getPosition].y;

            float speed = 0.1f - delta / 1000.0f;
            if ( speed < 0.0f )
            {
                speed = 0.05f;
            }

            if ( fabsf(dist) >= mt_DistanceBetweenItems * 0.5f )
            {
                if ( dist < 0.0f )
                {
                    [self scrollWheelDown:speed];
                }
                else
                {
                    [self scrollWheelUp:speed];
                }
            }
        }

        // update the last touch anyway because when we jump back to IDLE
        // we want to have a smallest delta possible.
        m_lastTouchY = touch.y();
    }

    return YES;
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if ( !m_bEnabled )
    {
        return NO;
    }

    if ( touches.size() == 1 )
    {
        TMTouch touch = touches.at(0);
        CGPoint point = CGPointMake(touch.x(), touch.y());

        // Should start song?
        if ( touch.tapCount() > 1 && CGRectContainsPoint(mt_Highlight, point) )
        {
            TMLog(@"Double tapped the wheel select item!");
            if ( m_bEnabled && m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler] )
            {
                [self disable];    // Disable the song list as we already picked a song to start
                [m_idActionDelegate performSelector:m_oActionHandler];
            }

            return YES;
        }

        // check if we are mid way scrolling to some new item but less than half way
        // was scrolled so we should animate back to the currently active item.
        float dist = mt_SelectedItemCenterY - [m_pWheelItems->at(mt_SelectedWheelItemId).get() getPosition].y;

        if ( fabsf(dist) < mt_DistanceBetweenItems * 0.5f )
        {
            [self scrollWheelBack:0.1f];
        }

        m_allowPreviewMusic = YES;
    }

    return YES;
}

- (void)scrollWheelUp:(float)animSpeed
{
    m_scrollAnimationStartTime = [TimingUtil getCurrentTime];
    m_scrollAnimationSpeed = animSpeed;
    m_scrollAnimationStartOffset =
            fabsf(mt_SelectedItemCenterY - [m_pWheelItems->at(mt_SelectedWheelItemId).get() getPosition].y);

    m_state = ANIMATING_UP;
}

- (void)scrollWheelDown:(float)animSpeed
{
    m_scrollAnimationStartTime = [TimingUtil getCurrentTime];
    m_scrollAnimationSpeed = animSpeed;
    m_scrollAnimationStartOffset =
            fabsf(mt_SelectedItemCenterY - [m_pWheelItems->at(mt_SelectedWheelItemId).get() getPosition].y);

    m_state = ANIMATING_DOWN;
}

- (void)scrollWheelBack:(float)animSpeed
{
    m_scrollAnimationStartTime = [TimingUtil getCurrentTime];
    m_scrollAnimationSpeed = animSpeed;
    m_scrollAnimationStartOffset =
            -(mt_SelectedItemCenterY - [m_pWheelItems->at(mt_SelectedWheelItemId).get() getPosition].y);

    m_state = ANIMATING_BACK;
}

- (SongPickerMenuItem *)getSelected
{
    return m_pWheelItems->at(mt_SelectedWheelItemId).get();
}

- (void)updateAllWithDifficulty:(TMSongDifficulty)diff
{
    for ( int i = 0; i < m_pWheelItems->size(); i++ )
    {
        [m_pWheelItems->at(i).get() updateWithDifficulty:diff];
    }
}

- (void)setMusicPlaybackHandler:(SEL)pSelector receiver:(id)receiver
{
    m_idMusicPlaybackDelegate = receiver;
    m_oMusicPlaybackHandler = pSelector;
}
@end
