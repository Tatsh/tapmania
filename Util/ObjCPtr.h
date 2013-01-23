//
//  $Id$
//  SharedPtr.h
//
//  Created by Alex Kremer on 5.10.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#pragma once
#ifndef __OBJC_PTR_H__
#define __OBJC_PTR_H__

#include <algorithm>
#import "LoggerUtil.h"

/**
 * This class implements a simple shared pointer for ObjC objects.
 * It will automatically call release when all references are lost.
 * Intended to use within C++ STL containers etc.
 */
template<typename T>
class ObjCPtr
{
private:
    struct Container
    {
        T *m_pObj;
        unsigned int m_uiRefCounter;

        Container() : m_uiRefCounter(0)
        {
        };
        Container(const Container& r)
        : m_pObj(r.m_pObj), m_uiRefCounter(r.m_uiRefCounter)
        {
        };
        ~Container()
        {
            TMLog(@"Call release on %@", m_pObj);
            [m_pObj release];
        };
    };

    Container *m_pSharedData;        // Shared

    void attach()
    {
        m_pSharedData->m_uiRefCounter++;
    };

    void detach()
    {
        m_pSharedData->m_uiRefCounter--;
        if ( m_pSharedData->m_uiRefCounter == 0 )
        {
            delete m_pSharedData;
        }
    };

public:
    ObjCPtr(T *p)
    {
        m_pSharedData = new Container();
        m_pSharedData->m_pObj = p;
        attach();
    };

    ObjCPtr(const ObjCPtr<T>& r)
    : m_pSharedData(r.m_pSharedData)
    {
        attach();
    };

    ~ObjCPtr()
    {
        detach();
    };

    ObjCPtr<T> operator = (const ObjCPtr<T>& r)
    {
        return ObjCPtr<T>(r);
    };

    T *const get()
    {
        return m_pSharedData->m_pObj;
    };
    T *const operator *()
    {
        return get();
    };

};

#if defined(__MACH__) || defined(__linux__) // Or just POSIX

#include <pthread.h>

#endif

namespace AtomicCounters
{

#if defined(__MACH__) || defined(__linux__) // Or just POSIX
    typedef unsigned counter;
#endif

    counter interlocked_increment(counter *c);

    counter interlocked_decrement(counter *c);

} // namespace AtomicCounters


template <typename T>
class SharedPtr;

template <typename T>
class WeakPtr
{
private:
    friend class SharedPtr<T>;

    // Shared data
    struct Counters
    {
        AtomicCounters::counter sc;
        AtomicCounters::counter wc;
    };

    static Counters forNulls;

    T *pObj;        // Managed by SharedPtr
    Counters *cnt;       // Managed by WeakPtr

    void attach()
    {
        AtomicCounters::interlocked_increment(&cnt->wc);
    }

    void detach()
    {
        if ( AtomicCounters::interlocked_decrement(&cnt->wc) == 0 )
        {
            delete cnt;
        }
    }

    // Used by SharedPtr only
    WeakPtr(T *p)
    : pObj(p)
    , cnt(new Counters)
    {
        cnt->sc = 0;
        cnt->wc = 0;
        attach();
    }

public:
    WeakPtr()
    : pObj(NULL)
    , cnt(&forNulls)
    {
        attach();
    }

    WeakPtr(const WeakPtr<T>& r)
    : pObj(r.pObj)
    , cnt(r.cnt)
    {
        attach();
    }

    void swap(WeakPtr<T>& other)
    {
        std::swap(pObj, other.pObj);
        std::swap(cnt, other.cnt);
    }

    WeakPtr<T>& operator = (const WeakPtr<T>& r)
    {
        WeakPtr<T> temp(r);
        swap(temp);
        return *this;
    }

    WeakPtr(SharedPtr<T>& p)
    : pObj(p.ptr.pObj)
    , cnt(p.ptr.cnt)
    {
        attach();
    }

    ~WeakPtr()
    {
        detach();
    }

    SharedPtr<T> lock()
    {
        AtomicCounters::counter c = AtomicCounters::interlocked_increment(&cnt->sc);
        SharedPtr<T> result;
        if ( c != 1 )
        {
            result = SharedPtr<T>(pObj, cnt);
        }
        AtomicCounters::interlocked_decrement(&cnt->sc);

        return result;
    }
};

template<typename T>
typename WeakPtr<T>::Counters WeakPtr<T>::forNulls = {1, 1};


template<typename T>
class SharedPtr
{
    friend class WeakPtr<T>;

private:
    WeakPtr<T> ptr;

    void attach()
    {
        AtomicCounters::interlocked_increment(&ptr.cnt->sc);
    }

    void detach()
    {
        if ( AtomicCounters::interlocked_decrement(&ptr.cnt->sc) == 0 )
        {
            delete ptr.pObj;
            ptr.pObj = 0;
        }
    }

    SharedPtr(T *p, typename WeakPtr<T>::Counters *c)
    {
        ptr.pObj = p;
        ptr.cnt = c;
        attach();
    }

public:
    SharedPtr()
    {
        attach();
    }

    explicit SharedPtr(T *p)
    : ptr(p)
    {
        attach();
    }

    SharedPtr(const SharedPtr<T>& r)
    : ptr(r.ptr)
    {
        attach();
    }

    ~SharedPtr()
    {
        detach();
    }

    bool isTheOne() const
    {
        return ptr.cnt->sc;
    }

    void swap(SharedPtr<T>& other)
    {
        ptr.swap(other.ptr);
    }

    SharedPtr<T>& operator = (const SharedPtr<T>& r)
    {
        SharedPtr<T> temp(r);
        swap(temp);
        return *this;
    }

    inline T *get() const
    {
        return ptr.pObj;
    }

    inline T *operator -> () const
    {
        return ptr.pObj;
    }

    inline operator bool () const
    {
        return ptr.pObj != 0;
    }

    inline bool operator < (const SharedPtr<T>& other) const
    {
        return ptr.pObj < other.ptr.pObj;
    }
};

template<typename T>
inline bool operator ==(const SharedPtr<T>& a, const SharedPtr<T>& b)
{
    return a.get() == b.get();
}

template<typename T>
inline bool operator ==(const SharedPtr<T>& a, T *b)
{
    return a.get() == b;
}

template<typename T>
inline bool operator ==(T *a, const SharedPtr<T>& b)
{
    return a == b.get();
}

#endif // once
