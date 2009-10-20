/*
 *  TMTouch.h
 *  TapMania
 *
 *  Created by Alex Kremer on 20.10.09.
 *  Copyright 2009 Godexsoft. All rights reserved.
 *
 */

class TMTouch {
private:
	float			m_X, m_Y;
	unsigned int	m_TapCount;
	float			m_Timestamp;
	
public:
	TMTouch(float x, float y, unsigned int tapCount, float timestamp) 
	: m_X(x) , m_Y(y), m_TapCount(tapCount), m_Timestamp(timestamp) {};
	
	inline const float x() const { return m_X; };
	inline const float y() const { return m_Y; };
	
	inline const unsigned int tapCount() const { return m_TapCount; };
	inline const float timestamp() const { return m_Timestamp; };
};

#include <vector>
typedef std::vector<TMTouch> TMTouchesVec;
