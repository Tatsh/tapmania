//
//  $Id$
//  SharedPtr.h
//
//  Created by Alex Kremer on 5.10.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

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
        if (m_pSharedData->m_uiRefCounter == 0)
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