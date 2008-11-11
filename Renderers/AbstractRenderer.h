//
//  AbstractRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

#define kRenderingFPS				60.0 // Hz

// The Scene Renderer protocol
@protocol SceneRenderer

- (id) initWithView:(EAGLView*) lGlView;
- (void) renderScene;

@end

@interface AbstractRenderer : NSObject <SceneRenderer> {
	EAGLView*				glView;
}

@property (retain, nonatomic) EAGLView* glView;

@end
