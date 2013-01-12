//
//  $Id$
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MainMenuRenderer.h"
#import "MenuItem.h"
#import "Label.h"
#import "ImageButton.h"

#import "TMRunLoop.h"
#import "TMRenderable.h"

#import "EAGLView.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "SongsDirectoryCache.h"

#import "ZoomEffect.h"

#import "FontManager.h"
#import "Font.h"
#import "Quad.h"

#import "TMSoundEngine.h"
#import "TMSound.h"

#import "GameState.h"
#import "VersionInfo.h"
#import "DisplayUtil.h"

extern TMGameState *g_pGameState;

@interface MainMenuRenderer () <FacebookLikeViewDelegate, FBSessionDelegate>
@end


@implementation MainMenuRenderer
{
    CGRect mt_LikeButton;
}

@synthesize facebookLikeView = _facebookLikeView;

- (id) initWithMetrics:(NSString *)inMetricsKey
{
    self = [super initWithMetrics:inMetricsKey];
    if(self)
    {
        _facebook = [[Facebook alloc] initWithAppId:@"101720580006180" andDelegate:self];
    }
    return self;
}

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    mt_LikeButton = RECT_METRIC(@"MainMenu LikeBtn");

    // the Y is screwed up a bit because of the automatic coordinate translation. fix it in code.
    mt_LikeButton.origin.y = ([DisplayUtil getDeviceDisplaySize].height - mt_LikeButton.origin.y)/([DisplayUtil isRetina]?2:1);
    mt_LikeButton.origin.x = mt_LikeButton.origin.x/([DisplayUtil isRetina]?2:1);

    self.facebookLikeView = [[[FacebookLikeView alloc] initWithFrame:mt_LikeButton] autorelease];
    self.facebookLikeView.delegate = self;

    self.facebookLikeView.href = [NSURL URLWithString:@"https://itunes.apple.com/app/tapmania.org/id378830500"];
    self.facebookLikeView.layout = @"button_count";
    self.facebookLikeView.ref = @"tapmania_game";
    self.facebookLikeView.showFaces = NO;

    self.facebookLikeView.alpha = 0;

    // add it to the window
    [[TapMania sharedInstance].m_pWindow addSubview:self.facebookLikeView];

    [self.facebookLikeView load];

    // sounds
    sr_BG = SOUND(@"MainMenu Music");

    // Create version and copyright
    Label *version = [[Label alloc] initWithMetrics:@"MainMenu Version"];
    [version setName:TAPMANIA_VERSION_STRING];
    [self pushBackChild:version];

    // Play music
    if (!sr_BG.playing)
    {
        [[TMSoundEngine sharedInstance] addToQueue:sr_BG];
    }

    // Get ads back to place
    [[TapMania sharedInstance] toggleAds:YES];

    // Enable/disable play button
    if ([SongsDirectoryCache sharedInstance].catalogueIsEmpty)
    {
        MenuItem *playButton = (MenuItem *) [self findControl:@"MainMenu PlayButton"];
        if (playButton != nil)
        {
            [playButton disable];
            [playButton setName:@"No Songs"];
        }
    }

    g_pGameState->m_bPlayingGame = NO;
}

- (void)beforeTransition
{
    [[InputEngine sharedInstance] disableDispatcher];

    [self.facebookLikeView removeFromSuperview];
    self.facebookLikeView = nil;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    // Draw children and bg
    [super render:fDelta];
}

- (void)dealloc
{
    [_facebook release];
    [_facebookLikeView release];
    [super dealloc];
}

#pragma mark FBSessionDelegate methods

- (void)fbDidLogin
{
	self.facebookLikeView.alpha = 1;
    [self.facebookLikeView load];
}

- (void)fbDidLogout
{
	self.facebookLikeView.alpha = 1;
    [self.facebookLikeView load];
}

#pragma mark FacebookLikeViewDelegate methods

- (void)facebookLikeViewRequiresLogin:(FacebookLikeView *)aFacebookLikeView
{
    [_facebook authorize:[NSArray array]];
}

- (void)facebookLikeViewDidRender:(FacebookLikeView *)aFacebookLikeView
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelay:0.5];
    self.facebookLikeView.alpha = 1;
    [UIView commitAnimations];
}

- (void)facebookLikeViewDidLike:(FacebookLikeView *)aFacebookLikeView
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Liked"
                                                     message:@"You liked TapMania. Thanks!"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)facebookLikeViewDidUnlike:(FacebookLikeView *)aFacebookLikeView
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Unliked"
                                                     message:@"You unliked TapMania... Really??"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

@end
