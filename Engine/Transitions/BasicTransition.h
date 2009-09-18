//
//  BasicTransition.h
//  TapMania
//
//  Created by Alex Kremer on 02.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMTransition.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

#define kDefaultTransitionInTime	0.3
#define kDefaultTransitionOutTime	0.3

typedef enum {
	kTransitionStateInitializing = 0,
	kTransitionStateIn,
	kTransitionStateOut,
	kTransitionStateFinished,
	kNumTransitionStates
} TMTransitionState;

@class TMScreen;

@interface BasicTransition : NSObject <TMTransition, TMRenderable, TMLogicUpdater> {
	TMScreen *m_pFrom, 
					 *m_pTo;
	
	double			  m_dTimeStart;
	double			  m_dElapsedTime;
	TMTransitionState m_nState;
	
	double			  m_dTimeIn, m_dTimeOut;
}

- (id) initFromScreen:(TMScreen*)fromScreen toScreen:(TMScreen*)toScreen;
- (id) initFromScreen:(TMScreen*)fromScreen toScreen:(TMScreen*)toScreen timeIn:(double)timeIn timeOut:(double)timeOut;

- (BOOL) updateTransitionIn;
- (BOOL) updateTransitionOut;

@end
