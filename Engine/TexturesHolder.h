//
//  TexturesHolder.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "TMAnimatable.h"
#import "TMFramedTexture.h"
#import "TapNote.h"
#import "Receptor.h"

typedef enum {
	// Gameplay stuff
	kTexture_TapNote = 0,
	kTexture_GoReceptor,
	
	kTexture_HoldBodyActive,
	kTexture_HoldBottomCapActive,
	kTexture_HoldBodyInactive,
	kTexture_HoldBottomCapInactive,

	// Main menu stuff
	kTexture_Background,
	kTexture_MainMenuButtonPlay,
	kTexture_MainMenuButtonOptions,
	kTexture_MainMenuButtonCredits,
	
	// Song selection (wheel) screen
	kTexture_SongSelectionBackground,
	kTexture_SongSelectionWheelItem,
	kTexture_SongSelectionWheelItemSelected,
	kTexture_SongSelectionWheelLoadingAvatar,
	
	// O.o
	kNumTextures
} TMTexture;

@interface TexturesHolder : NSObject {
	Texture2D*				_textures[kNumTextures];
}

- (Texture2D*) getTexture:(TMTexture) textureId;

+ (TexturesHolder *)sharedInstance;

@end
