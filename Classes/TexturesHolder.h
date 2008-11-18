//
//  TexturesHolder.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "TMNote.h"

typedef enum {
	kTexture_LeftArrow_4 = 0,
	kTexture_RightArrow_4,
	kTexture_UpArrow_4,
	kTexture_DownArrow_4,
	
	kTexture_LeftArrow_8,
	kTexture_RightArrow_8,
	kTexture_UpArrow_8,
	kTexture_DownArrow_8,

	kTexture_LeftArrow_12,
	kTexture_RightArrow_12,
	kTexture_UpArrow_12,
	kTexture_DownArrow_12,	
	
	kTexture_LeftArrow_16,
	kTexture_RightArrow_16,
	kTexture_UpArrow_16,
	kTexture_DownArrow_16,
	
	kTexture_LeftArrow_24,
	kTexture_RightArrow_24,
	kTexture_UpArrow_24,
	kTexture_DownArrow_24,
	
	kTexture_LeftArrow_32,
	kTexture_RightArrow_32,
	kTexture_UpArrow_32,
	kTexture_DownArrow_32,	
	
	kTexture_LeftArrow_48,
	kTexture_RightArrow_48,
	kTexture_UpArrow_48,
	kTexture_DownArrow_48,	
	
	kTexture_LeftArrow_64,
	kTexture_RightArrow_64,
	kTexture_UpArrow_64,
	kTexture_DownArrow_64,
	
	kTexture_LeftArrow_192,
	kTexture_RightArrow_192,
	kTexture_UpArrow_192,
	kTexture_DownArrow_192,
	
	kTexture_HoldBody,
	kTexture_HoldBottom,
	
	kTexture_Base,
	kTexture_BaseDark,
	
	kTexture_Title,
	kTexture_Background,
	
	kNumTextures
} TMTexture;

@interface TexturesHolder : NSObject {
	Texture2D*				_textures[kNumTextures];
}

- (Texture2D*) getArrowTextureForType:(TMBeatType)type andDir:(TMNoteDirection) dir;
- (Texture2D*) getTexture:(TMTexture) textureId;

+ (TexturesHolder *)sharedInstance;

@end
