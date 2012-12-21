//
//  $Id$
//  TapMine.h
//  TapMania
//
//  Created by Alex Kremer on 18.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMAnimatable.h"
#import "TMNote.h"
#import "TMSteps.h"

/*
 * This class represents a mine.
 */
@interface TapMine : TMAnimatable
{
}

- (void)drawTapMineInRect:(CGRect)rect;

@end

