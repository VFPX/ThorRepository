### mDot
#### mDot on parameters
There is no need to put mdot in front of a parameter declared with @. This must be a variable.
Option _No MDots after @_ added to remove.
#### mDot on array / method
- Option _No MDots before method or array_ added, to allow to rempove mdot on array and methods
#### Note
Those options are only active if _Use MDots only where required_ is set.
Due to the design of the interface, the options will not be disabled, and no Tooltext is provided.

#### This changes.
- ThorRepository
   - thor\thor\tools\thor_tool_repository_addmdots.prg
   - Thor\Thor\Tools\Procs\Thor_Proc_AddMDotsSingleProc.prg

#### Todo
- Odd constructions like
  ````
  bla;
    = 1
  ````
  create **m.bla**
- Elemination of superfluous mdot on *NameList* of STORE
- Elemination of superfluous mdot after RELEASE?
- Elemination of superfluous mdot on ARRAY? -> both notifications
- Does not ignore variables removed with _RELEASE_
- Problems with dangerous use of mdot for vars near INSERT FROM MEMVAR, GATHER and SCATTER. Might create havoc.
  - In SELECT SQL, m.mu left of AS might be valid, right of AS isn't
  - FROM m.bla will fail
  - at least warnings must be issued, because result is syntactical fine.
    ````
    Local mu,bla
    
    ?m.mu
    
    Store 1 To m.mu
    m.mu.x()
    ?m.mu(1)
    
    Select;
    	m.mu As m.mu;
    	From m.bla
    ````

