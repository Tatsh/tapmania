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
	
	NSLock			*renderLock;
	
	TMRunLoop		*renderRunLoop;
}

@property (retain, nonatomic) EAGLView* glView;
@property (retain, nonatomic) UIWindow* window;

@property (retain, nonatomic, readonly) NSLock *renderLock;

- (void) registerRenderer:(AbstractRenderer*) renderer withPriority:(TMRunLoopPriority) priority;
- (void) clearRenderers;

+ (RenderEngine *)sharedInstance;

@end
