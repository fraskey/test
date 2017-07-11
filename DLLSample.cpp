//+------------------------------------------------------------------+
//|                                              Sample DLL for MQL4 |
//|                   Copyright 2001-2016, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#include <afx.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include"stdafx.h"
//---
#define MT4_EXPFUNC __declspec(dllexport)
//please be noted that delete usr_Dll
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#pragma pack(push,1)
struct RateInfo
{
	__int64           ctm;
	double            open;
	double            low;
	double            high;
	double            close;
	unsigned __int64  vol_tick;
	int               spread;
	unsigned __int64  vol_real;
};
#pragma pack(pop)
//---
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BOOL APIENTRY DllMain(HANDLE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
	//---
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	//---
	return(TRUE);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MT4_EXPFUNC int __stdcall GetTestIntValue(void)
{
	printf("GetIntValue takes %d\n", 999);
	return(999);
}
//+------------------------------------------------------------------+


//Make Sure if the file is exist!
MT4_EXPFUNC bool __stdcall MyDllFindFile(wchar_t *strFileName)
{
	bool ret;
	CFileFind fileFind;
	CString strFileName1;
	strFileName1.Format(_T("%s"), strFileName);
	//	WideCharToMultiByte(CP_ACP, 0, strFileName, 256, (wchar_t *)strFileName1.GetBuffer(0), 256, NULL, NULL);
	//	strFileName1.ReleaseBuffer(0);


	if (TRUE == fileFind.FindFile(strFileName1))
	{
		ret = true;
	}
	else
	{
		ret = false;
	}
	return ret;
}

//Create New File, if already exist,empty it!
MT4_EXPFUNC bool __stdcall MyDllCreateFile(wchar_t *strFileName)
{
	bool ret;
	CFile file;
	CString strFileName1;
	strFileName1.Format(_T("%s"), strFileName);
	CFileException exp;
	if (TRUE == file.Open(strFileName1, CFile::modeCreate, &exp))
	{
		file.Close();
		ret = true;
	}
	else
	{
		ret = false;
	}
	return ret;
}

//write int to the first line of the file!
MT4_EXPFUNC bool __stdcall MyDllWriteFileIntFirst(wchar_t *strFileName, int number)
{
	CStdioFile file;
	CString strFileName1;
	strFileName1.Format(_T("%s"), strFileName);

	CString strInfo;
	strInfo.Format(_T("%d"), number);
	if (FALSE == file.Open(strFileName1, CStdioFile::modeWrite | CStdioFile::shareDenyRead | CFile::shareDenyWrite))
	{
		return false;
	}
	file.WriteString(strInfo);
	file.Close();
	return true;
}


//Read int from the first line of the file!
MT4_EXPFUNC int __stdcall MyDllReadFileIntFirst(wchar_t *strFileName)
{
	CStdioFile file;
	CString strFileName1;
	strFileName1.Format(_T("%s"), strFileName);
	int number;
	if (FALSE == file.Open(strFileName1, CFile::modeRead))
	{
		return -1;
	}
	CString strText;
	if (FALSE == file.ReadString(strText))
	{
		file.Close();
		return -2;
	}
	file.Close();
	number = _ttoi(strText);
	if ((number >= 1000) || (number <= 10))
	{
		number = -3;
	}
	return number;
}

