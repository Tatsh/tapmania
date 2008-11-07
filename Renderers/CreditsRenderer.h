//
//  CreditsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractMenuRenderer.h"

@interface CreditsRenderer : AbstractMenuRenderer {
	NSMutableArray* texturesArray;
	
	float currentPos; // Current Y coordinate of the scrolling text
}

@end
