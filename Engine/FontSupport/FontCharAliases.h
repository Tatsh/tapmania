//
//  $Id$
//  FontCharAliases.h
//  TapMania
//
//  Created by Alex Kremer on 31.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FontCharAliases : NSObject
{
    NSDictionary *m_pCharAliases;
}

// Replace alias with corresponding UTF code
- (BOOL)getChar:(NSString *)alias result:(unichar *)res;

- (void)replaceAll:(NSString *)text;

+ (FontCharAliases *)sharedInstance;

@end
