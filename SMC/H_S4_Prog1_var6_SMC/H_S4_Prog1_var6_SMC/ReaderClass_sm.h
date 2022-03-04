//
// ex: set ro:
// DO NOT EDIT.
// generated by smc (http://smc.sourceforge.net/)
// from file : ReaderClass.sm
//

#ifndef READERCLASS_SM_H
#define READERCLASS_SM_H


#define SMC_USES_IOSTREAMS

#include "statemap.h"

// Forward declarations.
class RMap;
class RMap_Ftp;
class RMap_Sl1;
class RMap_Sl2;
class RMap_Server;
class RMap_DomZone;
class RMap_OK;
class RMap_Error;
class RMap_Default;
class ReaderClassState;
class ReaderClassContext;
class ReaderClass;

class ReaderClassState :
    public statemap::State
{
public:

    ReaderClassState(const char * const name, const int stateId)
    : statemap::State(name, stateId)
    {};

    virtual void Entry(ReaderClassContext&) {};
    virtual void Exit(ReaderClassContext&) {};

    virtual void Colon(ReaderClassContext& context);
    virtual void Dig(ReaderClassContext& context, char c);
    virtual void Dot(ReaderClassContext& context);
    virtual void EOS(ReaderClassContext& context);
    virtual void Letter(ReaderClassContext& context, char c);
    virtual void Reset(ReaderClassContext& context);
    virtual void Slash(ReaderClassContext& context);
    virtual void Unknown(ReaderClassContext& context);

protected:

    virtual void Default(ReaderClassContext& context);
};

class RMap
{
public:

    static RMap_Ftp Ftp;
    static RMap_Sl1 Sl1;
    static RMap_Sl2 Sl2;
    static RMap_Server Server;
    static RMap_DomZone DomZone;
    static RMap_OK OK;
    static RMap_Error Error;
};

class RMap_Default :
    public ReaderClassState
{
public:

    RMap_Default(const char * const name, const int stateId)
    : ReaderClassState(name, stateId)
    {};

    virtual void Dig(ReaderClassContext& context, char c);
    virtual void Letter(ReaderClassContext& context, char c);
    virtual void Colon(ReaderClassContext& context);
    virtual void Slash(ReaderClassContext& context);
    virtual void Dot(ReaderClassContext& context);
    virtual void Unknown(ReaderClassContext& context);
    virtual void EOS(ReaderClassContext& context);
    virtual void Reset(ReaderClassContext& context);
};

class RMap_Ftp :
    public RMap_Default
{
public:
    RMap_Ftp(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

    virtual void Colon(ReaderClassContext& context);
    virtual void Letter(ReaderClassContext& context, char c);
};

class RMap_Sl1 :
    public RMap_Default
{
public:
    RMap_Sl1(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

    virtual void Slash(ReaderClassContext& context);
};

class RMap_Sl2 :
    public RMap_Default
{
public:
    RMap_Sl2(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

    virtual void Slash(ReaderClassContext& context);
};

class RMap_Server :
    public RMap_Default
{
public:
    RMap_Server(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

    virtual void Dig(ReaderClassContext& context, char c);
    virtual void Dot(ReaderClassContext& context);
    virtual void Letter(ReaderClassContext& context, char c);
};

class RMap_DomZone :
    public RMap_Default
{
public:
    RMap_DomZone(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

    virtual void Dig(ReaderClassContext& context, char c);
    virtual void Dot(ReaderClassContext& context);
    virtual void EOS(ReaderClassContext& context);
    virtual void Letter(ReaderClassContext& context, char c);
};

class RMap_OK :
    public RMap_Default
{
public:
    RMap_OK(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

};

class RMap_Error :
    public RMap_Default
{
public:
    RMap_Error(const char * const name, const int stateId)
    : RMap_Default(name, stateId)
    {};

};

class ReaderClassContext :
    public statemap::FSMContext
{
public:

    explicit ReaderClassContext(ReaderClass& owner)
    : FSMContext(RMap::Ftp),
      _owner(owner)
    {};

    ReaderClassContext(ReaderClass& owner, const statemap::State& state)
    : FSMContext(state),
      _owner(owner)
    {};

    virtual void enterStartState()
    {
        getState().Entry(*this);
        return;
    }

    inline ReaderClass& getOwner()
    {
        return (_owner);
    };

    inline ReaderClassState& getState()
    {
        if (_state == NULL)
        {
            throw statemap::StateUndefinedException();
        }

        return dynamic_cast<ReaderClassState&>(*_state);
    };

    inline void Colon()
    {
        getState().Colon(*this);
    };

    inline void Dig(char c)
    {
        getState().Dig(*this, c);
    };

    inline void Dot()
    {
        getState().Dot(*this);
    };

    inline void EOS()
    {
        getState().EOS(*this);
    };

    inline void Letter(char c)
    {
        getState().Letter(*this, c);
    };

    inline void Reset()
    {
        getState().Reset(*this);
    };

    inline void Slash()
    {
        getState().Slash(*this);
    };

    inline void Unknown()
    {
        getState().Unknown(*this);
    };

private:
    ReaderClass& _owner;
};


#endif // READERCLASS_SM_H

//
// Local variables:
//  buffer-read-only: t
// End:
//