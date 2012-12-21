//
//	$Id$
//  TapDBService.h
//	TapMania
//
//  Created by Alex Kremer on 8/18/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TapDBService : NSObject
{
    NSMutableData *receivedData;
    SEL curCallback;
    id curDelegate;
    NSURLConnection *con;
}

// Search TapDB against a string with paging support
- (void)searchByTitle:(NSString *)title forTotalItems:(int)cnt startingAt:(int)idx withCallback:(SEL)cb delegate:(id)del;

+ (TapDBService *)sharedInstance;

@end
