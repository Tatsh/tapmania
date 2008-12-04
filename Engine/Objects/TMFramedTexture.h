//
//  TMFramedTexture.h
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"

@interface TMFramedTexture : Texture2D {
	int totalFrames;	// Total count of loaded frames. defaults to 1
	int framesToLoad[2];	// Rectangle to load [cols,rows]. defaults to 1,1
}

// Constructor
- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows;

// Drawing routines
- (void) drawFrame:(int)frameId inRect:(CGRect)rect;

@end