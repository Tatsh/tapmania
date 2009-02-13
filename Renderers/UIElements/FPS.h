//
//  FPS.h
//  TapMania
//
//  Created by Alex Kremer on 13.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "Texture2D.h"

@interface FPS : NSObject <TMRenderable, TMLogicUpdater> {
	long	m_lFpsCounter;
	double	m_dTimeCounter;
	
	Texture2D*	m_pCurrentTexture;
}

@end
