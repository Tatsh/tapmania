//
//	$Id$
//  TapDBService.h
//	TapMania
//
//  Created by Alex Kremer on 8/18/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "TapDBService.h"
#import "CJSONDeserializer.h" 

static TapDBService *sharedTapDBServiceDelegate = nil;
static NSString *tapDBHost = @"http://127.0.0.1/tapdb";

@interface TapDBService (Private)
- (void)request:(NSString *)url withCallback:(SEL)cb delegate:(id)del;
@end


@implementation TapDBService

- (void)request:(NSString *)url withCallback:(SEL)cb delegate:(id)del
{
    NSString *uri = [tapDBHost stringByAppendingString:url];
    TMLog(@"Request to: '%@'", uri);

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:5.0];

    receivedData = [[NSMutableData alloc] initWithLength:0];

    curCallback = cb;
    curDelegate = del;
    con = [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    TMLog(@"Appending...");
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TMLog(@"Going to parse json...");
    TMLog(@"Data: %d bytes", [receivedData length]);

    NSError *err = nil;
    NSArray *output = [[CJSONDeserializer deserializer] deserializeAsArray:receivedData error:&err];

    [curDelegate performSelectorOnMainThread:curCallback withObject:[output retain] waitUntilDone:YES];
    [receivedData release];
    [output release];
}


- (void)searchByTitle:(NSString *)title forTotalItems:(int)cnt startingAt:(int)idx withCallback:(SEL)cb delegate:(id)del
{
    NSString *uri = [NSString stringWithFormat:@"/getItems/%d/%d/%@", idx, cnt, title];
    [self request:uri withCallback:cb delegate:del];
}


#pragma mark Singleton stuff

+ (TapDBService *)sharedInstance
{
    @synchronized (self)
    {
        if (sharedTapDBServiceDelegate == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedTapDBServiceDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (sharedTapDBServiceDelegate == nil)
        {
            sharedTapDBServiceDelegate = [super allocWithZone:zone];
            return sharedTapDBServiceDelegate;
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
