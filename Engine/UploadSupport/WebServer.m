//
//  $Id$
//  WebServer.m
//  TapMania
//
//  Created by Alex Kremer on 7/22/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "WebServer.h"
#import "ThemeManager.h"
#import "SongsDirectoryCache.h"
#import "ThemeManager.h"
#import "TMSong.h"
#import "TMZipFile.h"
#import "TMResource.h"
#import "Texture2D.h"

#include <arpa/inet.h>
#include <ifaddrs.h>


@interface WebServer (Private)
- (NSString *)getAddress;

- (NSString *)getIncomingPath;
@end

// This is a singleton class, see below
static WebServer *sharedWebServerDelegate = nil;

@interface WebServer ()
- (void)loadBannerForSong:(TMSong *)song;

@end

@implementation WebServer

@synthesize m_sCurrentServerURL;

#pragma mark C part of the server

#define POSTBUFFERSIZE  512

#define GET             0
#define POST            1


char *getPage(char *page)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    TMResource *pageResource = [[ThemeManager sharedInstance].web getResource:[NSString stringWithUTF8String:page]];
    if ( !pageResource )
    {
        [pool release];
        return strdup("<b>Page not found in current theme! Report to theme developer please.</b>");
    }

    NSData *contents = (NSData *) [pageResource resource];
    char *ptr = malloc(([contents length]) + 1);

    strncpy(ptr, [contents bytes], [contents length]);
    ptr[([contents length])] = 0; // Make sure we don't mess up the interface

    [pool release];
    return ptr;
}

void *getBytes(char *path, int *size)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    TMResource *binaryResource = [[ThemeManager sharedInstance].web getResource:[NSString stringWithUTF8String:path]];
    if ( !binaryResource )
    {
        [pool release];
        return NULL;
    }

    NSData *resData = (NSData *) [binaryResource resource];

    *size = [resData length];
    void *ptr = malloc(([resData length]) + 1);

    [resData getBytes:ptr];

    [pool release];
    return ptr;
}

char *getIndexPage(char *message)
{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Get the main page template
    char *pageContents = getPage("index");
    char *itemTmpl = getPage("item");

    // We need to evaluate the catalogue list and embed it where the
    // %CATALOGUE% variable is in the index page.
    NSArray *songs = [[SongsDirectoryCache sharedInstance] getSongList];
    NSMutableString *catalogue = [[NSMutableString alloc] initWithCapacity:[songs count]];

    for ( TMSong *song in songs )
    {
        NSString *item = [NSString stringWithUTF8String:itemTmpl];
        item = [item stringByReplacingOccurrencesOfString:@"%TITLE%" withString:song.title];
        item = [item stringByReplacingOccurrencesOfString:@"%AUTHOR%" withString:song.m_sArtist];

        // Can only delete user songs
        if ( song.m_iSongsPath == kUserSongsPath )
        {
            item = [item stringByReplacingOccurrencesOfString:@"%DELETE%" withString:
                    [NSString stringWithFormat:@"<a href=\"/delete?song=%@\">[ delete ]</a>", song.m_sSongDirName]];
        }
        else
        {
            item = [item stringByReplacingOccurrencesOfString:@"%DELETE%" withString:@"built-in"];
        }

        NSMutableString *diffs = [[NSMutableString alloc] initWithCapacity:3];

        // Get song difficulties
        for ( TMSongDifficulty diff = kSongDifficulty_Beginner; diff < kNumSongDifficulties; diff++ )
        {
            int level = -1;

            if ( (level = [song getDifficultyLevel:diff]) != -1 )
            {
                [diffs appendFormat:@" %@(%d) ", [TMSong difficultyToString:diff], level];
            }
        }

        item = [item stringByReplacingOccurrencesOfString:@"%DIFFICULTIES%" withString:diffs];
        [diffs release];

        // Add to resulting catalogue html
        [catalogue appendString:item];
    }

    // Generate result
    NSString *result = [NSString stringWithUTF8String:pageContents];
    result = [result stringByReplacingOccurrencesOfString:@"%CATALOGUE%" withString:catalogue];
    result = [result stringByReplacingOccurrencesOfString:@"%MESSAGE%" withString:[NSString stringWithUTF8String:message]];

    char *ptr = malloc(([result length]) + 1);
    strcpy(ptr, [result UTF8String]);

    [catalogue release];
    free(pageContents);

    [pool release];
    return ptr;
}

int
send_page(struct MHD_Connection *connection, const char *page,
        int status_code)
{
    int ret;
    struct MHD_Response *response;


    response =
            MHD_create_response_from_data(strlen(page), (void *) page, MHD_NO,
                    MHD_YES);
    if ( !response )
    {
        return MHD_NO;
    }

    ret = MHD_queue_response(connection, status_code, response);
    MHD_destroy_response(response);

    return ret;
}

int
send_bytes(struct MHD_Connection *connection, const void *bytes, int size,
        int status_code)
{
    int ret;
    struct MHD_Response *response;

    response =
            MHD_create_response_from_data(size, (void *) bytes, MHD_NO,
                    MHD_YES);
    if ( !response )
    {
        return MHD_NO;
    }

    ret = MHD_queue_response(connection, status_code, response);
    MHD_destroy_response(response);

    return ret;
}

int
iterate_post(void *coninfo_cls, enum MHD_ValueKind kind, const char *key,
        const char *filename, const char *content_type,
        const char *transfer_encoding, const char *data, uint64_t off,
        size_t size)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    FILE *fp;
    struct connection_info_struct *con_info =
            (struct connection_info_struct *) coninfo_cls;

    char *pageContents = getPage("InternalError");
    con_info->answerstring = pageContents;
    con_info->answercode = MHD_HTTP_INTERNAL_SERVER_ERROR;
    con_info->file_uploaded = false;

    if ( 0 != strcmp(key, "file") )
    {
        [pool release];
        return MHD_NO;
    }

    if ( !con_info->fp )
    {
        char buffer[1024] = {0,};
        snprintf(buffer, 1024, [[[[WebServer sharedInstance] getIncomingPath] stringByAppendingString:@"/\%s"] UTF8String], filename);

        TMLog(@"Check incoming file: '%s'", buffer);

        if ( NULL != (fp = fopen(buffer, "r")) )
        {
            free(pageContents);
            pageContents = getIndexPage("The file you are uploading seems to exist already");

            fclose(fp);
            con_info->answerstring = pageContents;
            con_info->answercode = MHD_HTTP_FORBIDDEN;

            [pool release];
            return MHD_NO;
        }

        con_info->fp = fopen(buffer, "ab");
        if ( !con_info->fp )
        {
            [pool release];
            return MHD_NO;
        }

        // Store file path
        con_info->file_path = (char *) malloc(sizeof(char) * (strlen(buffer) + 1));
        strncpy(con_info->file_path, buffer, strlen(buffer));
        con_info->file_path[strlen(buffer)] = 0;
    }

    if ( size > 0 )
    {
        if ( !fwrite(data, size, sizeof (char), con_info->fp) )
        {
            [pool release];
            return MHD_NO;
        }
    }

    [pool release];
    return MHD_YES;
}

void
request_completed(void *cls, struct MHD_Connection *connection,
        void **con_cls, enum MHD_RequestTerminationCode toe)
{
    struct connection_info_struct *con_info =
            (struct connection_info_struct *) *con_cls;

    if ( NULL == con_info )
    {
        return;
    }

    if ( con_info->connectiontype == POST )
    {
        if ( NULL != con_info->postprocessor )
        {
            MHD_destroy_post_processor(con_info->postprocessor);
        }

        if ( con_info->fp )
        {
            fclose(con_info->fp);
        }

        // Now when the file is uploaded completely we can unzip it
        if ( con_info->file_uploaded )
        {
            // Finished the upload
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

            TMLog(@"Going to unzip the file at '%s'...", con_info->file_path);

            // If we got here the file should be uploaded now
            TMZipFile *zipHandler = [[TMZipFile alloc] initWithPath:[NSString stringWithUTF8String:con_info->file_path]];
            if ( zipHandler )
            {
                NSString *extDir = [[[WebServer sharedInstance] getIncomingPath] stringByAppendingString:@"/Staging"];

                // Try to extract
                [zipHandler extractTo:extDir];

                // Delete the zip self
                NSError *err;
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:con_info->file_path] error:&err];

                // Move the simfile(s)
                [[SongsDirectoryCache sharedInstance] delegate:[WebServer sharedInstance]];
                [[SongsDirectoryCache sharedInstance] addSongsFrom:extDir];
                [[ThemeManager sharedInstance] addSkinsFrom:extDir];

                // Cleanup
                [zipHandler release];

                // Delete the staging dir
                [[NSFileManager defaultManager] removeItemAtPath:extDir error:&err];

            }
            else
            {
                // TODO raise error on gui
                TMLog(@"Couldn't work with this zip file for some reason...");
            }

            [pool release];
        }

        con_info->file_uploaded = FALSE;
    }

    // FIXME: PROBLEM here:
    // This line is required to prevent a memleak. hotfix for os 4.0
    //	if(con_info->file_path) free(con_info->file_path);

    if ( con_info )
    {
        free(con_info);
    }
    *con_cls = NULL;
}


int
answer_to_connection(void *cls, struct MHD_Connection *connection,
        const char *url, const char *method,
        const char *version, const char *upload_data,
        size_t *upload_data_size, void **con_cls)
{
    if ( NULL == *con_cls )
    {
        struct connection_info_struct *con_info;

        con_info = malloc(sizeof (struct connection_info_struct));
        if ( NULL == con_info )
        {
            return MHD_NO;
        }

        con_info->fp = NULL;

        if ( 0 == strcmp(method, "POST") )
        {
            con_info->postprocessor =
                    MHD_create_post_processor(connection, POSTBUFFERSIZE,
                            iterate_post, (void *) con_info);

            if ( NULL == con_info->postprocessor )
            {
                free(con_info);
                return MHD_NO;
            }

            con_info->connectiontype = POST;
            con_info->answercode = MHD_HTTP_OK;
            con_info->answerstring = getIndexPage("");
        }
        else
        {
            con_info->connectiontype = GET;
        }

        *con_cls = (void *) con_info;

        return MHD_YES;
    }

    if ( 0 == strcmp(method, "GET") )
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        // Check whether we need a page or a binary file
        NSString *objUrl = [[NSString stringWithUTF8String:url] lowercaseString];

        // Should get us 'Images/imageName.png' or so
        NSString *objShortUrl = [[NSString stringWithUTF8String:url]
                stringByReplacingOccurrencesOfString:
                        [[WebServer sharedInstance] getAddress] withString:@""];

        if ( [objUrl hasSuffix:@".png"] || [objUrl hasSuffix:@".jpg"] || [objUrl hasSuffix:@".gif"] )
        {

            // Create a resource path from it
            objShortUrl = [objShortUrl stringByReplacingOccurrencesOfString:@"/" withString:@" "];

            // Remove ext and trim
            objShortUrl = [[objShortUrl stringByDeletingPathExtension] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];

            int size;
            char *bytes = getBytes([objShortUrl UTF8String], &size);
            int code = send_bytes(connection, bytes, size, MHD_HTTP_OK);

            free(bytes);

            [pool release];
            return code;

        }
        else if ( [objShortUrl hasPrefix:@"/delete"] )
        {
            // We requested the delete handler
            char *cParam = MHD_lookup_connection_value(connection, MHD_GET_ARGUMENT_KIND, "song");
            if ( !cParam )
            {
                return send_page(connection, getPage("Error"), MHD_HTTP_BAD_REQUEST);
            }

            NSString *param = [NSString stringWithUTF8String:cParam];
            TMLog(@"Delete song '%@' using web interface", param);

            [[SongsDirectoryCache sharedInstance] deleteSong:param];

            char *pageContents = getIndexPage("The requested song was deleted");
            int code = send_page(connection, pageContents, MHD_HTTP_OK);

            free(pageContents);

            [pool release];
            return code;

        }
        else
        {

            // Otherwise by default we return the main page
            char *pageContents = getIndexPage("");
            int code = send_page(connection, pageContents, MHD_HTTP_OK);

            free(pageContents);

            [pool release];
            return code;
        }
    }
    // End of new connection block

    // Returning connection block below
    if ( 0 == strcmp(method, "POST") )
    {
        struct connection_info_struct *con_info = *con_cls;

        if ( 0 != *upload_data_size )
        {
            MHD_post_process(con_info->postprocessor, upload_data,
                    *upload_data_size);
            *upload_data_size = 0;

            return MHD_YES;
        }
        else
        {
            con_info->file_uploaded = true;
            con_info->answerstring = getPage("Success");
            con_info->answercode = MHD_HTTP_OK;

            return send_page(connection, con_info->answerstring,
                    con_info->answercode);
        }
    }

    return send_page(connection, getPage("Error"), MHD_HTTP_BAD_REQUEST);
}


#pragma mark Obj-C part of the server

- (id)init
{
    self = [super init];
    if ( !self )
    {
        return nil;
    }

    m_pDaemon = NULL;
    m_sCurrentServerURL = @"No URL";

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)start
{
    TMLog(@"Starting web server...");

    // Cleanup the incoming dir first
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:[self getIncomingPath] error:err];

    m_pDaemon = MHD_start_daemon(MHD_USE_SELECT_INTERNALLY, 9002, NULL, NULL,
            &answer_to_connection, NULL,
            MHD_OPTION_NOTIFY_COMPLETED, request_completed,
            NULL, MHD_OPTION_END);

    m_sCurrentServerURL = [self getAddress];

    TMLog(@"Web server is up at '%@'.", m_sCurrentServerURL);
    TMLog(@"Incoming dir pointing at '%@'.", [self getIncomingPath]);
}

- (void)stop
{
    TMLog(@"Stopping web server...");

    MHD_stop_daemon(m_pDaemon);
    m_sCurrentServerURL = @"No URL";

    TMLog(@"Web server is down.");
}


- (NSString *)getIncomingPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    if ( [paths count] > 0 )
    {
        NSString *dir = [paths objectAtIndex:0];

        // ...Documents/TapManiaIncoming
        dir = [dir stringByAppendingPathComponent:kWebServerIncomingPath];

        // Create the incoming dir if missing
        if ( ![[NSFileManager defaultManager] isReadableFileAtPath:dir] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];
        }

        return dir;
    }

    // Fallback path
    return @"/tmp/";
}

- (NSString *)getAddress
{
    NSString *address = @"Turn Wi-Fi ON in iOS settings";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if ( success == 0 )
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while ( temp_addr != NULL )
        {
            if ( temp_addr->ifa_addr->sa_family == AF_INET )
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ( [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] )
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
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

- (void)doneLoadingSong:(TMSong *)song withPath:(NSString *)path
{
    [self performSelectorOnMainThread:@selector(loadBannerForSong:)
                           withObject:song waitUntilDone:NO];
}

- (void)loadBannerForSong:(TMSong *)song
{
    NSString *songPath = [[SongsDirectoryCache sharedInstance] getSongsPath:song.m_iSongsPath];
    songPath = [songPath stringByAppendingPathComponent:song.m_sSongDirName];

    NSString *bannerFilePath = [songPath stringByAppendingPathComponent:song.m_sBannerFilePath];
    TMLog(@"Banner full path: '%@'", bannerFilePath);

    UIImage *img = [UIImage imageWithContentsOfFile:bannerFilePath];
    if ( img )
    {
        TMLog(@"Allocating banner texture on song cache sync...");
        song.bannerTexture = [[[Texture2D alloc] initWithImage:img columns:1 andRows:1] autorelease];
    }

    // also load cd title
    if ( song.m_sCDTitleFilePath != nil )
    {
        NSString *cdFilePath = [songPath stringByAppendingPathComponent:song.m_sCDTitleFilePath];

        img = [UIImage imageWithContentsOfFile:cdFilePath];
        if ( img )
        {
            TMLog(@"Allocating CD title texture on song cache sync...");
            song.cdTitleTexture = [[[Texture2D alloc] initWithImage:img columns:1 andRows:1] autorelease];
        }
    }
}

+ (WebServer *)sharedInstance
{
    @synchronized ( self )
    {
        if ( sharedWebServerDelegate == nil )
        {
            [[self alloc] init];
        }
    }
    return sharedWebServerDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ( self )
    {
        if ( sharedWebServerDelegate == nil )
        {
            sharedWebServerDelegate = [super allocWithZone:zone];
            return sharedWebServerDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}

@end
