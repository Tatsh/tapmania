//
//  $Id$
//  SongPickerMenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuItem.h"
#import "Texture2D.h"
#import "TMFramedTexture.h"
#import "Quad.h"
#import "FontString.h"
#import "Font.h"
#import "FontManager.h"

#import "TMSong.h"
#import "ThemeManager.h"
#import "TapMania.h"

@interface SongPickerMenuItem (Private)
- (void)generateTextures;
@end


@implementation SongPickerMenuItem
{
    float mt_nameYOffset;
}

@synthesize song = m_pSong, m_pSavedScore;

- (id)initWithSong:(TMSong *)song atPoint:(CGPoint)point
{
    self = [super initWithShape:CGRectMake(point.x, point.y, 0, 0)];
    if (!self)
        return nil;

    m_pSong = song;
    m_pSavedScore = nil;

    // Get metrics
    mt_nameLeftOffset = FLOAT_METRIC(@"SongPickerMenu Wheel NameLeftOffset");
    mt_nameYOffset = FLOAT_METRIC(@"SongPickerMenu Wheel NameYOffset");
    mt_nameMaxWidth = FLOAT_METRIC(@"SongPickerMenu Wheel NameMaxWidth");
    mt_artistYOffset = FLOAT_METRIC(@"SongPickerMenu Wheel ArtistYOffset");
    mt_gradeXOffset = FLOAT_METRIC(@"SongPickerMenu Wheel GradeXOffset");

    // Cache texture
    t_Grades = (TMFramedTexture *) TEXTURE(@"SongResults Grades");
    t_WheelItem = TEXTURE(@"SongPickerMenu Wheel ItemSong");
    [self generateTextures];

    return self;
}

- (void)dealloc
{
    [m_pTitleStr release];
    [m_pArtistStr release];

    // Don't release the song
    TMLog(@"DEALLOC SONG PICKER MENU ITEM");

    [super dealloc];
}

- (void)generateTextures
{
    // The title must be taken from the song file
    NSString *titleStr = [NSString stringWithFormat:@"%@", m_pSong.m_sTitle];
    NSString *artistStr = [NSString stringWithFormat:@"/%@", m_pSong.m_sArtist];

    m_pTitleStr = [[FontString alloc] initWithFont:@"SongPickerMenu WheelItem" andText:titleStr];
    m_pArtistStr = [[FontString alloc] initWithFont:@"SongPickerMenu WheelItemArtist" andText:artistStr];
}

/* TMRenderable stuff */
- (void)render:(float)fDelta
{
    glEnable(GL_BLEND);
    [t_WheelItem drawAtPoint:m_rShape.origin];

    // TODO: wtf /2-8????
    CGPoint leftCorner = CGPointMake(mt_nameLeftOffset, m_rShape.origin.y + mt_nameYOffset);
    CGRect rectTitle, rectArtist;

    if (mt_nameMaxWidth < m_pTitleStr.contentSize.width)
    {
        rectTitle = CGRectMake(leftCorner.x, leftCorner.y, mt_nameMaxWidth, m_pTitleStr.contentSize.height);

    } else
    {

        rectTitle = CGRectMake(leftCorner.x, leftCorner.y, m_pTitleStr.contentSize.width, m_pTitleStr.contentSize.height);
    }

    if (mt_nameMaxWidth < m_pArtistStr.contentSize.width)
    {
        rectArtist = CGRectMake(leftCorner.x, leftCorner.y + mt_artistYOffset, mt_nameMaxWidth, m_pArtistStr.contentSize.height);

    } else
    {

        rectArtist = CGRectMake(leftCorner.x, leftCorner.y + mt_artistYOffset, m_pArtistStr.contentSize.width, m_pArtistStr.contentSize.height);
    }


    [m_pTitleStr drawInRect:rectTitle];
    [m_pArtistStr drawInRect:rectArtist];

    if (m_pSavedScore != nil)
    {
        // We need to display the grade
        int gr = [m_pSavedScore.bestGrade intValue];
        [t_Grades drawFrame:gr atPoint:CGPointMake(mt_gradeXOffset, m_rShape.origin.y) withScale:0.5f];
    }

    glDisable(GL_BLEND);
}

- (void)updateWithDifficulty:(TMSongDifficulty)diff
{
    NSString *sql = [NSString stringWithFormat:@"WHERE hash = '%@' AND difficulty = '%@'", m_pSong.m_sHash, [NSNumber numberWithInt:diff]];
    TMLog(@"UPDATING with difficulty: %d and hash = %@", diff, m_pSong.m_sHash);

    if (m_pSavedScore)
        [m_pSavedScore release];
    m_pSavedScore = [[TMSongSavedScore findFirstByCriteria:sql] retain];

    if (m_pSavedScore)
    {
        TMLog(@"FOUND A SCORE!");
    }
}

- (void)updateYPosition:(float)y
{
    m_rShape.origin.y = y;
}

- (void)updateYPositionWith:(float)pixels
{
    m_rShape.origin.y += pixels;
}

- (void)updateWithSong:(TMSong *)song atPoint:(CGPoint)point
{
    m_rShape.origin = point; // We don't really use the size here
    m_pSong = song;
    m_pSavedScore = nil;

    [m_pTitleStr updateText:m_pSong.m_sTitle];
    [m_pArtistStr updateText:[NSString stringWithFormat:@"/%@", m_pSong.m_sArtist]];
}

@end
