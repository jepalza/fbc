''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2005 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


'' runtime-lib helpers, for when simple calls can't be done, 'cause args for diff types, etc
''
'' chng: oct/2004 written [v1ctor]

defint a-z
option explicit

'$include: 'inc\fb.bi'
'$include: 'inc\fbint.bi'
'$include: 'inc\rtl.bi'
'$include: 'inc\ir.bi'
'$include: 'inc\ast.bi'
'$include: 'inc\emit.bi'

type RTLCTX
	datainited		as integer
	lastlabel		as integer
    labelcnt 		as integer
end type


''globals
	dim shared ctx as RTLCTX

	redim shared ifuncTB( 0 ) as integer

'' name,alias,typ,mode, args, [arg typ,mode,optional[,value]]*args (same order as FB.IFUNC)
ifuncdata:

'' fb_StrConcat ( dst as string, _
''				  str1 as any, byval str1len as integer, _
''				  str2 as any, byval str2len as integer ) as string
data "fb_StrConcat","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 5, _
						FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_StrCompare ( str1 as any, byval str1len as integer, _
''				   str2 as any, byval str2len as integer ) as integer
'' returns: 0= equal; -1=str1 < str2; 1=str1 > str2
data "fb_StrCompare","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 4, _
						 FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_StrAssign ( dst as any, byval dst_len as integer, _
'' 				  src as any, byval src_len as integer ) as void
data "fb_StrAssign","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 4, _
						FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_StrDelete ( str as string ) as void
data "fb_StrDelete","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_StrAllocTempResult ( str as string ) as string
data "fb_StrAllocTempResult","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_StrAllocTempDesc ( str as any, byval strlen as integer ) as string
data "fb_StrAllocTempDesc","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 2, _
						FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_ArrayRedim CDECL ( array() as ANY, byval elementlen as integer, _
''					     byval isvarlen as integer, byval preserve as integer, _
''						 byval dimensions as integer, ... ) as void
data "fb_ArrayRedim","", FB.SYMBTYPE.VOID,FB.FUNCMODE.CDECL, 6, _
						 FB.SYMBTYPE.VOID,FB.ARGMODE.BYDESC, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 -1,-1, FALSE
'' fb_ArrayErase ( array() as ANY, byval isvarlen as integer ) as void
data "fb_ArrayErase","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						 FB.SYMBTYPE.VOID,FB.ARGMODE.BYDESC, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_ArrayLBound ( array() as ANY, byval dimension as integer ) as integer
data "fb_ArrayLBound","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.VOID,FB.ARGMODE.BYDESC, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_ArrayUBound ( array() as ANY, byval dimension as integer ) as integer
data "fb_ArrayUBound","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.VOID,FB.ARGMODE.BYDESC, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_ArraySetDesc CDECL ( array() as ANY, arraydata as ANY, byval elementlen as integer, _
''						   byval dimensions as integer, ... ) as void
data "fb_ArraySetDesc","", FB.SYMBTYPE.VOID,FB.FUNCMODE.CDECL, 5, _
						   FB.SYMBTYPE.VOID,FB.ARGMODE.BYDESC, FALSE, _
						   FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						   -1,-1, FALSE
'' fb_ArrayStrErase ( array() as any ) as void
data "fb_ArrayStrErase","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
							FB.SYMBTYPE.VOID,FB.ARGMODE.BYDESC, FALSE

''
'' fb_IntToStr ( byval number as integer ) as string
data "fb_IntToStr","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FloatToStr ( byval number as single ) as string
data "fb_FloatToStr","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYVAL, FALSE
'' fb_DoubleToStr ( byval number as double ) as string
data "fb_DoubleToStr","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE

'' fb_StrInstr ( byval start as integer, srcstr as string, pattern as string ) as integer
data "fb_StrInstr","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_StrMid ( str as string, byval start as integer, byval len as integer ) as string
data "fb_StrMid","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 3, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_StrAssignMid ( dst as string, byval start as integer, byval len as integer, src as string ) as void
data "fb_StrAssignMid","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 4, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_StrFill1 ( byval cnt as integer, byval char as integer ) as string
data "fb_StrFill1","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 2, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_StrFill2 ( byval cnt as integer, str as string ) as string
data "fb_StrFill2","", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 2, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_StrLen ( str as any, byval strlen as integer ) as integer
data "fb_StrLen","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
					 FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

''
'' fb_END ( byval errlevel as integer ) as void
data "fb_End","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
				  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

''
'' fb_DataRestore ( byval labeladdrs as void ptr ) as void
data "fb_DataRestore","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE
'' fb_DataReadStr ( dst as any, byval dst_size as integer ) as void
data "fb_DataReadStr","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_DataReadByte ( dst as byte ) as void
data "fb_DataReadByte","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						   FB.SYMBTYPE.BYTE,FB.ARGMODE.BYREF, FALSE
'' fb_DataReadShort ( dst as short ) as void
data "fb_DataReadShort","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
							FB.SYMBTYPE.SHORT,FB.ARGMODE.BYREF, FALSE
'' fb_DataReadInt ( dst as integer ) as void
data "fb_DataReadInt","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYREF, FALSE
'' fb_DataReadSingle ( dst as single ) as void
data "fb_DataReadSingle","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						     FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYREF, FALSE
'' fb_DataReadDouble ( dst as single ) as void
data "fb_DataReadDouble","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						     FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYREF, FALSE

''
'' fb_Pow CDECL ( byval x as double, byval y as double ) as double
data "fb_Pow","pow", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 2, _
					 FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE, _
					 FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' fb_SGNSingle ( byval x as single ) as integer
data "fb_SGNSingle","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYVAL, FALSE
'' fb_SGNDouble ( byval x as double ) as integer
data "fb_SGNDouble","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' fb_FIXSingle ( byval x as single ) as single
data "fb_FIXSingle","", FB.SYMBTYPE.SINGLE,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYVAL, FALSE
'' fb_FIXDouble ( byval x as double ) as double
data "fb_FIXDouble","", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE

''
'' fb_PrintVoid ( byval filenum as integer = 0, byval mask as integer ) as void
data "fb_PrintVoid","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintByte ( byval filenum as integer = 0, byval x as byte, byval mask as integer ) as void
data "fb_PrintByte","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						FB.SYMBTYPE.BYTE,FB.ARGMODE.BYVAL, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintUByte ( byval filenum as integer = 0, byval x as ubyte, byval mask as integer ) as void
data "fb_PrintUByte","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						 FB.SYMBTYPE.UBYTE,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintShort ( byval filenum as integer = 0, byval x as short, byval mask as integer ) as void
data "fb_PrintShort","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						 FB.SYMBTYPE.SHORT,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintUShort ( byval filenum as integer = 0, byval x as ushort, byval mask as integer ) as void
data "fb_PrintUShort","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.USHORT,FB.ARGMODE.BYVAL, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintInt ( byval filenum as integer = 0, byval x as integer, byval mask as integer ) as void
data "fb_PrintInt","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintUInt ( byval filenum as integer = 0, byval x as uinteger, byval mask as integer ) as void
data "fb_PrintUInt","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintSingle ( byval filenum as integer = 0, byval x as single, byval mask as integer ) as void
data "fb_PrintSingle","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYVAL, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintDouble ( byval filenum as integer = 0, byval x as double, byval mask as integer ) as void
data "fb_PrintDouble","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintString ( byval filenum as integer = 0, x as string, byval mask as integer ) as void
data "fb_PrintString","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' spc ( byval filenum as integer = 0, byval n as integer ) as void
data "fb_PrintSPC","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' tab ( byval filenum as integer = 0, byval newcol as integer ) as void
data "fb_PrintTab","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

''
'' fb_WriteVoid ( byval filenum as integer = 0, byval mask as integer ) as void
data "fb_WriteVoid","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteByte ( byval filenum as integer = 0, byval x as byte, byval mask as integer ) as void
data "fb_WriteByte","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						FB.SYMBTYPE.BYTE,FB.ARGMODE.BYVAL, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteUByte ( byval filenum as integer = 0, byval x as ubyte, byval mask as integer ) as void
data "fb_WriteUByte","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						 FB.SYMBTYPE.UBYTE,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteShort ( byval filenum as integer = 0, byval x as short, byval mask as integer ) as void
data "fb_WriteShort","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						 FB.SYMBTYPE.SHORT,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteUShort ( byval filenum as integer = 0, byval x as ushort, byval mask as integer ) as void
data "fb_WriteUShort","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.USHORT,FB.ARGMODE.BYVAL, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteInt ( byval filenum as integer = 0, byval x as integer, byval mask as integer ) as void
data "fb_WriteInt","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteUInt ( byval filenum as integer = 0, byval x as uinteger, byval mask as integer ) as void
data "fb_WriteUInt","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteSingle ( byval filenum as integer = 0, byval x as single, byval mask as integer ) as void
data "fb_WriteSingle","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYVAL, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteDouble ( byval filenum as integer = 0, byval x as double, byval mask as integer ) as void
data "fb_WriteDouble","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_WriteString ( byval filenum as integer = 0, x as string, byval mask as integer ) as void
data "fb_WriteString","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_PrintUsingInit ( fmtstr as string ) as integer
data "fb_PrintUsingInit","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						     FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_PrintUsingStr ( byval filenum as integer, s as string, byval mask as integer ) as integer
data "fb_PrintUsingStr","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						    FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintUsingVal ( byval filenum as integer, byval v as double, byval mask as integer ) as integer
data "fb_PrintUsingVal","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						    FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_PrintUsingEnd ( byval filenum as integer ) as integer
data "fb_PrintUsingEnd","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE


'' fb_ConsoleView ( byval toprow as integer = 0, byval botrow as integer = 0 ) as void
data "fb_ConsoleView","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0

''
'' fb_MemCopy cdecl ( dst as any, src as any, byval bytes as integer ) as void
data "fb_MemCopy","memcpy", FB.SYMBTYPE.VOID,FB.FUNCMODE.CDECL, 3, _
							FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
							FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
							FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_MemSwap ( dst as any, src as any, byval bytes as integer ) as void
data "fb_MemSwap","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 3, _
					  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_StrSwap ( str1 as any, byval str1len as integer, str2 as any, byval str2len as integer ) as void
data "fb_StrSwap","", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 4, _
					  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

''
'' fb_FileOpen( s as string, byval mode as integer, byval access as integer,
''		        byval lock as integer, byval filenum as integer, byval len as integer ) as integer
data "fb_FileOpen","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 6, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FileClose	( byval filenum as integer ) as integer
data "fb_FileClose","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FilePut ( byval filenum as integer, byval offset as uinteger, value as any, byval valuelen as integer ) as integer
data "fb_FilePut","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 4, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					  FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE, _
					  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FilePutStr ( byval filenum as integer, byval offset as uinteger, s as string ) as integer
data "fb_FilePutStr","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_FileGet ( byval filenum as integer, byval offset as uinteger, value as any, byval valuelen as integer ) as integer
data "fb_FileGet","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 4, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					  FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE, _
					  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FileGetStr ( byval filenum as integer, byval offset as uinteger, s as string ) as integer
data "fb_FileGetStr","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' fb_FileTell ( byval filenum as integer ) as uinteger
data "fb_FileTell","", FB.SYMBTYPE.UINT,FB.FUNCMODE.STDCALL, 1, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FileSeek ( byval filenum as integer, byval newpos as uinteger ) as integer
data "fb_FileSeek","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE

'' fb_FileStrInput ( byval bytes as integer, byval filenum as integer = 0 ) as string
data "fb_FileStrInput", "", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 2, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0

'' fb_FileLineInput ( byval filenum as integer, dst as string ) as integer
data "fb_FileLineInput", "", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
						     FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						     FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_LineInput ( text as string, dst as string, byval addquestion as integer, _
''				  byval addnewline as integer ) as integer
data "fb_LineInput", "", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 4, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_FileInput ( byval filenum as integer ) as integer
data "fb_FileInput", "", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_ConsoleInput ( text as string,  byval addquestion as integer, _
''				     byval addnewline as integer ) as integer
data "fb_ConsoleInput", "", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
						    FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_InputByte ( x as byte ) as void
data "fb_InputByte","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						FB.SYMBTYPE.BYTE,FB.ARGMODE.BYREF, FALSE
'' fb_InputShort ( x as short ) as void
data "fb_InputShort","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.SHORT,FB.ARGMODE.BYREF, FALSE
'' fb_InputInt ( x as integer ) as void
data "fb_InputInt","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYREF, FALSE
'' fb_InputSingle ( x as single ) as void
data "fb_InputSingle","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYREF, FALSE
'' fb_InputDouble ( x as double ) as void
data "fb_InputDouble","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYREF, FALSE
'' fb_InputString ( x as any, byval strlen as integer ) as void
data "fb_InputString","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.VOID,FB.ARGMODE.BYREF, FALSE, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_FileLock ( byval inipos as integer, byval endpos as integer ) as integer
data "fb_FileLock","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0
'' fb_FileUnlock ( byval inipos as integer, byval endpos as integer ) as integer
data "fb_FileUnlock","", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 3, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0


''
'' fb_ErrorThrow( byval errnum as integer ) as any ptr
data "fb_ErrorThrow","", FB.SYMBTYPE.UINT,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_ErrorSetHandler( byval newhandler as any ptr ) as any ptr
data "fb_ErrorSetHandler","", FB.SYMBTYPE.UINT,FB.FUNCMODE.STDCALL, 1, _
							  FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE

'' fb_ErrorGetNum( ) as integer
data "fb_ErrorGetNum", "", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 0
'' fb_ErrorSetNum( byval errnum as integer ) as void
data "fb_ErrorSetNum", "", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
						   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'':::::::::::::::::::::::::::::::::::::::::::::::::::

'' fb_FileFree ( ) as integer
data "freefile", "fb_FileFree", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 0
'' fb_FileEof ( byval filenum as integer ) as integer
data "eof", "fb_FileEof", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_FileKill ( s as string ) as integer
data "kill", "fb_FileKill", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
							FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' fb_CHR ( byval number as uinteger ) as string
data "chr","fb_CHR", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.UINT,FB.ARGMODE.BYVAL, FALSE
'' fb_ASC ( str as string ) as uinteger
data "asc","fb_ASC", FB.SYMBTYPE.UINT,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' fb_CVD ( str as string ) as double
data "cvd","fb_CVD", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
data "cvs","fb_CVD", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_CVI ( str as string ) as integer
data "cvi","fb_CVI", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
data "cvl","fb_CVI", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' fb_HEX ( byval number as integer ) as string
data "hex","fb_HEX", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_OCT ( byval number as integer ) as string
data "oct","fb_OCT", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_BIN ( byval number as integer ) as string
data "bin","fb_BIN", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_MKD ( byval number as double ) as string
data "mkd","fb_MKD", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' fb_MKI ( byval number as integer ) as string
data "mki","fb_MKI", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
data "mkl","fb_MKI", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_MKS ( byval number as single ) as string
data "mks","fb_MKS", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.SINGLE,FB.ARGMODE.BYVAL, FALSE

'' fb_LEFT ( str as string, byval n as integer ) as string
data "left","fb_LEFT", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 2, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
					   FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' fb_RIGHT ( str as string, byval n as integer ) as string
data "right","fb_RIGHT", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 2, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_SPACE ( byval n as integer ) as string
data "space","fb_SPACE", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' fb_LTRIM ( str as string ) as string
data "ltrim","fb_LTRIM", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_RTRIM ( str as string ) as string
data "rtrim","fb_RTRIM", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_TRIM ( str as string ) as string
data "trim","fb_TRIM", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_LCASE ( str as string ) as string
data "lcase","fb_LCASE", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' fb_UCASE ( str as string ) as string
data "ucase","fb_UCASE", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
						 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' fb_VAL ( str as string ) as double
data "val","fb_VAL", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' cos CDECL ( byval rad as double ) as double
data "cos","cos", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' acos CDECL ( byval x as double ) as double
data "acos","acos", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
					FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' sin CDECL ( byval rad as double ) as double
data "sin","sin", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' asin CDECL ( byval x as double ) as double
data "asin","asin", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
					FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' tan CDECL ( byval rad as double ) as double
data "tan","tan", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' atn CDECL ( byval x as double ) as double
data "atn","atan", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				   FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' atan2 CDECL ( byval x as double, byval y as double ) as double
data "atan2","atan2", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 2, _
					  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE, _
					  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' sqr CDECL ( byval rad as double ) as double
data "sqr","sqrt", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				   FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' log CDECL ( byval rad as double ) as double
data "log","log", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' exp CDECL ( byval rad as double ) as double
data "exp","exp", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
				  FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE
'' int CDECL ( byval val as double ) as double
data "int","floor", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.CDECL, 1, _
					FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, FALSE

'' command ( ) as string
data "command","fb_Command", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 0
'' curdir ( ) as string
data "curdir","fb_CurDir", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 0
'' exepath ( ) as string
data "exepath","fb_ExePath", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 0

'' randomize ( byval seed as double = -1.0 ) as void
data "randomize","fb_Randomize", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
					             FB.SYMBTYPE.DOUBLE,FB.ARGMODE.BYVAL, TRUE, -1.0
'' rnd ( byval n as integer ) as double
data "rnd","fb_Rnd", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.STDCALL, 1, _
					 FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,1

'' timer ( ) as double
data "timer","fb_Timer", FB.SYMBTYPE.DOUBLE,FB.FUNCMODE.STDCALL, 0
'' time ( ) as string
data "time","fb_Time", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 0
'' date ( ) as string
data "date","fb_Date", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 0

'' pos( ) as integer
data "pos", "fb_ConsoleGetX", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 0
'' csrlin( ) as integer
data "csrlin", "fb_ConsoleGetY", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 0
'' cls( byval n as integer = 1 ) as void
data "cls", "fb_Cls", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
					  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,1
'' locate( byval row as integer = 0, byval col as integer = 0 ) as void
data "locate", "fb_Locate", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
				 		    FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
							FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0
'' color( byval fc as integer = -1, byval bc as integer = -1 ) as void
data "color", "fb_Color", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,-1, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,-1
'' width( byval cols as integer = 0, byval rows as integer = 0 ) as void
data "width", "fb_Width", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0

'' inkey ( ) as string
data "inkey","fb_Inkey", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 0
'' getkey ( ) as integer
data "getkey","fb_Getkey", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 0

'' shell ( byval cmm as string ) as integer
data "shell","system", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.CDECL, 1, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYVAL, FALSE

'' rename ( byval oldname as string, byval newname as string ) as integer
data "rename","rename", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.CDECL, 2, _
					    FB.SYMBTYPE.STRING,FB.ARGMODE.BYVAL, FALSE, _
					    FB.SYMBTYPE.STRING,FB.ARGMODE.BYVAL, FALSE

'' system ( ) as void
data "system","fb_End", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
				        FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0
'' stop ( ) as void
data "stop","fb_End", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 1, _
				      FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE,0

'' run ( exename as string ) as integer
data "run","fb_Run", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
				      FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' chain ( exename as string ) as integer
data "chain","fb_Chain", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
				         FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' exec ( exename as string, arguments as string ) as integer
data "exec","fb_Exec", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 2, _
				       FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
				       FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' environ ( varname as string ) as string
data "environ","fb_GetEnviron", FB.SYMBTYPE.STRING,FB.FUNCMODE.STDCALL, 1, _
				       			FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' setenviron ( varname as string ) as integer
data "setenviron","fb_SetEnviron", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
				       			   FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'' sleep ( byval msecs as integer ) as void
data "sleep","fb_Sleep", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.STDCALL, 1, _
					     FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, TRUE, -1

'' reset ( ) as void
data "reset","fb_FileReset", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 0
'' lof ( byval filenum as integer ) as uinteger
data "lof","fb_FileSize", FB.SYMBTYPE.UINT,FB.FUNCMODE.STDCALL, 1, _
						  FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE
'' loc ( byval filenum as integer ) as uinteger
data "loc","fb_FileLocation", FB.SYMBTYPE.UINT,FB.FUNCMODE.STDCALL, 1, _
						      FB.SYMBTYPE.INTEGER,FB.ARGMODE.BYVAL, FALSE

'' lset ( dst as string, src as string ) as void
data "lset","fb_StrLset", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
				          FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
				          FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE
'' rset ( dst as string, src as string ) as void
data "rset","fb_StrRset", FB.SYMBTYPE.VOID,FB.FUNCMODE.STDCALL, 2, _
				          FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE, _
				          FB.SYMBTYPE.STRING,FB.ARGMODE.BYREF, FALSE

'':::::::::::::::::::::::::::::::::::::::::::::::::::

'' beep ( ) as void
data "beep","_beep", FB.SYMBTYPE.VOID,FB.FUNCMODE.CDECL, 0

'' mkdir ( byval path as string ) as integer
data "mkdir","_mkdir", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.CDECL, 1, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYVAL, FALSE
'' rmdir ( byval path as string ) as integer
data "rmdir","_rmdir", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.CDECL, 1, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYVAL, FALSE
'' chdir ( byval path as string ) as integer
data "chdir","_chdir", FB.SYMBTYPE.INTEGER,FB.FUNCMODE.CDECL, 1, _
					   FB.SYMBTYPE.STRING,FB.ARGMODE.BYVAL, FALSE



'' EOL
data ""


'':::::::::::::::::::::::::::::::::::::::::::::::::::
deflibsdata:
data "fb"
data "crtdll"
data "kernel32"
data "user32"
data ""

'':::::
sub rtlAddDefaultLibs
    dim lname as string

	restore deflibsdata

	do
		read lname
		if( len( lname ) = 0 ) then
			exit do
		end if

		symbAddLib lname
	loop

end sub

'':::::
sub rtlInit static
	dim i as integer, a as integer
	dim p as integer, pname as string, aname as string
	dim args as integer, typ as integer, mode as integer
	dim argv(0 to FB_MAXPROCARGS-1) as FBPROCARG

    ''
	rtlAddDefaultLibs

	''
	redim ifuncTB( 0 to FB.RTL.MAXFUNCTIONS-1 ) as integer

	restore ifuncdata
	i = 0
	do
		read pname
		if( len( pname ) = 0 ) then
			exit do
		end if
		read aname
		read typ
		read mode
		read args
		for a = 0 to args-1
			read argv(a).typ
			read argv(a).mode
			read argv(a).optional

			if( argv(a).optional ) then
				read argv(a).defvalue
			end if

			argv(a).nameidx = INVALID
			if( argv(a).typ <> INVALID ) then
				argv(a).lgt	= symbCalcLen( argv(a).typ, INVALID )
			else
				argv(a).lgt	= FB.POINTERSIZE
			end if
		next a

		ifuncTB(i) = symbAddProc( pname, aname, "fb", typ, mode, args, argv(), TRUE )
		i = i + 1
	loop

	''
	ctx.datainited	= FALSE
	ctx.lastlabel	= INVALID
    ctx.labelcnt 	= 0

end sub

'':::::
sub rtlEnd

	'' procs will be deleted when symbEnd is called

	erase ifuncTB

end sub

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' strings
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
function hGetFixStrLen( byval expr as integer ) as integer
	dim s as integer, e as integer

	e = astGetVARElm( expr )
	if( e <> INVALID ) then
		hGetFixStrLen = symbGetUDTElmLen( e ) - 1
	else
		s = astGetSymbol( expr )
		hGetFixStrLen = symbGetLen( s ) - 1
	end if

end function


'':::::
function rtlStrCompare ( byval str1 as integer, byval sdtype1 as integer, _
					     byval str2 as integer, byval sdtype2 as integer ) as integer static
    dim res as integer, lgt as integer
    dim proc as integer, f as integer
    dim str1len as integer, str2len as integer
    dim s as integer

	''
	f = ifuncTB(FB.RTL.STRCOMPARE)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 4 )

   	''
	str1len = -1
	if( hIsStrFixed( sdtype1 ) ) then
		str1len = hGetFixStrLen( str1 )
		if( str1len < 0 ) then str1len = 0
	end if

    ''
	str2len = -1
	if( hIsStrFixed( sdtype2 ) ) then
		str2len = hGetFixStrLen( str2 )
		if( str2len < 0 ) then str2len = 0
	end if

    ''
    res = astNewPARAM( proc, str1, sdtype1 )
    lgt = astNewCONST( str1len, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

    res = astNewPARAM( proc, str2, sdtype2 )
    lgt = astNewCONST( str2len, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

    rtlStrCompare = proc

end function

'':::::
function rtlStrConcat( byval str1 as integer, byval sdtype1 as integer, _
					   byval str2 as integer, byval sdtype2 as integer ) as integer static
    dim res as integer, lgt as integer, tstr as integer
    dim proc as integer, f as integer
    dim str1len as integer, str2len as integer
    dim s as integer

	''
	f = ifuncTB(FB.RTL.STRCONCAT)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 5 )

    '' dst as string
    tstr = symbAddTempVar( FB.SYMBTYPE.STRING )
    tstr = astNewVAR( tstr, 0, IR.DATATYPE.STRING )
    res = astNewPARAM( proc, tstr, IR.DATATYPE.STRING )

   	''
	str1len = -1
	if( hIsStrFixed( sdtype1 ) ) then
		str1len = hGetFixStrLen( str1 )
		if( str1len < 0 ) then str1len = 0
	end if

    ''
	str2len = -1
	if( hIsStrFixed( sdtype2 ) ) then
		str2len = hGetFixStrLen( str2 )
		if( str2len < 0 ) then str2len = 0
	end if

    ''
    res = astNewPARAM( proc, str1, sdtype1 )
    lgt = astNewCONST( str1len, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

    res = astNewPARAM( proc, str2, sdtype2 )
    lgt = astNewCONST( str2len, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

    rtlStrConcat = proc

end function

'':::::
function rtlStrAssign( byval dst as integer, byval src as integer ) as integer static
    dim lgt as integer, dtype as integer
    dim f as integer, proc as integer
    dim s as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.STRASSIGN)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 4 )

    ''
   	dtype = astGetDataType( dst )

	lgt = -1
	if( hIsStrFixed( dtype ) ) then
		lgt = hGetFixStrLen( dst )
		if( lgt < 0 ) then lgt = 0
	end if
	res = astNewPARAM( proc, dst, dtype )
	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

   	''
   	dtype = astGetDataType( src )

	lgt = -1
	if( hIsStrFixed( dtype ) ) then
		lgt = hGetFixStrLen( src )
		if( lgt < 0 ) then lgt = 0
	end if
	res = astNewPARAM( proc, src, dtype )
	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

	''
	rtlStrAssign = proc

end function

'':::::
function rtlStrDelete( byval strg as integer ) as integer static
    dim res as integer, lgt as integer
    dim proc as integer, f as integer

	''
	f = ifuncTB(FB.RTL.STRDELETE)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' str as ANY
    res = astNewPARAM( proc, strg, IR.DATATYPE.STRING )

    rtlStrDelete = proc

end function

'':::::
function rtlStrAllocTmpResult( byval strg as integer ) as integer static
    dim res as integer, lgt as integer
    dim proc as integer, f as integer

	''
	f = ifuncTB(FB.RTL.STRALLOCTMPRES)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' src as string
    res = astNewPARAM( proc, strg, IR.DATATYPE.STRING )


	rtlStrAllocTmpResult = proc

end function

'':::::
function rtlStrAllocTmpDesc	( byval strg as integer ) as integer static
    dim res as integer
    dim proc as integer, f as integer
    dim s as integer, lgt as integer, dtype as integer

	''
	f = ifuncTB(FB.RTL.STRALLOCTMPDESC)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' str as any
    res = astNewPARAM( proc, strg, IR.DATATYPE.STRING )

    '' byval strlen as integer
   	dtype = astGetDataType( strg )

	lgt = -1
	if( hIsStrFixed( dtype ) ) then
		lgt = hGetFixStrLen( strg )
		if( lgt < 0 ) then lgt = 0
	end if
	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

	''
	rtlStrAllocTmpDesc = proc

end function

'':::::
function rtlToStr( byval expr as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer

	select case astGetDataClass( expr )
	case IR.DATACLASS.INTEGER
		f = ifuncTB(FB.RTL.INT2STR)
	case IR.DATACLASS.FPOINT
		if( astGetDataType( expr ) = IR.DATATYPE.SINGLE ) then
			f = ifuncTB(FB.RTL.FLT2STR)
		else
			f = ifuncTB(FB.RTL.DBL2STR)
		end if
	case else
		rtlToStr = INVALID
		exit function
	end select

	''
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    ''
    res = astNewPARAM( proc, expr, INVALID )

    rtlToStr = proc

end function

'':::::
function rtlStrInstr( byval expr1 as integer, byval expr2 as integer, byval expr3 as integer ) as integer static
    dim res as integer
    dim proc as integer, f as integer

	''
	f = ifuncTB(FB.RTL.STRINSTR)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 3 )

    ''
    res = astNewPARAM( proc, expr1, INVALID )

    res = astNewPARAM( proc, expr2, INVALID )

    res = astNewPARAM( proc, expr3, INVALID )

    rtlStrInstr = proc

end function

'':::::
function rtlStrMid( byval expr1 as integer, byval expr2 as integer, byval expr3 as integer ) as integer static
    dim res as integer
    dim proc as integer, f as integer

	''
	f = ifuncTB(FB.RTL.STRMID)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 3 )

    ''
    res = astNewPARAM( proc, expr1, INVALID )

    res = astNewPARAM( proc, expr2, INVALID )

    res = astNewPARAM( proc, expr3, INVALID )

    rtlStrMid = proc

end function

'':::::
sub rtlStrAssignMid( byval expr1 as integer, byval expr2 as integer, byval expr3 as integer, byval expr4 as integer ) static
    dim res as integer
    dim proc as integer, f as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.STRASSIGNMID)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 4 )

    ''
    res = astNewPARAM( proc, expr1, INVALID )

    res = astNewPARAM( proc, expr2, INVALID )

    res = astNewPARAM( proc, expr3, INVALID )

    res = astNewPARAM( proc, expr4, INVALID )

    ''
    astFlush proc, vr

end sub

'':::::
function rtlStrFill( byval expr1 as integer, byval expr2 as integer ) as integer static
    dim res as integer
    dim proc as integer, f as integer

	select case astGetDataClass( expr2 )
	case IR.DATACLASS.INTEGER, IR.DATACLASS.FPOINT
		f = ifuncTB(FB.RTL.STRFILL1)
	case else
		f = ifuncTB(FB.RTL.STRFILL2)
	end select

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    ''
    res = astNewPARAM( proc, expr1, INVALID )

    res = astNewPARAM( proc, expr2, INVALID )

    rtlStrFill = proc

end function


'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' arrays
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
sub rtlArrayRedim( byval s as integer, byval elementlen as integer, byval dimensions as integer, _
				   exprTB() as integer, byval dopreserve as integer ) static
    dim res as integer
    dim proc as integer, f as integer
    dim typ as integer, dtype as integer, t as integer, isvarlen as integer
    dim i as integer, vr as integer

	''
	f = ifuncTB(FB.RTL.ARRAYREDIM)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 5+dimensions*2 )

    '' array() as ANY
    typ = symbGetType( s )
    dtype =  hStyp2Dtype( typ )
	t = astNewVAR( s, 0, dtype )
    res = astNewPARAM( proc, t, dtype )

	'' byval element_len as integer
	t = astNewCONST( elementlen, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

	'' byval isvarlen as integer
	isvarlen = FALSE
	if( symbIsString( s ) ) then
		isvarlen = not hIsStrFixed( dtype )
	end if
	t = astNewCONST( isvarlen, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

	'' byval preserve as integer
	t = astNewCONST( dopreserve, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

	'' byval dimensions as integer
	t = astNewCONST( dimensions, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

	'' ...
	for i = 0 to dimensions-1
		t = exprTB(i,0)
		dtype = astGetDataType( t )
		res = astNewPARAM( proc, t, dtype )

		t = exprTB(i,1)
		dtype = astGetDataType( t )
		res = astNewPARAM( proc, t, dtype )
	next i

    ''
	astFlush proc, vr

end sub

'':::::
sub rtlArrayErase( byval s as integer ) static
    dim res as integer
    dim proc as integer, f as integer
    dim typ as integer, dtype as integer, t as integer, isvarlen as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.ARRAYERASE)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' array() as ANY
    typ = symbGetType( s )
    dtype =  hStyp2Dtype( typ )
	t = astNewVAR( s, 0, dtype )
    res = astNewPARAM( proc, t, dtype )

	'' byval isvarlen as integer
	isvarlen = FALSE
	if( symbIsString( s ) ) then
		isvarlen = not hIsStrFixed( dtype )
	end if
	t = astNewCONST( isvarlen, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

    ''
	astFlush proc, vr

end sub

'':::::
sub rtlArrayStrErase( byval s as integer ) static
    dim res as integer
    dim proc as integer, f as integer
    dim typ as integer, dtype as integer, t as integer, isvarlen as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.ARRAYSTRERASE)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' array() as ANY
    typ = symbGetType( s )
    dtype =  hStyp2Dtype( typ )
	t = astNewVAR( s, 0, dtype )
    res = astNewPARAM( proc, t, dtype )

    ''
	astFlush proc, vr

end sub

'':::::
function rtlArrayBound( byval s as integer, byval dimexpr as integer, byval islbound as integer ) as integer static
    dim res as integer
    dim proc as integer, f as integer
    dim typ as integer, dtype as integer, v as integer
    dim vr as integer

	''
	if( islbound ) then
		f = ifuncTB(FB.RTL.ARRAYLBOUND)
	else
		f = ifuncTB(FB.RTL.ARRAYUBOUND)
	end if
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' array() as ANY
    typ = symbGetType( s )
    dtype =  hStyp2Dtype( typ )
	v = astNewVAR( s, 0, dtype )
    res = astNewPARAM( proc, v, dtype )

	'' byval dimension as integer
	res = astNewPARAM( proc, dimexpr, INVALID )

    ''
    rtlArrayBound = proc

end function

'':::::
sub rtlArraySetDesc( byval s as integer, byval elementlen as integer, byval dimensions as integer, dTB() as FBARRAYDIM ) static
    dim res as integer
    dim proc as integer, f as integer
    dim typ as integer, dtype as integer, t as integer
    dim i as integer, vr as integer

	f = ifuncTB(FB.RTL.ARRAYSETDESC)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 4+dimensions*2 )

    '' array() as ANY
    typ = symbGetType( s )
    dtype =  hStyp2Dtype( typ )
	t = astNewVAR( s, 0, dtype )
    res = astNewPARAM( proc, t, dtype )

	'' arraydata as ANY
	t = astNewVAR( s, 0, dtype )
    res = astNewPARAM( proc, t, dtype )

	'' byval element_len as integer
	t = astNewCONST( elementlen, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

	'' byval dimensions as integer
	t = astNewCONST( dimensions, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

	'' ...
	for i = 0 to dimensions-1
		t = astNewCONST( dTB(i).lower, IR.DATATYPE.INTEGER )
		res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )
		t = astNewCONST( dTB(i).upper, IR.DATATYPE.INTEGER )
		res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )
	next i

    ''
	astFlush proc, vr

end sub

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' data
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
sub rtlDataRead( byval varexpr as integer ) static
    dim res as integer
    dim proc as integer, f as integer, args as integer
    dim vr as integer, dtype as integer, lgt as integer

	f = INVALID
	select case astGetDataClass( varexpr )
	case IR.DATACLASS.INTEGER
		select case astGetDataSize( varexpr )
		case 1
			f = ifuncTB(FB.RTL.DATAREADBYTE)
		case 2
			f = ifuncTB(FB.RTL.DATAREADSHORT)
		case 4
			f = ifuncTB(FB.RTL.DATAREADINT)
		end select
		args = 1

	case IR.DATACLASS.FPOINT
		select case astGetDataSize( varexpr )
		case 4
			f = ifuncTB(FB.RTL.DATAREADSINGLE)
		case 8
			f = ifuncTB(FB.RTL.DATAREADDOUBLE)
		end select
		args = 1

	case else
		f = ifuncTB(FB.RTL.DATAREADSTR)
		args = 2
	end select

    if( f = INVALID ) then
    	exit sub
    end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' byref var as any
    res = astNewPARAM( proc, varexpr, INVALID )

    if( args = 2 ) then
		'' byval dst_size as integer
		lgt = -1
		dtype = astGetDataType( varexpr )
		if( hIsStrFixed( dtype ) ) then
			lgt = hGetFixStrLen( varexpr )
			if( lgt < 0 ) then lgt = 0
		end if
		lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
		res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )
    end if

    ''
    astFlush proc, vr

end sub

'':::::
sub rtlDataRestore( byval label as integer ) static
    dim res as integer
    dim proc as integer, f as integer
    dim vr as integer
    dim lname as string, rname as string
    dim s as integer, dTB(0) as FBARRAYDIM

	f = ifuncTB(FB.RTL.DATARESTORE)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' begin of data or start from label?
    if( label <> INVALID ) then
    	lname = FB.DATALABELPREFIX + symbGetLabelName( label )
    else
    	lname = FB.DATALABELNAME
    end if

    '' label already declared as var? (i have to do this as labels aren't stored in
    '' symbolTB array, as in QB you can have label with the same name as vars and
    '' functions.. symbGet#### knows nothing about diferent tables)
    s = symbLookupVar( lname, FB.SYMBTYPE.DATALABEL, 0, 0, 0 )
    if( s = INVALID ) then
       	rname = hMakeTmpStr
       	s = symbAddVarEx( lname, rname, FB.SYMBTYPE.DATALABEL, 0, 1, 0, dTB(), FB.ALLOCTYPE.SHARED or FB.ALLOCTYPE.STATIC, TRUE, FALSE, TRUE )
    end if

    '' byval labeladdrs as void ptr
    s = astNewVAR( s, 0, IR.DATATYPE.UINT )
    label = astNewADDR( IR.OP.ADDROF, s )

    res = astNewPARAM( proc, label, INVALID )

	''
	astFlush proc, vr

end sub

'':::::
sub rtlDataStoreBegin static
    dim label as integer, lname as string, rname as string
    dim s as integer, dTB(0) as FBARRAYDIM

	irFlush

	'' switch section, can't be code coz it will screw up debugging
	emitSECTION EMIT.SECTYPE.CONST

	'' emit default label if not yet emited
	if( not ctx.datainited ) then
		ctx.datainited = TRUE

		rname = hMakeTmpStr
		s = symbAddVarEx( FB.DATALABELNAME, rname, FB.SYMBTYPE.DATALABEL, 0, 1, 0, dTB(), FB.ALLOCTYPE.SHARED or FB.ALLOCTYPE.STATIC, TRUE, FALSE, TRUE )
		if( s = INVALID ) then
			s = symbLookupVar( FB.DATALABELNAME, FB.SYMBTYPE.DATALABEL, 0, 0, 0 )
		end if

		rname = symbGetVarName( s )
		emitLABEL rname, TRUE

	else
		s = symbLookupVar( FB.DATALABELNAME, FB.SYMBTYPE.DATALABEL, 0, 0, 0 )
		rname = symbGetVarName( s )
	end if

	'' emit last label as a label in const section (read the comment at Restore)
	'' if any defined already, otherwise it will be the default
	label = symbGetLastLabel
	if( label <> INVALID ) then
    	''
    	lname = FB.DATALABELPREFIX + symbGetLabelName( label )
    	s = symbLookupVar( lname, FB.SYMBTYPE.DATALABEL, 0, 0, 0 )
    	if( s = INVALID ) then
    		rname = hMakeTmpStr
       		s = symbAddVarEx( lname, rname, FB.SYMBTYPE.DATALABEL, 0, 1, 0, dTB(), FB.ALLOCTYPE.SHARED or FB.ALLOCTYPE.STATIC, TRUE, FALSE, TRUE )
    	else
    		rname = symbGetVarName( s )
    	end if

    	'' stills the same label as before? incrase counter to link DATA's
    	if( ctx.lastlabel = label ) then
    		ctx.labelcnt = ctx.labelcnt + 1
    		rname = rname + "_" + ltrim$( str$( ctx.labelcnt ) )
    	else
    		ctx.lastlabel = label
    		ctx.labelcnt = 0
    	end if

    	emitLABEL rname, TRUE
    end if

	'' emit will link the last DATA with this one if any exists
	emitDATABEGIN rname

end sub

'':::::
sub rtlDataStore( littext as string, byval typ as integer ) static

	'' emit will take care of all dirty details
	emitDATA littext, typ

end sub

'':::::
sub rtlDataStoreEnd static

	'' emit end of data (will be repatched be emit if more DATA stmts follow)
	emitDATAEND

	'' back to code section
	emitSECTION EMIT.SECTYPE.CODE

end sub

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' math
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
function rtlMathPow	( byval xexpr as integer, byval yexpr as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.POW)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' byval x as double
    res = astNewPARAM( proc, xexpr, INVALID )

    '' byval y as double
    res = astNewPARAM( proc, yexpr, INVALID )

    ''
    rtlMathPow = proc

end function

'':::::
function rtlMathFSGN ( byval expr as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer

	''
	if( astGetDataType( expr ) = IR.DATATYPE.SINGLE ) then
		f = ifuncTB(FB.RTL.SGNSINGLE)
	else
		f = ifuncTB(FB.RTL.SGNDOUBLE)
	end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval x as single|double
    res = astNewPARAM( proc, expr, INVALID )

    ''
    rtlMathFSGN = proc

end function

'':::::
function rtlMathFIX ( byval expr as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer

	''
	select case astGetDataClass( expr )
	case IR.DATACLASS.FPOINT
		if( astGetDataType( expr ) = IR.DATATYPE.SINGLE ) then
			f = ifuncTB(FB.RTL.FIXSINGLE)
		else
			f = ifuncTB(FB.RTL.FIXDOUBLE)
		end if

	case IR.DATACLASS.INTEGER
		rtlMathFIX = expr
		exit function

	case else
		rtlMathFIX = INVALID
		exit function
	end select

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval x as single|double
    res = astNewPARAM( proc, expr, INVALID )

    ''
    rtlMathFIX = proc

end function

'':::::
function hCalcExprLen( byval expr as integer ) as integer static
	dim lgt as integer, s as integer, e as integer

	lgt = -1

	select case astGetDataType( expr )
	case IR.DATATYPE.BYTE, IR.DATATYPE.UBYTE
		lgt = 1
	case IR.DATATYPE.SHORT, IR.DATATYPE.USHORT
		lgt = 2
	case IR.DATATYPE.INTEGER, IR.DATATYPE.UINT
		lgt = FB.INTEGERSIZE
	case IR.DATATYPE.SINGLE
		lgt = 4
	case IR.DATATYPE.DOUBLE
		lgt = 9
	case is >= IR.DATATYPE.POINTER
		lgt = FB.POINTERSIZE
	case IR.DATATYPE.USERDEF
		e = astGetVARElm( expr )
		if( e <> INVALID ) then
			lgt = symbGetUDTELmLen( e )
		else
			s = astGetSymbol( expr )
			s = symbGetSubtype( s )
			lgt = symbGetLen( s )
		end if
	end select

	hCalcExprLen = lgt

end function

'':::::
function rtlMathLen( byval expr as integer ) as integer static
    dim proc as integer, f as integer
    dim dtype as integer, lgt as integer, s as integer
    dim res as integer

	dtype = astGetDataType( expr )

	if( hIsString( dtype ) ) then
		f = ifuncTB(FB.RTL.STRLEN)
    	proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    	'' str as any
    	res = astNewPARAM( proc, expr, IR.DATATYPE.STRING )

    	'' byval strlen as integer
		lgt = -1
		if( hIsStrFixed( dtype ) ) then
			lgt = hGetFixStrLen( expr )
			if( lgt < 0 ) then lgt = 0
		end if
		lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
		res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

		rtlMathLen = proc
		exit function
	end if

	''
	lgt = hCalcExprLen( expr )

	rtlMathLen = astNewCONST( lgt, IR.DATATYPE.INTEGER )

end function

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' console
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
sub rtlPrint( byval fileexpr as integer, byval iscomma as integer, byval issemicolon as integer, byval expr as integer )
    dim proc as integer, f as integer
    dim t as integer, mask as integer, args as integer
    dim res as integer, vr as integer

	if( expr = INVALID ) then
		f = ifuncTB(FB.RTL.PRINTVOID)
		args = 2
	else
        astUpdNodeResult expr

		select case astGetDataType( expr )
		case IR.DATATYPE.FIXSTR, IR.DATATYPE.STRING
			f = ifuncTB(FB.RTL.PRINTSTR)
		case IR.DATATYPE.BYTE
			f = ifuncTB(FB.RTL.PRINTBYTE)
		case IR.DATATYPE.UBYTE
			f = ifuncTB(FB.RTL.PRINTUBYTE)
		case IR.DATATYPE.SHORT
			f = ifuncTB(FB.RTL.PRINTSHORT)
		case IR.DATATYPE.USHORT
			f = ifuncTB(FB.RTL.PRINTUSHORT)
		case IR.DATATYPE.INTEGER
			f = ifuncTB(FB.RTL.PRINTINT)
		case IR.DATATYPE.UINT, is >= IR.DATATYPE.POINTER
			f = ifuncTB(FB.RTL.PRINTUINT)
		case IR.DATATYPE.SINGLE
			f = ifuncTB(FB.RTL.PRINTSINGLE)
		case IR.DATATYPE.DOUBLE
			f = ifuncTB(FB.RTL.PRINTDOUBLE)
		end select

		args = 3
	end if

    ''
	proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' byval filenum as integer
    res = astNewPARAM( proc, fileexpr, INVALID )

    if( expr <> INVALID ) then
    	'' byval? x as ???
    	res = astNewPARAM( proc, expr, INVALID )
    end if

    '' byval mask as integer
	mask = 0
	if( iscomma ) then
		mask = mask or FB.PRINTMASK.PAD
	elseif( not issemicolon ) then
		mask = mask or FB.PRINTMASK.NEWLINE
	end if

	t = astNewCONST( mask, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

    ''
    astFlush proc, vr

end sub

'':::::
sub rtlPrintSPC( byval fileexpr as integer, byval expr as integer ) static
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.PRINTSPC)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' byval filenum as integer
    res = astNewPARAM( proc, fileexpr, INVALID )

    '' byval n as integer
    res = astNewPARAM( proc, expr, INVALID )

    astFlush proc, vr

end sub

'':::::
sub rtlPrintTab( byval fileexpr as integer, byval expr as integer ) static
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.PRINTTAB)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' byval filenum as integer
    res = astNewPARAM( proc, fileexpr, INVALID )

    '' byval newcol as integer
    res = astNewPARAM( proc, expr, INVALID )

    astFlush proc, vr

end sub

'':::::
sub rtlWrite( byval fileexpr as integer, byval iscomma as integer, byval expr as integer )
    dim proc as integer, f as integer
    dim t as integer, mask as integer, args as integer
    dim res as integer, vr as integer

	if( expr = INVALID ) then
		f = ifuncTB(FB.RTL.WRITEVOID)
		args = 2
	else
        astUpdNodeResult expr

		select case astGetDataType( expr )
		case IR.DATATYPE.FIXSTR, IR.DATATYPE.STRING
			f = ifuncTB(FB.RTL.WRITESTR)
		case IR.DATATYPE.BYTE
			f = ifuncTB(FB.RTL.WRITEBYTE)
		case IR.DATATYPE.UBYTE
			f = ifuncTB(FB.RTL.WRITEUBYTE)
		case IR.DATATYPE.SHORT
			f = ifuncTB(FB.RTL.WRITESHORT)
		case IR.DATATYPE.USHORT
			f = ifuncTB(FB.RTL.WRITEUSHORT)
		case IR.DATATYPE.INTEGER
			f = ifuncTB(FB.RTL.WRITEINT)
		case IR.DATATYPE.UINT, is >= IR.DATATYPE.POINTER
			f = ifuncTB(FB.RTL.WRITEUINT)
		case IR.DATATYPE.SINGLE
			f = ifuncTB(FB.RTL.WRITESINGLE)
		case IR.DATATYPE.DOUBLE
			f = ifuncTB(FB.RTL.WRITEDOUBLE)
		end select

		args = 3
	end if

    ''
	proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' byval filenum as integer
    res = astNewPARAM( proc, fileexpr, INVALID )

    if( expr <> INVALID ) then
    	'' byval? x as ???
    	res = astNewPARAM( proc, expr, INVALID )
    end if

    '' byval mask as integer
	mask = 0
	if( iscomma ) then
		mask = mask or FB.PRINTMASK.PAD
	else
		mask = mask or FB.PRINTMASK.NEWLINE
	end if

	t = astNewCONST( mask, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

    ''
    astFlush proc, vr

end sub

'':::::
sub rtlPrintUsingInit( byval usingexpr as integer ) static
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.PRINTUSGINIT)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' fmtstr as string
    res = astNewPARAM( proc, usingexpr, INVALID )

    astFlush proc, vr

end sub

'':::::
sub rtlPrintUsingEnd( byval fileexpr as integer ) static
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.PRINTUSGEND)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval filenum as integer
    res = astNewPARAM( proc, fileexpr, INVALID )

    astFlush proc, vr

end sub

'':::::
sub rtlPrintUsing( byval fileexpr as integer, byval expr as integer, byval issemicolon as integer )
    dim proc as integer, f as integer
    dim t as integer, mask as integer
    dim res as integer, vr as integer

	astUpdNodeResult expr

	select case astGetDataType( expr )
	case IR.DATATYPE.FIXSTR, IR.DATATYPE.STRING
		f = ifuncTB(FB.RTL.PRINTUSGSTR)
	case else
		f = ifuncTB(FB.RTL.PRINTUSGVAL)
	end select

    ''
	proc = astNewFUNCT( f, symbGetFuncDataType( f ), 3 )

    '' byval filenum as integer
    res = astNewPARAM( proc, fileexpr, INVALID )

    '' s as string or byval v as double
    res = astNewPARAM( proc, expr, INVALID )

    '' byval mask as integer
	mask = 0
	if( not issemicolon ) then
		mask = mask or FB.PRINTMASK.NEWLINE or FB.PRINTMASK.ISLAST
	end if

	t = astNewCONST( mask, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, t, IR.DATATYPE.INTEGER )

    ''
    astFlush proc, vr

end sub

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' misc
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
sub rtlExit( byval errlevel as integer ) static
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.END)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' errlevel
    res = astNewPARAM( proc, errlevel, INVALID )

    astFlush proc, vr

end sub

'':::::
function rtlMemCopy( byval dst as integer, byval src as integer, byval bytes as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer, t as integer

	''
	f = ifuncTB(FB.RTL.MEMCOPY)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 3 )

    '' dst as any
    res = astNewPARAM( proc, dst, INVALID )

    '' src as any
    res = astNewPARAM( proc, src, INVALID )

    '' byval bytes as integer
    t = astNewCONST( bytes, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, t, INVALID )

    ''
    rtlMemCopy = proc

end function

'':::::
sub rtlMemSwap( byval dst as integer, byval src as integer ) static
    dim proc as integer, f as integer
    dim res as integer, t as integer, bytes as integer
    dim vr as integer, vs as integer
    dim s as integer, d as integer
    dim dtype as integer, typ as integer

	'' simple type?
	dtype = astGetDataType( dst )
	if( (dtype <> IR.DATATYPE.USERDEF) and (astGetType( dst ) = AST.NODETYPE.VAR) ) then

		d = astGetSymbol( dst )
		s = astGetSymbol( src )

		'' push src
		vr = irAllocVRVAR( dtype, s, 0 )
		irEmitPUSH vr

		'' src = dst
		vr = irAllocVRVAR( dtype, s, 0 )
		vs = irAllocVRVAR( dtype, d, 0 )
		irEmitSTORE vr, vs

		'' pop dst
		vr = irAllocVRVAR( dtype, d, 0 )
		irEmitPOP vr

		exit sub
	end if

	''
	f = ifuncTB(FB.RTL.MEMSWAP)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 3 )

    '' dst as any
    res = astNewPARAM( proc, dst, INVALID )

    '' src as any
    res = astNewPARAM( proc, src, INVALID )

    '' byval bytes as integer
	bytes = hCalcExprLen( dst )

    t = astNewCONST( bytes, IR.DATATYPE.INTEGER )
    res = astNewPARAM( proc, t, INVALID )

    ''
    astFlush proc, vr

end sub

'':::::
sub rtlStrSwap( byval str1 as integer, byval str2 as integer ) static
    dim proc as integer, f as integer
    dim res as integer, lgt as integer, s as integer, dtype as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.STRSWAP)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 4 )

    '' str1 as any
    res = astNewPARAM( proc, str1, IR.DATATYPE.STRING )

    '' byval str1len as integer
	dtype = astGetDataType( str1 )
	lgt = -1
	if( hIsStrFixed( dtype ) ) then
		lgt = hGetFixStrLen( str1 )
		if( lgt < 0 ) then lgt = 0
	end if
	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

    '' str2 as any
    res = astNewPARAM( proc, str2, IR.DATATYPE.STRING )

    '' byval str1len as integer
	dtype = astGetDataType( str2 )
	lgt = -1
	if( hIsStrFixed( dtype ) ) then
		lgt = hGetFixStrLen( str2 )
		if( lgt < 0 ) then lgt = 0
	end if
	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
	res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )

    ''
    astFlush proc, vr

end sub

'':::::
sub rtlConsoleView ( byval topexpr as integer, byval botexpr as integer )
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.CONSOLEVIEW)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' byval toprow as integer
    res = astNewPARAM( proc, topexpr, INVALID )

    '' byval botrow as integer
    res = astNewPARAM( proc, botexpr, INVALID )

    astFlush proc, vr

end sub

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' error
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

sub rtlCheckError( byval vr as integer ) static
    dim f as integer
	dim lname as string, label as integer
	dim cr as integer

	if( not env.clopt.errorcheck ) then
		exit function
	end if

	''
	lname = hMakeTmpStr
	label = symbAddLabel( lname )

	'' result == FB_RTERROR_OK? skip..
	cr = irAllocVRIMM( IR.DATATYPE.INTEGER, 0 )
	irEmitCOMPBRANCHNF IR.OP.EQ, vr, cr, label

	'' else, fb_ErrorThrow( result );
	irEmitPUSH vr

	vr = irAllocVREG( IR.DATATYPE.INTEGER )
	irEmitCALLFUNCT ifuncTB(FB.RTL.ERRORTHROW), 0, vr

	irEmitBRANCHPTR vr

	irEmitLABEL label, FALSE

	'''''symbDelLabel label

end sub

'':::::
sub rtlErrorThrow( byval errexpr as integer ) static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.ERRORTHROW)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval errnum as integer
    res = astNewPARAM( proc, errexpr, INVALID )

    ''
    astFlush proc, vr

	irEmitBRANCHPTR vr

end sub

'':::::
sub rtlErrorSetHandler( byval newhandler as integer, byval savecurrent as integer ) static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer, vs as integer

	''
	f = ifuncTB(FB.RTL.ERRORSETHANDLER)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval newhandler as uint
    res = astNewPARAM( proc, newhandler, INVALID )

    ''
    astFlush proc, vr

    if( savecurrent ) then
    	if( env.scope > 0 ) then
    		if( env.procerrorhnd = INVALID ) then
				env.procerrorhnd = symbAddTempVar( IR.DATATYPE.UINT )

				vs = irAllocVRVAR( IR.DATATYPE.UINT, env.procerrorhnd, 0 )
				irEmitSTORE vs, vr
    		end if
		end if
    end if

end sub

'':::::
function rtlErrorGetNum as integer static
    dim proc as integer, f as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.ERRORGETNUM)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 0 )

    ''
    rtlErrorGetNum = proc

end function

'':::::
sub rtlErrorSetNum( byval errexpr as integer ) static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.ERRORSETNUM)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval errnum as integer
    res = astNewPARAM( proc, errexpr, INVALID )

    ''
    astFlush proc, vr

end sub

'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' file
'':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

'':::::
sub rtlFileOpen( byval filename as integer, byval fmode as integer, byval faccess as integer, _
				 byval flock, byval filenum as integer, byval flen as integer ) static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.FILEOPEN)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 6 )

    '' filename as string
    res = astNewPARAM( proc, filename, INVALID )

    '' byval mode as integer
    res = astNewPARAM( proc, fmode, INVALID )

    '' byval access as integer
    res = astNewPARAM( proc, faccess, INVALID )

    '' byval lock as integer
    res = astNewPARAM( proc, flock, INVALID )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    '' byval len as integer
    res = astNewPARAM( proc, flen, INVALID )

    ''
    astFlush proc, vr

    rtlCheckError vr

end sub

'':::::
sub rtlFileClose( byval filenum as integer ) static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.FILECLOSE)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    ''
    astFlush proc, vr

    rtlCheckError vr

end sub

'':::::
sub rtlFileSeek( byval filenum as integer, byval newpos as integer ) static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.FILESEEK)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    '' byval newpos as integer
    res = astNewPARAM( proc, newpos, INVALID )

    ''
    astFlush proc, vr

    rtlCheckError vr

end sub

'':::::
function rtlFileTell( byval filenum as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer
    dim vr as integer

	''
	f = ifuncTB(FB.RTL.FILETELL)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 1 )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    ''
    rtlFileTell = proc

end function

'':::::
sub rtlFilePut( byval filenum as integer, byval offset as integer, byval src as integer ) static
    dim proc as integer, f as integer
    dim res as integer, dtype as integer, args as integer, lgt as integer
    dim vr as integer

	''
	dtype = astGetDataType( src )
	if( hIsString( dtype ) ) then
		f = ifuncTB(FB.RTL.FILEPUTSTR)
		args = 3
	else
		f = ifuncTB(FB.RTL.FILEPUT)
		args = 4
	end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    '' byval offset as integer
    if( offset = INVALID ) then
    	offset = astNewCONST( 0, IR.DATATYPE.INTEGER )
    end if
    res = astNewPARAM( proc, offset, INVALID )

    '' value as any | s as string
    res = astNewPARAM( proc, src, INVALID )

    if( args = 4 ) then
    	'' byval valuelen as integer
    	lgt = hCalcExprLen( src )
    	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
    	res = astNewPARAM( proc, lgt, INVALID )
    end if

    ''
    astFlush proc, vr

    rtlCheckError vr

end sub

'':::::
sub rtlFileGet( byval filenum as integer, byval offset as integer, byval dst as integer ) static
    dim proc as integer, f as integer
    dim res as integer, dtype as integer, args as integer, lgt as integer
    dim vr as integer

	''
	dtype = astGetDataType( dst )
	if( hIsString( dtype ) ) then
		f = ifuncTB(FB.RTL.FILEGETSTR)
		args = 3
	else
		f = ifuncTB(FB.RTL.FILEGET)
		args = 4
	end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    '' byval offset as integer
    if( offset = INVALID ) then
    	offset = astNewCONST( 0, IR.DATATYPE.INTEGER )
    end if
    res = astNewPARAM( proc, offset, INVALID )

    '' value as any | s as string
    res = astNewPARAM( proc, dst, INVALID )

    if( args = 4 ) then
    	'' byval valuelen as integer
    	lgt = hCalcExprLen( dst )
    	lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
    	res = astNewPARAM( proc, lgt, INVALID )
    end if

    ''
    astFlush proc, vr

    rtlCheckError vr

end sub

'':::::
function rtlFileStrInput( byval bytesexpr as integer, byval filenum as integer ) as integer static
    dim proc as integer, f as integer
    dim res as integer

	''
	f = ifuncTB(FB.RTL.FILESTRINPUT)
    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 2 )

    '' byval bytes as integer
    res = astNewPARAM( proc, bytesexpr, INVALID )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    ''
    rtlFileStrInput = proc

end function

'':::::
sub rtlFileLineInput( byval isfile as integer, byval expr as integer, byval dstexpr as integer, _
					  byval addquestion as integer, byval addnewline as integer )
    dim proc as integer, f as integer, args as integer
    dim vr as integer
    dim res as integer

	''
	if( isfile ) then
		f = ifuncTB(FB.RTL.FILELINEINPUT)
		args = 2
	else
		f = ifuncTB(FB.RTL.CONSOLELINEINPUT)
		args = 4
	end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' "byval filenum as integer" or "text as string "
    if( (not isfile) and (expr = INVALID) ) then
		expr = astNewVAR( hAllocStringConst( "" ), 0, IR.DATATYPE.FIXSTR )
	end if

    res = astNewPARAM( proc, expr, INVALID )

    '' dst as string
    res = astNewPARAM( proc, dstexpr, INVALID )

    if( args = 4 ) then
    	'' byval addquestion as integer
    	res = astNewPARAM( proc, astNewCONST( addquestion, IR.DATATYPE.INTEGER ), INVALID )

    	'' byval addnewline as integer
    	res = astNewPARAM( proc, astNewCONST( addnewline, IR.DATATYPE.INTEGER ), INVALID )
    end if

    astFlush proc, vr

end sub

'':::::
sub rtlFileInput( byval isfile as integer, byval expr as integer, _
				  byval addquestion as integer, byval addnewline as integer )
    dim proc as integer, f as integer, args as integer
    dim vr as integer
    dim res as integer

	''
	if( isfile ) then
		f = ifuncTB(FB.RTL.FILEINPUT)
		args = 1
	else
		f = ifuncTB(FB.RTL.CONSOLEINPUT)
		args = 3
	end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' "byval filenum as integer" or "text as string "
    if( (not isfile) and (expr = INVALID) ) then
		expr = astNewVAR( hAllocStringConst( "" ), 0, IR.DATATYPE.FIXSTR )
	end if

	res = astNewPARAM( proc, expr, INVALID )

    if( args = 3 ) then
    	'' byval addquestion as integer
    	res = astNewPARAM( proc, astNewCONST( addquestion, IR.DATATYPE.INTEGER ), INVALID )

    	'' byval addnewline as integer
    	res = astNewPARAM( proc, astNewCONST( addnewline, IR.DATATYPE.INTEGER ), INVALID )
    end if

    astFlush proc, vr

end sub

'':::::
sub rtlFileInputGet( byval dstexpr as integer )
    dim proc as integer, f as integer, args as integer
    dim vr as integer, lgt as integer
    dim res as integer

	''
    astUpdNodeResult dstexpr

	args = 1
	select case astGetDataType( dstexpr )
	case IR.DATATYPE.FIXSTR, IR.DATATYPE.STRING
		f = ifuncTB(FB.RTL.INPUTSTR)
		args = 2
	case IR.DATATYPE.BYTE, IR.DATATYPE.UBYTE
		f = ifuncTB(FB.RTL.INPUTBYTE)
	case IR.DATATYPE.SHORT, IR.DATATYPE.USHORT
		f = ifuncTB(FB.RTL.INPUTSHORT)
	case IR.DATATYPE.INTEGER, IR.DATATYPE.UINT, is >= IR.DATATYPE.POINTER
		f = ifuncTB(FB.RTL.INPUTINT)
	case IR.DATATYPE.SINGLE
		f = ifuncTB(FB.RTL.INPUTSINGLE)
	case IR.DATATYPE.DOUBLE
		f = ifuncTB(FB.RTL.INPUTDOUBLE)
	end select

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), args )

    '' dst as any
    res = astNewPARAM( proc, dstexpr, INVALID )

    if( args > 1 ) then
		lgt = -1
		if( hIsStrFixed( astGetDataType( dstexpr ) ) ) then
			lgt = hGetFixStrLen( dstexpr )
			if( lgt < 0 ) then lgt = 0
		end if
		lgt = astNewCONST( lgt, IR.DATATYPE.INTEGER )
		res = astNewPARAM( proc, lgt, IR.DATATYPE.INTEGER )
    end if

    astFlush proc, vr

end sub

'':::::
sub rtlFileLock( byval islock as integer, byval filenum as integer, byval iniexpr as integer, byval endexpr as integer )
    dim proc as integer, f as integer
    dim vr as integer
    dim res as integer

	''
	if( islock ) then
		f = ifuncTB(FB.RTL.FILELOCK)
	else
		f = ifuncTB(FB.RTL.FILEUNLOCK)
	end if

    proc = astNewFUNCT( f, symbGetFuncDataType( f ), 3 )

    '' byval filenum as integer
    res = astNewPARAM( proc, filenum, INVALID )

    '' byval inipos as integer
    res = astNewPARAM( proc, iniexpr, INVALID )

    '' byval endpos as integer
    res = astNewPARAM( proc, endexpr, INVALID )

    astFlush proc, vr

end sub

