//
//  $Id$
//  TMChangeSegment.h
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMChangeSegment : NSObject <NSCoding> {
	float	m_fNoteRow;		// The noteRow when this change should fire
	float	m_fChangeValue;	// The value to change to
}

@property (assign, readonly) float m_fNoteRow;
@property (assign) float m_fChangeValue;

- (id) initWithNoteRow:(long) noteRow andValue:(float) value;

@end
