#pragma once

extern "Windows"

#define __unknwnbase_h__
#define __IUnknown_FWD_DEFINED__
#define __AsyncIUnknown_FWD_DEFINED__
#define __IClassFactory_FWD_DEFINED__
#define __IUnknown_INTERFACE_DEFINED__
type IUnknown as IUnknown_
type LPUNKNOWN as IUnknown ptr
extern IID_IUnknown as const GUID

type IUnknownVtbl
	QueryInterface as function(byval This as IUnknown ptr, byval riid as const IID const ptr, byval ppvObject as any ptr ptr) as HRESULT
	AddRef as function(byval This as IUnknown ptr) as ULONG
	Release as function(byval This as IUnknown ptr) as ULONG
end type

type IUnknown_
	lpVtbl as IUnknownVtbl ptr
end type

declare function IUnknown_QueryInterface_Proxy(byval This as IUnknown ptr, byval riid as const IID const ptr, byval ppvObject as any ptr ptr) as HRESULT
declare sub IUnknown_QueryInterface_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function IUnknown_AddRef_Proxy(byval This as IUnknown ptr) as ULONG
declare sub IUnknown_AddRef_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function IUnknown_Release_Proxy(byval This as IUnknown ptr) as ULONG
declare sub IUnknown_Release_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
#define __AsyncIUnknown_INTERFACE_DEFINED__
extern IID_AsyncIUnknown as const GUID
type AsyncIUnknown as AsyncIUnknown_

type AsyncIUnknownVtbl
	QueryInterface as function(byval This as AsyncIUnknown ptr, byval riid as const IID const ptr, byval ppvObject as any ptr ptr) as HRESULT
	AddRef as function(byval This as AsyncIUnknown ptr) as ULONG
	Release as function(byval This as AsyncIUnknown ptr) as ULONG
	Begin_QueryInterface as function(byval This as AsyncIUnknown ptr, byval riid as const IID const ptr) as HRESULT
	Finish_QueryInterface as function(byval This as AsyncIUnknown ptr, byval ppvObject as any ptr ptr) as HRESULT
	Begin_AddRef as function(byval This as AsyncIUnknown ptr) as HRESULT
	Finish_AddRef as function(byval This as AsyncIUnknown ptr) as ULONG
	Begin_Release as function(byval This as AsyncIUnknown ptr) as HRESULT
	Finish_Release as function(byval This as AsyncIUnknown ptr) as ULONG
end type

type AsyncIUnknown_
	lpVtbl as AsyncIUnknownVtbl ptr
end type

declare function AsyncIUnknown_Begin_QueryInterface_Proxy(byval This as AsyncIUnknown ptr, byval riid as const IID const ptr) as HRESULT
declare sub AsyncIUnknown_Begin_QueryInterface_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function AsyncIUnknown_Finish_QueryInterface_Proxy(byval This as AsyncIUnknown ptr, byval ppvObject as any ptr ptr) as HRESULT
declare sub AsyncIUnknown_Finish_QueryInterface_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function AsyncIUnknown_Begin_AddRef_Proxy(byval This as AsyncIUnknown ptr) as HRESULT
declare sub AsyncIUnknown_Begin_AddRef_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function AsyncIUnknown_Finish_AddRef_Proxy(byval This as AsyncIUnknown ptr) as ULONG
declare sub AsyncIUnknown_Finish_AddRef_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function AsyncIUnknown_Begin_Release_Proxy(byval This as AsyncIUnknown ptr) as HRESULT
declare sub AsyncIUnknown_Begin_Release_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function AsyncIUnknown_Finish_Release_Proxy(byval This as AsyncIUnknown ptr) as ULONG
declare sub AsyncIUnknown_Finish_Release_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
#define __IClassFactory_INTERFACE_DEFINED__
type IClassFactory as IClassFactory_
type LPCLASSFACTORY as IClassFactory ptr
extern IID_IClassFactory as const GUID

type IClassFactoryVtbl
	QueryInterface as function(byval This as IClassFactory ptr, byval riid as const IID const ptr, byval ppvObject as any ptr ptr) as HRESULT
	AddRef as function(byval This as IClassFactory ptr) as ULONG
	Release as function(byval This as IClassFactory ptr) as ULONG
	CreateInstance as function(byval This as IClassFactory ptr, byval pUnkOuter as IUnknown ptr, byval riid as const IID const ptr, byval ppvObject as any ptr ptr) as HRESULT
	LockServer as function(byval This as IClassFactory ptr, byval fLock as WINBOOL) as HRESULT
end type

type IClassFactory_
	lpVtbl as IClassFactoryVtbl ptr
end type

declare function IClassFactory_RemoteCreateInstance_Proxy(byval This as IClassFactory ptr, byval riid as const IID const ptr, byval ppvObject as IUnknown ptr ptr) as HRESULT
declare sub IClassFactory_RemoteCreateInstance_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function IClassFactory_RemoteLockServer_Proxy(byval This as IClassFactory ptr, byval fLock as WINBOOL) as HRESULT
declare sub IClassFactory_RemoteLockServer_Stub(byval This as IRpcStubBuffer ptr, byval pRpcChannelBuffer as IRpcChannelBuffer ptr, byval pRpcMessage as PRPC_MESSAGE, byval pdwStubPhase as DWORD ptr)
declare function IClassFactory_CreateInstance_Proxy(byval This as IClassFactory ptr, byval pUnkOuter as IUnknown ptr, byval riid as const IID const ptr, byval ppvObject as any ptr ptr) as HRESULT
declare function IClassFactory_CreateInstance_Stub(byval This as IClassFactory ptr, byval riid as const IID const ptr, byval ppvObject as IUnknown ptr ptr) as HRESULT
declare function IClassFactory_LockServer_Proxy(byval This as IClassFactory ptr, byval fLock as WINBOOL) as HRESULT
declare function IClassFactory_LockServer_Stub(byval This as IClassFactory ptr, byval fLock as WINBOOL) as HRESULT

end extern