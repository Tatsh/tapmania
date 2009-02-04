//
//  BasicTransition.h
//  TapMania
//
//  Created by Alex Kremer on 02.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSingleTimeTask.h"

@class AbstractRenderer;

@interface BasicTransition : NSObject <TMSingleTimeTask> {
	AbstractRenderer *m_pFrom, 
					 *m_pTo;
}

- (id) initFromScreen:(AbstractRenderer*)fromScreen toScreen:(AbstractRenderer*)toScreen;

@end
