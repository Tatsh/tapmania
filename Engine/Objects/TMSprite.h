//
//  TMSprite.h
//  TapMania
//
//  Created by Alex Kremer.
//  Copyright 2012 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"

@interface TMSprite : NSObject
{
    Texture2D* texture_;

    float x_;
    float y_;
    float width_;
    float height_;
}

@property (retain, nonatomic) Texture2D* texture;

// Constructor
- (id) initWithTexture:(Texture2D *)texture andRect:(CGRect)rect;

// Drawing routines
- (void) draw;

@end
