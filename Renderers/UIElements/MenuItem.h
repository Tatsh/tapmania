//
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuItem : UIButton {
}

- (id) initWithTitle:(NSString*) title;
- (void) setPosition:(int) yPos;

@end
