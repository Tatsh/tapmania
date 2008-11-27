//
//  RenderEngine.h
//  TapMania
//
//  Created by Alex Kremer on 27.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMRunLoop.h"
#import "EAGLView.h"
#import "AbstractRenderer.h"

@interface RenderEngine : NSObject <TMRunLoopDelegate> {
	UIWindow		*window;
	EAGLView		*glView;
	UIView          *rootView;
	
	NSLock			*renderLock;
	
	TMRunLoop		*renderRunLoop;
	TMRunLoop		*logicRunLoop;
}

@property (retain, nonatomic) EAGLView* glView;
@property (retain, nonatomic) UIWindow* window;

- (void) registerRenderer:(AbstractRenderer*) renderer withPriority:(TMRunLoopPriority) priority;
- (void) clearRenderers;

+ (RenderEngine *)sharedInstance;

@end
