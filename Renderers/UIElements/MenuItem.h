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
	int m_nTextureId;	// The id of the texture for the menu button
	CGRect m_rShape;	// The points where the button is drawn
}

- (id) initWithTexture:(int) textureId andShape:(CGRect) shape;
- (BOOL) containsPoint:(CGPoint)point;

@end
