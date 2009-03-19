//
//  SMParser.m
//  TapMania
//
//  Created by Alex Kremer on 18.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SMParser.h"

#import "TMSong.h"
#import "TMNote.h"
#import "TMSteps.h"
#import "TMChangeSegment.h"

@interface SMParser (Pravite)
+ (TMSteps*) parseStepDataWithFD:(FILE*) fd forSong:(TMSong*) song;
+ (char*) parseSectionWithFD:(FILE*) fd;
+ (char*) parseSectionPartWithFD:(FILE*) fd trimWhitespaces:(BOOL)trim;
+ (NSMutableArray*) getChangesArray:(char*) data;
+ (TMSongDifficulty) getDifficultyWithName:(char*) difficulty;
@end

/* 
	The implementation 
 */
@implementation SMParser

// Parse basic information from the .sm file
+ (TMSong*) parseFromFile:(NSString*) filename {
	FILE* fd;
	int c; // Incoming char
	char varName[32]; // The name of the variable which comes directly after the '#' till the ':'.
	int i;
	
	TMSong* song = [[TMSong alloc] init];
	
	if( ! (fd = fopen([filename UTF8String], "r"))) {
		TMLog(@"Err: can't open file '%@' for reading.", filename);
		return nil;	
	}
	
	// Read the whole file
	while(!feof(fd)) {
		c = getc(fd);
		
		// Start new section
		if(c == '#') {
			TMLog(@"Opening new section.");
			
			// Read the var name
			c = getc(fd);
			i = 0;
			
			while(!feof(fd) && c != ':') {
				if(i >= 31){ 				
					TMLog(@"Fatal: sm file broken.");
					return nil; 
				}
				
				varName[i++] = c;	
				c = getc(fd);
			}
			
			if(feof(fd)){ 
				TMLog(@"Fatal: sm file broken.");
				return nil; 
			}
			
			varName[i] = 0;
			TMLog(@"Found var: '%s'", varName);
			
			// Now determine whether we are interested in this var or not
			if( !strcasecmp(varName, "TITLE") ) {
				TMLog(@"Title...");
				char* data = [SMParser parseSectionWithFD:fd];
				TMLog(@"is '%s'", data);
				song.m_sTitle = [[NSString stringWithCString:data] retain];
				
				free(data);
			} 
			else if( !strcasecmp(varName, "ARTIST") ) {
				TMLog(@"Artist...");
				char* data = [SMParser parseSectionWithFD:fd];
				TMLog(@"is '%s'", data);
				song.m_sArtist = [[NSString stringWithCString:data] retain];
				
				free(data);
			}
			else if( !strcasecmp(varName, "OFFSET") ) {
				TMLog(@"OFFSET...");
				char* data = [SMParser parseSectionWithFD:fd];
				TMLog(@"is '%s'", data);
				
				// The gap in SM is the opposite of the DWI one.
				// Thus 2050 becomes -2.050
				song.m_dGap = (double) -atof(data); 
				
				free(data);
			}
			else if( !strcasecmp(varName, "BPMS") ) {
				TMLog(@"BPMS...");
				char* data = [SMParser parseSectionWithFD:fd];
				TMLog(@"is '%s'", data);
				song.m_aBpmChangeArray = [SMParser getChangesArray:data];
				
				song.m_fBpm = ((TMChangeSegment*)[song.m_aBpmChangeArray objectAtIndex:0]).m_fChangeValue;
				[song.m_aBpmChangeArray removeObjectAtIndex:0];	// First object represents the initial bpm..
				
				free(data);
			}
			else if( !strcasecmp(varName, "STOPS") ){
				TMLog(@"STOPS...");
				char* data = [SMParser parseSectionWithFD:fd];
				TMLog(@"is '%s'", data);
				song.m_aFreezeArray = [SMParser getChangesArray:data];

				free(data);
			}
			else if( !strcasecmp(varName, "NOTES") ){ 
				// This is interesting! Some stepchart here..
				// For now we just want to get information about the difficulty/level of this one
				char* notesType = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];

				// We are only interested in dance-single notes anyway
				if(!strcasecmp(notesType, "dance-single")) {				
					char* desc		= [SMParser parseSectionPartWithFD:fd trimWhitespaces:NO];
					char* diffStr   = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];
					char* levelStr  = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];
					
					TMLog(@"SM format: got dance-single with %s(%s) difficulty. description: %s", diffStr, levelStr, desc);
					TMSongDifficulty difficulty = [SMParser getDifficultyWithName:diffStr];
					[song enableDifficulty:difficulty withLevel:atoi(levelStr)];
					
					free(desc);
					free(diffStr);
					free(levelStr);
				}
				
				free(notesType);
			}
		}
		// End the section
		else if(c == ';') {
			TMLog(@"Closing section.");
		}
	}
	
	// Close the file handle
	TMLog(@"Done parsing the SM file. close handle");
	if(fd) fclose(fd);
	
	return song;	
}

+ (TMSteps*) parseStepsFromFile:(NSString*) filename forDifficulty:(TMSongDifficulty)difficulty forSong:(TMSong*)song {
	FILE* fd;
	int c; // Incoming char
	char varName[16]; // The name of the variable which comes directly after the '#' till the ':'.
	int i;
	
	if( ! (fd = fopen([filename UTF8String], "r"))) {
		TMLog(@"Err: can't open file '%s' for reading.", [filename UTF8String]);
		return nil;	
	}
	
	// Read the whole file
	while(!feof(fd)) {
		c = getc(fd);
		
		// Start new section
		if(c == '#') {
			TMLog(@"Opening new section.");
			
			// Read the var name
			c = getc(fd);
			i = 0;
			
			while(!feof(fd) && c != ':') {
				varName[i++] = c;	
				c = getc(fd);
			}
			
			if(feof(fd)){ 
				TMLog(@"Fatal: SM file broken.");
				return nil; 
			}
			
			varName[i] = 0;
			
			if( !strcasecmp(varName, "NOTES") ){ 
				TMLog(@"Got NOTES input...");
				
				// Check for dance-single
				char* notesType = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];
				
				// We are only interested in dance-single notes anyway
				if(!strcasecmp(notesType, "dance-single")) {				
					char* desc		= [SMParser parseSectionPartWithFD:fd trimWhitespaces:NO];
					char* diffStr   = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];
					char* levelStr  = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];
					char* radar     = [SMParser parseSectionPartWithFD:fd trimWhitespaces:YES];
					
					TMLog(@"Diff=%s level=%s", diffStr, levelStr);					
					TMSongDifficulty thisDiff = [SMParser getDifficultyWithName:diffStr];
					
					// If this is the difficulty we are looking for - parse the data
					if(thisDiff == difficulty) {
						TMLog(@"FOUND our difficulty!!!");
						
						TMSteps* steps = [SMParser parseStepDataWithFD:fd forSong:song];
						fclose(fd);
						return steps;
					}
					
					free(desc);
					free(diffStr);
					free(levelStr);
					free(radar);
				}
				
				free(notesType);				
			}
		}
		// End the section
		else if(c == ';') {
			TMLog(@"Closing section.");
		}
	}
	
	// Close the file handle
	TMLog(@"Done parsing the dwi file. close handle..");
	fclose(fd);
	
	return nil;
}

// Private methods
// Parse the whole step data line using the file descriptor
+ (TMSteps*) parseStepDataWithFD:(FILE*) fd forSong:(TMSong*) song{
	TMSteps* steps = [[TMSteps alloc] init];
	
	int initialCapacity = 2048;
	int memCounter = 0;
	int totalElements = 0;
	char *stepData = (char*) malloc(initialCapacity * sizeof(char));
	
	char c;
	
	// We will need to read all the pending data into a single array of characters
	while( !feof(fd) && c != ';' ) {
		if(memCounter >= 2047) {
			initialCapacity += 2048;
			
			stepData = (char*) realloc(stepData, initialCapacity * sizeof(char));
			memCounter = 0;
		}
		
		c = getc(fd);
		stepData[totalElements ++] = c; 
		
		memCounter ++;
	}
	
	// Now we can go ahead and start parsing the contents	
	int curPos = 0;	// Current position in the array
	int rowsInMeasure = 0;		// A counter for rows in the current measure
	int measureId = 1;			// Start at 1
	
	char measureData[4096];		// May be way too much but it's just to prevent problems which i don't like to search for later on
	int measureDataIndex = 0;
	
	int currentNoteRow = 0;	// Start with 0..
	
	// Go through all the stepchart
	for(; curPos < totalElements; ++curPos) {
		char c = stepData[curPos];
		
		// Get measure. This means we must find a block till ','
		// And also.. if we encounter a linebreak we must increment the row counter
		// '//' indicates a comment line. the comment ends at a line break
		
		if(c == ' ' || c == '\t' || c == '\r' || c == '\n') {
			continue; // Skip this char
			
		} else 
		if(c == '/' && stepData[curPos+1] == '/') {
			
			// Got a comment... skip all till \n
			while(stepData[++curPos] != '\n');
			
			// Now we are exactly after the \n (line after the comment line)			
			continue;
		} else 
		if(c == ',') {
			
			// End of measure.
			measureData[measureDataIndex] = 0;			
			rowsInMeasure = (measureDataIndex+1)/kNotesPerMeasureRow;
			
			TMLog(@"End of measure %d. rows in measure: %d", measureId, rowsInMeasure);			
			TMLog(@"Measure data: '%s'", measureData);
			
			// Parse measure data and create notes		
			int row, note;
			int thisMeasure = measureId-1;
			TMNote* holds[kNumOfAvailableTracks];	// Used to store the objects which require a closing hold
			
			for(row = 0; row < rowsInMeasure; ++row) {			
				
				float percent = row/(float)rowsInMeasure;
				float beat = ((float)thisMeasure + percent) * kBeatsPerMeasure;
				currentNoteRow = [TMNote beatToNoteRow:beat];
				
				TMLog(@"CALCULATED SM noterow is %d for beat %f", currentNoteRow, beat);
				
				for(note = 0; note < kNotesPerMeasureRow; ++note) {
					char cc = measureData[row*kNotesPerMeasureRow + note];
					
					if(cc != '0') {
						// something should be tapped
						if(cc == '1') {
							// it's a regular tap note. good
							// TMLog(@"Place a note on %d in panel %d", currentNoteRow, note);
							[steps setNote:[[TMNote alloc] initWithNoteRow:currentNoteRow andType:kNoteType_Original] toTrack:note onNoteRow:currentNoteRow];									
						}
						else
						if(cc == '2') {
							// it's a hold note start... not bad too
							// TMLog(@"Place a holdhead on %d in panel %d", currentNoteRow, note);
							TMNote* holdHead = [[TMNote alloc] initWithNoteRow:currentNoteRow andType:kNoteType_HoldHead];
							
							// save it in the holds array
							holds[note] = holdHead;
							
							// add to steps
							[steps setNote:holdHead toTrack:note onNoteRow:currentNoteRow];									
						}	
						else
						if(cc == '3') {
							// should close the hold note started by the above
							if(holds[note] == nil) {
								TMLog(@"Error: SM file is broken.");								
							} else {
								// Set the stop note row to current
								holds[note].m_nStopNoteRow = currentNoteRow;
								holds[note] = nil;		// Done with this hold
							}
						}
						
						// TODO: add mines and rolls support
					}
				}
			}
			
			++measureId;
			rowsInMeasure = 0;	// Drop rows counter
			measureDataIndex = 0;								
		} else {
			
			// Contents
			measureData[measureDataIndex++] = c;			
		}		
	
	}	
	
	return steps;
}

// This one is used to parse simple variables with little data. such as title and artist.
+ (char*) parseSectionWithFD:(FILE*) fd {
	int c; // Incoming char
	int i; // Counter
	char data[4096];	// 4k should be enough
	
	c = getc(fd);
	
	// Get all data till the ';'
	for(i=0; i<4096 && !feof(fd) && c != ';';) {
		if(c != '\n' && c != '\r') { 
			if(c == '/') {
				c = getc(fd);
				if(c == '/') {
					// Got a comment... skip all till \n
					do{ c = getc(fd); } while(c != '\n' && !feof(fd));				
				
					// Now we are exactly after the \n (line after the comment line)			
					continue;
				} else {
					// put it back
					ungetc(c, fd);
					c = '/';
				}
			} 
		
			data[i++] = c;
		}
		
		c = getc(fd);	
	}
	
	if(feof(fd) || c != ';'){ 
		TMLog(@"Fatal: sm file broken.");
		return nil; 
	}
	
	data[i] = 0;
	
	return strdup(data);
}

// This one is used to parse some parts of the 'NOTES:' var
+ (char*) parseSectionPartWithFD:(FILE*) fd trimWhitespaces:(BOOL)trim {
	int c; // Incoming char
	int i; // Counter
	char data[256];
	
	c = getc(fd);
	
	// Get all data till the ':'
	for(i=0; i<255 && !feof(fd) && c != ':';) {
		
		if(c == '/') {
			c = getc(fd);
			if(c == '/') {
				
				// Got a comment... skip all till \n
				do{ c = getc(fd); } while(c != '\n' && !feof(fd));				
			
				// Now we are exactly after the \n (line after the comment line)			
				continue;
			} else {
				// put it back
				ungetc(c, fd);
				c = '/';
			}
		} 
		
		if(trim) {
			if(c != ' ' && c != '\t' && c != '\n' && c != '\r') {
				data[i++] = c;
			}
		} else {
			data[i++] = c;	
		}
		
		c = getc(fd);	
	}
	
	if(feof(fd) || c != ':'){ 
		TMLog(@"Fatal: sm file broken.");
		return nil; 
	}
	
	data[i] = 0;
	
	return strdup(data);
}


// This one is used to parse the BPMCHANGE and the FREEZE variable into the array
+ (NSMutableArray*) getChangesArray:(char*) data {
	char *token, *value;
	int i;
	
	TMChangeSegment* changer = nil;
	NSMutableArray* arr = [[NSMutableArray arrayWithCapacity:10] retain];
	NSMutableArray* resArr = nil;
	
	// 1288=666,1312=333,1316=166.5,1320=83.25,1356=333
	// or happen to be something like 1288.000=666.000 etc.
	// Here, unlike the dwi format the left side of the equation is in beats. not in noterows.
	token = strtok( data, "," );
	
	while( token != nil ) {
		TMLog(@"got token: %s", token);
		[arr addObject:[[NSString stringWithCString:token] retain]];
		token = strtok( nil, "," );
	}
	
	// Now for every saved change pair - split by '='
	resArr = [[NSMutableArray arrayWithCapacity:[arr count]] retain];
	
	for(i = 0; i<[arr count]; i++){
		token = strtok ( (char*)[[arr objectAtIndex:i] UTF8String], "=" );
		value = strtok(nil, "=");
		
		if(!token || !value) {
			TMLog(@"Fatal: changes array broken.");
			return nil;
		}
		
		// Got '$token=$value'
		int noteRow = [TMNote beatToNoteRow:atof(token)];
		
		changer = [[TMChangeSegment alloc] initWithNoteRow:noteRow andValue:atof(value)];
		[resArr addObject:changer];	
	}
	
	[arr release];
	TMLog(@"Total count of found tokens: %d", [resArr count]);
	return resArr;
}

// Get the difficulty number from a string representation
+ (TMSongDifficulty) getDifficultyWithName:(char*) difficulty {
	if( !strcasecmp( difficulty, "beginner" ) )   return kSongDifficulty_Beginner;
	if( !strcasecmp( difficulty, "easy" ) )       return kSongDifficulty_Easy;
	if( !strcasecmp( difficulty, "basic" ) )      return kSongDifficulty_Easy;
	if( !strcasecmp( difficulty, "light" ) )      return kSongDifficulty_Easy;
	if( !strcasecmp( difficulty, "medium" ) )     return kSongDifficulty_Medium;
	if( !strcasecmp( difficulty, "another" ) )    return kSongDifficulty_Medium;
	if( !strcasecmp( difficulty, "trick" ) )      return kSongDifficulty_Medium;
	if( !strcasecmp( difficulty, "standard" ) )   return kSongDifficulty_Medium;
	if( !strcasecmp( difficulty, "difficult" ) )  return kSongDifficulty_Medium;
	if( !strcasecmp( difficulty, "hard" ) )       return kSongDifficulty_Hard;
	if( !strcasecmp( difficulty, "ssr" ) )        return kSongDifficulty_Hard;
	if( !strcasecmp( difficulty, "maniac" ) )     return kSongDifficulty_Hard;
	if( !strcasecmp( difficulty, "heavy" ) )      return kSongDifficulty_Hard;
	if( !strcasecmp( difficulty, "smaniac" ) )    return kSongDifficulty_Challenge;
	if( !strcasecmp( difficulty, "challenge" ) )  return kSongDifficulty_Challenge;
	if( !strcasecmp( difficulty, "expert" ) )     return kSongDifficulty_Challenge;
	if( !strcasecmp( difficulty, "oni" ) )        return kSongDifficulty_Challenge;
	else                                          return kSongDifficulty_Invalid;
}

@end
