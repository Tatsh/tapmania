//
//  $Id$
//  TMZipFile.h
//  TapMania
//
//  Created by Alex Kremer on 28.07.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//
//  This class uses minizip to extract a SMZip/Zip (PK-Zip) file.
//

#import <Foundation/Foundation.h>

#include <minizip/unzip.h>

@interface TMZipFile : NSObject
{
    NSString *m_sArchivePath;
    NSString *m_sExtractedPath;

    unzFile m_oUnzipFile;

    BOOL m_bIsExtracted;
}

@property(assign, readonly, getter=isExtracted) BOOL m_bIsExtracted;
@property(retain, readonly, getter=extractedPath) NSString *m_sExtractedPath;

- (id)initWithPath:(NSString *)path;

- (BOOL)extractTo:(NSString *)path;

@end
