//
//  TMTrack.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMNote;

@interface TMTrack : NSObject {
	NSMutableArray* m_aNotesArray;
}

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow;
- (TMNote*) getNote:(int) index;
- (TMNote*) getNoteFromRow:(int)noteRow;
- (BOOL) hasNoteAtRow:(int)noteRow;

- (int) getNotesCount;

@end
