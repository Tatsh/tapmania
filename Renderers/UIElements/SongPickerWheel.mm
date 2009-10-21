//
//  SongPickerWheel.mm
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SongPickerWheel.h"
#import "SongPickerMenuItem.h"

#import "SongsDirectoryCache.h"
#import "ThemeManager.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "PhysicsUtil.h"
#import "Texture2D.h"

@interface SongPickerWheel (Private)
- (void) saveSwipeElement:(float)value withTime:(float)delta;
- (float) calculateSwipeVelocity;
- (void) clearSwipes;

- (void) rollWheel:(float) pixels;
- (float) findClosest;
@end


@implementation SongPickerWheel

- (id) init {
	// FIXME: metrics please!
	self = [super initWithShape:CGRectMake(160, 0, 320, 320)];
	if(!self) return nil;
	
	m_pWheelItems = new TMWheelItems();	
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	
	// Cache metrics
	mt_ItemSong =			RECT_METRIC(@"SongPickerMenu Wheel ItemSong");
	mt_ItemSongHalfHeight = mt_ItemSong.size.height/2;
	
	mt_HighlightCenter =	RECT_METRIC(@"SongPickerMenu Wheel Highlight");	
	mt_Highlight.size =		mt_HighlightCenter.size;
	
	mt_Highlight.origin.x =  mt_HighlightCenter.origin.x - mt_Highlight.size.width/2;
	mt_Highlight.origin.y =	 mt_HighlightCenter.origin.y - mt_Highlight.size.height/2;
	mt_HighlightHalfHeight = mt_Highlight.size.height/2;
	
	// Cache graphics
	t_Highlight = TEXTURE(@"SongPicker Wheel Highlight");
	
	m_fVelocity = 0.0f;	
	[self clearSwipes];
	
	float curYOffset = 0.0f;
	int i,j;
	for(i=j=0; i<kNumWheelItems; i++) {		
		if(j == [songList count]) {
			j = 0;
		}
		
		TMSong *song = [songList objectAtIndex:j++];				
		m_pWheelItems->push_back([[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, curYOffset)]);
		
		curYOffset += mt_ItemSong.size.height;
	}	
	
	return self;
}

- (void) dealloc {	
	// Explicitly deallocate memory
	// TODO: move to objcPtr
	for(int i = 0; i < m_pWheelItems->size(); i++) {
		[m_pWheelItems->at(i) release];
	}	
	
	[super dealloc];
}	


/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	int i;
	for(i=0; i<m_pWheelItems->size(); i++){
		[(SongPickerMenuItem*)(m_pWheelItems->at(i)) render:fDelta];
	}
	
	// Highlight selection and draw top element
	glEnable(GL_BLEND);
	[t_Highlight drawAtPoint:mt_HighlightCenter.origin];
	glDisable(GL_BLEND);
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {	
	[super update:fDelta];
		
	// Do all scroll related stuff
	if(m_fVelocity != 0.0f) {
		
		float frictionForce = kWheelStaticFriction * (-kWheelMass*kGravity);
		float frictionDelta = fDelta * frictionForce;
		
		if(fabsf(m_fVelocity) < frictionDelta) {
			m_fVelocity = 0.0f;
			
			float closestY = [self findClosest];
			if(closestY != 0.0f) {
				[self rollWheel: -closestY];

				TMLog(@"Double tapped the wheel select item!");
				if(m_bEnabled && m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler]) {
					[m_idChangedDelegate performSelector:m_oChangedActionHandler];
				}				
			}
			
			return;
		} else {
			
			if(m_fVelocity < 0.0f) {
				m_fVelocity += frictionDelta;
			} else {
				m_fVelocity -= frictionDelta;
			}
			
			[self rollWheel: fDelta * m_fVelocity];
		}
	}
}

/* TMGameUIResponder methods */
- (BOOL) tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if(!m_bEnabled)
		return NO;
	
	switch (touches.size()) {
		case 1:
		{
			TMTouch touch = touches.at(0);
			
			// FIXME!
			if(touch.y() < 400) {
				m_fLastSwipeY = touch.y();
				m_fVelocity = 0.0f;	// Stop scrollin if touching the screen
				m_dLastSwipeTime = touch.timestamp();
			}
			
			break;
		}
	}
	
	return YES;
}

- (BOOL) tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if(!m_bEnabled)
		return NO;
	
	switch (touches.size()) {
		case 1:
		{
			TMTouch touch = touches.at(0);
			
			if(touch.y() < 400) {
				float yDelta = touch.y()-m_fLastSwipeY;
				
				[self saveSwipeElement:yDelta withTime:touch.timestamp()-m_dLastSwipeTime];
				m_fLastSwipeY = touch.y();
				m_dLastSwipeTime = touch.timestamp();
				
				[self rollWheel:yDelta];	// Roll the wheel				
			} else {
				[self clearSwipes];
			}
			
			break;
		}
	}
	
	return YES;
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if(!m_bEnabled)
		return NO;
	
	if(touches.size() == 1){		
		TMTouch touch = touches.at(0);
		CGPoint point = CGPointMake(touch.x(), touch.y());

		
		// Should start song?
		if(touch.tapCount() > 1 && CGRectContainsPoint(mt_Highlight, point)) {
			TMLog(@"Double tapped the wheel select item!");
			if(m_bEnabled && m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {			
				[self disable];	// Disable the song list as we already picked a song to start
				[m_idActionDelegate performSelector:m_oActionHandler];
			}
			
			return YES;
		}
		
		// Now the fun part - swipes
		if(point.y < 400) {
			m_fVelocity = [self calculateSwipeVelocity];
			if(m_fVelocity == 0.0f) m_fVelocity = 0.01f;	// Make it jump to closest anyway
		}
		
		[self clearSwipes];
	}
	
	return YES;
}

- (void) clearSwipes {	
	int i;
	for(i=0; i<kNumSwipePositions; ++i) {
		m_fSwipeBuffer[i][0] = 0.0f;
		m_fSwipeBuffer[i][1] = 0.0f;
	}
	
	m_nCurrentSwipePosition = 0;
	m_fLastSwipeY = 0.0f;
}	

- (float) calculateSwipeVelocity {
	int i;
	float totalVelocity = 0.0f;	
	float totalTime = 0.0f;
	
	for(i=0; i<kNumSwipePositions; ++i) {
		totalTime += m_fSwipeBuffer[i][0];
		totalVelocity += m_fSwipeBuffer[i][1];
	}
	
	// Get average
	totalTime /= kNumSwipePositions;
	totalVelocity /= kNumSwipePositions;
	
	// v = d/t
	if(totalTime > 0.0f) {
		totalVelocity /= totalTime;
	}
	
	TMLog(@"Got swipe velocity: %f from delta time %f", totalVelocity, totalTime);
	
	return totalVelocity;
}

- (void) saveSwipeElement:(float)value withTime:(float)delta {
	if(m_nCurrentSwipePosition == kNumSwipePositions-1) {
		m_nCurrentSwipePosition = 0;
	}
	
	m_fSwipeBuffer[m_nCurrentSwipePosition][0] = delta;
	m_fSwipeBuffer[m_nCurrentSwipePosition][1] = value;
	
	++m_nCurrentSwipePosition;
}

- (void) rollWheel:(float) pixels {
	int i;
	for(i=0; i<m_pWheelItems->size(); ++i) {
		SongPickerMenuItem* item = (SongPickerMenuItem*)m_pWheelItems->at(i);		
		[item updateYPosition:pixels];
	}
	
	// Check last object
	SongPickerMenuItem* item = (SongPickerMenuItem*)m_pWheelItems->at(0);
	float lastWheelItemY = [item getPosition].y;
	
	do {
		
		if (lastWheelItemY <= -mt_ItemSongHalfHeight ) {		
			SongPickerMenuItem* itemToRemove = (SongPickerMenuItem*)m_pWheelItems->at(0);
			m_pWheelItems->pop_front();
			
			// Now we must add one on top of the wheel (last element of the array)
			float firstWheelItemY = lastWheelItemY + mt_ItemSong.size.height*kNumWheelItems;
			
			// Get current song on top of the wheel
			SongPickerMenuItem* lastItem = (SongPickerMenuItem*)*(m_pWheelItems->rbegin());
			TMSong* searchSong = [lastItem song];				
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongPrevFrom:searchSong];				
			
			[itemToRemove updateWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, firstWheelItemY)];
			m_pWheelItems->push_back(itemToRemove);			
			
		} else if(lastWheelItemY >= mt_ItemSongHalfHeight) {		
			// Explicitly deallocate the object. autorelease didn't work for some reason.
			SongPickerMenuItem* itemToRemove = (SongPickerMenuItem*)*(m_pWheelItems->rbegin());
			m_pWheelItems->pop_back();
			
			// Now we must add one on the bottom of the wheel (first element of the array)
			float newLastWheelItemY = lastWheelItemY - mt_ItemSong.size.height;
			
			// Get current song on bottom of the wheel
			SongPickerMenuItem* firstItem = (SongPickerMenuItem*)m_pWheelItems->at(0);
			TMSong* searchSong = [firstItem song];				
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongNextTo:searchSong];				
			
			[itemToRemove updateWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, newLastWheelItemY)];
			m_pWheelItems->push_front(itemToRemove);
		}
		
		// get possibly new first item
		SongPickerMenuItem* firstItem = (SongPickerMenuItem*)m_pWheelItems->at(0);
		lastWheelItemY = [firstItem getPosition].y;
		
	} while (lastWheelItemY < -mt_ItemSongHalfHeight || lastWheelItemY > mt_ItemSongHalfHeight);
}

- (float) findClosest {
	float tmp = MAXFLOAT;	// Holds current minimum
	int i;
	
	for(i=kSelectedWheelItemId-2; i<kSelectedWheelItemId+2; ++i) {
		float t = [(SongPickerMenuItem*)(m_pWheelItems->at(i)) getPosition].y - mt_HighlightCenter.origin.y;
		if(fabsf(t) < fabsf(tmp)) { tmp = t; }
	}
	
	return tmp;
}

- (SongPickerMenuItem*) getSelected {
	return m_pWheelItems->at(kSelectedWheelItemId);
}

@end
