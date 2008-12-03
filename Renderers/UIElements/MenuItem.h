//
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"

@interface MenuItem : AbstractRenderer {
	int textureId;	// The id of the texture for the menu button
	CGRect shape;	// The points where the button is drawn
}

- (id) initWithTexture:(int) lTextureId andShape:(CGRect) lShape;

- (BOOL) containsPoint:(CGPoint)point;

@end
