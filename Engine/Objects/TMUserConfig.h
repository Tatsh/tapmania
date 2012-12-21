//
//  $Id$
//  TMUserConfig.h
//  TapMania
//
//  Created by Alex Kremer on 13.05.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TMUserConfig : NSObject
{
    NSMutableDictionary *m_pConfigDict;        // The real dictionary
}

- (id)initWithContentsOfFile:(NSString *)configPath;

// Check config
- (int)check;

@end
