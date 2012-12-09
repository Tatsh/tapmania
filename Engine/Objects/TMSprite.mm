//
//  TMSprite.m
//  TapMania
//
//  Created by Alex Kremer
//  Copyright 2012 Godexsoft. All rights reserved.
//

#import "TMSprite.h"
#include "GLUtil.h"

@implementation TMSprite

@synthesize texture = texture_;

- (id) initWithTexture:(Texture2D *)texture andRect:(CGRect)rect
{
    self = [super init];
	if(!self) 
		return nil;
	
    x_ = rect.origin.x;
    y_ = rect.origin.y;
    width_ = rect.size.width;
    height_ = rect.size.height;
    self.texture = texture;
    
	return self;
}

- (void) draw
{
    glPushMatrix();
    assert(self.texture);
        
    float uv_width =  width_ / self.texture.pixelsWide;
    float uv_height = height_ / self.texture.pixelsHigh;
    
    float x_off = x_ / self.texture.pixelsWide;
    float y_off = y_ / self.texture.pixelsHigh;
    
    float width_off = x_off + uv_width;
    float height_off = y_off + uv_height;
    
    float coordinates[] =
    {
        x_off,        height_off,
        width_off,    height_off,
        x_off,        y_off,
        width_off,    y_off
    };
    
    float width = width_;
    float height = height_;
    
    float vertices[] =
    {
        -width / 2,     -height / 2,    0.0,
        width / 2,      -height / 2,    0.0,
        -width / 2,     height / 2,     0.0,
        width / 2,      height / 2,     0.0
    };
    
    glEnable(GL_BLEND);
    TMBindTexture(self.texture.name);
    
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
    
    glPopMatrix();
}

@end
