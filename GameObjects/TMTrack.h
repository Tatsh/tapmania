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
#include "ObjCPtr.h"
using namespace std;

typedef ObjCPtr<TMNote> TMNotePtr;
typedef vector<TMNotePtr> TMNoteList;

#endif

@interface TMTrack : NSObject {

#ifdef __cplusplus
	TMNoteList*		m_aNotesArray;
#endif
	
	int m_nHoldsCnt;
	int m_nTapAndHoldNotesCnt;

}

- (void) setNote:(TMNote*) note onNoteRow:(long)noteRow;

- (TMNote*) getNoteFromRow:(long)noteRow;
- (TMNote*) getNote:(unsigned long)index;

- (BOOL) hasNoteAtRow:(long)noteRow;

- (unsigned long) getNotesCount;
- (int) getHoldsCount;
- (int) getTapAndHoldNotesCount;

@end
