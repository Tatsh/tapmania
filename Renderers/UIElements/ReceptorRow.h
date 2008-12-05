//
//  ReceptorRow.h
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMAnimatable.h"

/*
 * This class is able to render all 4 receptor arrows at their places with animation
 * Uses the Receptor class which holds the receptor arrow texture
*/
@interface ReceptorRow : TMAnimatable {
	CGPoint position;	// Where the left-bottom of the receptor row is relative to the screen
	float receptorXPositions[4];	// Final positions on the X axis of the receptor arrows
	float receptorRotations[4];
}

- (id) initOnPosition:(CGPoint)lPosition;

@end
