//
//  DWIParser.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "DWIParser.h"

#import <stdio.h>
#import <syslog.h>
#import <strings.h>


@interface DWIParser (Private)
+ (char*) parseSectionWithFD:(FILE*) fd;
+ (NSMutableArray*) getChangesArray:(char*) data;
@end

@implementation DWIParser

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
				song.gap = atoi(data);	
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

// Private methods
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
	
	if(feof(fd)){ 
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

@end
