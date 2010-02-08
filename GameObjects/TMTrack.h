//
//  $Id$
//  TMTrack.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMNote;

#ifdef __cplusplus

#include <vector>
using namespace std;

typedef vector<TMNote*> TMNoteList;

#endif

@interface TMTrack : NSObject {

#ifdef __cplusplus
	TMNoteList*		m_aNotesArray;
#endif
	
	int m_nHoldsCnt;
	int m_nTapAndHoldNotesCnt;

}

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow;

- (TMNote*) getNoteFromRow:(int)noteRow;
- (TMNote*) getNote:(int)index;

- (BOOL) hasNoteAtRow:(int)noteRow;

- (int) getNotesCount;
- (int) getHoldsCount;
- (int) getTapAndHoldNotesCount;

@end
