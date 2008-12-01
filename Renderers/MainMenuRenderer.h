//
//  MainMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractMenuRenderer.h"
#import "TMLogicUpdater.h"

enum {
	kMainMenuItem_Play = 0,
	kMainMenuItem_Options,
	kMainMenuItem_Credits,
	kNumMainMenuItems
};

@interface MainMenuRenderer : AbstractMenuRenderer <TMLogicUpdater> {
	int selectedMenu;
}

@end
