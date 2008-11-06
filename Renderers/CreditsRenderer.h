//
//  CreditsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractMenuRenderer.h"
#import "Texture2D.h"

#define kCreditLines 14

@interface CreditsRenderer : AbstractMenuRenderer {
	Texture2D* texturesArray[kCreditLines];
	
	float currentPos;
}

@end
