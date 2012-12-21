//
//  $Id$
//  WebServer.h
//  TapMania
//
//  Created by Alex Kremer on 7/22/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "platform.h"
#include "microhttpd.h"

#define kWebServerIncomingPath    @"TapManiaIncoming"

struct connection_info_struct
{
    int connectiontype;
    struct MHD_PostProcessor *postprocessor;

    bool file_uploaded;
    char *file_path;
    FILE *fp;

    const char *answerstring;
    int answercode;
};


@protocol WebServerDelegate

@optional
- (void)newSongUploaded:(NSString *)zipPath;    // Notification about new zip file available for processing

@end


@interface WebServer : NSObject
{
    struct MHD_Daemon *m_pDaemon;
    NSString *m_sCurrentServerURL;    // something like http://192.168.0.101:9002/ or error string
}

@property(retain, nonatomic, readonly) NSString *m_sCurrentServerURL;

// Server control methods
- (void)start;

- (void)stop;

+ (WebServer *)sharedInstance;

@end
