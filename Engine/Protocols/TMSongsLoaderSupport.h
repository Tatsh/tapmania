//
//  $Id$
//  TMSongsLoaderSupport.h
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

@class TMSong;

@protocol TMSongsLoaderSupport

- (void)startLoadingSong:(NSString *)path;

- (void)doneLoadingSong:(TMSong*)song withPath:(NSString *)path;

- (void)errorLoadingSong:(NSString *)path withReason:(NSString *)message;

- (void)songLoaderError:(NSString *)message;

- (void)songLoaderFinished;

@end
