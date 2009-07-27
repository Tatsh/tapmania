//
//  WebServer.m
//  TapMania
//
//  Created by Alex Kremer on 7/22/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "WebServer.h"
#import "ThemeManager.h"

#include <arpa/inet.h>
#include <ifaddrs.h>


@interface WebServer (Private)
- (NSString *) getAddress;
- (NSString *) getIncomingPath;
@end

// This is a singleton class, see below
static WebServer *sharedWebServerDelegate = nil;

@implementation WebServer

@synthesize m_sCurrentServerURL;

#pragma mark C part of the server

#define POSTBUFFERSIZE  512

#define GET             0
#define POST            1

struct connection_info_struct
{
	int connectiontype;
	struct MHD_PostProcessor *postprocessor;
	FILE *fp;
	const char *answerstring;
	int answercode;
};

char* getPage (char* page) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
	NSString* pagePath = [NSString stringWithFormat:@"%@/%@/WebServer/%s", themesDir, [ThemeManager sharedInstance].m_sCurrentThemeName, page];
	TMLog(@"Page should be at '%@'...", pagePath);

	if(! [[NSFileManager defaultManager] isReadableFileAtPath:pagePath]){
		[pool release];
		return strdup("No page in current theme!");
	}
	
	NSData* contents = [[NSFileManager defaultManager] contentsAtPath:pagePath];
	char* ptr = strdup([contents bytes]);
	
	[pool release];
	return ptr;
}

int
send_page (struct MHD_Connection *connection, const char *page,
           int status_code)
{
	int ret;
	struct MHD_Response *response;
	
	
	response =
    MHD_create_response_from_data (strlen (page), (void *) page, MHD_NO,
                                   MHD_YES);
	if (!response)
		return MHD_NO;
	
	ret = MHD_queue_response (connection, status_code, response);
	MHD_destroy_response (response);
	
	return ret;
}


int
iterate_post (void *coninfo_cls, enum MHD_ValueKind kind, const char *key,
              const char *filename, const char *content_type,
              const char *transfer_encoding, const char *data, uint64_t off,
              size_t size)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	FILE *fp;
	struct connection_info_struct *con_info =
    (struct connection_info_struct *) coninfo_cls;
	
	char* pageContents = getPage("internal_error.htm");
	con_info->answerstring = pageContents;
	con_info->answercode = MHD_HTTP_INTERNAL_SERVER_ERROR;
	
	if (0 != strcmp (key, "file")) {
		[pool release];
		return MHD_NO;
	}
	
	if (!con_info->fp)
    {
		char buffer[1024] = {0,};
		snprintf(buffer, 1024, [[[[WebServer sharedInstance] getIncomingPath] stringByAppendingString:@"/\%s"] UTF8String], filename);
		
		TMLog(@"Check incoming file: '%s'", buffer);
		
		if (NULL != (fp = fopen (buffer, "r")))
        {
			free(pageContents);
			pageContents = getPage("exists.htm");
			
			fclose (fp);
			con_info->answerstring = pageContents;
			con_info->answercode = MHD_HTTP_FORBIDDEN;
			
			[pool release];
			return MHD_NO;
        }
		
		con_info->fp = fopen (buffer, "ab");
		if (!con_info->fp) {
			[pool release];
			return MHD_NO;
		}
    }
	
	if (size > 0)
    {
		if (!fwrite (data, size, sizeof (char), con_info->fp)) {
			[pool release];
			return MHD_NO;
		}
    }
	
	TMLog(@"Upload complete...");
	
	free(pageContents);
	pageContents = getPage("success.htm");
	
	con_info->answerstring = pageContents;
	con_info->answercode = MHD_HTTP_OK;
	
	[pool release];
	return MHD_YES;
}

void
request_completed (void *cls, struct MHD_Connection *connection,
                   void **con_cls, enum MHD_RequestTerminationCode toe)
{
	struct connection_info_struct *con_info =
    (struct connection_info_struct *) *con_cls;
	
	if (NULL == con_info)
		return;
	
	if (con_info->connectiontype == POST)
    {
		if (NULL != con_info->postprocessor)
        {
			MHD_destroy_post_processor (con_info->postprocessor);
        }
		
		if (con_info->fp)
			fclose (con_info->fp);
    }
	
	free (con_info);
	*con_cls = NULL;
}


int
answer_to_connection (void *cls, struct MHD_Connection *connection,
                      const char *url, const char *method,
                      const char *version, const char *upload_data,
                      size_t *upload_data_size, void **con_cls)
{
	if (NULL == *con_cls)
    {
		struct connection_info_struct *con_info;
				
		con_info = malloc (sizeof (struct connection_info_struct));
		if (NULL == con_info)
			return MHD_NO;
		
		con_info->fp = NULL;
		
		if (0 == strcmp (method, "POST"))
        {
			con_info->postprocessor =
            MHD_create_post_processor (connection, POSTBUFFERSIZE,
                                       iterate_post, (void *) con_info);
			
			if (NULL == con_info->postprocessor)
            {
				free (con_info);
				return MHD_NO;
            }
			
			con_info->connectiontype = POST;
			con_info->answercode = MHD_HTTP_OK;
			con_info->answerstring = getPage("success.htm");
        }
		else
			con_info->connectiontype = GET;
		
		*con_cls = (void *) con_info;
		
		return MHD_YES;
    }
	
	if (0 == strcmp (method, "GET"))
    {
		char* pageContents = getPage("index.htm");
		int code = send_page (connection, pageContents, MHD_HTTP_OK);

		free(pageContents);
		return code;
    }
	
	if (0 == strcmp (method, "POST"))
    {
		struct connection_info_struct *con_info = *con_cls;
		
		if (0 != *upload_data_size)
        {
			MHD_post_process (con_info->postprocessor, upload_data,
							  *upload_data_size);
			*upload_data_size = 0;
			
			return MHD_YES;
        }
		else
			return send_page (connection, con_info->answerstring,
							  con_info->answercode);
    }
	
	return send_page (connection, getPage("error.htm"), MHD_HTTP_BAD_REQUEST);
}


#pragma mark Obj-C part of the server

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	m_pDaemon = NULL;
	m_sCurrentServerURL = @"No URL";
	
	return self;
}

- (void) dealloc {	
	[super dealloc];
}

- (void) start {
	TMLog(@"Starting web server...");
	
	m_pDaemon = MHD_start_daemon (MHD_USE_SELECT_INTERNALLY, 9002, NULL, NULL,
								  &answer_to_connection, NULL,
								  MHD_OPTION_NOTIFY_COMPLETED, request_completed,
								  NULL, MHD_OPTION_END);	
	
	m_sCurrentServerURL = [self getAddress];
	
	TMLog(@"Web server is up at '%@'.", m_sCurrentServerURL);
	TMLog(@"Incoming dir pointing at '%@'.", [self getIncomingPath]);
}

- (void) stop {
	TMLog(@"Stopping web server...");
	
	MHD_stop_daemon (m_pDaemon);
	m_sCurrentServerURL = @"No URL";
	
	TMLog(@"Web server is down.");
}


- (NSString *) getIncomingPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		
		// ...Documents/TapManiaIncoming
		dir = [dir stringByAppendingPathComponent:kWebServerIncomingPath];
		
		// Create the incoming dir if missing
		if(! [[NSFileManager defaultManager] isReadableFileAtPath:dir]){
			[[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];
		}
		
		return dir;
	}	
	
	// Fallback path
	return @"/tmp/";
}

- (NSString *) getAddress { 
	NSString *address = @"Turn WiFi on first"; 
	struct ifaddrs *interfaces = NULL; 
	struct ifaddrs *temp_addr = NULL; 
	int success = 0; 
	
	// retrieve the current interfaces - returns 0 on success 
	success = getifaddrs(&interfaces); 
	if (success == 0)  { 
		// Loop through linked list of interfaces  
		temp_addr = interfaces; 
		while(temp_addr != NULL)  { 
			if(temp_addr->ifa_addr->sa_family == AF_INET)  {
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])  { 
					// Get NSString from C String 
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; 
					address = [NSString stringWithFormat:@"http://%@:9002/", address];
				} 
			} 
			
			temp_addr = temp_addr->ifa_next; 
		} 
	} 

	// Free memory  
	freeifaddrs(interfaces); 
	
	return address; 
} 

#pragma mark Singleton stuff

+ (WebServer *)sharedInstance {
    @synchronized(self) {
        if (sharedWebServerDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedWebServerDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedWebServerDelegate	== nil) {
            sharedWebServerDelegate = [super allocWithZone:zone];
            return sharedWebServerDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
