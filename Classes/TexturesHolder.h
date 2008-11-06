//
//  TexturesHolder.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"

typedef enum {
	kTexture_Title = 0,
	kTexture_Background,
	kTexture_LeftArrow,
	kTexture_RightArrow,
	kTexture_UpArrow,
	kTexture_DownArrow,
	kTexture_Base,
	kNumTextures
} TMTexture;

@interface TexturesHolder : NSObject {
	Texture2D*				_textures[kNumTextures];
}

- (Texture2D*) getTexture:(TMTexture) textureId;

+ (TexturesHolder *)sharedInstance;

@end
