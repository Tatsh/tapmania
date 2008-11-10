//
//  TMTrack.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMNote.h"

@interface TMTrack : NSObject {
	NSMutableArray* notesArray;
}

- (void) addNote:(TMNote*) note;
- (TMNote*) getNote:(int) index;
- (int) getNotesCount;

@end
