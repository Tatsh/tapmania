//
//  $Id$
//  BasicEffect.h
//  TapMania
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "TMEffectSupport.h"
#import "TMGameUIResponder.h"

@interface BasicEffect : NSObject <TMRenderable, TMLogicUpdater, TMEffectSupport, TMGameUIResponder>
{
    id m_idDecoratedObject;    // The object to decorate

    CGRect m_rShape;            // We maintain our own shape
    CGRect m_rOriginalShape;    // And save the original as well
}

- (id)initWithRenderable:(id)renderable;

@end
