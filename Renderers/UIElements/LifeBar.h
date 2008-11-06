//
//  LifeBar.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LifeBar : NSObject {
	float _currentValue;  // 0.0 -> 100.0 :: defaults to 50.0 on song start
}

- (float) getCurrentValue;
- (void) updateBy:(float)value;

@end
