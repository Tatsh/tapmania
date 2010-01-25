//
//  $Id$
//  ComboMeter.h
//  TapMania
//
//  Created by Alex Kremer on 25.01.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"

@class Font, FontString, Texture2D;

@interface ComboMeter : NSObject <TMLogicUpdater, TMRenderable, TMMessageSupport> {
	int				m_nCombo;
	FontString*		m_pComboStr;
	Texture2D*	m_pComboTexture;	// Static
	
	/* Metrics and such */
	CGPoint mt_ComboMeter, mt_ComboStr;	
}

-(id) initWithMetrics:(NSString*)metricsKey;

@end
