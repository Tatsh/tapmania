//
//  TMTrack.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMNote;

#define kDefaultTrackCapacity 1024

@interface TMTrack : NSObject {
//	NSMutableArray* m_aNotesArray;
	TMNote**		m_aNotesArray;

	int				m_nTotalNotes;
	int				m_nCurrentCapacity;
}

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow;

- (TMNote*) getNoteFromRow:(int)noteRow;
- (TMNote*) getNote:(int)index;

- (BOOL) hasNoteAtRow:(int)noteRow;

- (int) getNotesCount;

@end
