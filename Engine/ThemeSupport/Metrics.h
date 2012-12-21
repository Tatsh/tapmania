//
//  $Id$
//  Metrics.h
//  TapMania
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

@interface Metrics : NSObject
{
}

@property(nonatomic, retain) NSMutableDictionary *impl_;

- (void)overrideWith:(Metrics *)metrics;

- (id)initWithContentsOfFile:(NSString *)fp;

- (id)objectForKey:(id)key;

@end
