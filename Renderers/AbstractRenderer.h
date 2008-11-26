//
//  AbstractRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "TMRenderable.h"

#define kRenderingFPS				60.0 // Hz

// The Scene Renderer protocol
// FIXME: To be removed
@protocol SceneRenderer

- (id) initWithView:(EAGLView*) lGlView;
- (void) renderScene;

@end

@interface AbstractRenderer : NSObject <SceneRenderer, TMRenderable> {
	EAGLView*				glView;
}

@property (retain, nonatomic) EAGLView* glView;

@end
