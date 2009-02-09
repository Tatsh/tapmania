//
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"

@class Texture2D;

@interface MenuItem : AbstractRenderer {
	Texture2D*	m_pTexture;
	CGRect		m_rShape;	// The points where the button is drawn
}

- (id) initWithTexture:(Texture2D*) texture andShape:(CGRect) shape;
- (BOOL) containsPoint:(CGPoint)point;

@end
