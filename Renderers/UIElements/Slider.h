//
//  Slider.h
//  TapMania
//
//  Created by Alex Kremer on 23.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "MenuItem.h"

@interface Slider : MenuItem {
	float	m_fCurrentValue;	// 0.0 -- 1.0
}

- (id) initWithShape:(CGRect)shape andValue:(float)xValue;
- (float) currentValue;

@end
