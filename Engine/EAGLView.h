//
//  $Id$
//  EAGLView.h
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class EAGLView;

@interface EAGLView : UIView
{
@private
    NSString *_format;
    GLuint _depthFormat;
    BOOL _autoresize;
    EAGLContext *_context;
    GLuint _framebuffer;
    GLuint _renderbuffer;
    GLuint _depthBuffer;
    CGSize _size;
    BOOL _hasBeenCurrent;
}

@property(readonly) GLuint framebuffer;
@property(readonly) NSString *pixelFormat;
@property(readonly) GLuint depthFormat;
@property(readonly) EAGLContext *context;

@property BOOL autoresizesSurface; //NO by default - Set to YES to have the EAGL surface automatically resized when the view bounds change, otherwise the EAGL surface contents is rendered scaled
@property(readonly, nonatomic) CGSize surfaceSize;

- (void)setCurrentContext;

- (BOOL)isCurrentContext;

- (void)clearCurrentContext;

- (void)swapBuffers; //This also checks the current OpenGL error and logs an error if needed

- (CGPoint)convertPointFromViewToSurface:(CGPoint)point;

- (CGPoint)convertPointFromViewToOpenGL:(CGPoint)point;

- (CGRect)convertRectFromViewToSurface:(CGRect)rect;

@end
