//
//  $Id$
//  TMFramedTexture.h
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"

@interface TMFramedTexture : Texture2D
{
    int m_nTotalFrames;    // Total count of loaded frames. defaults to 1
    int m_nFramesToLoad[2];    // Rectangle to load [cols,rows]. defaults to 1,1
}

@property(assign, readonly, getter=totalFrames) int m_nTotalFrames;

// Constructor
- (id)initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows;

// Drawing routines
- (void)drawFrame:(int)frameId withExtraLeft:(float)pixelsLeft extraRight:(float)pixelsRight inRect:(CGRect)rect;

- (void)drawFrame:(int)frameId inRect:(CGRect)rect;

- (void)drawFrame:(int)frameId rotation:(float)rotation inRect:(CGRect)rect;

- (void)drawFrame:(int)frameId atPoint:(CGPoint)point;

- (void)drawFrame:(int)frameId atPoint:(CGPoint)point withScale:(float)scale;

- (void)drawFrame:(int)frameId withExtraLeft:(float)pixelsLeft extraRight:(float)pixelsRight atPoint:(CGPoint)point;


- (int)cols;

- (int)rows;

@end
