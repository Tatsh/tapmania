//
//  MainMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputEngine.h"
#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

#import "MenuItem.h"

enum {
	kMainMenuItem_Play = 0,
	kMainMenuItem_Options,
	kMainMenuItem_Credits,
	kNumMainMenuItems
};

@interface MainMenuRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	int selectedMenu;
	MenuItem* mainMenuItems[kNumMainMenuItems];
}

@end
