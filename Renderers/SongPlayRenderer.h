//
//  SongPlayRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"

@interface SongPlayRenderer : AbstractRenderer {
	unsigned				_combo;  // Current combo
	unsigned				_score;  // Current score
	
	// JUST FOR TEST!!!
	float arrowPos;
}

@end
