//
//  $Id$
//  TMControl.m
//  TapMania
//
//  Created by Alex Kremer on 16.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "CommandParser.h"
#import "EAGLView.h"

@implementation TMControl

- (id)initWithMetrics:(NSString *)inMetricsKey
{
    self = [self initWithShape:RECT_METRIC(inMetricsKey)];
    if (!self)
        return nil;

    [self initCommands:inMetricsKey];

    return self;
}

- (id)initWithShape:(CGRect)inShape
{
    self = [super initWithShape:inShape];
    if (!self)
        return nil;

    m_pOnCommand = m_pOffCommand = m_pHitCommand = m_pSlideCommand = nil;
    m_idActionDelegate = nil;
    m_idChangedDelegate = nil;
    m_oActionHandler = nil;
    m_oChangedActionHandler = nil;
    m_sControlPath = nil;    // Made from code without metrics usage

    return self;
}

- (void)initCommands:(NSString *)inMetricsKey
{
    // Store the control path
    m_sControlPath = [inMetricsKey retain];

    // Try to get the commands. can be omitted
    NSString *onCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OnCommand"]);
    if ([onCommandList length] > 0)
    {
        m_pOnCommand = [[[CommandParser sharedInstance] createCommandListFromString:onCommandList forRequestingObject:self] retain];
    }

    NSString *offCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OffCommand"]);
    if ([offCommandList length] > 0)
    {
        m_pOffCommand = [[[CommandParser sharedInstance] createCommandListFromString:offCommandList forRequestingObject:self] retain];
    }

    NSString *hitCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" HitCommand"]);
    if ([hitCommandList length] > 0)
    {
        m_pHitCommand = [[[CommandParser sharedInstance] createCommandListFromString:hitCommandList forRequestingObject:self] retain];
    }

    NSString *slideCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" SlideCommand"]);
    if ([slideCommandList length] > 0)
    {
        m_pSlideCommand = [[[CommandParser sharedInstance] createCommandListFromString:slideCommandList forRequestingObject:self] retain];
    }
}

- (void)initGraphicsAndSounds:(NSString *)inMetricsKey
{
    // Override this
}

- (NSString *)getControlPath
{
    return m_sControlPath;
}

- (void)dealloc
{
    TMLog(@"Deallocating TMControl instance %X", self);

    if (m_sControlPath)
        [m_sControlPath release];

    if (m_pOnCommand)
        [m_pOnCommand release];
    if (m_pOffCommand)
        [m_pOffCommand release];
    if (m_pHitCommand)
        [m_pHitCommand release];
    if (m_pSlideCommand)
        [m_pSlideCommand release];

    [super dealloc];
}

- (void)setActionHandler:(SEL)selector receiver:(id)receiver
{
    m_idActionDelegate = receiver;
    m_oActionHandler = selector;
}

- (void)setChangedActionHandler:(SEL)selector receiver:(id)receiver
{
    m_idChangedDelegate = receiver;
    m_oChangedActionHandler = selector;
}

- (void)setOnCommand:(TMCommand *)inCmd
{
    m_pOnCommand = inCmd;
}

- (void)setOffCommand:(TMCommand *)inCmd
{
    m_pOffCommand = inCmd;
}

- (void)setHitCommand:(TMCommand *)inCmd
{
    m_pHitCommand = inCmd;
}

- (void)setSlideCommand:(TMCommand *)inCmd
{
    m_pSlideCommand = inCmd;
}

/* TMGameUIResponder stuff */
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (!m_bEnabled)
        return NO;

    // Controls are singletouch. always
    if (touches.size() == 1)
    {
        if ([super tmTouchesBegan:touches withEvent:event])
        {

            if (m_pOnCommand != nil)
            {
                TMLog(@"Running control's OnCommand...");
                [[CommandParser sharedInstance] runCommandList:m_pOnCommand forRequestingObject:self];
            }

            if (m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler])
            {
                TMLog(@"Control touched");
            }

            return YES;
        }
    }

    return NO;
}

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    BOOL res = NO;
    if (!m_bEnabled)
        return res;

    // Controls are singletouch. always
    if (touches.size() == 1)
    {

        CGPoint oldPos = CGPointMake(touches.at(0).px(), touches.at(0).py());
        BOOL inView = [super tmTouchesMoved:touches withEvent:event];

        // Check whether we need a On command here
        if (!CGRectContainsPoint(m_rShape, oldPos) && inView)
        {
            TMLog(@"Slided into the control! run OnCommand...");
            if (m_pOnCommand != nil)
            {
                [[CommandParser sharedInstance] runCommandList:m_pOnCommand forRequestingObject:self];
                res = YES;
            }
        }

        // Or maybe a Off command?
        if (CGRectContainsPoint(m_rShape, oldPos) && !inView)
        {
            TMLog(@"Slided out of the control! run OffCommand...");
            if (m_pOffCommand != nil)
            {
                [[TapMania sharedInstance] deregisterCommandsForObject:self];
                [[CommandParser sharedInstance] runCommandList:m_pOffCommand forRequestingObject:self];
                res = YES;
            }
        }

        // We are moving the finger over the control?
        if (m_pSlideCommand != nil && inView)
        {
            if (inView)
            {
                TMLog(@"Running control's SlideCommand...");
                [[CommandParser sharedInstance] runCommandList:m_pSlideCommand forRequestingObject:self];
                res = YES;
            }
        }

        if (m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler])
        {
            if ([super tmTouchesMoved:touches withEvent:event])
            {
                TMLog(@"Control touches moved");
                [m_idChangedDelegate performSelector:m_oChangedActionHandler];

                res = YES;
            }
        }
    }

    return res;
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (!m_bEnabled)
        return NO;

    // Controls are singletouch. always
    if (touches.size() == 1)
    {

        // Focus lost on release inside the area?
        if ([super tmTouchesEnded:touches withEvent:event])
        {

            // Discard all previous running commands if we are going to do Off/Hit commands here
            if (m_pOffCommand != nil || m_pHitCommand != nil)
            {
                [[TapMania sharedInstance] deregisterCommandsForObject:self];
            }

            // Off command because the focus is lost now
            if (m_pOffCommand != nil)
            {
                TMLog(@"Running control's OffCommand...");
                [[CommandParser sharedInstance] runCommandList:m_pOffCommand forRequestingObject:self];
            }

            // Run the Hit command
            if (m_pHitCommand != nil)
            {
                TMLog(@"Running control's HitCommand...");
                [[CommandParser sharedInstance] runCommandList:m_pHitCommand forRequestingObject:self];
            }

            if (m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler])
            {
                TMLog(@"Control, finger raised!");
                [m_idActionDelegate performSelector:m_oActionHandler];
            }

            return YES;
        }
    }

    return NO;
}

/* TMEffectSupport stuff */
- (CGPoint)getPosition
{
    return m_rShape.origin;
}

- (void)updatePosition:(CGPoint)point
{
    m_rShape.origin.x = point.x;
    m_rShape.origin.y = point.y;
}

- (CGRect)getShape
{
    return m_rShape;
}

- (CGRect)getOriginalShape
{
    return m_rOriginalShape;
}

- (void)updateShape:(CGRect)shape
{
    m_rShape.origin = shape.origin;
    m_rShape.size = shape.size;
}

@end
