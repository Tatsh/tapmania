//
//  DWIParser.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "DWIParser.h"

#import "TMSteps.h"

#import <stdio.h>
#import <syslog.h>
#import <strings.h>

#define kBeatsPerMeasure 	4
#define kRowsPerBeat 		48

@interface DWIParser (Private)
+ (TMSteps*) parseStepDataWithFD:(FILE*) fd forSong:(TMSong*) song;
+ (char*) parseSectionWithFD:(FILE*) fd;
+ (char*) parseSectionPartWithFD:(FILE*) fd;
+ (NSMutableArray*) getChangesArray:(char*) data;
+ (TMSongDifficulty) getDifficultyWithName:(char*) difficulty;

+ (int) beatToNoteRow:(float) beat;
+ (void) dwiCharToNote:(int)c noteOut1:(int*) note1Out noteOut2:(int*) note2Out;
+ (void) dwiCharToNoteCol:(int)c colOut1:(int*) colOut1 colOut2:(int*) colOut2;
@end

@implementation DWIParser

/*
 * Parse basic song information from a dwi file
 */
+ (TMSong*) parseFromFile:(NSString*) filename {
	FILE* fd;
	int c; // Incoming char
	char varName[16]; // The name of the variable which comes directly after the '#' till the ':'.
	int i;

	TMSong* song = [[TMSong alloc] init];
	
	if( ! (fd = fopen([filename UTF8String], "r"))) {
		syslog(LOG_DEBUG, "Err: can't open file '%s' for reading.", [filename UTF8String]);
		return nil;	
	}

	// Read the whole file
	while(!feof(fd)) {
		c = getc(fd);
	
		// Start new section
		if(c == '#') {
			syslog(LOG_DEBUG, "Opening new section.");

			// Read the var name
			c = getc(fd);
			i = 0;

			while(!feof(fd) && c != ':') {
				varName[i++] = c;	
				c = getc(fd);
			}
			
			if(feof(fd)){ 
				syslog(LOG_DEBUG, "Fatal: dwi file broken.");
				return nil; 
			}

			varName[i] = 0;
			syslog(LOG_DEBUG, "Found var: '%s'", varName);

			// Now determine whether we are interested in this var or not
			if( !strcasecmp(varName, "TITLE") ) {
				syslog(LOG_DEBUG, "Title...");
				char* data = [DWIParser parseSectionWithFD:fd];
				syslog(LOG_DEBUG, "is '%s'", data);
				song.title = [[NSString stringWithCString:data] retain];
			} 
			else if( !strcasecmp(varName, "ARTIST") ) {
				syslog(LOG_DEBUG, "Artist...");
				char* data = [DWIParser parseSectionWithFD:fd];
				syslog(LOG_DEBUG, "is '%s'", data);
				song.artist = [[NSString stringWithCString:data] retain];
			}
			else if( !strcasecmp(varName, "BPM") ) {
				syslog(LOG_DEBUG, "BPM...");
				char* data = [DWIParser parseSectionWithFD:fd];
				syslog(LOG_DEBUG, "is '%s'", data);
				song.bpm = atof(data);	
			}
			else if( !strcasecmp(varName, "GAP") ) {
				syslog(LOG_DEBUG, "GAP...");
				char* data = [DWIParser parseSectionWithFD:fd];
				syslog(LOG_DEBUG, "is '%s'", data);
				song.gap = (double)atoi(data) / 1000.0f;
			}
			else if( !strcasecmp(varName, "CHANGEBPM") || !strcasecmp(varName, "BPMCHANGE") ) {
				syslog(LOG_DEBUG, "BPMCHANGE...");
				char* data = [DWIParser parseSectionWithFD:fd];
				syslog(LOG_DEBUG, "is '%s'", data);
				song.bpmChangeArray = [DWIParser getChangesArray:data];
			}
			else if( !strcasecmp(varName, "FREEZE") ){
				syslog(LOG_DEBUG, "FREEZE...");
				char* data = [DWIParser parseSectionWithFD:fd];
				syslog(LOG_DEBUG, "is '%s'", data);
				song.freezeArray = [DWIParser getChangesArray:data];
			}
			else if( !strcasecmp(varName, "SINGLE") ){ 
				// This is interesting! Some single mode stepchart here..
				// For now we just want to get information about the difficulty/level of this one
				char* diffStr  = [DWIParser parseSectionPartWithFD:fd];
				char* levelStr = [DWIParser parseSectionPartWithFD:fd];

				TMSongDifficulty difficulty = [DWIParser getDifficultyWithName:diffStr];
				[song enableDifficulty:difficulty withLevel:atoi(levelStr)];
			}
		}
		// End the section
		else if(c == ';') {
			syslog(LOG_DEBUG, "Closing section.");
		}
	}
	
	// Close the file handle
	syslog(LOG_DEBUG, "Done parsing the dwi file. close handle..");
	fclose(fd);

	return song;
}

/*
 * Parse steps data from file
 */
+ (TMSteps*) parseStepsFromFile:(NSString*) filename forDifficulty:(TMSongDifficulty)difficulty forSong:(TMSong*)song{
	FILE* fd;
	int c; // Incoming char
	char varName[16]; // The name of the variable which comes directly after the '#' till the ':'.
	int i;

	if( ! (fd = fopen([filename UTF8String], "r"))) {
		syslog(LOG_DEBUG, "Err: can't open file '%s' for reading.", [filename UTF8String]);
		return nil;	
	}

	// Read the whole file
	while(!feof(fd)) {
		c = getc(fd);
	
		// Start new section
		if(c == '#') {
			syslog(LOG_DEBUG, "Opening new section.");

			// Read the var name
			c = getc(fd);
			i = 0;

			while(!feof(fd) && c != ':') {
				varName[i++] = c;	
				c = getc(fd);
			}
			
			if(feof(fd)){ 
				syslog(LOG_DEBUG, "Fatal: dwi file broken.");
				return nil; 
			}

			varName[i] = 0;
		
			if( !strcasecmp(varName, "SINGLE") ){ 
				syslog(LOG_DEBUG, "Got SINGLE input...");

				char* diffStr  = [DWIParser parseSectionPartWithFD:fd];
				char* levelStr = [DWIParser parseSectionPartWithFD:fd];

				syslog(LOG_DEBUG, "Diff=%s level=%s", diffStr, levelStr);
				
				TMSongDifficulty thisDiff = [DWIParser getDifficultyWithName:diffStr];
				
				// If this is the difficulty we are looking for - parse the data
				if(thisDiff == difficulty) {
					syslog(LOG_DEBUG, "FOUND our difficulty!!!");
					
					TMSteps* steps = [DWIParser parseStepDataWithFD:fd forSong:song];
					fclose(fd);
					return steps;
				}
			}
		}
		// End the section
		else if(c == ';') {
			syslog(LOG_DEBUG, "Closing section.");
		}
	}
	
	// Close the file handle
	syslog(LOG_DEBUG, "Done parsing the dwi file. close handle..");
	fclose(fd);

	return nil;
}



// Private methods

+ (void) dwiCharToNote:(int)c noteOut1:(int*) note1Out noteOut2:(int*) note2Out {

	switch( c ) {
	        case '0':       
			*note1Out = DANCE_NOTE_NONE;             *note2Out = DANCE_NOTE_NONE;     
			break;
	        case '1':
			*note1Out = DANCE_NOTE_PAD1_DOWN;        *note2Out = DANCE_NOTE_PAD1_LEFT;
			break;
	        case '2':
			*note1Out = DANCE_NOTE_PAD1_DOWN;        *note2Out = DANCE_NOTE_NONE;     
			break;
	        case '3':
			*note1Out = DANCE_NOTE_PAD1_DOWN;        *note2Out = DANCE_NOTE_PAD1_RIGHT;
			break;
	        case '4':
			*note1Out = DANCE_NOTE_PAD1_LEFT;        *note2Out = DANCE_NOTE_NONE;     
			break;
	        case '5':
			*note1Out = DANCE_NOTE_NONE;             *note2Out = DANCE_NOTE_NONE;     
			break;
		case '6':
			*note1Out = DANCE_NOTE_PAD1_RIGHT;       *note2Out = DANCE_NOTE_NONE;     
			break;
		case '7':
			*note1Out = DANCE_NOTE_PAD1_UP;          *note2Out = DANCE_NOTE_PAD1_LEFT;
			break;
		case '8':
			*note1Out = DANCE_NOTE_PAD1_UP;          *note2Out = DANCE_NOTE_NONE;     
			break;
		case '9':
			*note1Out = DANCE_NOTE_PAD1_UP;          *note2Out = DANCE_NOTE_PAD1_RIGHT;
			break;
		case 'A':
			*note1Out = DANCE_NOTE_PAD1_UP;          *note2Out = DANCE_NOTE_PAD1_DOWN;
			break;
		case 'B':
			*note1Out = DANCE_NOTE_PAD1_LEFT;        *note2Out = DANCE_NOTE_PAD1_RIGHT;
			break;
		case 'C':
			*note1Out = DANCE_NOTE_PAD1_UPLEFT;      *note2Out = DANCE_NOTE_NONE;     
			break;
		case 'D':
			*note1Out = DANCE_NOTE_PAD1_UPRIGHT;     *note2Out = DANCE_NOTE_NONE;     
			break;
		case 'E':
			*note1Out = DANCE_NOTE_PAD1_LEFT;        *note2Out = DANCE_NOTE_PAD1_UPLEFT;
			break;
		case 'F':
			*note1Out = DANCE_NOTE_PAD1_UPLEFT;      *note2Out = DANCE_NOTE_PAD1_DOWN;
			break;
		case 'G':
			*note1Out = DANCE_NOTE_PAD1_UPLEFT;      *note2Out = DANCE_NOTE_PAD1_UP;  
			break;
		case 'H':
			*note1Out = DANCE_NOTE_PAD1_UPLEFT;      *note2Out = DANCE_NOTE_PAD1_RIGHT;
			break;
		case 'I':
			*note1Out = DANCE_NOTE_PAD1_LEFT;       *note2Out = DANCE_NOTE_PAD1_UPRIGHT;
			break;
		case 'J':
			*note1Out = DANCE_NOTE_PAD1_DOWN;       *note2Out = DANCE_NOTE_PAD1_UPRIGHT;
			break;
		case 'K':
			*note1Out = DANCE_NOTE_PAD1_UP;         *note2Out = DANCE_NOTE_PAD1_UPRIGHT;
			break;
		case 'L':
			*note1Out = DANCE_NOTE_PAD1_UPRIGHT;    *note2Out = DANCE_NOTE_PAD1_RIGHT;
			break;
		case 'M':
			*note1Out = DANCE_NOTE_PAD1_UPLEFT;     *note2Out = DANCE_NOTE_PAD1_UPRIGHT;
			break;
		default:
			*note1Out = DANCE_NOTE_NONE;		*note2Out = DANCE_NOTE_NONE; 	
			break;
	}
			
}

+ (void) dwiCharToNoteCol:(int)c colOut1:(int*) colOut1 colOut2:(int*) colOut2 {
	int note1, note2;
	[DWIParser dwiCharToNote:c noteOut1:&note1 noteOut2:&note2];


	if(note1 != DANCE_NOTE_NONE) {
		switch(note1) {
			case DANCE_NOTE_PAD1_LEFT:
				*colOut1 = 0;
				break;
			case DANCE_NOTE_PAD1_DOWN:
				*colOut1 = 1;
				break;
			case DANCE_NOTE_PAD1_UP:
				*colOut1 = 2;
				break;
			case DANCE_NOTE_PAD1_RIGHT:
				*colOut1 = 3;
				break;
			default:
				*colOut1 = -1;
				break;
		} 
	} else { *colOut1 = -1; }

	if(note2 != DANCE_NOTE_NONE) {
		switch(note2) {
			case DANCE_NOTE_PAD1_LEFT:
				*colOut2 = 0;
				break;
			case DANCE_NOTE_PAD1_DOWN:
				*colOut2 = 1;
				break;
			case DANCE_NOTE_PAD1_UP:
				*colOut2 = 2;
				break;
			case DANCE_NOTE_PAD1_RIGHT:
				*colOut2 = 3;
				break;
			default:
				*colOut2 = -1;
				break;
		} 
	} else { *colOut2 = -1; }
}

// Parse the whole step data line using the file descriptor
+ (TMSteps*) parseStepDataWithFD:(FILE*) fd forSong:(TMSong*) song{
	TMSteps* steps = [[TMSteps alloc] init];

	double currentBeat = 0;
	double currentIncrementer = 1.0/8*kBeatsPerMeasure;

	int c = getc(fd);
					
	// Parse every char till ';'
	while (!feof(fd) && c != ';') {
		if(c == ' ' || c == '\t' || c == '\n' || c == '\r'){
			c = getc(fd);
			continue; // Skip this char
		}

		switch(c) {
			case '(':
				currentIncrementer = 1.0/16 *kBeatsPerMeasure;
				break;
			case '[':
				currentIncrementer = 1.0/24 *kBeatsPerMeasure;
				break;
			case '{':
				currentIncrementer = 1.0/64 *kBeatsPerMeasure;
				break;
			case '`':
				currentIncrementer = 1.0/192 *kBeatsPerMeasure;
				break;
			case ')':
			case ']':
			case '}':
			case '\'':
			case '>':
				currentIncrementer = 1.0/8 *kBeatsPerMeasure;
				break;
			default:
			{
				// A note character
				if(c == '!') { 
					c = getc(fd);
					continue; 
				}
								
				BOOL jump = NO;
		
				if(c == '<') {
					// TODO: check whether is jump or 192
					// Jump! read till next '>'
					jump = YES;
				}

				// int index = [DWIParser beatToRowNum:currentBeat];

				do {
					if(jump && c == '>')
						break;

					int col1, col2;
					[DWIParser dwiCharToNoteCol:c colOut1:&col1 colOut2:&col2];
					
					double currentTime, holdStartTime, holdEndTime;
					int holdChar;
					BOOL hold = NO;
		
					if(col1 != -1 || col2 != -1) {
						currentTime = song.gap + song.timePerBeat*currentBeat; 

						// Peek at the next note char
						int nc = getc(fd);
						
						if(nc == '!') {
							// Oops... looks like a hold!
							hold = YES;

							holdStartTime = currentTime;

							// Find hold end time
							holdChar = getc(fd);

							while(!feof(fd) && c == '0') {
								c = getc(fd);
								currentBeat += currentIncrementer;
							}
							
							if(feof(fd)){
								syslog(LOG_DEBUG, "Fatal: dwi file broken.");
								return nil; 
							}
	
							// Calculate the end time for the hold
							holdEndTime = song.gap + song.timePerBeat*currentBeat;

						} else {
							ungetc(nc, fd);
						}	
					}

					if(col1 != -1) {
						TMNote* note = nil;
						
						// Setup the note
						if(!hold) {
							note = [[TMNote alloc] initWithTime:currentTime 
									tillTime:-1];	
						} else {
							note = [[TMNote alloc] initWithTime:holdStartTime 
									tillTime:holdEndTime];
						}

						// Add note to steps
						[steps addNote:note toTrack:col1]; 
					} 

					if(col2 != -1) {
						// Setup the note
						TMNote* note = nil;
						
						// Setup the note
						if(!hold) {
							note = [[TMNote alloc] initWithTime:currentTime 
									tillTime:-1];	
						} else {
							note = [[TMNote alloc] initWithTime:holdStartTime 
									tillTime:holdEndTime];
						}

						// Add note to steps
						[steps addNote:note toTrack:col2]; 
					}

					if(jump)
						c = getc(fd);

				} while (jump);

				currentBeat += currentIncrementer;
			}
		}
					
		// Get next char
		c = getc(fd);
	}

	return steps;
}

+ (int) beatToNoteRow:(float) beat {
	return lrintf( beat * kRowsPerBeat );	
}

// This one is used to parse simple variables with little data. such as title and artist.
+ (char*) parseSectionWithFD:(FILE*) fd {
	int c; // Incoming char
	int i; // Counter
	char data[256];

	c = getc(fd);

	// Get all data till the ';'
	for(i=0; i<255 && !feof(fd) && c != ';'; i++) {
		data[i] = c;
		c = getc(fd);	
	}
	
	if(feof(fd) || c != ';'){ 
		syslog(LOG_DEBUG, "Fatal: dwi file broken.");
		return nil; 
	}
	
	data[i] = 0;

	return strdup(data);
}

// This one is used to parse some parts of the 'SINGLE:' var
+ (char*) parseSectionPartWithFD:(FILE*) fd {
	int c; // Incoming char
	int i; // Counter
	char data[256];

	c = getc(fd);

	// Get all data till the ':'
	for(i=0; i<255 && !feof(fd) && c != ':'; i++) {
		data[i] = c;
		c = getc(fd);	
	}
	
	if(feof(fd) || c != ':'){ 
		syslog(LOG_DEBUG, "Fatal: dwi file broken.");
		return nil; 
	}
	
	data[i] = 0;

	return strdup(data);
}


// This one is used to parse the BPMCHANGE and the FREEZE variable into the array
+ (NSMutableArray*) getChangesArray:(char*) data {
	char *token;
	NSMutableArray* arr = [[NSMutableArray arrayWithCapacity:10] retain];
	
	// 1288=666,1312=333,1316=166.5,1320=83.25,1356=333
	token = strtok( data, "," );

	while( token != nil ) {
		syslog(LOG_DEBUG, "got token: %s", token);
		[arr addObject:[[NSString stringWithCString:token] retain]];
		token = strtok( nil, "," );
	}

	syslog(LOG_DEBUG, "Total count of found tokens: %d", [arr count]);
	return arr;
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
