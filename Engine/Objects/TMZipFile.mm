//
//  $Id$
//  TMZipFile.m
//  TapMania
//
//  Created by Alex Kremer on 28.07.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//
//	Code used in this class is partly taken from http://code.google.com/p/ziparchive project.
//

#import "TMZipFile.h"


@implementation TMZipFile

@synthesize m_sExtractedPath, m_bIsExtracted;

- (id)init
{
    NSException *ex = [NSException exceptionWithName:@"INVALID CONSTRUCTOR"
                                              reason:@"Use initWithPath: instead." userInfo:nil];
    @throw ex;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (!self)
        return nil;

    m_bIsExtracted = NO;
    m_sArchivePath = [NSString stringWithString:path];

    TMLog(@"Init zip handler with '%@'...", path);
    m_oUnzipFile = unzOpen([m_sArchivePath UTF8String]);

    if (m_oUnzipFile)
    {
        unz_global_info globalInfo = {0};
        if (unzGetGlobalInfo(m_oUnzipFile, &globalInfo) == UNZ_OK)
        {
            NSLog([NSString stringWithFormat:
                    @"There are %d entries in the smzip file", globalInfo.number_entry]);
        }

        return self;
    }

    return nil;
}

- (BOOL)extractTo:(NSString *)path
{
    m_sExtractedPath = path;

    BOOL success = YES;
    int ret = unzGoToFirstFile(m_oUnzipFile);

    unsigned char buffer[4096] = {0};
    NSFileManager *fman = [NSFileManager defaultManager];

    if (ret != UNZ_OK)
    {
        TMLog(@"Error: goToFirstFile failed.");
        return NO;
    }

    do
    {
        ret = unzOpenCurrentFile(m_oUnzipFile);
        if (ret != UNZ_OK)
        {
            TMLog(@"Error: openCurrentFile failed.");
            success = NO;
            break;
        }

        int read;
        unz_file_info fileInfo = {0};
        ret = unzGetCurrentFileInfo(m_oUnzipFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
        if (ret != UNZ_OK)
        {
            TMLog(@"Error: getting file info.");
            success = NO;
            unzCloseCurrentFile(m_oUnzipFile);
            break;
        }

        char *filename = (char *) malloc(fileInfo.size_filename + 1);
        unzGetCurrentFileInfo(m_oUnzipFile, &fileInfo, filename,
                fileInfo.size_filename + 1, NULL, 0, NULL, 0);
        filename[fileInfo.size_filename] = '\0';

        NSString *strPath = [NSString stringWithUTF8String:filename];
        BOOL isDirectory = NO;

        if (filename[fileInfo.size_filename - 1] == '/' || filename[fileInfo.size_filename - 1] == '\\')
            isDirectory = YES;

        free(filename);

        if ([strPath rangeOfCharacterFromSet:
                [NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location != NSNotFound)
        {
            strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        }

        NSString *fullPath = [path stringByAppendingPathComponent:strPath];

        if (isDirectory)
            [fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        else
            [fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]
            withIntermediateDirectories:YES attributes:nil error:nil];

        // write the file out
        FILE *fp = fopen((const char *) [fullPath UTF8String], "wb");
        while (fp)
        {
            read = unzReadCurrentFile(m_oUnzipFile, buffer, 4096);
            if (read > 0)
            {
                fwrite(buffer, read, 1, fp);
            } else if (read < 0)
            {
                TMLog(@"Failure during zip reading.");
                break;
            } else
                break;
        }

        if (fp)
        {
            fclose(fp);
        }

        unzCloseCurrentFile(m_oUnzipFile);
        ret = unzGoToNextFile(m_oUnzipFile);
    } while (ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE);

    m_bIsExtracted = success;
    return success;
}

- (void)dealloc
{
    unzClose(m_oUnzipFile);
    [super dealloc];
}

@end
