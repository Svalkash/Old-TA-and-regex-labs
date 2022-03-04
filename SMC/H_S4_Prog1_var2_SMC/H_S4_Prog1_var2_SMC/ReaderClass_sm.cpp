#include "pch.h"
//
// ex: set ro:
// DO NOT EDIT.
// generated by smc (http://smc.sourceforge.net/)
// from file : ReaderClass.sm
//

#include "ReaderClass.h"
#include "ReaderClass_sm.h"

using namespace statemap;

// Static class declarations.
RMap_Ftp RMap::Ftp("RMap::Ftp", 0);
RMap_Sl1 RMap::Sl1("RMap::Sl1", 1);
RMap_Sl2 RMap::Sl2("RMap::Sl2", 2);
RMap_Username RMap::Username("RMap::Username", 3);
RMap_Password RMap::Password("RMap::Password", 4);
RMap_Server RMap::Server("RMap::Server", 5);
RMap_Zone RMap::Zone("RMap::Zone", 6);
RMap_OK RMap::OK("RMap::OK", 7);
RMap_Error RMap::Error("RMap::Error", 8);

void ReaderClassState::At(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::Colon(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::Dig(ReaderClassContext& context, char c)
{
    Default(context);
}

void ReaderClassState::Dot(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::EOS(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::Letter(ReaderClassContext& context, char c)
{
    Default(context);
}

void ReaderClassState::Reset(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::Slash(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::Unknown(ReaderClassContext& context)
{
    Default(context);
}

void ReaderClassState::Default(ReaderClassContext& context)
{
    throw (
        TransitionUndefinedException(
            context.getState().getName(),
            context.getTransition()));

}

void RMap_Default::Dig(ReaderClassContext& context, char c)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::Letter(ReaderClassContext& context, char c)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::Colon(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::Slash(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::Dot(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::At(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::Unknown(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Error);
    context.getState().Entry(context);

}

void RMap_Default::EOS(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    context.getState().Exit(context);
    context.clearState();
    try
    {
        ctxt.fFail();
        context.setState(RMap::Error);
    }
    catch (...)
    {
        context.setState(RMap::Error);
        throw;
    }
    context.getState().Entry(context);

}

void RMap_Default::Reset(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Ftp);
    context.getState().Entry(context);

}

void RMap_Ftp::Colon(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkFtp())
    {
        context.getState().Exit(context);
        // No actions.
        context.setState(RMap::Sl1);
        context.getState().Entry(context);
    }
    else
    {
         RMap_Default::Colon(context);
    }

}

void RMap_Ftp::Letter(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkFL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.addFS(c);
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Letter(context, c);
    }

}

void RMap_Sl1::Slash(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Sl2);
    context.getState().Entry(context);

}

void RMap_Sl2::Slash(ReaderClassContext& context)
{

    context.getState().Exit(context);
    context.setState(RMap::Username);
    context.getState().Entry(context);

}

void RMap_Username::At(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkULN())
    {
        context.getState().Exit(context);
        // No actions.
        context.setState(RMap::Server);
        context.getState().Entry(context);
    }
    else
    {
         RMap_Default::At(context);
    }

}

void RMap_Username::Colon(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkULN())
    {
        context.getState().Exit(context);
        // No actions.
        context.setState(RMap::Password);
        context.getState().Entry(context);
    }
    else
    {
         RMap_Default::Colon(context);
    }

}

void RMap_Username::Dig(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkUL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.incUL();
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Dig(context, c);
    }

}

void RMap_Username::Letter(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkUL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.incUL();
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Letter(context, c);
    }

}

void RMap_Password::At(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkPLN())
    {
        context.getState().Exit(context);
        // No actions.
        context.setState(RMap::Server);
        context.getState().Entry(context);
    }
    else
    {
         RMap_Default::At(context);
    }

}

void RMap_Password::Dig(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkPL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.incPL();
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Dig(context, c);
    }

}

void RMap_Password::Letter(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkPL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.incPL();
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Letter(context, c);
    }

}

void RMap_Server::Dig(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkSL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.addSS(c);
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Dig(context, c);
    }

}

void RMap_Server::Dot(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkSLN())
    {
        context.getState().Exit(context);
        // No actions.
        context.setState(RMap::Zone);
        context.getState().Entry(context);
    }
    else
    {
         RMap_Default::Dot(context);
    }

}

void RMap_Server::Letter(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkSL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.addSS(c);
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Letter(context, c);
    }

}

void RMap_Zone::Dot(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkZLN())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.resetZL();
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Dot(context);
    }

}

void RMap_Zone::EOS(ReaderClassContext& context)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkZLN())
    {
        context.getState().Exit(context);
        context.clearState();
        try
        {
            ctxt.fSuccess();
            context.setState(RMap::OK);
        }
        catch (...)
        {
            context.setState(RMap::OK);
            throw;
        }
        context.getState().Entry(context);
    }
    else
    {
         RMap_Default::EOS(context);
    }

}

void RMap_Zone::Letter(ReaderClassContext& context, char c)
{
    ReaderClass& ctxt = context.getOwner();

    if (ctxt.checkZL())
    {
        ReaderClassState& endState = context.getState();

        context.clearState();
        try
        {
            ctxt.incZL();
            context.setState(endState);
        }
        catch (...)
        {
            context.setState(endState);
            throw;
        }
    }
    else
    {
         RMap_Default::Letter(context, c);
    }

}

//
// Local variables:
//  buffer-read-only: t
// End:
//
