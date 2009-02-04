//
//  CreditsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

@class TMRunLoop;

@interface CreditsRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	NSMutableArray* m_aTexturesArray;
	
	BOOL			m_bShouldReturn;
	float			m_fCurrentPos; // Current Y coordinate of the scrolling text
}

@end
