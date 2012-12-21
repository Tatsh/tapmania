/*
 *  $Id$
 *  TMTouch.h
 *  TapMania
 *
 *  Created by Alex Kremer on 20.10.09.
 *  Copyright 2009 Godexsoft. All rights reserved.
 *
 */

class TMTouch
{
private:
    float m_X, m_Y;
    float m_prevX, m_prevY;
    unsigned int m_TapCount;
    float m_Timestamp;

public:
    TMTouch(float x, float y, float px, float py, unsigned int tapCount, float timestamp)
    : m_X(x)
    , m_Y(y)
    , m_prevX(px)
    , m_prevY(py)
    , m_TapCount(tapCount)
    , m_Timestamp(timestamp)
    {
    };

    inline const float x() const
    {
        return m_X;
    };
    inline const float y() const
    {
        return m_Y;
    };

    inline const float px() const
    {
        return m_prevX;
    };
    inline const float py() const
    {
        return m_prevY;
    };

    inline const unsigned int tapCount() const
    {
        return m_TapCount;
    };
    inline const float timestamp() const
    {
        return m_Timestamp;
    };
};

#include <vector>

typedef std::vector<TMTouch> TMTouchesVec;
