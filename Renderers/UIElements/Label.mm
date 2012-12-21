//
//  $Id$
//  Label.m
//  TapMania
//
//  Created by Alex Kremer on 5/17/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Label.h"

#import "Texture2D.h"
#import "FontManager.h"
#import "Font.h"
#import "ThemeManager.h"
#import "Quad.h"

@interface Label (Private)
- (void)updateTitleTexture;
@end


@implementation Label

- (id)initWithMetrics:(NSString *)inMetricsKey
{
    CGPoint point = POINT_METRIC(inMetricsKey);
    self = [super initWithShape:CGRectMake(point.x, point.y, 0, 0)];
    if (!self)
        return nil;

    m_pTitle = nil;

    // Try to fetch extra width property
    m_FixedWidth = FLOAT_METRIC( ([inMetricsKey stringByAppendingString:@" FixedWidth"]) );    // This is optional. will be 0 if not specified

    // Text props
    [self initTextualProperties:inMetricsKey];

    // Add commands
    [super initCommands:inMetricsKey];

    // Generate texture
    [self updateTitleTexture];

    return self;
}

- (id)initWithTitle:(NSString *)title fontSize:(float)fontSize andShape:(CGRect)shape
{
    self = [super initWithShape:shape];
    if (!self)
        return nil;

    m_fFontSize = fontSize;

    m_sTitle = title;
    m_pTitle = nil;
    [self updateTitleTexture];

    return self;
}

- (id)initWithTitle:(NSString *)title andShape:(CGRect)shape
{
    self = [self initWithTitle:title fontSize:21.0f andShape:shape];
    return self;
}

- (void)initTextualProperties:(NSString *)inMetricsKey
{
    NSString *inFb = @"Common Label";

    // Handle Font, FontSize, Align defaults
    m_fFontSize = 21.0f;    // TODO: change and use
    m_Align = UITextAlignmentCenter;

    // Get font
    m_pFont = (Font *) [[FontManager sharedInstance] getFont:inMetricsKey];
    if (!m_pFont)
    {
        m_pFont = (Font *) [[FontManager sharedInstance] getFont:inFb];
    }
    if (!m_pFont)
    {
        m_pFont = (Font *) [[FontManager sharedInstance] defaultFont];
    }
}

- (void)updateTitleTexture
{
    if (m_pTitle)
        [m_pTitle release];
    m_pTitle = [m_pFont createQuadFromText:m_sTitle];
    m_rShape.size.width = m_pTitle.contentSize.width;
    m_rShape.size.height = m_pTitle.contentSize.height;

    // Calculate height for fixed width if specified
    if (m_FixedWidth > 0.0f)
    {
        if (m_FixedWidth < m_rShape.size.width)
        {
            m_rShape.size.width = m_FixedWidth;
        }
    }
}

- (void)dealloc
{
    [m_sTitle release];
    if (m_pTitle)
        [m_pTitle release];

    [super dealloc];
}

- (void)setName:(NSString *)inName
{
    if (m_sTitle)
        [m_sTitle release];
    m_sTitle = [inName retain];
    [self updateTitleTexture];
}

- (void)setFont:(NSString *)inName
{
    m_pFont = (Font *) [[FontManager sharedInstance] getFont:inName];
    if (!m_pFont)
    {
        m_pFont = (Font *) [[FontManager sharedInstance] defaultFont];
    }
}

- (void)setFontSize:(NSNumber *)inSize
{
    m_fFontSize = [inSize floatValue];
}

- (void)setAlignment:(NSString *)inAlign
{
    if (inAlign != nil)
    {
        if ([[inAlign lowercaseString] isEqualToString:@"center"])
        {
            m_Align = UITextAlignmentCenter;
        } else if ([[inAlign lowercaseString] isEqualToString:@"left"])
        {
            m_Align = UITextAlignmentLeft;
        } else if ([[inAlign lowercaseString] isEqualToString:@"right"])
        {
            m_Align = UITextAlignmentRight;
        }
    }
}

/* TMRenderable stuff */
- (void)render:(float)fDelta
{
    glEnable(GL_BLEND);

    // The position is determined by the alignment
    CGPoint point;

    switch (m_Align)
    {
        case UITextAlignmentLeft:
            point = CGPointMake(m_rShape.origin.x, m_rShape.origin.y - m_rShape.size.height / 2);
            break;
        case UITextAlignmentRight:
            point = CGPointMake(m_rShape.origin.x - m_rShape.size.width, m_rShape.origin.y - m_rShape.size.height / 2);
            break;
        case UITextAlignmentCenter:
        default:
            point = CGPointMake(m_rShape.origin.x - m_rShape.size.width / 2, m_rShape.origin.y - m_rShape.size.height / 2);
            break;
    }

    CGRect rect = CGRectMake(point.x, point.y, m_rShape.size.width, m_rShape.size.height);

    // TODO: support colorization
//	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
//	glColor4f(0.5f, 0.3f, 0.8f, 1.0f);
    [m_pTitle drawInRect:rect];

//	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

    glDisable(GL_BLEND);
}

@end
