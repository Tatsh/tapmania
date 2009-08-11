//
//  DialogRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 8/11/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractRenderer.h"
#import "TMLogicUpdater.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

@interface DialogRenderer : AbstractRenderer <TMLogicUpdater, TMGameUIResponder> {
	BOOL	m_bShouldReturn;
}

@end
