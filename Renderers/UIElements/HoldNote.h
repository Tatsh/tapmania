//
//  HoldNote.h
//  TapMania
//
//  Created by Alex Kremer on 10.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapNote.h"

/*
 * This class represents every tap hold body on screen.
 * The body of the hold is drawn using this class
 */
@interface HoldNote : TapNote {

}

// Drawing routines
- (void) drawBodyPieceWithSize:(CGFloat)lSize atPoint:(CGPoint)point;

@end
