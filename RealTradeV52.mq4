//+------------------------------------------------------------------+
//|                                       MutiPeriodAutoTradePro.mq4 |
//|                   Copyright 2005-2017, Copyright. Personal Keep  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2017, Xuejiayong."
#property link        "http://www.mql14.com"


//引入动态链接库函数，文件操作，解决MT4无法共享文件问题
#import "DLLSample.dll"
int    GetTestIntValue(void);
bool   MyDllFindFile(string );
bool   MyDllCreateFile(string );
bool   MyDllWriteFileIntFirst(string ,int );
int    MyDllReadFileIntFirst(string );
#import




//发送电子邮件，参数subject为邮件主题，some_text为邮件内容 void SendMail( string subject, string some_text)


//通用宏定义
//////////////////////////////////////////

#define HCROSSNUMBER  50


//////////////////////////////////////////
//结束通用宏定义


//外汇商专用宏定义
//定义外汇商的交易服务器
//////////////////////////////////////////

//交易零点帐号
#define HXMSERVER "XMUK-Real 15"

//传统帐号，多次订单拒绝交易
//#define HXMSERVER "XM.COM-Real 15"

#define HFXCMSERVER "FXCM-USDReal04"
#define HFXPROSERVER "FxPro.com-Real06"
#define HMARKETSSERVER "STAGlobalInvestments-HK"
#define HEXNESSSERVER "Exness-Real3"
#define HICMARKETSSERVER "ICMarkets-Live07"
#define HTHINKMARKETSSERVER "ThinkForexUK-Live"
#define HLMAXSERVER "LMAX-LiveUK"


#define HOANDASERVER ""

//结束外汇商专用宏定义
//////////////////////////////////////////


/*定义全局交易指标，确保每天只会交易一波，true为使能，false为禁止全局交易*/
bool globaltradeflag = true;
bool anti_globaltradeflag = true;

//全局变量定义
//////////////////////////////////////////
//input double TakeProfit    =50;
double MyLotsH          =0.02;
double MyLotsL          =0.02; 
//input double TrailingStop  =30;	

//定义服务器时间和本地时间（北京时间）差
int globaltimezonediff = 5;	
	



string g_forexserver;





int Move_Av = 2;
int iBoll_B = 60;
//input int iBoll_S = 20;


int timeperiod[16];
int TimePeriodNum = 6;

//通过该全局变量控制确保买卖成对出现，规避余额不足导致的不成对情况出现
bool trade_antitradeflag ;



/*重大重要数据时间，每个周末落实第二周的情况*/
//重大重要数据期间，现有所有订单以一分钟周期重新设置止损，放大止盈，不做额外的买卖

datetime feinongtime1= D'1980.07.19 12:30:27';  // Year Month Day Hours Minutes Seconds
int feilongtimeoffset1 = 30*60;

datetime feinongtime2= D'1980.07.19 12:30:27';  // Year Month Day Hours Minutes Seconds
int feilongtimeoffset2 = 30*60;

datetime yixitime1 =   D'1980.07.19 12:30:27'; 
int yixitimeoffset1 = 2*60*60;

datetime yixitime2 =   D'1980.07.19 12:30:27'; 
int yixitimeoffset2 = 2*60*60;

datetime bigeventstime = D'1980.07.19 12:30:27'; 
int bigeventstimeoffset = 12*60*60;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/////////////////////////////////////////////////////////////////////


//后面改为局部变量
double ma_pre;
double boll_up_B_pre,boll_low_B_pre,boll_mid_B_pre;
//!!!!!!!!!!!!!!!!!!!!!!!!!

int MagicNumberOne = 10;
int MagicNumberTwo = 20;
int MagicNumberThree = 30;
int MagicNumberFour = 40;
int MagicNumberFive = 50;
int MagicNumberSix = 60;
int MagicNumberSeven = 70;
int MagicNumberEight = 80;
int MagicNumberNine = 90;
int MagicNumberTen = 100;


int AntiMagicNumberEleven = 110;
int AntiMagicNumberTwelve = 120;
int AntiMagicNumberThirteen = 130;
int AntiMagicNumberFourteen = 140;
int AntiMagicNumberFifteen = 150;
int AntiMagicNumberSixteen = 160;
int AntiMagicNumberseventeen = 170;
int AntiMagicNumbereighteen = 180;
int AntiMagicNumbernineteen = 190;
int AntiMagicNumbertwenty = 200;




string MySymbol[50];
int symbolNum;




int Freq_Count = 0;
int TwentyS_Freq = 0;
int OneM_Freq = 0;
int ThirtyS_Freq = 0;
int FiveM_Freq = 0;
int ThirtyM_Freq = 0;


//结束全局变量定义
//////////////////////////////////////////





//结构体定义
//////////////////////////////////////////

struct stBuySellPosRecord
{	
	int TradeTimePos[20];
	int NextModifyPos[20];
	double CurrentOpenPrice[20];
	double NextModifyValue1[20];
	double NextModifyValue2[20];
	int ticket;
};



stBuySellPosRecord BuySellPosRecord[50];


struct stOrderRecord
{
	int ticket;
	int SymPos;
	int buyselltype;
	int buysellminor;
	
	double stopless;
	int number;
};

stOrderRecord OrderRecord[100];

////////////////////////////////////////////////////////////////////////


struct stBoolCrossRecord
{	
	int CrossFlag[HCROSSNUMBER];//5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨
	double CrossStrongWeak[HCROSSNUMBER];	
	double CrossTrend[HCROSSNUMBER];
	int CrossBoolPos[HCROSSNUMBER];
	double StrongWeak;	
	double Trend;
	double BoolIndex;
	double BoolFlag;	
	int CrossFlagChange;
	int CrossFlagTemp;	
	int CrossFlagTempPre;	
	int ChartEvent;
};


stBoolCrossRecord BoolCrossRecord[50][16];

////////////////////////////////////////////
//定义交易文件


#define FILENOTRADEFLAG 50
#define FILETRADINGFLAG 60
#define FILETRADEDFLAG 80



string MyTradeFile[20];
string MyAntiTradeFile[20];
string MyALLTradeFile[20];
int MyTradeFlag[20];
int MyAntiTradeFlag[20];
int MyALLTradeFlag[20];
int curtradefileNum;
int tradefileNum;


////////////////////////////////////////////
//结束结构体定义
//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////



void initsymbol()
{
	string subject="";
	g_forexserver = AccountServer();

//mail test
///////////////////
subject = g_forexserver +"Init Email Send Test is Good!";
SendMail( subject, "");
//Print(subject);
////////////////

/*
	if(AccountServer() == HXMSERVER)
	{		
		MySymbol[0] = "EURUSD";
		MySymbol[1] = "AUDUSD";
		MySymbol[2] = "USDJPY";         
		MySymbol[3] = "GOLD";         
		MySymbol[4] = "GBPUSD";         
		MySymbol[5] = "CADCHF"; 
		MySymbol[6] = "EURCAD"; 	
		MySymbol[7] = "GBPAUD"; 	
		MySymbol[8] = "AUDJPY";         
		MySymbol[9] = "EURJPY"; 
		MySymbol[10] = "GBPJPY"; 	
		MySymbol[11] = "USDCAD"; 
		MySymbol[12] = "AUDCAD"; 	
		MySymbol[13] = "AUDCHF"; 
		MySymbol[14] = "CADJPY"; 
		MySymbol[15] = "EURAUD"; 
		MySymbol[16] = "GBPCHF"; 
		MySymbol[17] = "NZDCAD"; 
		MySymbol[18] = "NZDUSD"; 
		MySymbol[19] = "NZDJPY"; 
		MySymbol[20] = "USDCHF"; 	
		MySymbol[21] = "EURGBP"; 	
		MySymbol[22] = "EURCHF"; 	
		MySymbol[23] = "AUDNZD"; 	
		MySymbol[24] = "CHFJPY"; 	
		MySymbol[25] = "EURNZD"; 		
		MySymbol[26] = "GBPCAD"; 	
		MySymbol[27] = "GBPNZD"; 		
		MySymbol[28] = "USDSGD"; 	
		MySymbol[29] = "USDZAR"; 	
	
		
		symbolNum = 30;
		
	}
*/
	if(AccountServer() == HXMSERVER)
	{		
		MySymbol[0] = "EURUSD.";
		MySymbol[1] = "AUDUSD.";
		MySymbol[2] = "USDJPY.";         
		MySymbol[3] = "GOLD.";         
		MySymbol[4] = "GBPUSD.";         
		MySymbol[5] = "CADCHF."; 
		MySymbol[6] = "EURCAD."; 	
		MySymbol[7] = "GBPAUD."; 	
		MySymbol[8] = "AUDJPY.";         
		MySymbol[9] = "EURJPY."; 
		MySymbol[10] = "GBPJPY."; 	
		MySymbol[11] = "USDCAD."; 
		MySymbol[12] = "AUDCAD."; 	
		MySymbol[13] = "AUDCHF."; 
		MySymbol[14] = "CADJPY."; 
		MySymbol[15] = "EURAUD."; 
		MySymbol[16] = "GBPCHF."; 
		MySymbol[17] = "NZDCAD."; 
		MySymbol[18] = "NZDUSD."; 
		MySymbol[19] = "NZDJPY."; 
		MySymbol[20] = "USDCHF."; 	
		MySymbol[21] = "EURGBP."; 	
		MySymbol[22] = "EURCHF."; 	
		MySymbol[23] = "AUDNZD."; 	
		MySymbol[24] = "CHFJPY."; 	
		MySymbol[25] = "EURNZD."; 		
		MySymbol[26] = "GBPCAD."; 	
		MySymbol[27] = "GBPNZD."; 		
		MySymbol[28] = "USDSGD."; 	
		MySymbol[29] = "USDZAR."; 	
	
		
		symbolNum = 30;
		
	}
	else if(AccountServer() == HFXCMSERVER)
	{

		MySymbol[0] = "EURCAD"; 		
		MySymbol[1] = "AUDJPY"; 		
		MySymbol[2] = "EURNZD"; 	
		MySymbol[3] = "GBPUSD";     
		MySymbol[4] = "USDCHF"; 	
		MySymbol[5] = "AUDNZD"; 
		MySymbol[6] = "EURCHF"; 	
		MySymbol[7] = "EURUSD";
		MySymbol[8] = "NZDJPY"; 
		MySymbol[9] = "USDJPY";    	
		MySymbol[10] = "AUDUSD";				
		MySymbol[11] = "EURGBP"; 	
		MySymbol[12] = "GBPCHF"; 
		MySymbol[13] = "NZDUSD"; 		
		MySymbol[14] = "EURAUD"; 
		MySymbol[15] = "EURJPY"; 				
		MySymbol[16] = "GBPJPY"; 	
		MySymbol[17] = "USDCAD"; 
		MySymbol[18] = "GBPAUD"; 		
		MySymbol[19] = "GBPNZD"; 		
		MySymbol[20] = "CADJPY"; 		     
		MySymbol[21] = "XAUUSD";  
		
		/*           
		MySymbol[5] = "CADCHF"; 
		MySymbol[12] = "AUDCAD"; 	
		MySymbol[13] = "AUDCHF"; 
		MySymbol[17] = "NZDCAD"; 	
		MySymbol[24] = "CHFJPY"; 			
		MySymbol[26] = "GBPCAD"; 	
		MySymbol[28] = "USDSGD"; 	
		MySymbol[29] = "USDZAR"; 	
		*/
		
		
		symbolNum = 22;
	}		
	else if(AccountServer() == HFXPROSERVER)
	{
		MySymbol[0] = "AUDUSD";
		MySymbol[1] = "EURCHF";
		MySymbol[2] = "EURGBP";         
		MySymbol[3] = "EURJPY";         
		MySymbol[4] = "EURUSD";         
		MySymbol[5] = "GBPCHF"; 
		MySymbol[6] = "GBPJPY"; 	
		MySymbol[7] = "GBPUSD"; 	
		MySymbol[8] = "NZDUSD";         
		MySymbol[9] = "USDCAD"; 
		MySymbol[10] = "USDCHF"; 	
		MySymbol[11] = "USDJPY"; 
		MySymbol[12] = "AUDCAD"; 	
		MySymbol[13] = "AUDCHF"; 
		MySymbol[14] = "AUDJPY"; 
		MySymbol[15] = "AUDNZD"; 
		MySymbol[16] = "CADCHF"; 
		MySymbol[17] = "CADJPY"; 
		MySymbol[18] = "CHFJPY"; 
		MySymbol[19] = "EURAUD"; 
		MySymbol[20] = "EURCAD"; 	
		MySymbol[21] = "EURNZD"; 	
		MySymbol[22] = "GBPAUD"; 	
		MySymbol[23] = "GBPCAD"; 	
		MySymbol[24] = "GBPNZD"; 	
		MySymbol[25] = "NZDCAD"; 		
		MySymbol[26] = "NZDCHF"; 	
		MySymbol[27] = "GOLD"; 			
				
		symbolNum = 28;
		
	}	
	else if(AccountServer() == HMARKETSSERVER)
	{
		MySymbol[0] = "AUDCAD";
		MySymbol[1] = "AUDCHF";
		MySymbol[2] = "AUDJPY";         
		MySymbol[3] = "AUDNZD";         
		MySymbol[4] = "AUDUSD";         
		MySymbol[5] = "CADCHF"; 
		MySymbol[6] = "CADJPY"; 	
		MySymbol[7] = "CHFJPY"; 	
		MySymbol[8] = "EURAUD";         
		MySymbol[9] = "EURCAD"; 
		MySymbol[10] = "EURCHF"; 	
		MySymbol[11] = "EURGBP"; 
		MySymbol[12] = "EURJPY"; 	
		MySymbol[13] = "EURNZD"; 
		MySymbol[14] = "EURUSD"; 
		MySymbol[15] = "GBPAUD"; 
		MySymbol[16] = "GBPCAD"; 
		MySymbol[17] = "GBPCHF"; 
		MySymbol[18] = "GBPJPY"; 
		MySymbol[19] = "GBPNZD"; 
		MySymbol[20] = "GBPUSD"; 	
		MySymbol[21] = "NZDCAD"; 	
		MySymbol[22] = "NZDCHF"; 	
		MySymbol[23] = "NZDJPY"; 	
		MySymbol[24] = "NZDUSD"; 	
		MySymbol[25] = "USDCAD"; 	
		MySymbol[26] = "USDCHF"; 			
		MySymbol[27] = "USDJPY";	
		MySymbol[28] = "XAUUSD"; 			
				
		symbolNum = 29;
	}	
	else if(AccountServer() == HEXNESSSERVER)
	{
		MySymbol[0] = "AUDCADe";
		MySymbol[1] = "AUDCHFe";
		MySymbol[2] = "AUDJPYe";         
		MySymbol[3] = "AUDNZDe";         
		MySymbol[4] = "AUDUSDe";         
		MySymbol[5] = "CADCHFe"; 
		MySymbol[6] = "CADJPYe"; 	
		MySymbol[7] = "CHFJPYe"; 	
		MySymbol[8] = "EURAUDe";         
		MySymbol[9] = "EURCADe"; 
		MySymbol[10] = "EURCHFe"; 	
		MySymbol[11] = "EURGBPe"; 
		MySymbol[12] = "EURJPYe"; 	
		MySymbol[13] = "EURNZDe"; 
		MySymbol[14] = "EURUSDe"; 
		MySymbol[15] = "GBPAUDe"; 
		MySymbol[16] = "GBPCADe"; 
		MySymbol[17] = "GBPCHFe"; 	
		MySymbol[18] = "GBPJPYe"; 
		MySymbol[19] = "GBPNZDe"; 
		MySymbol[20] = "GBPUSDe"; 	
		MySymbol[21] = "NZDJPYe"; 	
		MySymbol[22] = "NZDUSDe"; 	
		MySymbol[23] = "USDCADe"; 	
		MySymbol[24] = "USDCHFe"; 	
		MySymbol[25] = "USDJPYe"; 	
		MySymbol[26] = "USDSGDe"; 		
					
		//MySymbol[26] = "XAUUSDe";  
					
		
		//MySymbol[28] = "NZDCADe"; 
				
		symbolNum = 27;
	}	
	else if(AccountServer() == HICMARKETSSERVER)
	{
		MySymbol[0] = "AUDCAD";
		MySymbol[1] = "AUDCHF";
		MySymbol[2] = "AUDJPY";         
		MySymbol[3] = "AUDNZD";         
		MySymbol[4] = "AUDUSD";         
		MySymbol[5] = "CADCHF"; 
		MySymbol[6] = "CADJPY"; 	
		MySymbol[7] = "CHFJPY"; 	
		MySymbol[8] = "EURAUD";         
		MySymbol[9] = "EURCAD"; 
		MySymbol[10] = "EURCHF"; 	
		MySymbol[11] = "EURGBP"; 
		MySymbol[12] = "EURJPY"; 	
		MySymbol[13] = "EURNZD"; 
		MySymbol[14] = "EURUSD"; 
		MySymbol[15] = "GBPAUD"; 
		MySymbol[16] = "GBPCAD"; 
		MySymbol[17] = "GBPCHF"; 
		MySymbol[18] = "GBPJPY"; 
		MySymbol[19] = "GBPNZD"; 
		MySymbol[20] = "GBPUSD"; 	
		MySymbol[21] = "NZDCAD"; 	
		MySymbol[22] = "NZDCHF"; 	
		MySymbol[23] = "NZDJPY"; 	
		MySymbol[24] = "NZDUSD"; 	
		MySymbol[25] = "USDCAD"; 	
		MySymbol[26] = "USDCHF"; 			
		MySymbol[27] = "USDJPY";	
		MySymbol[28] = "XAUUSD"; 			
				
		symbolNum = 29;
	}		
		
	else if(AccountServer() == HTHINKMARKETSSERVER)
	{
		MySymbol[0] = "AUDCAD";
		MySymbol[1] = "AUDCHF";
		MySymbol[2] = "AUDJPY";         
		MySymbol[3] = "AUDNZD";         
		MySymbol[4] = "AUDUSD";         
		MySymbol[5] = "CADCHF"; 
		MySymbol[6] = "CADJPY"; 	
		MySymbol[7] = "CHFJPY"; 	
		MySymbol[8] = "EURAUD";         
		MySymbol[9] = "EURCAD"; 
		MySymbol[10] = "EURCHF"; 	
		MySymbol[11] = "EURGBP"; 
		MySymbol[12] = "EURJPY"; 	
		MySymbol[13] = "EURNZD"; 
		MySymbol[14] = "EURUSD"; 
		MySymbol[15] = "GBPAUD"; 
		MySymbol[16] = "GBPCAD"; 
		MySymbol[17] = "GBPCHF"; 
		MySymbol[18] = "GBPJPY"; 
		MySymbol[19] = "GBPNZD"; 
		MySymbol[20] = "GBPUSD"; 	
		MySymbol[21] = "NZDCAD"; 	
		MySymbol[22] = "NZDCHF"; 	
		MySymbol[23] = "NZDJPY"; 	
		MySymbol[24] = "NZDUSD"; 	
		MySymbol[25] = "USDCAD"; 	
		MySymbol[26] = "USDCHF"; 			
		MySymbol[27] = "USDJPY";	
		MySymbol[28] = "XAUUSDp"; 			
				
		symbolNum = 29;
	}		
		
	else if(AccountServer() == HLMAXSERVER)
	{
		MySymbol[0] = "AUDCAD.lmx";
		MySymbol[1] = "AUDCHF.lmx";
		MySymbol[2] = "AUDJPY.lmx";         
		MySymbol[3] = "AUDNZD.lmx";         
		MySymbol[4] = "AUDUSD.lmx";         
		MySymbol[5] = "CADCHF.lmx"; 
		MySymbol[6] = "CADJPY.lmx"; 	
		MySymbol[7] = "CHFJPY.lmx"; 	
		MySymbol[8] = "EURAUD.lmx";         
		MySymbol[9] = "EURCAD.lmx"; 
		MySymbol[10] = "EURCHF.lmx"; 	
		MySymbol[11] = "EURGBP.lmx"; 
		MySymbol[12] = "EURJPY.lmx"; 	
		MySymbol[13] = "EURNZD.lmx"; 
		MySymbol[14] = "EURUSD.lmx"; 
		MySymbol[15] = "GBPAUD.lmx"; 
		MySymbol[16] = "GBPCAD.lmx"; 
		MySymbol[17] = "GBPCHF.lmx"; 
		MySymbol[18] = "GBPJPY.lmx"; 
		MySymbol[19] = "GBPNZD.lmx"; 
		MySymbol[20] = "GBPUSD.lmx"; 	
		MySymbol[21] = "NZDCAD.lmx"; 	
		MySymbol[22] = "NZDCHF.lmx"; 	
		MySymbol[23] = "NZDJPY.lmx"; 	
		MySymbol[24] = "NZDUSD.lmx"; 	
		MySymbol[25] = "USDCAD.lmx"; 	
		MySymbol[26] = "USDCHF.lmx"; 			
		MySymbol[27] = "USDJPY.lmx";	
		MySymbol[28] = "XAUUSD.lmx"; 			
				
		symbolNum = 29;
	}				
		
	else if(AccountServer() == HOANDASERVER)
	{
		MySymbol[0] = "EURUSD";
		MySymbol[1] = "AUDUSD";
		MySymbol[2] = "USDJPY";         
		MySymbol[3] = "XAUUSD-2";         
		MySymbol[4] = "GBPUSD";         
		MySymbol[5] = "CADCHF"; 
		MySymbol[6] = "EURCAD"; 	
		MySymbol[7] = "GBPAUD"; 	
		MySymbol[8] = "AUDJPY";         
		MySymbol[9] = "EURJPY"; 
		MySymbol[10] = "GBPJPY"; 	
		MySymbol[11] = "USDCAD"; 
		MySymbol[12] = "AUDCAD"; 	
		MySymbol[13] = "AUDCHF"; 
		MySymbol[14] = "CADJPY"; 
		MySymbol[15] = "EURAUD"; 
		MySymbol[16] = "GBPCHF"; 
		MySymbol[17] = "NZDCAD"; 
		MySymbol[18] = "NZDUSD"; 
		MySymbol[19] = "NZDJPY"; 
		MySymbol[20] = "USDCHF";
	 	
		MySymbol[21] = "EURGBP"; 	
		MySymbol[22] = "EURCHF"; 	
		MySymbol[23] = "AUDNZD"; 	
		MySymbol[24] = "CHFJPY"; 	
		MySymbol[25] = "EURNZD"; 	
		
		MySymbol[26] = "GBPCAD"; 	
		MySymbol[27] = "GBPNZD"; 	
		
		MySymbol[28] = "USDSGD"; 	
		MySymbol[29] = "USDZAR"; 	
	
			
		symbolNum = 4;
	}	
	
	else
	{		
		symbolNum = 0;
		MySymbol[0] = "EURUSD";		
		Print("Bad Connect;Server name is ", AccountServer());	
				
	}
		
	
		
}

/*暂时未用到周线*/

void inittiimeperiod()
{
	timeperiod[0] = PERIOD_M1;
	timeperiod[1] = PERIOD_M5;
	timeperiod[2] = PERIOD_M30;
	timeperiod[3] = PERIOD_H4;
	timeperiod[4] = PERIOD_D1;
	timeperiod[5] = PERIOD_W1;
	
	TimePeriodNum = 5;
	
}


void initmagicnumber()
{
	MagicNumberOne = 10;
	MagicNumberTwo = 20;
	MagicNumberThree = 30;
	MagicNumberFour = 40;
	MagicNumberFive = 50;
	MagicNumberSix = 60;
	MagicNumberSeven = 70;
	MagicNumberEight = 80;
	MagicNumberNine = 90;
	MagicNumberTen = 100;


	/*对冲买卖点*/
	AntiMagicNumberEleven = 110;
	AntiMagicNumberTwelve = 120;
	AntiMagicNumberThirteen = 130;
	AntiMagicNumberFourteen = 140;
	AntiMagicNumberFifteen = 150;
	AntiMagicNumberSixteen = 160;
	AntiMagicNumberseventeen = 170;
	AntiMagicNumbereighteen = 180;
	AntiMagicNumbernineteen = 190;
	AntiMagicNumbertwenty = 200;
	
	
}

bool forexserverconnect()
{
	
	bool connectflag = false;
	
	if(AccountServer() == HXMSERVER)
	{		
		
		MyLotsH          =0.02;
		MyLotsL          =0.02; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;			
		
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}
	
	else if(AccountServer() == HFXCMSERVER)
	{
		
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;			
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}		
	else if(AccountServer() == HFXPROSERVER)
	{
		
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}	
	else if(AccountServer() == HMARKETSSERVER)
	{
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 8;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}	
	else if(AccountServer() == HEXNESSSERVER)
	{
		MyLotsH          =0.02;
		MyLotsL          =0.02; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 8;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}	
	else if(AccountServer() == HICMARKETSSERVER)
	{
		MyLotsH          =0.02;
		MyLotsL          =0.02; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}		
	else if(AccountServer() == HTHINKMARKETSSERVER)
	{
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}			
	
	else if(AccountServer() == HLMAXSERVER)
	{
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 8;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}				
	
	else if(AccountServer() == HOANDASERVER)
	{
		
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;	
				
		Print("Good Connect;Server name is ", AccountServer());	
		connectflag = true;				
	}	
	else
	{
		
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 5;	
				
		
		Print("Bad Connect;Server name is ", AccountServer());	
		connectflag = false;				
	}
		
	return connectflag;

	
}


void initfile()
{
	
	//test file
	string myaddress = "C:\\mytest\\mytest.bin";	
	Print(".....file function test...........");
	ForceWriteFileInt(myaddress,20);    
	ForceWriteFileInt(myaddress,30);   
	Print(".....end file funciton test............."); 

	
	//其中三个账户参与文件记录
	tradefileNum = 3;
	
	MyTradeFile[0] = 	"C:\\mytest\\HLMAXtrade.bin";
	MyAntiTradeFile[0] = 	"C:\\mytest\\HLMAXantitrade.bin";
	MyALLTradeFile[0] = 	"C:\\mytest\\HLMAXalltrade.bin";
	
	MyTradeFile[1] = 	"C:\\mytest\\HTHINKMARKETStrade.bin";
	MyAntiTradeFile[1] = 	"C:\\mytest\\HTHINKMARKETSantitrade.bin";
	MyALLTradeFile[1] = 	"C:\\mytest\\HTHINKMARKETSalltrade.bin";
	
	MyTradeFile[2] = 	"C:\\mytest\\HXMtrade.bin";
	MyAntiTradeFile[2] = 	"C:\\mytest\\HXMantitrade.bin";
	MyALLTradeFile[2] = 	"C:\\mytest\\HXMalltrade.bin";
	

	if(AccountServer() == HLMAXSERVER)
	{
		curtradefileNum = 0;
		Print("Current file point is ", curtradefileNum);	
		
		MyTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
		MyAntiTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
		MyALLTradeFlag[curtradefileNum] = FILENOTRADEFLAG;		
		ForceWriteFileInt(MyTradeFile[curtradefileNum],FILENOTRADEFLAG);
		ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILENOTRADEFLAG);
		ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILENOTRADEFLAG);				
		
	}				
	else if(AccountServer() == HTHINKMARKETSSERVER)
	{
		curtradefileNum = 1;
		Print("Current file point is ", curtradefileNum);	
		MyTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
		MyAntiTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
		MyALLTradeFlag[curtradefileNum] = FILENOTRADEFLAG;		
		ForceWriteFileInt(MyTradeFile[curtradefileNum],FILENOTRADEFLAG);		
		ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILENOTRADEFLAG);
		ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILENOTRADEFLAG);					
	}					
	else if(AccountServer() == HXMSERVER)
	{		
		curtradefileNum = 2;
		Print("Current file point is ", curtradefileNum);		
		MyTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
		MyAntiTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
		MyALLTradeFlag[curtradefileNum] = FILENOTRADEFLAG;		
		ForceWriteFileInt(MyTradeFile[curtradefileNum],FILENOTRADEFLAG);	
		ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILENOTRADEFLAG);
		ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILENOTRADEFLAG);							
	}
	else
	{		
		curtradefileNum = -1;
		Print("Not particpate fie Current file point is ", curtradefileNum);			
	}
	
	
	
	//设置有大量交易单的状况为交易中状态
	if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))	
	{
		

	
		if(ordercountall()>=5)
		{

				ForceWriteFileInt(MyTradeFile[curtradefileNum],FILETRADINGFLAG);						

		}		

	
		if(anti_ordercountall()>=5)
		{
			

				ForceWriteFileInt(MyAntiTradeFlag[curtradefileNum],FILETRADINGFLAG);						

		}		
	
	
	
		if(all_ordercountall()>=5)
		{

				ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILETRADINGFLAG);						

		}		
		

	}
	
	
	
	
	         
	
}


void autoadjestfile()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int i;
	datetime timelocal;	

	SymPos = 0;
	/*每隔五分钟算一次*/
	timeperiodnum = 1;
	
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;

	
	/*确保交易时间段，来临前开启全局交易交易标记*/
	if ((TimeHour(timelocal) >= 12 )&& (TimeHour(timelocal) <13 )) 
	{	
		
		//确保是每个周期五分钟计算一次，而不是每个tick计算一次
		if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
		{
								
								
				if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))
				{
					
					MyTradeFlag[curtradefileNum] = FILENOTRADEFLAG;
					MyAntiTradeFlag[curtradefileNum] = FILENOTRADEFLAG;	
					ForceWriteFileInt(MyTradeFile[curtradefileNum],FILENOTRADEFLAG);	
					ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILENOTRADEFLAG);		

					//周一重新调整，没必要
					//if (TimeDayOfWeek(timelocal) == 1)
					{						
						MyALLTradeFlag[curtradefileNum] = FILENOTRADEFLAG;	
						ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILENOTRADEFLAG);								
					}					
					
					//再次扫描确认文件状态正确
					if(TimeMinute(timelocal) >= 30 )
					{
					
						for(i = 0; i < tradefileNum;i++)
						{
							if(FILETRADEDFLAG == ReadFileInt(MyTradeFile[i]))
							{
								Sleep(1000);
								ForceWriteFileInt(MyTradeFile[i],FILENOTRADEFLAG);
								Print("something maybe is wrong with trade file: ", MyTradeFile[i]);																			
								
							}
							
							if(FILETRADEDFLAG == ReadFileInt(MyAntiTradeFlag[i]))
							{
								Sleep(1000);
								ForceWriteFileInt(MyAntiTradeFlag[i],FILENOTRADEFLAG);
								Print("something maybe is wrong with antitrade file: ", MyAntiTradeFlag[i]);																			
								
							}
							
							//周一重新调整，没必要
							//if (TimeDayOfWeek(timelocal) == 1)
							{		
								
								if(FILETRADEDFLAG == ReadFileInt(MyALLTradeFile[i]))
								{
									Sleep(1000);
									ForceWriteFileInt(MyALLTradeFile[i],FILENOTRADEFLAG);
									Print("something maybe is wrong with alltrade file: ", MyALLTradeFile[i]);																			
									
								}											
								
							}								
							
																															
							
						}						
						
					}
					
						
	
					if(ordercountall()>=5)
					{
			
							ForceWriteFileInt(MyTradeFile[curtradefileNum],FILETRADINGFLAG);						
			
					}		
			
				
					if(anti_ordercountall()>=5)
					{
						
			
							ForceWriteFileInt(MyAntiTradeFlag[curtradefileNum],FILETRADINGFLAG);						
			
					}		
				
				
				
					if(all_ordercountall()>=5)
					{
			
							ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILETRADINGFLAG);						
			
					}		
						
				
										
						
						
								
					
				}
	
		}		
		
	}
	

	
	
}


void transferfiletoflag()
{
	int i;
	
	datetime timelocal;	
	bool flag ;
	

	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;


	SymPos = 0;
	/*每隔一分钟算一次*/
	timeperiodnum = 0;
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	//确保是每个周期一分钟计算一次，而不是每个tick计算一次
	if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent == iBars(my_symbol,my_timeperiod))
	{
		return;	
	}	

	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;
	
	
	for(i = 0; i < tradefileNum;i++)
	{
		MyTradeFlag[i] = ReadFileInt(MyTradeFile[i]);
		MyAntiTradeFlag[i] = ReadFileInt(MyAntiTradeFile[i]);		
		MyALLTradeFlag[i] = ReadFileInt(MyALLTradeFile[i]);			
	}
	
	
	//设置有大量交易单的状况为交易中状态
	if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))	
	{
		
		if(FILETRADINGFLAG != MyTradeFlag[curtradefileNum])
		{
		
			if(ordercountall()>=5)
			{
				
				if ((TimeMinute(timelocal) == 25 )||(TimeMinute(timelocal) == 27 )	||(TimeMinute(timelocal) == 29 ))		
				{
					ForceWriteFileInt(MyTradeFile[curtradefileNum],FILETRADINGFLAG);						
					
				}	
				
			}		
			
		}		
		
		if(FILETRADINGFLAG != MyAntiTradeFlag[curtradefileNum])
		{
		
			if(anti_ordercountall()>=5)
			{
				
				if ((TimeMinute(timelocal) == 25 )||(TimeMinute(timelocal) == 27 )	||(TimeMinute(timelocal) == 29 ))		
				{
					ForceWriteFileInt(MyAntiTradeFlag[curtradefileNum],FILETRADINGFLAG);						
					
				}	
				
			}		
			
		}				
		
		
		if(FILETRADINGFLAG != MyALLTradeFlag[curtradefileNum])
		{
		
			if(all_ordercountall()>=5)
			{
				
				if ((TimeMinute(timelocal) == 25 )||(TimeMinute(timelocal) == 27 )	||(TimeMinute(timelocal) == 29 ))		
				{
					ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILETRADINGFLAG);						
					
				}	
				
			}		
			
		}				
		
			
		
	}

	//当没有处于交易中的平台时，设置初始状态
	if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))	
	{
		flag = true;
		
		for(i = 0; i < tradefileNum;i++)
		{
			if(MyTradeFlag[i] == FILETRADINGFLAG)
			{
					flag = false;
			}
			
		}
		
		//当前没有正在交易的平台，这个时候将所有的标记设置为NOtraded
		if(flag == true)
		{
			
			if(FILENOTRADEFLAG != MyTradeFlag[curtradefileNum])
			{
				
					ForceWriteFileInt(MyTradeFile[curtradefileNum],FILENOTRADEFLAG);					
			}

			
		}
		

		flag = true;
		
		for(i = 0; i < tradefileNum;i++)
		{
			if(MyAntiTradeFlag[i] == FILETRADINGFLAG)
			{
					flag = false;
			}
			
		}
		
		//当前没有正在交易的平台，这个时候将所有的标记设置为NOtraded
		if(flag == true)
		{
			
			if(FILENOTRADEFLAG != MyAntiTradeFlag[curtradefileNum])
			{
				
					ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILENOTRADEFLAG);					
			}

			
		}
		

		flag = true;
		
		for(i = 0; i < tradefileNum;i++)
		{
			if(MyALLTradeFlag[i] == FILETRADINGFLAG)
			{
					flag = false;
			}
			
		}
		
		//当前没有正在交易的平台，这个时候将所有的标记设置为NOtraded
		if(flag == true)
		{
			
			if(FILENOTRADEFLAG != MyALLTradeFlag[curtradefileNum])
			{
				
					ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILENOTRADEFLAG);					
			}

			
		}
				
		
		
		
		
	}
	
	
}


bool tradedok()
{
	
	bool ret = false;
	int count = 0;
	int i;
	for(i = 0; i < tradefileNum;i++)
	{
		if (FILETRADEDFLAG == MyTradeFlag[i])
		{
			count++;
		}			
	}	
	if(count>=1)
	{
		ret = true;		
	}
	return ret;
	
}

bool antitradedok()
{
	
	bool ret = false;
	int count = 0;
	int i;
	for(i = 0; i < tradefileNum;i++)
	{
		if (FILETRADEDFLAG == MyAntiTradeFlag[i])
		{
			count++;
		}			
	}	
	if(count>=2)
	{
		ret = true;		
	}
	return ret;
	
}


bool alltradedok()
{
	
	bool ret = false;
	int count = 0;
	int i;
	for(i = 0; i < tradefileNum;i++)
	{
		if (FILETRADEDFLAG == MyALLTradeFlag[i])
		{
			count++;
		}			
	}	
	if(count>=1)
	{
		ret = true;		
	}
	return ret;
	
}


void openallsymbo()
{
   
	int SymPos;

	string my_symbol;
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{
		
		my_symbol =   MySymbol[SymPos];
		
   	if(SymbolSelect(my_symbol,true)==false)
   	{
   	      Print("Open symbo error :" + my_symbol);
   	}
   }

}


int MakeMagic(int SymPos,int Magic)
{
   int symbolvalue;
   int subvalue;
	datetime timelocal;	

  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
	subvalue = (TimeDayOfWeek(timelocal))%5;  
	 
  symbolvalue = SymPos*1000 + Magic + subvalue;
  
   return symbolvalue;
}





void setglobaltradeflag(bool flag)
{

	globaltradeflag = flag;
}


bool getglobaltradeflag(void)
{

	return globaltradeflag ;
}



/*启动时初始化全局交易标记*/
void initglobaltradeflag()
{

	datetime timelocal;	

  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;

	//14点前不做趋势单，主要针对1分钟线和五分钟线，非欧美时间趋势不明显，针对趋势突破单，要用这个来检测
	//最原始的是下午4点前不做趋势单，通过扩大止损来寻找更多机会
	
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )) 
	{
		
		setglobaltradeflag(true);		
		
		
	}	
	else
	{
		setglobaltradeflag(false);				
	}
	
	if (((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <=24 )) ||(TimeHour(timelocal) <3 ))
	{
		
		/*在对冲盘已经清空的情况下设置Flag*/
		if((ordercountall()>4)&&(anti_ordercountall()<2))
		{		
			setglobaltradeflag(true);		
			anti_setglobaltradeflag(false);		
			Print("initglobaltradeflag  setglobaltradeflag true and anti_setglobaltradeflag set false");						
		}
		
		/*在对冲盘已经清空的情况下设置Flag*/
		if((ordercountall()<2)&&(anti_ordercountall()>4))
		{		
			setglobaltradeflag(false);		
			anti_setglobaltradeflag(true);		
			Print("initglobaltradeflag  setglobaltradeflag false and anti_setglobaltradeflag set true");						
		}
								
	}		
	
	
	
}


/*在交易时间段来临前确保使能全局交易标记*/
void enableglobaltradeflag()
{
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
		
	datetime timelocal;	

	SymPos = 0;
	/*每隔五分钟算一次*/
	timeperiodnum = 1;
	
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;

	
	/*确保交易时间段，来临前开启全局交易交易标记*/
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <14 )) 
	{			
		//确保是每个周期五分钟计算一次，而不是每个tick计算一次
		if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
		{		
			//if(false == getglobaltradeflag())
			{
				setglobaltradeflag(true);		
				Print("Enable Global Trade!");	 					
			}
			if ((TimeMinute(timelocal) >= 28 )&& (TimeMinute(timelocal) <=32 )) 
			{				
				string subject = g_forexserver +":Will Soon begin to trade !";
				SendMail( subject, "");		
				Print("Send Start Trade Email!");		
			}
			
		}
	}	

	
}



/*初始化交易手数*/
void initglobalamount()
{

	datetime timelocal;
  timelocal = TimeCurrent() + globaltimezonediff*60*60;
    
	/*关闭所有现存订单*/
	//不合理	
	//ordercloseall();
	
	if(AccountBalance() <= 2000)
	{
		MyLotsH          =0.02;
		MyLotsL          =0.01; 	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 				
	}
	else if((AccountBalance() > 2000)&&(AccountBalance() <= 4000))
	{
		MyLotsH          =0.04;
		MyLotsL          =0.02;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}
	else if((AccountBalance() > 4000)&&(AccountBalance() <= 6000))
	{
		MyLotsH          =0.06;
		MyLotsL          =0.03;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}
	else if((AccountBalance() > 6000)&&(AccountBalance() <= 8000))
	{
		MyLotsH          =0.08;
		MyLotsL          =0.04;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}
	else if((AccountBalance() > 8000)&&(AccountBalance() <= 10000))
	{
		MyLotsH          =0.10;
		MyLotsL          =0.05;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}	
	else if((AccountBalance() > 10000)&&(AccountBalance() <= 12000))
	{
		MyLotsH          =0.12;
		MyLotsL          =0.06;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}
	else if((AccountBalance() > 12000)&&(AccountBalance() <= 14000))
	{
		MyLotsH          =0.14;
		MyLotsL          =0.07;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}
	else if((AccountBalance() > 14000)&&(AccountBalance() <= 16000))
	{
		MyLotsH          =0.16;
		MyLotsL          =0.08;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}
	else if((AccountBalance() > 16000)&&(AccountBalance() <= 18000))
	{
		MyLotsH          =0.18;
		MyLotsL          =0.09;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}		
	else if((AccountBalance() > 18000)&&(AccountBalance() <= 20000))
	{
		MyLotsH          =0.2;
		MyLotsL          =0.1;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}		
	else if((AccountBalance() > 20000)&&(AccountBalance() <= 40000))
	{
		MyLotsH          =0.4;
		MyLotsL          =0.2;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}		
	else if((AccountBalance() > 40000)&&(AccountBalance() <= 60000))
	{
		MyLotsH          =0.6;
		MyLotsL          =0.3;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}		
	else if((AccountBalance() > 60000)&&(AccountBalance() <= 80000))
	{
		MyLotsH          =0.8;
		MyLotsL          =0.4;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}		
	else if((AccountBalance() > 80000)&&(AccountBalance() <= 100000))
	{
		MyLotsH          =1;
		MyLotsL          =0.5;	
		Print("init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}			

	else
	{
		MyLotsH          =0.02;
		MyLotsL          =0.01;	
		Print("default init Amount is = "+MyLotsH+":"+MyLotsL);	 							
	}		
	
	
	
}


/*每天交易前计算交易手数，只在下午一点计算，每隔5分钟算一次*/
void autoadjustglobalamount()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
		
	datetime timelocal;	

	SymPos = 0;
	/*每隔五分钟算一次*/
	timeperiodnum = 1;
	
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;

	
	/*确保交易时间段，来临前开启全局交易交易标记*/
	if ((TimeHour(timelocal) >= 12 )&& (TimeHour(timelocal) <13 )) 
	{	
		
		//确保是每个周期五分钟计算一次，而不是每个tick计算一次
		if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
		{					

			if(AccountBalance() <= 2000)
			{
				MyLotsH          =0.02;
				MyLotsL          =0.01; 	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 				
			}
			else if((AccountBalance() > 2000)&&(AccountBalance() <= 4000))
			{
				MyLotsH          =0.04;
				MyLotsL          =0.02;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}
			else if((AccountBalance() > 4000)&&(AccountBalance() <= 6000))
			{
				MyLotsH          =0.06;
				MyLotsL          =0.03;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}
			else if((AccountBalance() > 6000)&&(AccountBalance() <= 8000))
			{
				MyLotsH          =0.08;
				MyLotsL          =0.04;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}
			else if((AccountBalance() > 8000)&&(AccountBalance() <= 10000))
			{
				MyLotsH          =0.10;
				MyLotsL          =0.05;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}	
			else if((AccountBalance() > 10000)&&(AccountBalance() <= 12000))
			{
				MyLotsH          =0.12;
				MyLotsL          =0.06;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}
			else if((AccountBalance() > 12000)&&(AccountBalance() <= 14000))
			{
				MyLotsH          =0.14;
				MyLotsL          =0.07;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}
			else if((AccountBalance() > 14000)&&(AccountBalance() <= 16000))
			{
				MyLotsH          =0.16;
				MyLotsL          =0.08;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}
			else if((AccountBalance() > 16000)&&(AccountBalance() <= 18000))
			{
				MyLotsH          =0.18;
				MyLotsL          =0.09;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}		
			else if((AccountBalance() > 18000)&&(AccountBalance() <= 20000))
			{
				MyLotsH          =0.2;
				MyLotsL          =0.1;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}		
			else if((AccountBalance() > 20000)&&(AccountBalance() <= 40000))
			{
				MyLotsH          =0.4;
				MyLotsL          =0.2;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}		
			else if((AccountBalance() > 40000)&&(AccountBalance() <= 60000))
			{
				MyLotsH          =0.6;
				MyLotsL          =0.3;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}		
			else if((AccountBalance() > 60000)&&(AccountBalance() <= 80000))
			{
				MyLotsH          =0.8;
				MyLotsL          =0.4;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}		
			else if((AccountBalance() > 80000)&&(AccountBalance() <= 100000))
			{
				MyLotsH          =1;
				MyLotsL          =0.5;	
				Print("autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}			

			else
			{
				MyLotsH          =0.02;
				MyLotsL          =0.01;	
				Print("default autoadjustglobalamount Amount is = "+MyLotsH+":"+MyLotsL);	 							
			}		
			

	
		}		
		
	}
	

	
}


bool OneMOrderCloseStatus(int MagicNumber)
{
	bool status;
	int i;
	status = true;

	if ( OrdersTotal() > 200)
	{
		Print("OneMOrderKeepNumber exceed 200");
		return false;
	}
	
	for (i = 0; i < OrdersTotal(); i++)
	{
       if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
       {
              if((OrderCloseTime() == 0)&&(OrderMagicNumber()== MagicNumber))
              {
              
                  status= false;
                  break;
              
              }
                
       }
	}
   return status;
}



int  InitcrossValue(int SymPos,int timeperiodnum)
{	
	double myma,myboll_up_B,myboll_low_B,myboll_mid_B;
	double myma_pre,myboll_up_B_pre,myboll_low_B_pre,myboll_mid_B_pre;

	
	string my_symbol;

	int my_timeperiod;
	
	int crossflag;
	int j ;
	int i;
	int countnumber = 0;
	my_symbol =   MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];	
	
	/*确保覆盖最近6年以内数据*/
	if(timeperiodnum<5)
	{
		countnumber = 500;
	}
	else
	{
		countnumber = 500;
	}
	
	if(iBars(my_symbol,my_timeperiod) <countnumber)
	{
		Print(my_symbol + ":"+my_timeperiod+":Bar Number less than "+countnumber+"which is :" + iBars(my_symbol,my_timeperiod));
		return -1;
	}

	for (i = 2; i< countnumber;i++)
	{
		
		crossflag = 0;     
		myma=iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,i-1);  
		myboll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,i-1);   
		myboll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,i-1);
		myboll_mid_B = (	myboll_up_B +  myboll_low_B)/2;

		myma_pre = iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,i); 
		myboll_up_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,i);      
		myboll_low_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,i);
		myboll_mid_B_pre = (myboll_up_B_pre + myboll_low_B_pre)/2;

		if((myma >myboll_up_B) && (myma_pre < myboll_up_B_pre ) )
		{
				crossflag = 5;		
		}
		
		if((myma <myboll_up_B) && (myma_pre > myboll_up_B_pre ) )
		{
				crossflag = 4;
		}
			
		if((myma < myboll_low_B) && (myma_pre > myboll_low_B_pre ) )
		{
				crossflag = -5;
		}
			
		if((myma > myboll_low_B) && (myma_pre < myboll_low_B_pre ) )
		{
				crossflag = -4;	
		}
	
		if((myma > myboll_mid_B) && (myma_pre < myboll_mid_B_pre ))
		{
				crossflag = 1;				
		}	
		if( (myma < myboll_mid_B) && (myma_pre > myboll_mid_B_pre ))
		{
				crossflag = -1;								
		}			
		
		if(0 != 	crossflag)		
		{
				BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[j] = crossflag;
				//BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[j] = TimeCurrent() - i*Period()*60;
				BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[j] = iBars(my_symbol,my_timeperiod)-i;
				j++;
				if (j >= (HCROSSNUMBER-1))
				{
					break;
				}
		}

	}
	
	return 0;

}


void InitBuySellPos()
{
	int SymPos;
	int i ;
	string my_symbol;
	int my_timeperiod;
	double vbid;
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{
		
		my_symbol =   MySymbol[SymPos];
		vbid    = MarketInfo(my_symbol,MODE_BID);	
		for(i = 0; i < 20;i++)
		{			
			BuySellPosRecord[SymPos].NextModifyPos[i] = 1000000000;
			BuySellPosRecord[SymPos].CurrentOpenPrice[i] = vbid;
			
		}

		my_timeperiod = timeperiod[0];				
		BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);			
		BuySellPosRecord[SymPos].TradeTimePos[8] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[9] = iBars(my_symbol,my_timeperiod);
				
		my_timeperiod = timeperiod[1];				
		BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(my_symbol,my_timeperiod);	
		
		BuySellPosRecord[SymPos].TradeTimePos[10] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[11] = iBars(my_symbol,my_timeperiod);					
		BuySellPosRecord[SymPos].TradeTimePos[12] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[13] = iBars(my_symbol,my_timeperiod);			
				
		my_timeperiod = timeperiod[2];				
		
		
		BuySellPosRecord[SymPos].TradeTimePos[14] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[15] = iBars(my_symbol,my_timeperiod);			
										
		
	}
		
}


void InitMA(int SymPos,int timeperiodnum)
{

	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double StrongWeak;
	int my_timeperiod;	
	string my_symbol;
	
	my_symbol = MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];	
	
	MAThree=iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,1); 
	MAThen=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,1);  
	MAThenPre=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,2); 

	
	MAFive=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,1); 
	MAThentyOne=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,1); 
	MASixty=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,1); 
 
	MAFivePre=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,2); 
	MAThentyOnePre=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,2); 
	MASixtyPre=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,2); 
 
 	StrongWeak =0.5;
 

	if((MAThree > MAThen)&&(MAThenPre<MAThen))
	{		
		StrongWeak =0.9;	
	}
	else if ((MAThree < MAThen)&&(MAThenPre>MAThen))
	{
		StrongWeak =0.1;
	
	}
	else
	{
		StrongWeak =0.5;

	}

 			
	BoolCrossRecord[SymPos][timeperiodnum].Trend = StrongWeak;
			
			

 
 
	StrongWeak =0.5;

	if(MAFive > MAThentyOne)
	{
			
		/*多均线多头向上*/
		if(MASixty < MAThentyOne)
		{
			 StrongWeak =0.9;
		}
		else if ((MASixty >= MAThentyOne) &&(MASixty <MAFive))
		{
			 StrongWeak =0.6;
		}
		else
		{
			 StrongWeak =0.5;
		}
	
	}
	else if (MAFive < MAThentyOne)
	{
		/*多均线多头向下*/
		if(MASixty > MAThentyOne)
		{
			 StrongWeak =0.1;
		}
		else if ((MASixty <= MAThentyOne) &&(MASixty > MAFive))
		{
			 StrongWeak =0.4;
		}
		else
		{
			 StrongWeak =0.5;
		}  	
	
	}
	else
	{
		StrongWeak =0.5;

	}

	BoolCrossRecord[SymPos][timeperiodnum].StrongWeak = StrongWeak;	
	

	
}




void ChangeCrossValue( int mvalue,double  mstrongweak,int SymPos,int timeperiodnum)
{

	int i;
	int my_timeperiod;
	string symbol;
    symbol = MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];

		
	if (mvalue == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
	{
		BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] = mvalue;
	//	BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
		BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[0] = iBars(symbol,my_timeperiod);	
		
		BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0] = mstrongweak;		
	
		
		return;
	}
	for (i = 0 ; i <(HCROSSNUMBER-1); i++)
	{
		BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[(HCROSSNUMBER-2)-i];
	//	BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[(HCROSSNUMBER-2)-i];
		BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[(HCROSSNUMBER-2)-i] ;		
		BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[(HCROSSNUMBER-2)-i];
	}
	
	BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] = mvalue;
	//BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
	BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[0] = iBars(symbol,my_timeperiod);
	
	BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0] = mstrongweak;

	return;
}


/*非Openday期间不新开单*/
bool opendaycheck(int SymPos)
{
	//	int i;
	string symbol;
	bool tradetimeflag;
	datetime timelocal;

	symbol = MySymbol[SymPos];
	tradetimeflag = true;

		
    timelocal = TimeCurrent() + globaltimezonediff*60*60;


//	Print("opendaycheck:" + "timelocal=" + TimeToString(timelocal,TIME_DATE)
	//				 +"timelocal=" + TimeToString(timelocal,TIME_SECONDS));	

//	Print("opendaycheck:" + "timecur=" + TimeToString(TimeCurrent(),TIME_DATE)
//					 +"timecur=" + TimeToString(TimeCurrent(),TIME_SECONDS));	
		
					
	
	//周一早5点前不下单	
	if (TimeDayOfWeek(timelocal) == 1)
	{
		if (TimeHour(timelocal) < 5 ) 
		{
			tradetimeflag = false;
		}
	}
	
	//周六凌晨2点后不下单		
	if (TimeDayOfWeek(timelocal) == 6)
	{
		if (TimeHour(timelocal) > 2 )  
		{
			tradetimeflag = false;		
		}
	}	

	//周日不下单		
	if (TimeDayOfWeek(timelocal) == 0)
	{
			tradetimeflag = false;		
	}		
	return tradetimeflag;
}

/*欧美交易时间段多以趋势和趋势加强为主，非交易时间多以震荡为主，以此区分一些小周期的交易策略*/
bool tradetimecheck(int SymPos)
{
//	int i;
	string symbol;
	bool tradetimeflag ;
	datetime timelocal;	
  symbol = MySymbol[SymPos];
	tradetimeflag = false;


    /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
    timelocal = TimeCurrent() + globaltimezonediff*60*60;


	//13点前不做趋势单，主要针对1分钟线和五分钟线，非欧美时间趋势不明显，针对趋势突破单，要用这个来检测
	//最原始的是下午1点前不做趋势单，通过扩大止损来寻找更多机会
	
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <22 )) 
	{
		tradetimeflag = true;		
	}	
	/*测试期间全时间段交易*/
	//tradetimeflag = true;		
	
	return tradetimeflag;
	
}

/*欧美交易时间段多以趋势和趋势加强为主，非交易时间多以震荡为主，以此区分一些小周期的交易策略*/
bool tradetimecheck1(int SymPos)
{
//	int i;
	string symbol;
	bool tradetimeflag ;
	datetime timelocal;	
  symbol = MySymbol[SymPos];
	tradetimeflag = false;


    /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
    timelocal = TimeCurrent() + globaltimezonediff*60*60;


	//16点前不做趋势单，主要针对1分钟线和五分钟线，非欧美时间趋势不明显，针对趋势突破单，要用这个来检测
	//最原始的是下午4点前不做趋势单，通过扩大止损来寻找更多机会
	
	if ((TimeHour(timelocal) >= 16 )&& (TimeHour(timelocal) <18 )) 
	{
		tradetimeflag = true;		
	}	
	/*测试期间全时间段交易*/
	//tradetimeflag = true;	
	
	
	return tradetimeflag;
	
}






bool iddataoptflag = false;
bool iddatarecovflag = false;


/*重大数据发布期间处理*/
bool importantdatatimeoptall(datetime idtime,int offset,int type)
{
   int i,SymPos,NowMagicNumber,vdigits;
   double vbid,vask,orderLots,orderPrice,orderStopless,
   bool_length,orderTakeProfit,myMinValue3,myMaxValue4,
   boll_low_B,boll_up_B;
   string my_symbol;
   int res,ticket;
	datetime loctime;
	bool flag = false;
   int my_timeperiod = 0;
	int timeperiodnum=0;
	
//	int SymPos;

	/*本周无重大重要数据发布*/
	if(offset <= 0)
	{
		return false;
	}

    /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/
	/*OANDA 服务器时间为GMT + 3 ，北京时间为GMT + 8，相差5个小时*/		
    loctime = TimeCurrent() + globaltimezonediff*60*60;
	
	
	offset = 30*60;


	/*重大数据期间返回true*/
	if (((idtime-loctime)<offset)&&((idtime-loctime)>0))
	{
		flag = true;
	}
	if (((loctime-idtime)<offset)&&((loctime-idtime)>0))
	{
		flag = true;
	}
		
	
	
	//时间标记初始化
	if (((idtime-loctime)<2*offset)&&((idtime-loctime)>offset))
	{
		iddataoptflag = false;
		iddatarecovflag = false;
	
	}
	
		
	
	//执行现有订单的止损优化，或者直接关掉
	if (((idtime-loctime)<offset)&&((idtime-loctime)>0)&&(iddataoptflag == false))
	{
		Print("Enter important data publish time!!!!!!");
		iddataoptflag = true;
		iddatarecovflag = false;
		
		for (i = 0; i < OrdersTotal(); i++)
		{
		   if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		   {				   
				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;

				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" importantdatatimeoptall SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				if(OrderType()==OP_BUY)
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);						  
					vask    = MarketInfo(my_symbol,MODE_ASK);
					vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
					
					boll_up_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
					boll_low_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	

					bool_length = (boll_up_B - boll_low_B)/2;						
					
					
					myMinValue3 = 100000;
					for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]);i++)
					{
						if(myMinValue3 > iLow(my_symbol,my_timeperiod,i))
						{
							myMinValue3 = iLow(my_symbol,my_timeperiod,i);
						}
						
					}				
					orderLots = NormalizeDouble(MyLotsH,2);
					orderPrice = vask;				 
					orderStopless =myMinValue3- bool_length*0.5; 		
					
					orderTakeProfit	= orderPrice + bool_length*20;
					
					orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
					orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
					orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
										 
					if(1==type)
					{									 
						Print(my_symbol+" importantdatatimeoptall Modify:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);							   
						 if(false == res)
						 {

							Print("Error in importantdatatimeoptall OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {    								 
							Print("OrderModify importantdatatimeoptall  successfully ");
						 }	
					}	
					else
					{
						Print(my_symbol+" importantdatatimeoptall close:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);								
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose importantdatatimeoptall  failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose importantdatatimeoptall   successfully");
						 }    							 																												
					}
					 Sleep(1000);  	
				 
				}
			  
				if(OrderType()==OP_SELL)
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);						  
					vask    = MarketInfo(my_symbol,MODE_ASK);
					vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
					boll_up_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
					boll_low_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	

					bool_length = (boll_up_B - boll_low_B)/2;						
					
					
					
					myMaxValue4 = -1;
					for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]);i++)
					{
						if(myMaxValue4 < iHigh(my_symbol,my_timeperiod,i))
						{
							myMaxValue4 = iHigh(my_symbol,my_timeperiod,i);
						}					
					}				


					orderLots = NormalizeDouble(MyLotsH,2);
					orderPrice = vbid;						 
					orderStopless =myMaxValue4 + bool_length*0.5; 
															
					orderTakeProfit	= orderPrice - bool_length*20;
					
					if(orderTakeProfit<0)
					{
						orderTakeProfit = 0;
					}
										
					orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
					orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
					orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

					if(1==type)
					{									 
						Print(my_symbol+" importantdatatimeoptall Modify:" + "orderLots="
						 + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);	
							   
						 if(false == res)
						 {

							Print("Error in importantdatatimeoptall OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {    								 
							Print("OrderModify importantdatatimeoptall  successfully ");
						 }	
					}	
					else
					{
						Print(my_symbol+" importantdatatimeoptall close:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);								
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose importantdatatimeoptall  failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose importantdatatimeoptall   successfully");
						 }    							 																												
					}
					 Sleep(1000);  							
				  
				  
				}				  
			  
		   }
		}	   
		


	}


	

		
	//恢复订单的止损值到之前状态，经思考后确定暂时不搞这么复杂
	if (((loctime-idtime)<2*offset)&&((loctime-idtime)>offset)
	&&(iddatarecovflag == false)&&(iddataoptflag == true))
	{
		iddatarecovflag = true;
		iddataoptflag = false;		
		Print("Leave important data publish time!!!!!!");
			
	}	
	
	return flag;
	
}


int myaccountleverage()
{
	int leverage;
	
	
	leverage = AccountLeverage();
	
	/*规避exness实际显示杠杆错误的问题*/
	if(AccountServer() == HEXNESSSERVER)
	{
		leverage = leverage*2;
		
	}
	return leverage;
}

/*仓位检测，确保总额可以交易4次以上*/
bool accountcheck()
{
	bool accountflag ;
	int leverage ;
	accountflag = true;
	leverage = myaccountleverage();
	if(leverage < 10)
	{
		Print("Account leverage is to low leverage = ",leverage);		
		accountflag = false;		
	}
	else
	{		
		/*现有杠杆之下至少还能交易两次*/
		if((AccountFreeMargin()* leverage)<( 4*MyLotsH*100000))
		{
			Print("Account Money is not enough free margin = ",AccountFreeMargin() +";Leverage = "+leverage);		
			accountflag = false;
		}		
		
	}

	/*全局交易开关关闭的情况下不交易*/
	if(false == getglobaltradeflag())
	{
		accountflag = false;
	}

	return accountflag;	
	
}



bool isvalidmagicnumber(int magicnumber)
{
		
	bool flag = true;
	int SymPos,NowMagicNumber;
	datetime timelocal;	
	int subvalue;	
	
	SymPos = ((int)magicnumber) /1000;
	NowMagicNumber = magicnumber - SymPos *1000;

	if((SymPos<0)||(SymPos>=symbolNum))
	{
	 flag = false;
	}	
	
  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
	subvalue = (TimeDayOfWeek(timelocal))%5;  
	
	if(subvalue!= (NowMagicNumber%10))
	{
	 flag = false;
	}	
	
	NowMagicNumber = ((int)NowMagicNumber) /10;
	if((NowMagicNumber<=0)||(NowMagicNumber>=11))
	{
	 flag = false;
	}	
	
	//flag = true;

	return flag;
	
}

double orderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				profit = profit + OrderProfit()+OrderCommission();
			}
			
		}
	}
	return profit;
}


double profitorderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				if((OrderProfit()+OrderCommission())>0)
				{			
					profit = profit + OrderProfit()+OrderCommission();
				}
			}			

			
		}
	}
	return profit;
}


int ordercountwithprofit(double myprofit)
{
	int count = 0;
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
				if((OrderProfit()+OrderCommission())>myprofit)
				{
					count++;
				}
			}
		}
	}
	return count;
}



int ordercountall( )
{
	int count = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				count++;
			}
			
		}
	}
	return count;
}


int profitordercountall( double myprofit)
{
	int count = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
				if((OrderProfit()+OrderCommission())>myprofit)
				{
					count++;
				}	
			}		
		}
	}
	return count;
}


void ordercloseallwithprofit(double myprofit)
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
			
				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseallwithprofit SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if((OrderType()==OP_BUY)&&((OrderProfit()+OrderCommission())>myprofit))
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					if(ticket <0)
					{
						Print("OrderClose buy ordercloseallwithprofit with vbid failed with error #",GetLastError());
					}
					else
					{            
						Print("OrderClose buy ordercloseallwithprofit  with vbid  successfully");
					}    	
					Sleep(1000); 
	
				}
				
	
				if((OrderType()==OP_SELL)&&((OrderProfit()+OrderCommission())>myprofit))
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("OrderClose sell ordercloseallwithprofit with vask failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderClose sell ordercloseallwithprofit  with vask  successfully");
					 }    		
					Sleep(1000); 
				}
			
			}
			
		}
	}
	
	return;
}



void ordercloseall()
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			

				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseall SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if(OrderType()==OP_BUY)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					 if(ticket <0)
					 {
						Print("OrderClose buy ordercloseall with vbid failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderClose buy ordercloseall with vbid  successfully");
					 }    	
					Sleep(1000); 
			
				}
				
	
				if(OrderType()==OP_SELL)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("OrderClose sell ordercloseall with vask  failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderClose sell ordercloseall with vask   successfully");
					 }  
					Sleep(1000);				 
			
				}
			
			}
			
		}
	}
	
	return;
}


void ordercloseall2()
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			

				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseall2 SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if(OrderType()==OP_BUY)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("!!OrderClose buy ordercloseall2 with vask failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("!!OrderClose buy ordercloseall2 with vask  successfully");
					 }    	
					Sleep(1000); 
			
				}
					
				if(OrderType()==OP_SELL)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					 if(ticket <0)
					 {
						Print("!!OrderClose sell ordercloseall2 with vbid  failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("!!OrderClose sell ordercloseall2 with vbid   successfully");
					 }  
					Sleep(1000);				 
			
				}
			
			}
			
		}
	}
	
	return;
}


void monitoraccountprofit()
{

	double mylots = 0;	
	double mylots0 = 0;
	
	datetime timelocal;	

	string subject="";
	string some_text="";

	bool turnoffflag = false;

	/*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
	timelocal = TimeCurrent() + globaltimezonediff*60*60;

	/*当天订单已经平掉的情况下就不走这个分支了*/
	if(ordercountall()<=2)
	{
		return;
	}

	/*20:00之前的涨跌都没有充分因此不在这个时间段平仓，尤其是订单数量比较少的情况下*/
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )
	&&(ordercountall()<=(symbolNum/2))) 
	{
	   return;
	}		

	
	/*短线获利清盘，长线后面再考虑*/
	//if(1 == Period())
	{
	
   	/*20:00之前的涨跌都没有充分因此不在这个时间段平仓*/
   	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )) 
   	{
			mylots0 = MyLotsH*1.5;
			mylots = MyLotsH*1.5*0.75;
   	}	
		else if ((TimeHour(timelocal) >= 20 )&& (TimeHour(timelocal) <=23 )) 
		{
					
			/*超过9个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((ordercountall()>=(symbolNum/3))&&(ordercountall() == profitordercountall(0)))
			{
				Print("1.1 This turn Own more than "+(symbolNum/3)+" orders witch is "+ordercountall()+" all profit order,Close all");	
				
				turnoffflag = true;			
				
			}
			mylots0 = MyLotsH*1.5;
			mylots = MyLotsH*1.5*0.75;
				
		}	
		else if ((TimeHour(timelocal) >= 0 )&& (TimeHour(timelocal) <= 3 )) 
		{
			
			/*超过8个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((ordercountall()>=(symbolNum/6))&&(ordercountall() == profitordercountall(0)))
			{
				Print("1.2 This turn Own more than  "+(symbolNum/6)+"  orders witch is "+ordercountall()+" all profit order,Close all");					
				turnoffflag = true;		
						
			}		
			mylots0 = MyLotsH*1.5*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75;					
			
		}

		else if ((TimeHour(timelocal) >= 4 )&& (TimeHour(timelocal) <= 6 )) 
		{
			
			/*超过12个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((ordercountall()>=(symbolNum/9))&&(ordercountall() == profitordercountall(0)))
			{
				Print("1.3 This turn Own more than  "+(symbolNum/9)+"  orders witch is "+ordercountall()+" all profit order,Close all");					
				turnoffflag = true;		
				
			}		
			mylots0 = MyLotsH*1.5*0.75*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75*0.75;					
			
		}				
		
		else if ((TimeHour(timelocal) == 7 ) ||(TimeHour(timelocal) == 7 ))
		{
			
			/*超过12个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((ordercountall()>=(symbolNum/12))&&(ordercountall() == profitordercountall(0)))
			{
				Print("1.4 This turn win more than  "+(symbolNum/12)+"  orders witch is "+ordercountall()+" all profit order,Close all");					
				turnoffflag = true;		
				
			}		
			mylots0 = MyLotsH*1.5*0.5*0.75*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75*0.75*0.75;					
			
		}		
		else
		{			
			/*超过15个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((ordercountall()>=(symbolNum/15))&&(ordercountall() == profitordercountall(0)))
			{
				Print("1.4 This turn win more than  "+(symbolNum/15)+"  orders witch is "+ordercountall()+" all profit order,Close all");					
				turnoffflag = true;						
			}		
			mylots0 = MyLotsH*1.5*0.5*0.75*0.75*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75*0.75*0.75*0.75;					
						
		}						

		//对冲盘已经获利清空的情况下，降低本盘的获利标准
		
		if(false == anti_getglobaltradeflag())
		{
			mylots0 = mylots0*0.75;	
			mylots = mylots*0.75;
		}
		
		//当发现别的平台有盈利平仓后，本平台也盈利平仓
		if(true ==tradedok())
		{	
				mylots0 = mylots0*0.5;	
				mylots = mylots*0.5;			
				Print("!!!!turn off trade because of tradedok!!!");						
		}		
		
		
		/*盈利单的盈利总和超过1000美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((profitorderprofitall() > 10000*mylots0) &&(orderprofitall() >0))
		{					
			turnoffflag = true;		
			Print("2 This turn win more than "+5000*mylots0+" USD,Close all");
		}
			
		/*所有单的盈利总和超过500美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(orderprofitall() > 5000*mylots0)
		{
			
				
			turnoffflag = true;			
			Print("3 This turn Own more than "+2500*mylots0+" USD,Close all");
		}


		/*五个以上40美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((ordercountwithprofit(400*mylots0)>= (ordercountall()/10)*5)&&(orderprofitall()>0))
		{
			turnoffflag = true;					
			Print("4 This turn Own more than Five "+400*mylots0+" USD,Close all");
		}

		/*四个以上50美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((ordercountwithprofit(500*mylots0)>= (ordercountall()/10)*4)&&(orderprofitall()>0))
		{
			
			turnoffflag = true;				
			Print("5 This turn Own more than four "+500*mylots0+" USD,Close all");
		}

		/*三个以上70美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((ordercountwithprofit(700*mylots0)>= (ordercountall()/10)*3)&&(orderprofitall()>0))
		{		
			
			turnoffflag = true;				
			Print("6 This turn Own more than three "+700*mylots0+" USD,Close all");
		}
		
		/*两个以上100美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((ordercountwithprofit(1000*mylots0)>= (ordercountall()/10)*2)&&(orderprofitall()>0))
		{
			turnoffflag = true;			
			Print("7 1、This turn Own more than two "+1000*mylots0+" USD,Close all");
		}


		
		/*订单数量20个，且获利超过480美元，落袋为安*/
		if((ordercountwithprofit(-100)==20)&&(orderprofitall()>4800*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+4800*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量19个，且获利超过460美元，落袋为安*/
		if((ordercountwithprofit(-100)==19)&&(orderprofitall()>4600*mylots))
		{
			turnoffflag = true;					
			Print("9 This turn Own more than one "+4600*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量18个，且获利超过440美元，落袋为安*/
		if((ordercountwithprofit(-100)==18)&&(orderprofitall()>4400*mylots))
		{
			
			turnoffflag = true;							
			Print("10 This turn Own more than one "+4400*mylots+" USD,equal 12 order Close all");		
		}	

		
		/*订单数量17个，且获利超过420美元，落袋为安*/
		if((ordercountwithprofit(-100)==17)&&(orderprofitall()>4200*mylots))
		{
			
			turnoffflag = true;				
			Print("11 This turn Own more than one "+4200*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量16个，且获利超过400美元，落袋为安*/
		if((ordercountwithprofit(-100)==16)&&(orderprofitall()>4000*mylots))
		{
			
			turnoffflag = true;				
			Print("12 This turn Own more than one "+4000*mylots+" USD,equal 12 order Close all");		
		}	
		
		/*订单数量15个，且获利超过380美元，落袋为安*/
		if((ordercountwithprofit(-100)==15)&&(orderprofitall()>3800*mylots))
		{

			turnoffflag = true;			
			Print("13 This turn Own more than one "+3800*mylots+" USD,equal 11 order Close all");		
		}

		
		/*订单数量14个，且获利超过360美元，落袋为安*/
		if((ordercountwithprofit(-100) == 14)&&(orderprofitall()>3600*mylots))
		{
			turnoffflag = true;				
			Print("14 This turn Own more than one "+3600*mylots+" USD,equal1 or 10 order Close all");		
		}	
		

		
		/*订单数量13个，且获利超过340美元，落袋为安*/
		if((ordercountwithprofit(-100)==13)&&(orderprofitall()>3400*mylots))
		{
			turnoffflag = true;			
			Print("15 This turn Own more than one "+3400*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量12个，且获利超过320美元，落袋为安*/
		if((ordercountwithprofit(-100)==12)&&(orderprofitall()>3200*mylots))
		{
			turnoffflag = true;			
			Print("16 This turn Own more than one "+3200*mylots+" USD,equal 12 order Close all");		
		}	
		
		/*订单数量11个，且获利超过300美元，落袋为安*/
		if((ordercountwithprofit(-100)==11)&&(orderprofitall()>3000*mylots))
		{
			
			turnoffflag = true;						
			Print("17 This turn Own more than one "+3000*mylots+" USD,equal 11 order Close all");		
		}

		
		/*订单数量10个，且获利超过280美元，落袋为安*/
		if((ordercountwithprofit(-100) == 10)&&(orderprofitall()>2800*mylots))
		{
			turnoffflag = true;						
			Print("18 This turn Own more than one "+2800*mylots+" USD,equal1 or 10 order Close all");		
		}	
		
		

		
		/*订单数量9个，且获利超过260美元，落袋为安*/
		if((ordercountwithprofit(-100)==9)&&(orderprofitall()>2600*mylots))
		{
			turnoffflag = true;					
			Print("19 This turn Own more than one "+2600*mylots+" USD,equal 9 order Close all");		
		}	

		/*订单数量8个，且获利超过240美元，落袋为安*/
		if((ordercountwithprofit(-100)==8)&&(orderprofitall()>2400*mylots))
		{
			turnoffflag = true;						
			Print("20 This turn Own more than one "+2400*mylots+" USD,equal 8 order Close all");		
		}	
		
		/*订单数量7个，且获利超过220美元，落袋为安*/
		if((ordercountwithprofit(-100)==7)&&(orderprofitall()>2200*mylots))
		{
			
			turnoffflag = true;					
			Print("21 This turn Own more than one "+2200*mylots+" USD,equal 7 order Close all");		
		}

		
		/*订单数量6个，且获利超过200美元，落袋为安*/
		if((ordercountwithprofit(-100) == 6)&&(orderprofitall()>2000*mylots))
		{
			turnoffflag = true;				
			Print("22 This turn Own more than one "+2000*mylots+" USD,equal1 or 6 order Close all");		
		}	
				
		/*订单数量5个，且获利超过180美元，落袋为安*/
		if((ordercountwithprofit(-100)==5)&&(orderprofitall()>1800*mylots))
		{
			turnoffflag = true;			
			Print("23 This turn Own more than one "+1800*mylots+" USD,equal 5 order Close all");		
		}	

		/*订单数量4个，且获利超过150美元，落袋为安*/
		if((ordercountwithprofit(-100)==4)&&(orderprofitall()>1500*mylots))
		{
			turnoffflag = true;						
			Print("24 This turn Own more than one "+1500*mylots+" USD,equal 4 order Close all");		
		}	
		
		/*订单数量3个，且获利超过120美元，落袋为安*/
		if((ordercountwithprofit(-100)==3)&&(orderprofitall()>1200*mylots))
		{
			turnoffflag = true;						
			Print("25 This turn Own more than one "+1200*mylots+" USD,equal 3 order Close all");		
		}
		
		/*订单数量1\2个，且获利超过80美元，落袋为安*/
		if((ordercountwithprofit(-100) <= 2)&&(orderprofitall()>800*mylots))
		{
			turnoffflag = true;			
			Print("26 This turn Own more than one "+800*mylots+" USD,equal1 or 2 order Close all");		
		}			
		
	}	
	
	//本平台达到盈利关闭要求，设置文件标志
	if(turnoffflag == true)
	{	
		
		if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))
		{			
			ForceWriteFileInt(MyTradeFile[curtradefileNum],FILETRADEDFLAG);	
			Print("!!!Set Traded Flag Now!!");						
		}				
		
	}
	
	
	/*本币关闭时，直接关闭对冲币，损失手续费*/
	if(turnoffflag == true)
	{			
		int j=0;
		int k = 0;
		
		if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))
		{			
			ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILENOTRADEFLAG);
			Print("!!!Set anti-Trad Flag Notraded Now!!");						
		}			
		
		
		/*一波做完后，手工禁止交易；第二天继续做*/
		setglobaltradeflag(false);
		subject = g_forexserver +":All Orders Closed Now,Please Close Other Oders quickly";
		SendMail( subject,some_text);				
		ordercloseallwithprofit(-100);
		Sleep(1000); 
		ordercloseall();
		Sleep(1000); 
		ordercloseall2();	
		Sleep(1000); 	
		ordercloseallwithprofit(-100);
		Sleep(1000); 
		ordercloseall();
		Sleep(1000); 
		ordercloseall2();			
		Sleep(1000); 	
		ordercloseallwithprofit(-100);
		Sleep(1000); 
		ordercloseall();
		Sleep(1000); 
		ordercloseall2();		
		Sleep(1000); 	
		ordercloseallwithprofit(-100);
		Sleep(1000); 
		ordercloseall();
		Sleep(1000); 
		ordercloseall2();	
			
		for(j = 0;j < 12; j++)
		{
			if(ordercountall()>0)
			{
				ordercloseallwithprofit(-100);
				Sleep(1000); 
				ordercloseall();
				Sleep(1000); 
				ordercloseall2();					
				Sleep(1000); 
				k++;				
			}
			
		}
		if(k>=(j-1))
		{		
			Print("!!monitoraccountprofit Something Serious Error by colse all order,pls close handly");			
			SendMail( "!!monitoraccountprofit Something Serious Error by colse all order,pls close handly","");		
		}
		
		
		if(true == anti_getglobaltradeflag( ))
		{		
		
		
				j = 0;
		    k = 0;
			
			/*一波做完后，手工禁止交易；第二天继续做*/
			anti_setglobaltradeflag(false);
			subject = g_forexserver +":anti-trade All Orders Closed Now,Please Close Other Oders quickly";
			SendMail( subject,some_text);						
			anti_ordercloseallwithprofit(-100);
			Sleep(1000); 
			anti_ordercloseall();
			Sleep(1000); 
			anti_ordercloseall2();		
			Sleep(1000);
			anti_ordercloseallwithprofit(-100);
			Sleep(1000); 
			anti_ordercloseall();
			Sleep(1000); 
			anti_ordercloseall2();		
			anti_ordercloseallwithprofit(-100);
			Sleep(1000); 
			anti_ordercloseall();
			Sleep(1000); 
			anti_ordercloseall2();
			anti_ordercloseallwithprofit(-100);
			Sleep(1000); 
			anti_ordercloseall();
			Sleep(1000); 
			anti_ordercloseall2();
			anti_ordercloseallwithprofit(-100);
			Sleep(1000); 
			anti_ordercloseall();
			Sleep(1000); 
			anti_ordercloseall2();						
			anti_ordercloseallwithprofit(-100);
			Sleep(1000); 
			anti_ordercloseall();
			Sleep(1000); 
			anti_ordercloseall2();
			
			for(j = 0;j < 12; j++)
			{
				if(anti_ordercountall()>0)
				{
					anti_ordercloseallwithprofit(-100);
					Sleep(1000); 
					anti_ordercloseall();
					Sleep(1000); 
					anti_ordercloseall2();			
					Sleep(1000); 
					k++;				
				}
				
			}
			if(k>=(j-1))
			{		
				Print("!!anti_monitoraccountprofit Something Serious Error by colse all order,pls close handly");			
				SendMail( "!!anti_monitoraccountprofit Something Serious Error by colse all order,pls close handly","");		
			}		
			
		}
		
		
		
						
	}
	
	
}



int init()
{


	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int symbolvalue;

	string MailTitlle ="";

	symbolvalue = 0;
	
	if(false == forexserverconnect())
	{
		
		Print("connect to wrong server,and disable autotrade");			
		/*关闭自动交易*/
		return -1;
		
	}	
	else
	{
		Print("connect to right server,and enable autotrade");			
		/*打开自动交易*/
		//return 0;		
	}
	
	
	initsymbol();    
	openallsymbo();
	
	//初始化交易手数
	initglobalamount();	
	
	initmagicnumber();
	inittiimeperiod();
	
	//初始化标志文件体系
	initfile();
	
	/*初始化全局交易指标，交易时间段使能，非交易时间段禁止*/
	initglobaltradeflag();	
	anti_initglobaltradeflag();	
	
	InitBuySellPos();
	
	Freq_Count = 0;
	TwentyS_Freq = 0;
	OneM_Freq = 0;
	ThirtyS_Freq = 0;
	FiveM_Freq = 0;
	ThirtyM_Freq = 0;
	
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{	
		for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
		{	
	

			my_symbol =   MySymbol[SymPos];
			my_timeperiod = timeperiod[timeperiodnum];			 

			InitcrossValue(SymPos,timeperiodnum);  		 
			InitMA(SymPos,timeperiodnum);
			
			//initbuysellpos(SymPos);	
			
			//InitcrossSW(i);	
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);			
			
		}
	
	}
 
	  
	Print("Server name is ", AccountServer());	  
	Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
	Print("Account Balance= ",AccountBalance());		
	Print("Account free margin = ",AccountFreeMargin());	  
	Print("!Truely Amount is = "+MyLotsH+":"+MyLotsL);	 		               
  return 0;
  
}



int deinit()
{

	return 0;
}



int ChartEvent = 0;
bool PrintFlag = false;

void calculateindicator()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;

	double ma;
	double boll_up_B,boll_low_B,boll_mid_B,bool_length;
	
	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double StrongWeak;
	double vbid,vask; 
	string my_symbol;
	double boolindex;
	
	int crossflag;	

	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{	
		
		for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
		{
			
			my_symbol =   MySymbol[SymPos];
			my_timeperiod = timeperiod[timeperiodnum];			
			//确保指标计算是每个周期计算一次，而不是每个tick计算一次
			if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
			{
				
				ma=iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,1); 
				// ma = Close[0];  
				boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
				boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
				boll_mid_B = (boll_up_B + boll_low_B )/2;
				/*point*/
				bool_length =(boll_up_B - boll_low_B )/2;
	
				ma_pre = iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,2); 
				boll_up_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,2);      
				boll_low_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,2);
				boll_mid_B_pre = (boll_up_B_pre + boll_low_B_pre )/2;
	
				crossflag = 0;
				
			
				StrongWeak = BoolCrossRecord[SymPos][timeperiodnum].StrongWeak;
				
				/*本周期突破高点，观察如小周期未衰竭可追高买入，或者等待回调买入*/
				/*原则上突破bool线属于偏离价值方向太大，是要回归价值中枢的*/
				if((ma >boll_up_B) && (ma_pre < boll_up_B_pre ) )
				{
				
					crossflag = 5;		
					ChangeCrossValue(crossflag,StrongWeak,SymPos,timeperiodnum);
					//  Print(mMailTitlle + Symbol()+"::本周期突破高点，除(1M、5M周期bool口收窄且快速突破追高，移动止损），其他情况择机反向做空:"
					//  + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
	
				}
				
				/*本周期突破高点后回调，观察如小周期长时间筑顶，寻机卖出*/
				else if((ma <boll_up_B) && (ma_pre > boll_up_B_pre ) )
				{
					crossflag = 4;
					ChangeCrossValue(crossflag,StrongWeak,SymPos,timeperiodnum);
					//   Print(mMailTitlle + Symbol()+"::本周期突破高点后回调，观察小周期如长时间筑顶，寻机做空:"
					//   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
	
		   
				}
					
				
				/*本周期突破低点，观察如小周期未衰竭可追低卖出，或者等待回调卖出*/
				else if((ma < boll_low_B) && (ma_pre > boll_low_B_pre ) )
				{
				
					
					crossflag = -5;
					ChangeCrossValue(crossflag,StrongWeak,SymPos,timeperiodnum);
					//   Print(mMailTitlle + Symbol() + "::本周期突破低点，除(条件：1M、5M周期bool口收窄且快速突破追低，移动止损），其他情况择机反向做多:"
					//   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
		   
				}
					
				/*本周期突破低点后回调，观察如长时间筑底，寻机买入*/
				else if((ma > boll_low_B) && (ma_pre < boll_low_B_pre ) )
				{
					crossflag = -4;	
					ChangeCrossValue(crossflag,StrongWeak,SymPos,timeperiodnum);
					//   Print(mMailTitlle + Symbol() + "::本周期突破低点后回调，观察如小周期长时间筑底，寻机买入:"
					//   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
	
				}
		   
		   
						
				/*本周期上穿中线，表明本周期趋势开始发生变化为上升，在下降大趋势下也可能是回调杀入机会*/
				else if((ma > boll_mid_B) && (ma_pre < boll_mid_B_pre ))
				{
				
					crossflag = 1;				
					ChangeCrossValue(crossflag,StrongWeak,SymPos,timeperiodnum);			
					//    Print(mMailTitlle + Symbol() + "::本周期上穿中线变化为上升，大周期下降大趋势下可能是回调做空机会："
					//    + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
	   
				}	
				/*本周期下穿中线，表明趋势开始发生变化，在上升大趋势下也可能是回调杀入机会*/
				else if( (ma < boll_mid_B) && (ma_pre > boll_mid_B_pre ))
				{
					crossflag = -1;								
					ChangeCrossValue(crossflag,StrongWeak,SymPos,timeperiodnum);			
					 //     Print(mMailTitlle + Symbol() + "::本周期下穿中线变化为下降，大周期上升大趋势下可能是回调做多机会："
					 //     + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
				}							
				else
				{
					 crossflag = 0;   
	       
				}
	
				BoolCrossRecord[SymPos][timeperiodnum].BoolFlag = BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0];
				BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange = crossflag;
	
				
				
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				if(((bool_length <0.00001)&&(bool_length >0))||((bool_length >-0.00001)&&(bool_length <0))	)
				{
					Print(my_symbol+":"+my_timeperiod+"bool_length is Zero,ERROR!!");
				}			
				else
				{
					boolindex = ((vask + vbid)/2 - boll_mid_B)/bool_length;
					BoolCrossRecord[SymPos][timeperiodnum].BoolIndex = boolindex;
				}
	
		   
		   
				MAThree=iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,1); 
				MAThen=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,1);  
				MAThenPre=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,2); 
		 
					
				MAFive=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,1); 
				MAThentyOne=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,1); 
				MASixty=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,1); 
			 
				MAFivePre=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,2); 
				MAThentyOnePre=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,2); 
				MASixtyPre=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,2); 
				 
	
				StrongWeak =0.5;
			 
	
				if((MAThree > MAThen)&&(MAThenPre<MAThen))
				{		
					StrongWeak =0.9;	
				}
				else if ((MAThree < MAThen)&&(MAThenPre>MAThen))
				{
					StrongWeak =0.1;
				
				}
				else
				{
					StrongWeak =0.5;
	
				}
	
				
				BoolCrossRecord[SymPos][timeperiodnum].Trend = StrongWeak;
				
	
				 
				 
				 
				StrongWeak =0.5;
		   
				if(MAFive > MAThentyOne)
				{
						
					/*多均线多头向上*/
					if(MASixty < MAThentyOne)
					{
						 StrongWeak =0.9;
					}
					else if ((MASixty >= MAThentyOne) &&(MASixty <MAFive))
					{
						 StrongWeak =0.6;
					}
					else
					{
						 StrongWeak =0.5;
					}
				
				}
				else if (MAFive < MAThentyOne)
				{
					/*多均线多头向下*/
					if(MASixty > MAThentyOne)
					{
						 StrongWeak =0.1;
					}
					else if ((MASixty <= MAThentyOne) &&(MASixty > MAFive))
					{
						 StrongWeak =0.4;
					}
					else
					{
						 StrongWeak =0.5;
					}  	
				
				}
				else
				{
					StrongWeak =0.5;
		   
				}
		   
		   
				BoolCrossRecord[SymPos][timeperiodnum].StrongWeak = StrongWeak;
	
		   
	
		
			}
		}	
		
	}	
	
	return;
}



/*一分钟具有相当的不稳定性，因此1分钟交易是有时间段的，主要在交易活跃期间进行，这个期间容易形成小周期的趋势*/
void orderbuyselltypeone(int SymPos)
{
	
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;

	double boll_up_B,boll_low_B,boll_mid_B,bool_length;	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;
	double orderpoint;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	datetime timelocal;	
	int subvalue;
	
	int i,ticket;
 	int ttick;
	int    vdigits ;
	
	/*一分钟周期寻找买卖点*/
	timeperiodnum = 0;	

	orderStopLevel=0;
	orderLots = 0;   
	orderStopless = 0;
	orderTakeProfit = 0;
	orderPrice = 0;
	
		
	
	my_symbol =   MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
	//确保寻找买卖点是每个周期计算一次，而不是每个tick计算一次
	if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent == iBars(my_symbol,my_timeperiod))
	{
		return;
	}
	
	
	boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
	boll_mid_B = (boll_up_B + boll_low_B )/2;
	/*point*/
	bool_length =(boll_up_B - boll_low_B )/2;	
	


	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
					
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true))
		)
	{
		
		
		/*三十分钟强势，五分钟不若失，一分钟bool背驰，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.55)			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)				
			)			
					
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	


			BuySellPosRecord[SymPos].NextModifyValue1[0] = orderStopless;
			
			
			orderStopless =MinValue3- bool_length*64; 	
			BuySellPosRecord[SymPos].NextModifyValue2[0] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[0] = orderPrice;		
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderPrice - orderStopless) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice - orderStopLevel*orderpoint;
			 }
			 if ((orderTakeProfit - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice + orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  			

			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
				    			 	 		 			 	 		 			 	
			
			Print(my_symbol+" MagicNumberOne OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless+"subvalue="+subvalue);	
						
			if(true == anti_accountcheck())
			{			
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;					
						
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberOne"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberOne),0,Blue);
		
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberOne"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {       
					 	ttick = 100;     
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);	
						trade_antitradeflag = true;	 											 				 
						Print("OrderSend MagicNumberOne"+IntegerToString(subvalue)+"  successfully");
					 }													
					Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}		
								
			}


		}

				
		
		/*三十分钟和四小时多头向上，五分钟空头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.45)	
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.15)		
											
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)			
			)			
			
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	

			BuySellPosRecord[SymPos].NextModifyValue1[2] = orderStopless;
			
			orderStopless =MinValue3- bool_length*64; 	
			BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[2] = orderPrice;
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderPrice - orderStopless) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice - orderStopLevel*orderpoint;
			 }
			 if ((orderTakeProfit - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice + orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  			
			
			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
				
			
			Print(my_symbol+" MagicNumberThree"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless+"subvalue="+subvalue);	
			
			if(true == anti_accountcheck())
			{
				
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;		
								
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberThree"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberThree),0,Blue);
		
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberThree"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}
	
					 }
					 else
					 {     
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);		
						trade_antitradeflag = true;	 										 				 
						Print("OrderSend MagicNumberThree"+IntegerToString(subvalue)+"   successfully");
					 }													
					Sleep(1000);
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}					
			}					
				
		}			
					

		
		
	}			
	
	
////////////////////////////////////////////////////////////////////////
//多空分界线
////////////////////////////////////////////////////////////////////////

	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了优化比较好的入场点，和止损点
	//趋势回调高点型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
					
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)		
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)))
	{
		
		/*三十分钟强势，五分钟不弱势，一分钟bool背驰，多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

											
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.45)			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)				
			)
		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vbid;						 

			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[1] = orderStopless;	

			
			orderStopless =MaxValue4 + bool_length*64; 
			BuySellPosRecord[SymPos].NextModifyValue2[1] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[1] = orderPrice;

			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderStopless - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice + orderStopLevel*orderpoint;
			 }
			 if ((orderPrice - orderTakeProfit) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice - orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  	
									

			//orderTakeProfit = 0;									
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
											
					
			Print(my_symbol+" MagicNumberTwo"+IntegerToString(subvalue)+"  OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{		
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);	
					orderPrice = vbid;		
															
			 
					 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "MagicNumberTwo"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberTwo),0,Blue);
			
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberTwo"+IntegerToString(subvalue)+"  failed with error #",GetLastError());
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {   
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);	
						trade_antitradeflag = true;	 											 					 
						Print("OrderSend MagicNumberTwo"+IntegerToString(subvalue)+"   successfully");
					 }
														 
					 Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}					
				
			}					 
							
		}
		


		/*五分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.65)	

			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex > -0.15)		
											
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)			
			)	

		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vbid;		
			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[3] = orderStopless;
			
			orderStopless =MaxValue4 + bool_length*64; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[3] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderStopless - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice + orderStopLevel*orderpoint;
			 }
			 if ((orderPrice - orderTakeProfit) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice - orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  	
									


			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
													
					
			Print(my_symbol+" MagicNumberFour"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			 if(true == anti_accountcheck())
			 {
			 	
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);	
					orderPrice = vbid;		
																		 
					 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "MagicNumberFour"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberFour),0,Blue);
			
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberFour"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {   
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);				
						trade_antitradeflag = true;	 								 					 
						Print("OrderSend MagicNumberFour"+IntegerToString(subvalue)+"  successfully");
					 }
														 
					 Sleep(1000);		
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}					
								
				
			}					 
							
		
		}					
		
		
					
	}	
						
}


void orderbuyselltypetwo(int SymPos)
{
	
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;

	double boll_up_B,boll_low_B,boll_mid_B,bool_length;	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	datetime timelocal;	
	int subvalue;
		
	int i,ticket;
 	int ttick;
	int    vdigits ;
	
	/*五分钟周期寻找买卖点，用到日线指标*/
	timeperiodnum = 1;	

	orderStopLevel=0;
	orderLots = 0;   
	orderStopless = 0;
	orderTakeProfit = 0;
	orderPrice = 0;
			
	
	my_symbol =   MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];
		
	//确保寻找买卖点是每个周期计算一次，而不是每个tick计算一次
	if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent == iBars(my_symbol,my_timeperiod))
	{
		return;
	}

	boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
	boll_mid_B = (boll_up_B + boll_low_B )/2;
	/*point*/
	bool_length =(boll_up_B - boll_low_B )/2;	
	
	
	

	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) == true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)))
	{

		
		/*四小时强势，三十分钟不弱势，五分钟bool背驰，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.55)			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)			
			)	
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	


			BuySellPosRecord[SymPos].NextModifyValue1[4] = orderStopless;
			
			
			orderStopless =MinValue3- bool_length*32; 	
			BuySellPosRecord[SymPos].NextModifyValue2[4] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[4] = orderPrice;		
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			

			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
																				

		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  			
			
			Print(my_symbol+" MagicNumberFive"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;						
				
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberFive"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberFive),0,Blue);
		
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberFive"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {    
					 	ttick =100;        
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[4] = iBars(my_symbol,my_timeperiod)+20;					 
						BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(my_symbol,my_timeperiod);			
						trade_antitradeflag = true;	 				 
						Print("OrderSend MagicNumberFive"+IntegerToString(subvalue)+"  successfully");
					 }													
					 Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}									
				
				
			}


		}
				
		
		/*日线和四小时多头向上，五分钟空头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	

			
			&& (3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])										
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.55)			


			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)			
			)			
			
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	

			BuySellPosRecord[SymPos].NextModifyValue1[6] = orderStopless;
			
			orderStopless =MinValue3- bool_length*32; 	
			BuySellPosRecord[SymPos].NextModifyValue2[6] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[6] = orderPrice;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			
			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  																			
	    			 	 		 			 	 		 			 	

			Print(my_symbol+" MagicNumberSeven"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;					
				
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberSeven"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberSeven),0,Blue);
		
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberSeven"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {     
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(my_symbol,my_timeperiod)+20;					 
						BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);				
						trade_antitradeflag = true;	 		 				 
						Print("OrderSend MagicNumberSeven"+IntegerToString(subvalue)+"  successfully");
					 }													
					Sleep(1000);	
				}
				
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}									
								
				
			}					
			
		}			
					

	}			
	

	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////		
	//多空分界		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////		
			
			
	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了优化比较好的入场点，和止损点
	//趋势回调探高型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
							
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) == true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)))
	{
		
		/*四小时强势，三十分钟不弱势，五分钟bool背驰，多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

											
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.45)			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)				
			)

		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vbid;						 

			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[5] = orderStopless;	

			
			orderStopless =MaxValue4 + bool_length*32; 
			BuySellPosRecord[SymPos].NextModifyValue2[5] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[5] = orderPrice;
			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			

									

			//orderTakeProfit = 0;		
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  										
					
			Print(my_symbol+" MagicNumberSix"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == anti_accountcheck())
			 {
					ttick = 0;
					ticket = -1;
					while((ticket<0)&&(ttick<20))
					{
						vbid    = MarketInfo(my_symbol,MODE_BID);	
						orderPrice = vbid;					
										
					 
						 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
										   "MagicNumberSix"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberSix),0,Blue);
				
						 if(ticket <0)
						 {
						 	ttick++;
							Print("OrderSend MagicNumberSix"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
						 }
						 else
						 {   
						 	ttick = 100;
							TwentyS_Freq++;
							OneM_Freq++;
							ThirtyS_Freq++;
							FiveM_Freq++;
							ThirtyM_Freq++;				 
							BuySellPosRecord[SymPos].NextModifyPos[5] = iBars(my_symbol,my_timeperiod)+20;					 
							BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(my_symbol,my_timeperiod);		
							trade_antitradeflag = true;	 											 					 
							Print("OrderSend MagicNumberSix"+IntegerToString(subvalue)+"  successfully");
						 }
															 
						 Sleep(1000);	
					}
					if((ttick>= 19)	&&(ttick<25))
					{
							Print("!!Fatel error encouter please check your platform right now!");					
					}									
									
			 }					 
							
		}
			


		/*三十分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
						
			&& (-3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])										
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.45)			
										
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)			
			)	

		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vbid;		
			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[7] = orderStopless;
			
			orderStopless =MaxValue4 + bool_length*32; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[7] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[7] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  																							
					
			Print(my_symbol+" MagicNumberEight"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
				+ orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == anti_accountcheck())
			 {
				 
					ttick = 0;
					ticket = -1;
					while((ticket<0)&&(ttick<20))
					{
						vbid    = MarketInfo(my_symbol,MODE_BID);	
						orderPrice = vbid;					
														 
				 
						 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
										   "MagicNumberEight"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberEight),0,Blue);
				
						 if(ticket <0)
						 {
						 	ttick++;
							Print("OrderSend MagicNumberEight"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
						 }
						 else
						 {   
						 	ttick = 100;
							TwentyS_Freq++;
							OneM_Freq++;
							ThirtyS_Freq++;
							FiveM_Freq++;
							ThirtyM_Freq++;				 
							BuySellPosRecord[SymPos].NextModifyPos[7] = iBars(my_symbol,my_timeperiod)+20;					 
							BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(my_symbol,my_timeperiod);			
							trade_antitradeflag = true;	 										 					 
							Print("OrderSend MagicNumberEight"+IntegerToString(subvalue)+"  successfully");
						 }
															 
						 Sleep(1000);	
					}
					if((ttick>= 19)	&&(ttick<25))
					{
							Print("!!Fatel error encouter please check your platform right now!");					
					}						
					
			 }					 
								
		
		}			
		
		
		
	}						

						
	
}


	
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
//Start anti-order zone

void anti_setglobaltradeflag(bool flag)
{

	anti_globaltradeflag = flag;
}


bool anti_getglobaltradeflag(void)
{

	return anti_globaltradeflag ;
}





/*启动时初始化全局交易标记*/
void anti_initglobaltradeflag()
{

	datetime timelocal;	

  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;

	//14点前不做趋势单，主要针对1分钟线和五分钟线，非欧美时间趋势不明显，针对趋势突破单，要用这个来检测
	//最原始的是下午4点前不做趋势单，通过扩大止损来寻找更多机会
	
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )) 
	{
		
		anti_setglobaltradeflag(true);		

	}	
	else
	{
		anti_setglobaltradeflag(false);				
	}
	
	if (((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <=24 )) ||(TimeHour(timelocal) <3 ))
	{
		
		/*在对冲盘已经清空的情况下设置Flag*/
		if((ordercountall()>4)&&(anti_ordercountall()<2))
		{		
			setglobaltradeflag(true);		
			anti_setglobaltradeflag(false);		
			Print("anti_initglobaltradeflag  setglobaltradeflag true and anti_setglobaltradeflag set false");						
		}
		
		/*在对冲盘已经清空的情况下设置Flag*/
		if((ordercountall()<2)&&(anti_ordercountall()>4))
		{		
			setglobaltradeflag(false);		
			anti_setglobaltradeflag(true);		
			Print("anti_initglobaltradeflag  setglobaltradeflag false and anti_setglobaltradeflag set true");						
		}
								
	}		
		
	
	
	
}


/*在交易时间段来临前确保使能全局交易标记*/
void anti_enableglobaltradeflag()
{
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
		
	datetime timelocal;	

	SymPos = 0;
	/*每隔五分钟算一次*/
	timeperiodnum = 1;
	
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;

	
	/*确保交易时间段，来临前开启全局交易交易标记*/
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <14 )) 
	{			
		//确保是每个周期五分钟计算一次，而不是每个tick计算一次
		if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
		{		
			//if(false == anti_getglobaltradeflag())
			{
				anti_setglobaltradeflag(true);		
				Print("Enable anti_trade Global Trade!");	 					
			}
			if ((TimeMinute(timelocal) >= 28 )&& (TimeMinute(timelocal) <=32 )) 
			{				
				string subject = g_forexserver +":Will Soon begin to anti_trade !";
				SendMail( subject, "");		
				Print("Send Start anti_Trade Email!");		
			}
			
		}
	}	

	
}

/*仓位检测，确保总额可以交易4次以上*/
bool anti_accountcheck()
{
	bool accountflag ;
	int leverage ;
	accountflag = true;
	leverage = myaccountleverage();
	if(leverage < 10)
	{
		Print("Account leverage is to low leverage = ",leverage);		
		accountflag = false;		
	}
	else
	{		
		/*现有杠杆之下至少还能交易两次*/
		if((AccountFreeMargin()* leverage)<( 4*MyLotsH*100000))
		{
						
			/*尽管余额不足的情况下，还是要完成最后一个货币对购买*/
			if(trade_antitradeflag == true)
			{
					Print("Althrough Account Money is not enough but do the last trade free margin = ",AccountFreeMargin() +";Leverage = "+leverage);		
					accountflag = true;		
			}			
			else
			{
				Print("Account Money is not enough free margin = ",AccountFreeMargin() +";Leverage = "+leverage);		
				accountflag = false;				
			}

			
		}		
						
		
	}
	


	/*全局交易开关关闭的情况下不交易*/
	if(false == getglobaltradeflag())
	{
		accountflag = false;
	}
	if(false == anti_getglobaltradeflag())
	{
		accountflag = false;
	}
	return accountflag;	
	
}


bool anti_isvalidmagicnumber(int magicnumber)
{
		
	bool flag = true;
	int SymPos,NowMagicNumber;
	datetime timelocal;	
	int subvalue;		
	
	SymPos = ((int)magicnumber) /1000;
	NowMagicNumber = magicnumber - SymPos *1000;

	if((SymPos<0)||(SymPos>=symbolNum))
	{
	 flag = false;
	}	
  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
	subvalue = (TimeDayOfWeek(timelocal))%5;  
	if(subvalue!= (NowMagicNumber%10))
	{
	 flag = false;
	}	
	
	NowMagicNumber = ((int)NowMagicNumber) /10;
	if((NowMagicNumber<=10)||(NowMagicNumber>=19))
	{
	 flag = false;
	}	
	
	//flag = true;


	return flag;
	
}

double anti_orderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				profit = profit + OrderProfit()+OrderCommission();
			}
			
		}
	}
	return profit;
}


double anti_profitorderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				if((OrderProfit()+OrderCommission())>0)
				{			
					profit = profit + OrderProfit()+OrderCommission();
				}
			}			

			
		}
	}
	return profit;
}



int anti_ordercountwithprofit(double myprofit)
{
	int count = 0;
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
				if((OrderProfit()+OrderCommission())>myprofit)
				{
					count++;
				}
			}
		}
	}
	return count;
}



int anti_ordercountall( )
{
	int count = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				count++;
			}
			
		}
	}
	return count;
}


int anti_profitordercountall( double myprofit)
{
	int count = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
				if((OrderProfit()+OrderCommission())>myprofit)
				{
					count++;
				}	
			}		
		}
	}
	return count;
}



void anti_ordercloseallwithprofit(double myprofit)
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
			
				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseallwithprofit SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if((OrderType()==OP_BUY)&&((OrderProfit()+OrderCommission())>myprofit))
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					if(ticket <0)
					{
						Print("anti-OrderClose buy ordercloseallwithprofit with vbid failed with error #",GetLastError());
					}
					else
					{            
						Print("anti-OrderClose buy ordercloseallwithprofit  with vbid  successfully");
					}    	
					Sleep(1000); 
	
				}
				
	
				if((OrderType()==OP_SELL)&&((OrderProfit()+OrderCommission())>myprofit))
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("anti-OrderClose sell ordercloseallwithprofit with vask failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("anti-OrderClose sell ordercloseallwithprofit  with vask  successfully");
					 }    		
					Sleep(1000); 
				}
			
			}
			
		}
	}
	
	return;
}



void anti_ordercloseall()
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			

				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" anti-ordercloseall SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if(OrderType()==OP_BUY)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					 if(ticket <0)
					 {
						Print("anti-OrderClose buy ordercloseall with vbid failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("anti-OrderClose buy ordercloseall with vbid  successfully");
					 }    	
					Sleep(1000); 
			
				}
				
	
				if(OrderType()==OP_SELL)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("anti-OrderClose sell ordercloseall with vask  failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("anti-OrderClose sell ordercloseall with vask   successfully");
					 }  
					Sleep(1000);				 
			
				}
			
			}
			
		}
	}
	
	return;
}


void anti_ordercloseall2()
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(anti_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			

				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" anti-ordercloseall2 SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if(OrderType()==OP_BUY)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("!!anti-OrderClose buy ordercloseall2 with vask failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("!!anti-OrderClose buy ordercloseall2 with vask  successfully");
					 }    	
					Sleep(1000); 
			
				}
					
				if(OrderType()==OP_SELL)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					 if(ticket <0)
					 {
						Print("!!anti-OrderClose sell ordercloseall2 with vbid  failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("!!anti-OrderClose sell ordercloseall2 with vbid   successfully");
					 }  
					Sleep(1000);				 
			
				}
			
			}
			
		}
	}
	
	return;
}




/*默认晚上4:30点后强制关闭所有订单，实际情况是如果晚上8:30以后有重要数据，建议8:10之前平仓所有订单，不要受重大数据影响*/
/*坚决不参与重大数据发布行情*/
//this is bad situation
void anti_forcecloseall(int hour,int minute)
{

	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int j = 0;
	int k = 0;		
	datetime timelocal;	

	SymPos = 0;
	/*每隔五分钟算一次*/
	timeperiodnum = 1;
	
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;
	
	/*确保交易时间段，来临前开启全局交易交易标记*/
	if ((TimeHour(timelocal) == 7 )&& (TimeMinute(timelocal) >=  25))
	{			
		//确保是每个周期五分钟计算一次，而不是每个tick计算一次
		if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
		{					
			/*考虑关闭不彻*/		
			if(true == anti_getglobaltradeflag())
			{
				
				j = 0;
				k = 0;
								
				anti_setglobaltradeflag(false);				
				anti_ordercloseallwithprofit(-100);
				Sleep(1000); 
				anti_ordercloseall();
				Sleep(1000); 
				anti_ordercloseall2();		
				Sleep(1000); 
				anti_ordercloseallwithprofit(-100);
				Sleep(1000); 
				anti_ordercloseall();
				Sleep(1000); 
				anti_ordercloseall2();		
				Sleep(1000); 
				anti_ordercloseallwithprofit(-100);
				Sleep(1000); 
				anti_ordercloseall();
				Sleep(1000); 
				anti_ordercloseall2();		
				Sleep(1000); 
				anti_ordercloseallwithprofit(-100);
				Sleep(1000); 
				anti_ordercloseall();
				Sleep(1000); 
				anti_ordercloseall2();		
				Sleep(1000); 												
				for(j = 0;j < 12; j++)
				{
					if(anti_ordercountall()>0)
					{
						anti_ordercloseallwithprofit(-100);
						Sleep(1000); 
						anti_ordercloseall();
						Sleep(1000); 
						anti_ordercloseall2();			
						Sleep(1000); 
						k++;				
					}
					
				}
				if(k>=(j-1))
				{		
					Print("!!anti_forcecloseall Something Serious Error by colse all order,pls close handly");			
					SendMail( "!!anti_forcecloseall Something Serious Error by colse all order,pls close handly","");		
				}
																									
				Print("anti_forcecloseall Bad Solution anti-trade Force Close All Trade!");	 			
								
				if(ordercountall()>0)	
				{			
					j = 0;
					k = 0;				
					setglobaltradeflag(false);				
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 												
												
					for(j = 0;j < 12; j++)
					{
						if(ordercountall()>0)
						{
							ordercloseallwithprofit(-100);
							Sleep(1000); 
							ordercloseall();
							Sleep(1000); 
							ordercloseall2();		
							Sleep(1000); 
							k++;				
						}
						
					}
					if(k>=(j-1))
					{		
						Print("!!forcecloseall Something Serious Error by colse all order,pls close handly");			
						SendMail( "!!forcecloseall Something Serious Error by colse all order,pls close handly","");		
					}
						
					Print("forcecloseall Bad Solution trade Force Close All Trade!");	
				} 											

						
			}			
			
			
		}
	}	
	
}


void anti_monitoraccountprofit()
{

	double mylots = 0;	
	double mylots0 = 0;
	
	datetime timelocal;	

	string subject="";
	string some_text="";
	
	bool anti_turnoffflag = false;


	/*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
	timelocal = TimeCurrent() + globaltimezonediff*60*60;


	
	/*当天订单已经平掉的情况下就不走这个分支了*/
	if(anti_ordercountall()<=2)
	{
		return;
	}
	
	/*20:00之前的涨跌都没有充分因此不在这个时间段平仓，尤其是订单数量比较少的情况下*/
	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )
	&&(anti_ordercountall()<=(symbolNum/2))) 
	{
	   return;
	}		
	
	

//	else
	{
	
	
   	/*20:00之前的涨跌都没有充分因此不在这个时间段平仓全为正的操作*/
   	if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )) 
   	{		
   		
   			mylots0 = MyLotsL*1.5;
   			mylots = MyLotsL*1.5*0.75;
   	}		
		else if ((TimeHour(timelocal) >= 20 )&& (TimeHour(timelocal) <=23 )) 
		{
					
			/*超过3个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/			
			if((anti_ordercountall()>=(symbolNum/3))&&(anti_ordercountall() == anti_profitordercountall(0)))
			{
				Print("1.1 This turn Own more than "+(symbolNum/3)+" orders witch is "+anti_ordercountall()+" all profit order,Close all");	

				anti_turnoffflag = true;									
			}
			mylots0 = MyLotsL*1.5;
			mylots = MyLotsL*1.5*0.75;
				
		}	
		else if ((TimeHour(timelocal) >= 0 )&& (TimeHour(timelocal) <= 3 )) 
		{
			
			/*超过6个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((anti_ordercountall()>=(symbolNum/6))&&(anti_ordercountall() == anti_profitordercountall(0)))
			{
				Print("1.2 This turn Own more than  "+(symbolNum/6)+"  orders witch is "+anti_ordercountall()+" all profit order,Close all");					
				anti_turnoffflag = true;								
	
						
			}		
			mylots0 = MyLotsL*1.5*0.75;	
			mylots = MyLotsL*1.5*0.75*0.75;					
			
		}

		else if ((TimeHour(timelocal) >= 4 )&& (TimeHour(timelocal) <= 6 )) 
		{
			
			/*超过9个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((anti_ordercountall()>=(symbolNum/9))&&(anti_ordercountall() == anti_profitordercountall(0)))
			{
				Print("1.3 This turn Own more than  "+(symbolNum/9)+"  orders witch is "+anti_ordercountall()+" all profit order,Close all");					
				anti_turnoffflag = true;								
	
				
			}		
			mylots0 = MyLotsL*1.5*0.75*0.75;	
			mylots = MyLotsL*1.5*0.75*0.75*0.75;					
			
		}				
		
		else if ((TimeHour(timelocal) == 7 )  ||(TimeHour(timelocal) == 7 ))
		{
			
			/*超过12个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/			
			if((anti_ordercountall()>=(symbolNum/12))&&(anti_ordercountall() == anti_profitordercountall(0)))
			{
				Print("1.4 This turn win more than  "+(symbolNum/12)+"  orders witch is "+anti_ordercountall()+" all profit order,Close all");					
				/*一波做完后，手工禁止交易；第二天继续做*/
				anti_turnoffflag = true;									
				
			}		
			mylots0 = MyLotsL*1.5*0.5*0.75*0.75;	
			mylots = MyLotsL*1.5*0.75*0.75*0.75*0.75;					
			
		}				
		else
		{
			
			/*超过15个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/			
			if((anti_ordercountall()>=(symbolNum/15))&&(anti_ordercountall() == anti_profitordercountall(0)))
			{
				Print("1.5 This turn win more than  "+(symbolNum/15)+"  orders witch is "+anti_ordercountall()+" all profit order,Close all");					
				/*一波做完后，手工禁止交易；第二天继续做*/
				anti_turnoffflag = true;									
				
			}		
			mylots0 = MyLotsL*1.5*0.5*0.75*0.75*0.75;	
			mylots = MyLotsL*1.5*0.75*0.75*0.75*0.75*0.75;					
			
		}				


		//对冲盘已经获利清空的情况下，降低本盘的获利标准
		if(false == getglobaltradeflag())
		{
			mylots0 = mylots0*0.75;	
			mylots = mylots*0.75;
		}
		
		//当发现别的平台有盈利平仓后，本平台也盈利平仓
		if(true ==antitradedok())
		{
			mylots0 = mylots0*0.75;	
			mylots = mylots*0.75;	
			Print("!!!!turn off all anti-trade because of antitradedok!!!");			
			
		}		
		
		
		/*盈利单的盈利总和超过1000美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((anti_profitorderprofitall() > 10000*mylots0) &&(anti_orderprofitall() >0))
		{	
				
			anti_turnoffflag = true;								
		
			Print("2 This turn win more than "+5000*mylots0+" USD,Close all");
		}
			
		/*所有单的盈利总和超过500美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(anti_orderprofitall() > 5000*mylots0)
		{				
			anti_turnoffflag = true;				
			Print("3 This turn Own more than "+2500*mylots0+" USD,Close all");
		}

		
		/*订单数量20个，且获利超过480美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==20)&&(anti_orderprofitall()>4800*mylots))
		{

			anti_turnoffflag = true;					
			Print("8 This turn Own more than one "+4800*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量19个，且获利超过460美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==19)&&(anti_orderprofitall()>4600*mylots))
		{
			anti_turnoffflag = true;					
			Print("9 This turn Own more than one "+4600*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量18个，且获利超过440美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==18)&&(anti_orderprofitall()>4400*mylots))
		{
			
			anti_turnoffflag = true;							
			Print("10 This turn Own more than one "+4400*mylots+" USD,equal 12 order Close all");		
		}	

		
		/*订单数量17个，且获利超过420美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==17)&&(anti_orderprofitall()>4200*mylots))
		{
			
			anti_turnoffflag = true;					
			Print("11 This turn Own more than one "+4200*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量16个，且获利超过400美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==16)&&(anti_orderprofitall()>4000*mylots))
		{
			
			anti_turnoffflag = true;					
			Print("12 This turn Own more than one "+4000*mylots+" USD,equal 12 order Close all");		
		}	
		
		/*订单数量15个，且获利超过380美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==15)&&(anti_orderprofitall()>3800*mylots))
		{

			anti_turnoffflag = true;				
			Print("13 This turn Own more than one "+3800*mylots+" USD,equal 11 order Close all");		
		}

		
		/*订单数量14个，且获利超过360美元，落袋为安*/
		if((anti_ordercountwithprofit(-100) == 14)&&(anti_orderprofitall()>3600*mylots))
		{
			anti_turnoffflag = true;						
			Print("14 This turn Own more than one "+3600*mylots+" USD,equal1 or 10 order Close all");		
		}	
		
		
		/*订单数量13个，且获利超过340美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==13)&&(anti_orderprofitall()>3400*mylots))
		{
			anti_turnoffflag = true;					
			Print("15 This turn Own more than one "+3400*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量12个，且获利超过320美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==12)&&(anti_orderprofitall()>3200*mylots))
		{
			anti_turnoffflag = true;					
			Print("16 This turn Own more than one "+3200*mylots+" USD,equal 12 order Close all");		
		}	
		
		/*订单数量11个，且获利超过300美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==11)&&(anti_orderprofitall()>3000*mylots))
		{
			
			anti_turnoffflag = true;								
			Print("17 This turn Own more than one "+3000*mylots+" USD,equal 11 order Close all");		
		}

		
		/*订单数量10个，且获利超过280美元，落袋为安*/
		if((anti_ordercountwithprofit(-100) == 10)&&(anti_orderprofitall()>2800*mylots))
		{
			anti_turnoffflag = true;							
			Print("18 This turn Own more than one "+2800*mylots+" USD,equal1 or 10 order Close all");		
		}	
		
		

		
		/*订单数量9个，且获利超过260美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==9)&&(anti_orderprofitall()>2600*mylots))
		{
			anti_turnoffflag = true;							
			Print("19 This turn Own more than one "+2600*mylots+" USD,equal 9 order Close all");		
		}	

		/*订单数量8个，且获利超过240美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==8)&&(anti_orderprofitall()>2400*mylots))
		{
			anti_turnoffflag = true;					
			Print("20 This turn Own more than one "+2400*mylots+" USD,equal 8 order Close all");		
		}	
		
		/*订单数量7个，且获利超过220美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==7)&&(anti_orderprofitall()>2200*mylots))
		{
			
			anti_turnoffflag = true;					
			Print("21 This turn Own more than one "+2200*mylots+" USD,equal 7 order Close all");		
		}

		
		/*订单数量6个，且获利超过200美元，落袋为安*/
		if((anti_ordercountwithprofit(-100) == 6)&&(anti_orderprofitall()>2000*mylots))
		{
			anti_turnoffflag = true;			
			Print("22 This turn Own more than one "+2000*mylots+" USD,equal1 or 6 order Close all");		
		}	
				
		/*订单数量5个，且获利超过180美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==5)&&(anti_orderprofitall()>1800*mylots))
		{
			anti_turnoffflag = true;				
			Print("23 This turn Own more than one "+1800*mylots+" USD,equal 5 order Close all");		
		}	

		/*订单数量4个，且获利超过150美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==4)&&(anti_orderprofitall()>1500*mylots))
		{
			anti_turnoffflag = true;					
			Print("24 This turn Own more than one "+1500*mylots+" USD,equal 4 order Close all");		
		}	
		
		/*订单数量3个，且获利超过120美元，落袋为安*/
		if((anti_ordercountwithprofit(-100)==3)&&(anti_orderprofitall()>1200*mylots))
		{
			anti_turnoffflag = true;						
			Print("25 This turn Own more than one "+1200*mylots+" USD,equal 3 order Close all");		
		}
		
		/*订单数量1\2个，且获利超过80美元，落袋为安*/
		if((anti_ordercountwithprofit(-100) <= 2)&&(anti_orderprofitall()>800*mylots))
		{
			anti_turnoffflag = true;			
			Print("26 This turn Own more than one "+800*mylots+" USD,equal1 or 2 order Close all");		
		}	
						
		
		
	}	
	
	//本平台达到盈利关闭要求，设置文件标志
	if(anti_turnoffflag == true)
	{	
		
		if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))
		{			
			ForceWriteFileInt(MyAntiTradeFile[curtradefileNum],FILETRADEDFLAG);	
			Print("!!!Set anti-Traded Flag Now!!");						
		}				
		
	}
	
	
	
	
	if(true == anti_turnoffflag)
	{
		int j = 0;
		int k = 0;
		
		/*一波做完后，手工禁止交易；第二天继续做*/
		anti_setglobaltradeflag(false);
		subject = g_forexserver +":anti-trade All Orders Closed Now,Please Close Other Oders quickly";
		SendMail( subject,some_text);						
		anti_ordercloseallwithprofit(-100);
		Sleep(1000); 
		anti_ordercloseall();
		Sleep(1000); 
		anti_ordercloseall2();		
		Sleep(1000);
		anti_ordercloseallwithprofit(-100);
		Sleep(1000); 
		anti_ordercloseall();
		Sleep(1000); 
		anti_ordercloseall2();		
		anti_ordercloseallwithprofit(-100);
		Sleep(1000); 
		anti_ordercloseall();
		Sleep(1000); 
		anti_ordercloseall2();
		anti_ordercloseallwithprofit(-100);
		Sleep(1000); 
		anti_ordercloseall();
		Sleep(1000); 
		anti_ordercloseall2();
		anti_ordercloseallwithprofit(-100);
		Sleep(1000); 
		anti_ordercloseall();
		Sleep(1000); 
		anti_ordercloseall2();						
		anti_ordercloseallwithprofit(-100);
		Sleep(1000); 
		anti_ordercloseall();
		Sleep(1000); 
		anti_ordercloseall2();
		
		for(j = 0;j < 12; j++)
		{
			if(anti_ordercountall()>0)
			{
				anti_ordercloseallwithprofit(-100);
				Sleep(1000); 
				anti_ordercloseall();
				Sleep(1000); 
				anti_ordercloseall2();			
				Sleep(1000); 
				k++;				
			}
			
		}
		if(k>=(j-1))
		{		
			Print("!!anti_monitoraccountprofit Something Serious Error by colse all order,pls close handly");			
			SendMail( "!!anti_monitoraccountprofit Something Serious Error by colse all order,pls close handly","");		
		}
				
				
	}
	
}


void anti_orderbuyselltypeone(int SymPos)
{
	
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;

	double boll_up_B,boll_low_B,boll_mid_B,bool_length;	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;
	double orderpoint;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	
	datetime timelocal;	
	int subvalue;
		
	int i,ticket;
 	int ttick=0 ;
	int    vdigits ;
	
	/*一分钟周期寻找买卖点*/
	timeperiodnum = 0;	
	orderStopLevel=0;
	orderLots = 0;   
	orderStopless = 0;
	orderTakeProfit = 0;
	orderPrice = 0;
			
	
	my_symbol =   MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
	//确保寻找买卖点是每个周期计算一次，而不是每个tick计算一次
	if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent == iBars(my_symbol,my_timeperiod))
	{
		return;
	}
	
	
	boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
	boll_mid_B = (boll_up_B + boll_low_B )/2;
	/*point*/
	bool_length =(boll_up_B - boll_low_B )/2;	


	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
					
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberEleven))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberThirteen))==true))
		)
	{
		
		
		/*三十分钟强势，五分钟不若失，一分钟bool背驰，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	

			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	
									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.55)			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberEleven))==true)				
			)			
		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vbid;						 

			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[10] = orderStopless;	

			
			orderStopless =MaxValue4 + bool_length*48; 
			BuySellPosRecord[SymPos].NextModifyValue2[10] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[10] = orderPrice;

			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderStopless - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice + orderStopLevel*orderpoint;
			 }
			 if ((orderPrice - orderTakeProfit) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice - orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			

									

			//orderTakeProfit = 0;									
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
											

		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  
			
					
			Print(my_symbol+" AntiMagicNumberEleven"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{			

				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);	
					orderPrice = vbid;							
				 
					 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "AntiMEleven"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberEleven),0,Blue);
			
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend AntiMagicNumberEleven"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {   
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[10] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[10] = iBars(my_symbol,my_timeperiod);				 					 
						Print("OrderSend AntiMagicNumberEleven"+IntegerToString(subvalue)+"  successfully");
					 }
														 
					 Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}					
				
			}					 
							
		}
		

		
		/*三十分钟和四小时多头向上，五分钟空头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.45)	
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.15)		
											
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberThirteen))==true)			
			)			

		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vbid;		
			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[12] = orderStopless;
			
			orderStopless =MaxValue4 + bool_length*48; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[12] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[12] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderStopless - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice + orderStopLevel*orderpoint;
			 }
			 if ((orderPrice - orderTakeProfit) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice - orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			



			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  													
					
			Print(my_symbol+" AntiMagicNumberThirteen"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			 if(true == anti_accountcheck())
			 {
			 	
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);	
					orderPrice = vbid;				 	
			 
					 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "AntiMThirteen"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberThirteen),0,Blue);
			
					 if(ticket <0)
					 {
						 	ttick++;
							Print("OrderSend AntiMagicNumberThirteen"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
					 }
					 else
					 {  
						 	ttick = 100; 
							TwentyS_Freq++;
							OneM_Freq++;
							ThirtyS_Freq++;
							FiveM_Freq++;
							ThirtyM_Freq++;	
							BuySellPosRecord[SymPos].NextModifyPos[12] = iBars(my_symbol,my_timeperiod)+22;					 
							BuySellPosRecord[SymPos].TradeTimePos[12] = iBars(my_symbol,my_timeperiod);				 					 
							Print("OrderSend AntiMagicNumberThirteen"+IntegerToString(subvalue)+"  successfully");
					 }
														 
					 Sleep(1000);		
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}						
				
			}					 
							
		
		}					
		
		
	}			
	
	
////////////////////////////////////////////////////////////////////////
//多空分界线
////////////////////////////////////////////////////////////////////////
	
	
	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了优化比较好的入场点，和止损点
	//趋势回调高点型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
					
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)		
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberTwelve))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberFourteen))==true)))
	{
		
		/*三十分钟强势，五分钟不弱势，一分钟bool背驰，多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

											
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.45)			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberTwelve))==true)				
			)			
				
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	


			BuySellPosRecord[SymPos].NextModifyValue1[11] = orderStopless;
			
			
			orderStopless =MinValue3- bool_length*48; 	
			BuySellPosRecord[SymPos].NextModifyValue2[11] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[11] = orderPrice;		
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderPrice - orderStopless) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice - orderStopLevel*orderpoint;
			 }
			 if ((orderTakeProfit - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice + orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			

			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
				    			 	 		 			 	 		 			 	
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  													
								
			Print(my_symbol+" AntiMagicNumberTwelve"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
						
			if(true == anti_accountcheck())
			{	
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;					
								
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "AntiMTwelve"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberTwelve),0,Blue);
		
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend AntiMagicNumberTwelve"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}					
					 }
					 else
					 {    
					 	ttick=100;        
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[11] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[11] = iBars(my_symbol,my_timeperiod);				 				 
						Print("OrderSend AntiMagicNumberTwelve"+IntegerToString(subvalue)+"  successfully");
					 }													
					Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}						
				
			}


		}

				


		/*五分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.65)	

			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex > -0.15)		
											
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberFourteen))==true)			
			)	
			
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	

			BuySellPosRecord[SymPos].NextModifyValue1[13] = orderStopless;
			
			orderStopless =MinValue3- bool_length*48; 	
			BuySellPosRecord[SymPos].NextModifyValue2[13] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[13] = orderPrice;
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*96;
			/*参数修正*/ 
			orderStopLevel =MarketInfo(my_symbol,MODE_STOPLEVEL);	
			orderpoint = MarketInfo(my_symbol,MODE_POINT);
			orderStopLevel = 1.2*orderStopLevel;
			 if ((orderPrice - orderStopless) < orderStopLevel*orderpoint)
			 {
					orderStopless = orderPrice - orderStopLevel*orderpoint;
			 }
			 if ((orderTakeProfit - orderPrice) < orderStopLevel*orderpoint)
			 {
					orderTakeProfit = orderPrice + orderStopLevel*orderpoint;
			 }
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			
			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
				
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  				
			Print(my_symbol+" AntiMagicNumberFourteen"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{
				
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;					
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "AntiMFourteen"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberFourteen),0,Blue);
		
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend AntiMagicNumberFourteen"+IntegerToString(subvalue)+" failed with error #",GetLastError());
						if(GetLastError()!=134)
						{
							 //---- 5 seconds wait
							 Sleep(5000);
							 //---- refresh price data
							 RefreshRates();						
						}
						else 
						{
							Print("There is no enough money!");						
						}
	
					 }
					 else
					 {     
					 	ttick=100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[13] = iBars(my_symbol,my_timeperiod)+22;					 
						BuySellPosRecord[SymPos].TradeTimePos[13] = iBars(my_symbol,my_timeperiod);				 				 
						Print("OrderSend AntiMagicNumberFourteen"+IntegerToString(subvalue)+"  successfully");
					 }													
					Sleep(1000);
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}						
				
			}					
				
		}			
							
					
	}	
						
}



void anti_orderbuyselltypetwo(int SymPos)
{
	
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;

	double boll_up_B,boll_low_B,boll_mid_B,bool_length;	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	datetime timelocal;	
	int subvalue;	
	int i,ticket;
 	int ttick;
	int    vdigits ;
	
	/*五分钟周期寻找买卖点，用到日线指标*/
	timeperiodnum = 1;	

	orderStopLevel=0;
	orderLots = 0;   
	orderStopless = 0;
	orderTakeProfit = 0;
	orderPrice = 0;
			
	
	my_symbol =   MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];
		
	//确保寻找买卖点是每个周期计算一次，而不是每个tick计算一次
	if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent == iBars(my_symbol,my_timeperiod))
	{
		return;
	}

	boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
	boll_mid_B = (boll_up_B + boll_low_B )/2;
	/*point*/
	bool_length =(boll_up_B - boll_low_B )/2;	
	

	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) == true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberFifteen))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberseventeen))==true)))
	{

		
		/*四小时强势，三十分钟不弱势，五分钟bool背驰，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.55)			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberFifteen))==true)			
			)	
			
		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vbid;						 

			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[14] = orderStopless;	

			
			orderStopless =MaxValue4 + bool_length*16; 
			BuySellPosRecord[SymPos].NextModifyValue2[14] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[14] = orderPrice;
			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			

									

			//orderTakeProfit = 0;		
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  										
					
			Print(my_symbol+" AntiMagicNumberFifteen"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == anti_accountcheck())
			 {
					 
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
						vbid    = MarketInfo(my_symbol,MODE_BID);	
						orderPrice = vbid;							 
						
						ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "AntiMFifteen"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberFifteen),0,Blue);
						
						if(ticket <0)
						{
							ttick++;
							Print("OrderSend AntiMagicNumberFifteen"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
						}
						else
						{   
							ttick = 100;
							TwentyS_Freq++;
							OneM_Freq++;
							ThirtyS_Freq++;
							FiveM_Freq++;
							ThirtyM_Freq++;				 
							BuySellPosRecord[SymPos].NextModifyPos[14] = iBars(my_symbol,my_timeperiod)+20;					 
							BuySellPosRecord[SymPos].TradeTimePos[14] = iBars(my_symbol,my_timeperiod);				 					 
							Print("OrderSend AntiMagicNumberFifteen"+IntegerToString(subvalue)+"  successfully");
						}
														 
						Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}							
				
			}					 
							
		}
			
			

		
		/*日线和四小时多头向上，五分钟空头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	

			
			&& (3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])										
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.55)			


			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberseventeen))==true)			
			)	
			
		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vbid;		
			
			orderStopless =MaxValue4 + bool_length*4; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[16] = orderStopless;
			
			orderStopless =MaxValue4 + bool_length*16; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[16] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[16] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/
				
			orderTakeProfit	= 	orderPrice - bool_length*48;			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
																					


		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  										
										
			Print(my_symbol+" AntiMagicNumberseventeen"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
				+ orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == anti_accountcheck())
			 {
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
						vbid    = MarketInfo(my_symbol,MODE_BID);	
						orderPrice = vbid;				 	
				 
					 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "AntiMseventeen"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberseventeen),0,Blue);
			
					 if(ticket <0)
					 {
					 		ttick++;
							Print("OrderSend AntiMagicNumberseventeen"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
					 }
					 else
					 {   
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;				 
						BuySellPosRecord[SymPos].NextModifyPos[16] = iBars(my_symbol,my_timeperiod)+20;					 
						BuySellPosRecord[SymPos].TradeTimePos[16] = iBars(my_symbol,my_timeperiod);				 					 
						Print("OrderSend AntiMagicNumberseventeen"+IntegerToString(subvalue)+"  successfully");
					 }
														 
					 Sleep(1000);	
				}
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}						
				
			}					 
								
		
		}			
			

	}			
	

	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////		
	//多空分界		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////		
			


	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了优化比较好的入场点，和止损点
	//趋势回调探高型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
							
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) == true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberSixteen))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumbereighteen))==true)))
	{
		
		/*四小时强势，三十分钟不弱势，五分钟bool背驰，多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	


			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	

											
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.45)			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumberSixteen))==true)				
			)
	
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	


			BuySellPosRecord[SymPos].NextModifyValue1[15] = orderStopless;
			
			
			orderStopless =MinValue3- bool_length*16; 	
			BuySellPosRecord[SymPos].NextModifyValue2[15] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[15] = orderPrice;		
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			

			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
																				
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5;  				
			
			Print(my_symbol+" AntiMagicNumberSixteen"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;		
							 									
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "AntiMSixteen"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumberSixteen),0,Blue);
		
					 if(ticket <0)
					 {
						 	ttick++;
							Print("OrderSend AntiMagicNumberSixteen"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
					 }
					 else
					 {        
					 	ttick = 100;    
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[15] = iBars(my_symbol,my_timeperiod)+20;					 
						BuySellPosRecord[SymPos].TradeTimePos[15] = iBars(my_symbol,my_timeperiod);				 				 
						Print("OrderSend AntiMagicNumberSixteen"+IntegerToString(subvalue)+"  successfully");
					 }	
					Sleep(1000);						 
				}		
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}									

			}


		}
				

		/*三十分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
						
			&& (-3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])										
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.45)			
										
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,AntiMagicNumbereighteen))==true)			
			)	
			
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;				 

			orderStopless =MinValue3- bool_length*4; 	

			BuySellPosRecord[SymPos].NextModifyValue1[17] = orderStopless;
			
			orderStopless =MinValue3- bool_length*16; 	
			BuySellPosRecord[SymPos].NextModifyValue2[17] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[17] = orderPrice;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*48;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			
			//orderTakeProfit = 0;
																
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
																			
		  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
		  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
			subvalue = (TimeDayOfWeek(timelocal))%5; 	    			 	 		 			 	 		 			 	

			Print(my_symbol+" AntiMagicNumbereighteen"+IntegerToString(subvalue)+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == anti_accountcheck())
			{
				
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					orderPrice = vask;									 																					
					ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "AntiMeighteen"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,AntiMagicNumbereighteen),0,Blue);
		
					 if(ticket <0)
					 {
						 	ttick++;
							Print("OrderSend AntiMagicNumbereighteen"+IntegerToString(subvalue)+" failed with error #",GetLastError());
							if(GetLastError()!=134)
							{
								 //---- 5 seconds wait
								 Sleep(5000);
								 //---- refresh price data
								 RefreshRates();						
							}
							else 
							{
								Print("There is no enough money!");						
							}					
					 }
					 else
					 {     
					 	ttick = 100;
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[17] = iBars(my_symbol,my_timeperiod)+20;					 
						BuySellPosRecord[SymPos].TradeTimePos[17] = iBars(my_symbol,my_timeperiod);				 				 
						Print("OrderSend AntiMagicNumbereighteen"+IntegerToString(subvalue)+"  successfully");
					 }													
					Sleep(1000);	
				}
				
				if((ttick>= 19)	&&(ttick<25))
				{
						Print("!!Fatel error encouter please check your platform right now!");					
				}						
				
				
			}					
			
		}			
				

		
	}						

						
	
}




//end anti-order zone
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
	
	
	
	
	


//int start()
void OnTick(void)
{


	string mMailTitlle = "";

	int SymPos;
	double orderStopLevel;
	
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;

	string my_symbol;
	
	double MinValue3 = 100000;
	double MaxValue4=-1;
	///////////
	int my_timeperiod = 0;
	int timeperiodnum = 0;
	///////////
	

	
	//---
	// initial data checks
	// it is important to make sure that the expert works with a normal
	// chart and the user did not make any mistakes setting external 
	// variables (Lots, StopLoss, TakeProfit, 
	// TrailingStop) in our case, we check TakeProfit
	// on a chart of less than 100 bars
	//---

	if(iBars(NULL,0) <500)
	{
	  Print("Bar Number less than 500");
	  return;
	}


	orderStopLevel=0;
	orderLots = 0;   
	orderStopless = 0;
	orderTakeProfit = 0;
	orderPrice = 0;


	/*异常大量交易检测*/
	Freq_Count++;

	if(TwentyS_Freq > 9)
	{
		 Print("detect ordersend unnormal");
		 return;
	}
	else
	{
		if (0== (Freq_Count%20))
		{
			 TwentyS_Freq = 0;
		}
	}

	if(ThirtyS_Freq > 15)
	{
      Print("detect ordersend unnorma2");
		 return;
	}
	else
	{
		if (0== (Freq_Count%30))
		{
			 ThirtyS_Freq = 0;
		}
	}

	if(OneM_Freq > 21)
	{
      Print("detect ordersend unnorma3");
		 return;
	}
	else
	{
		if (0== (Freq_Count%60))
		{
			 OneM_Freq = 0;
		}
	}

	if(FiveM_Freq > 37)
	{
      Print("detect ordersend unnorma4");
		 return;
	}
	else
	{
		if (0== (Freq_Count%300))
		{
			 FiveM_Freq = 0;
		}
	}

	if(ThirtyM_Freq > 55)
	{
      Print("detect ordersend unnorma5");
		 return;
	}
	else
	{
		if (0== (Freq_Count%1800))
		{
			 ThirtyM_Freq = 0;
		}
	}
	


	
	//美国非农数据发布时间 
	//原则上持有订单，但是订单设置为1分钟止损类型，期间不做任何其他处理，时间周期一般在1个小时	
	if(importantdatatimeoptall(feinongtime1,feilongtimeoffset1,1)==true)
	{
	   PrintFlag = true;
	   ChartEvent = iBars(NULL,0);     
		for(SymPos = 0; SymPos < symbolNum;SymPos++)
		{	
			for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
			{
				my_symbol =   MySymbol[SymPos];
				my_timeperiod = timeperiod[timeperiodnum];		
				BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(my_symbol,my_timeperiod);
			}
	   }			
		return;
	}



	
	//美国非农数据发布时间 
	//原则上持有订单，但是订单设置为1分钟止损类型，期间不做任何其他处理，时间周期一般在1个小时	
	if(importantdatatimeoptall(feinongtime2,feilongtimeoffset2,1)==true)
	{
	   PrintFlag = true;
	   ChartEvent = iBars(NULL,0);     
		for(SymPos = 0; SymPos < symbolNum;SymPos++)
		{	
			for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
			{
				my_symbol =   MySymbol[SymPos];
				my_timeperiod = timeperiod[timeperiodnum];		
				BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(my_symbol,my_timeperiod);
			}
	   }			
		return;
	}



	//联储议息会议结果发布期间，
	//原则上持有订单，但是订单设置为1分钟止损类型，期间不做任何其他处理，时间周期一般在4个小时
	
	if(importantdatatimeoptall(yixitime1,yixitimeoffset1,1)==true)
	{
	   PrintFlag = true;
	   ChartEvent = iBars(NULL,0);     
		for(SymPos = 0; SymPos < symbolNum;SymPos++)
		{	
			for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
			{
				my_symbol =   MySymbol[SymPos];
				my_timeperiod = timeperiod[timeperiodnum];		
				BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(my_symbol,my_timeperiod);
			}
	   }			
		return;
	}

	if(importantdatatimeoptall(yixitime2,yixitimeoffset2,1)==true)
	{
	   PrintFlag = true;
	   ChartEvent = iBars(NULL,0);     
		for(SymPos = 0; SymPos < symbolNum;SymPos++)
		{	
			for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
			{
				my_symbol =   MySymbol[SymPos];
				my_timeperiod = timeperiod[timeperiodnum];		
				BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(my_symbol,my_timeperiod);
			}
	   }			
		return;
	}



	

	//重大黑天鹅事件期间，原则上关闭所有订单，期间不做任何交易；期间至少在16个小时以上
	//诸如美国总统大选、法国总统大选、意大利总统大选等时间点可预测事件
	if(importantdatatimeoptall(bigeventstime,bigeventstimeoffset,0)==true)
	{
	   PrintFlag = true;
	   ChartEvent = iBars(NULL,0);     
		for(SymPos = 0; SymPos < symbolNum;SymPos++)
		{	
			for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
			{
				my_symbol =   MySymbol[SymPos];
				my_timeperiod = timeperiod[timeperiodnum];		
				BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(my_symbol,my_timeperiod);
			}
	   }		
		
		return;
	}


	/*自动调整交易手数，即下午1-2点之间每隔5分钟检查一次设计*/
	autoadjustglobalamount();
	
	
	//新一轮周期开始前初始化文件系统
	autoadjestfile();


	//将文件值转存到变量中
	transferfiletoflag();

	/*在交易时间段来临前确保使能全局交易标记，即下午1-2点之间每隔5分钟检查一次设计*/
	enableglobaltradeflag();
	anti_enableglobaltradeflag();

/*默认晚上07:30点后强制关闭所有订单，实际情况是如果晚上8:30以后有重要数据，建议8:10之前平仓所有订单，不要受重大数据影响*/
/*坚决不参与重大数据发布行情*/
/*4点以后如果只有anti-trade，那么强行关闭所有anti-trade*/
	anti_forcecloseall(4,29);	
	
	
	/*每周五的晚上强行清盘*/
	all_forcecloseall();	
	
	
	/*所有货币对所有周期指标计算*/	
	calculateindicator();
      
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{	
		
		trade_antitradeflag = false;
		
		/*特定货币一分钟寻找买卖点*/
		orderbuyselltypeone(SymPos);		
		anti_orderbuyselltypeone(SymPos);
				
		trade_antitradeflag = false;
		/*特定货币五分钟寻找买卖点*/		
		orderbuyselltypetwo(SymPos);		
		anti_orderbuyselltypetwo(SymPos);
				
		/*特定货币三十分钟寻找买卖点*/		
		//orderbuyselltypethree(SymPos);
	}
   

  
   ////////////////////////////////////////////////////////////////////////////////////////////////
   //订单管理优化，包括移动止损、直接止损、订单时间管理
   //暂时还没有想清楚该如何移动止损优化  
   ////////////////////////////////////////////////////////////////////////////////////////////////

		/*遗留顺势单的监控管理，基于顺势、马丁原理*/
		all_monitoraccountprofit();

      
   /*短线获利清盘针对一分钟盘面*/
   monitoraccountprofit();
   anti_monitoraccountprofit();

	/////////////////////////////////////////////////
   //OneMSaveOrder();
   PrintFlag = true;
   ChartEvent = iBars(NULL,0);     
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{	
		for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
		{
			my_symbol =   MySymbol[SymPos];
			my_timeperiod = timeperiod[timeperiodnum];		
			BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(my_symbol,my_timeperiod);
		}
   }
   
   return;
   
   
}
//+------------------------------------------------------------------+

//"C:\\hkfy168.com"
////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//排除当天所有顺势单，当天的单有专门的监控程序来监控，5天为一个周期
bool all_isvalidmagicnumber(int magicnumber)
{
		
	bool flag = true;
	int SymPos,NowMagicNumber;
	datetime timelocal;	
	int subvalue;	
	
	SymPos = ((int)magicnumber) /1000;
	NowMagicNumber = magicnumber - SymPos *1000;

	if((SymPos<0)||(SymPos>=symbolNum))
	{
	 flag = false;
	}	
	
  /*原则上采用GMT时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60-8*60*60; 
	subvalue = (TimeDayOfWeek(timelocal))%5;  
	//排除当天的顺势单
	if(subvalue== (NowMagicNumber%10))
	{
	 flag = false;
	}	
	
	if(5 < (NowMagicNumber%10))
	{
	 flag = false;
	}	
	
	NowMagicNumber = ((int)NowMagicNumber) /10;
	if((NowMagicNumber<=0)||(NowMagicNumber>=11))
	{
	 flag = false;
	}	
	
	//flag = true;

	return flag;
	
}


double all_orderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				profit = profit + OrderProfit()+OrderCommission();
			}
			
		}
	}
	return profit;
}


double all_profitorderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				if((OrderProfit()+OrderCommission())>0)
				{			
					profit = profit + OrderProfit()+OrderCommission();
				}
			}			

			
		}
	}
	return profit;
}


int all_ordercountwithprofit(double myprofit)
{
	int count = 0;
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
				if((OrderProfit()+OrderCommission())>myprofit)
				{
					count++;
				}
			}
		}
	}
	return count;
}



int all_ordercountall( )
{
	int count = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{
				count++;
			}
			
		}
	}
	return count;
}


int all_profitordercountall( double myprofit)
{
	int count = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
				if((OrderProfit()+OrderCommission())>myprofit)
				{
					count++;
				}	
			}		
		}
	}
	return count;
}


void all_ordercloseallwithprofit(double myprofit)
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			
			
				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseallwithprofit SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if((OrderType()==OP_BUY)&&((OrderProfit()+OrderCommission())>myprofit))
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					if(ticket <0)
					{
						Print("OrderClose buy ordercloseallwithprofit with vbid failed with error #",GetLastError());
					}
					else
					{            
						Print("OrderClose buy ordercloseallwithprofit  with vbid  successfully");
					}    	
					Sleep(1000); 
	
				}
				
	
				if((OrderType()==OP_SELL)&&((OrderProfit()+OrderCommission())>myprofit))
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("OrderClose sell ordercloseallwithprofit with vask failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderClose sell ordercloseallwithprofit  with vask  successfully");
					 }    		
					Sleep(1000); 
				}
			
			}
			
		}
	}
	
	return;
}



void all_ordercloseall()
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			

				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseall SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if(OrderType()==OP_BUY)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					 if(ticket <0)
					 {
						Print("OrderClose buy ordercloseall with vbid failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderClose buy ordercloseall with vbid  successfully");
					 }    	
					Sleep(1000); 
			
				}
				
	
				if(OrderType()==OP_SELL)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("OrderClose sell ordercloseall with vask  failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderClose sell ordercloseall with vask   successfully");
					 }  
					Sleep(1000);				 
			
				}
			
			}
			
		}
	}
	
	return;
}


void all_ordercloseall2()
{
	int i,SymPos,NowMagicNumber,ticket;
	string my_symbol;
	double vbid,vask;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			if(all_isvalidmagicnumber((int)OrderMagicNumber()) == true)
			{			

				SymPos = ((int)OrderMagicNumber()) /1000;
				NowMagicNumber = OrderMagicNumber() - SymPos *1000;
	
				if((SymPos<0)||(SymPos>=symbolNum))
				{
				 Print(" ordercloseall2 SymPos error 0");
				}
					
				my_symbol = MySymbol[SymPos];
				
				vbid    = MarketInfo(my_symbol,MODE_BID);						  
				vask    = MarketInfo(my_symbol,MODE_ASK);	
				
				if(OrderType()==OP_BUY)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
					  
					 if(ticket <0)
					 {
						Print("!!OrderClose buy ordercloseall2 with vask failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("!!OrderClose buy ordercloseall2 with vask  successfully");
					 }    	
					Sleep(1000); 
			
				}
					
				if(OrderType()==OP_SELL)
				{
					ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
					  
					 if(ticket <0)
					 {
						Print("!!OrderClose sell ordercloseall2 with vbid  failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("!!OrderClose sell ordercloseall2 with vbid   successfully");
					 }  
					Sleep(1000);				 
			
				}
			
			}
			
		}
	}
	
	return;
}


void all_monitoraccountprofit()
{

	double mylots = 0;	
	double mylots0 = 0;
	
	datetime timelocal;	

	string subject="";
	string some_text="";

	bool turnoffflag = false;

	/*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
	timelocal = TimeCurrent() + globaltimezonediff*60*60;

	/*当天订单已经平掉的情况下就不走这个分支了*/
	if(all_ordercountall()<=2)
	{
		return;
	}
	
	/*短线获利清盘，长线后面再考虑*/
	//if(1 == Period())
	{
		
		/*欧美盘最有可能创新高*/
		if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <=23 )) 
		{
					
			/*超过9个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((all_ordercountall()>=(symbolNum/3))&&(all_ordercountall() == all_profitordercountall(0)))
			{
				Print("1.1 This turn Own more than "+(symbolNum/3)+" orders witch is "+all_ordercountall()+" all profit order,Close all");	
				
				turnoffflag = true;			
								
			}
			mylots0 = MyLotsH*1.5;
			mylots = MyLotsH*1.5*0.75;
				
		}	
		/*ya盘也有可能创新高*/
		else if ((TimeHour(timelocal) >= 6 )&& (TimeHour(timelocal) <= 12 )) 
		{
			
			/*超过8个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((all_ordercountall()>=(symbolNum/6))&&(all_ordercountall() == all_profitordercountall(0)))
			{
				Print("1.2 This turn Own more than  "+(symbolNum/6)+"  orders witch is "+all_ordercountall()+" all profit order,Close all");					
				turnoffflag = true;		
						
			}		
			mylots0 = MyLotsH*1.5*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75;					
			
		}
		/*欧美盘延续期间可能持续创新高*/
		else if ((TimeHour(timelocal) >= 0 )&& (TimeHour(timelocal) <= 3 )) 
		{
			
			/*超过12个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((all_ordercountall()>=(symbolNum/9))&&(all_ordercountall() == all_profitordercountall(0)))
			{
				Print("1.3 This turn Own more than  "+(symbolNum/9)+"  orders witch is "+all_ordercountall()+" all profit order,Close all");					
				turnoffflag = true;		
				
			}		
			mylots0 = MyLotsH*1.5*0.75*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75*0.75;					
			
		}				
		
		else 
		{
			
			/*超过12个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
			
			if((all_ordercountall()>=(symbolNum/12))&&(all_ordercountall() == all_profitordercountall(0)))
			{
				Print("1.4 This turn win more than  "+(symbolNum/12)+"  orders witch is "+all_ordercountall()+" all profit order,Close all");					
				turnoffflag = true;		
				
			}		
			mylots0 = MyLotsH*1.5*0.5*0.75*0.75;	
			mylots = MyLotsH*1.5*0.75*0.75*0.75*0.75;					
			
		}		
				

		//对冲盘已经获利清空的情况下，降低本盘的获利标准，作废
		/*
		if(false == anti_getglobaltradeflag())
		{
			mylots0 = mylots0*0.75;	
			mylots = mylots*0.75;
		}
		*/
		//当发现别的平台有盈利平仓后，本平台也盈利平仓
		if(true ==alltradedok())
		{
			mylots0 = mylots0*0.5;	
			mylots = mylots*0.5;	
			Print("!!!!turn off all trade because of alltradedok!!!");			
			
		}

		
		/*盈利单的盈利总和超过1400美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_profitorderprofitall() > 14000*mylots0) &&(all_orderprofitall() >0)&&(all_ordercountall()>15))
		{					
			turnoffflag = true;		
			Print("2 This turn win more than "+14000*mylots0+" USD,Close all");
		}
		else if((all_profitorderprofitall() > 10000*mylots0) &&(all_orderprofitall() >0)&&(all_ordercountall()<=15))
		{
			turnoffflag = true;		
			Print("2.1 This turn win more than "+10000*mylots0+" USD,Close all");			
		}
		else
		{
			;
		}		
			
		/*所有单的盈利总和超过680美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(all_orderprofitall() > 6800*mylots0)
		{
							
			turnoffflag = true;			
			Print("3 This turn Own more than "+6800*mylots0+" USD,Close all");
		}

		/*八个以上30美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_ordercountwithprofit(300*mylots0)>= (all_ordercountall()/10)*8)&&(all_orderprofitall()>0))
		{
			turnoffflag = true;					
			Print("4 This turn Own more than eight "+":"+((all_ordercountall()/10)*8)+"::"+300*mylots0+" USD,Close all");
		}

		/*六个以上40美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_ordercountwithprofit(400*mylots0)>= (all_ordercountall()/10)*6)&&(all_orderprofitall()>0))
		{
			turnoffflag = true;					
			Print("4 This turn Own more than six "+":"+((all_ordercountall()/10)*6)+"::"+400*mylots0+" USD,Close all");
		}

		/*五个以上50美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_ordercountwithprofit(500*mylots0)>= (all_ordercountall()/10)*5)&&(all_orderprofitall()>0))
		{
			
			turnoffflag = true;				
			Print("5 This turn Own more than Five "+":"+((all_ordercountall()/10)*5)+"::"+500*mylots0+" USD,Close all");
		}

		/*四个以上70美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_ordercountwithprofit(700*mylots0)>= (all_ordercountall()/10)*4)&&(all_orderprofitall()>0))
		{		
			
			turnoffflag = true;				
			Print("6 This turn Own more than four "+":"+((all_ordercountall()/10)*4)+"::"+700*mylots0+" USD,Close all");
		}
		
		/*三个以上100美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_ordercountwithprofit(1000*mylots0)>= (all_ordercountall()/10)*3)&&(all_orderprofitall()>0))
		{
			turnoffflag = true;			
			Print("7 1、This turn Own more than three "+":"+((all_ordercountall()/10)*3)+"::"+1000*mylots0+" USD,Close all");
		}
		
		/*两个以上150美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if((all_ordercountwithprofit(1500*mylots0)>= (all_ordercountall()/10)*2)&&(all_orderprofitall()>0))
		{
			turnoffflag = true;			
			Print("7 2、This turn Own more than two "+":"+((all_ordercountall()/10)*2)+"::"+1500*mylots0+" USD,Close all");
		}


		/*订单数量29个，且获利超过660美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==29)&&(all_orderprofitall()>6600*mylots))
		{

			turnoffflag = true;					
			Print("81 This turn Own more than one "+6600*mylots+" USD,equal 29 order Close all");		
		}	
		
		/*订单数量28个，且获利超过640美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==28)&&(all_orderprofitall()>6400*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+6400*mylots+" USD,equal 28 order Close all");		
		}	


		/*订单数量27个，且获利超过620美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==27)&&(all_orderprofitall()>6200*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+6200*mylots+" USD,equal 27 order Close all");		
		}	
		
		/*订单数量26个，且获利超过600美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==26)&&(all_orderprofitall()>6000*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+6000*mylots+" USD,equal 26 order Close all");		
		}	


		/*订单数量25个，且获利超过580美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==25)&&(all_orderprofitall()>5800*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+5800*mylots+" USD,equal 25 order Close all");		
		}	
		
		/*订单数量24个，且获利超过460美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==24)&&(all_orderprofitall()>5600*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+5600*mylots+" USD,equal 24 order Close all");		
		}	

		/*订单数量23个，且获利超过540美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==23)&&(all_orderprofitall()>5400*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+5400*mylots+" USD,equal 23 order Close all");		
		}	
		
		/*订单数量22个，且获利超过520美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==22)&&(all_orderprofitall()>5200*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+5200*mylots+" USD,equal 22 order Close all");		
		}	


		/*订单数量21个，且获利超过500美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==21)&&(all_orderprofitall()>5000*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+5000*mylots+" USD,equal 21 order Close all");		
		}	
		
		/*订单数量20个，且获利超过480美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==20)&&(all_orderprofitall()>4800*mylots))
		{

			turnoffflag = true;					
			Print("8 This turn Own more than one "+4800*mylots+" USD,equal 20 order Close all");		
		}	

		/*订单数量19个，且获利超过460美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==19)&&(all_orderprofitall()>4600*mylots))
		{
			turnoffflag = true;					
			Print("9 This turn Own more than one "+4600*mylots+" USD,equal 19 order Close all");		
		}	

		/*订单数量18个，且获利超过440美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==18)&&(all_orderprofitall()>4400*mylots))
		{
			
			turnoffflag = true;							
			Print("10 This turn Own more than one "+4400*mylots+" USD,equal 18 order Close all");		
		}	

		
		/*订单数量17个，且获利超过420美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==17)&&(all_orderprofitall()>4200*mylots))
		{
			
			turnoffflag = true;				
			Print("11 This turn Own more than one "+4200*mylots+" USD,equal 17 order Close all");		
		}	

		/*订单数量16个，且获利超过400美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==16)&&(all_orderprofitall()>4000*mylots))
		{
			
			turnoffflag = true;				
			Print("12 This turn Own more than one "+4000*mylots+" USD,equal 16 order Close all");		
		}	
		
		/*订单数量15个，且获利超过380美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==15)&&(all_orderprofitall()>3800*mylots))
		{

			turnoffflag = true;			
			Print("13 This turn Own more than one "+3800*mylots+" USD,equal 15 order Close all");		
		}

		
		/*订单数量14个，且获利超过360美元，落袋为安*/
		if((all_ordercountwithprofit(-100) == 14)&&(all_orderprofitall()>3600*mylots))
		{
			turnoffflag = true;				
			Print("14 This turn Own more than one "+3600*mylots+" USD,equal1 or 14 order Close all");		
		}	
		

		
		/*订单数量13个，且获利超过340美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==13)&&(all_orderprofitall()>3400*mylots))
		{
			turnoffflag = true;			
			Print("15 This turn Own more than one "+3400*mylots+" USD,equal 13 order Close all");		
		}	

		/*订单数量12个，且获利超过320美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==12)&&(all_orderprofitall()>3200*mylots))
		{
			turnoffflag = true;			
			Print("16 This turn Own more than one "+3200*mylots+" USD,equal 12 order Close all");		
		}	
		
		/*订单数量11个，且获利超过300美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==11)&&(all_orderprofitall()>3000*mylots))
		{
			
			turnoffflag = true;						
			Print("17 This turn Own more than one "+3000*mylots+" USD,equal 11 order Close all");		
		}

		
		/*订单数量10个，且获利超过280美元，落袋为安*/
		if((all_ordercountwithprofit(-100) == 10)&&(all_orderprofitall()>2800*mylots))
		{
			turnoffflag = true;						
			Print("18 This turn Own more than one "+2800*mylots+" USD,equal1 or 10 order Close all");		
		}	
		
		

		
		/*订单数量9个，且获利超过260美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==9)&&(all_orderprofitall()>2600*mylots))
		{
			turnoffflag = true;					
			Print("19 This turn Own more than one "+2600*mylots+" USD,equal 9 order Close all");		
		}	

		/*订单数量8个，且获利超过240美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==8)&&(all_orderprofitall()>2400*mylots))
		{
			turnoffflag = true;						
			Print("20 This turn Own more than one "+2400*mylots+" USD,equal 8 order Close all");		
		}	
		
		/*订单数量7个，且获利超过220美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==7)&&(all_orderprofitall()>2200*mylots))
		{
			
			turnoffflag = true;					
			Print("21 This turn Own more than one "+2200*mylots+" USD,equal 7 order Close all");		
		}

		
		/*订单数量6个，且获利超过200美元，落袋为安*/
		if((all_ordercountwithprofit(-100) == 6)&&(all_orderprofitall()>2000*mylots))
		{
			turnoffflag = true;				
			Print("22 This turn Own more than one "+2000*mylots+" USD,equal1 or 6 order Close all");		
		}	
				
		/*订单数量5个，且获利超过180美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==5)&&(all_orderprofitall()>1800*mylots))
		{
			turnoffflag = true;			
			Print("23 This turn Own more than one "+1800*mylots+" USD,equal 5 order Close all");		
		}	

		/*订单数量4个，且获利超过150美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==4)&&(all_orderprofitall()>1500*mylots))
		{
			turnoffflag = true;						
			Print("24 This turn Own more than one "+1500*mylots+" USD,equal 4 order Close all");		
		}	
		
		/*订单数量3个，且获利超过120美元，落袋为安*/
		if((all_ordercountwithprofit(-100)==3)&&(all_orderprofitall()>1200*mylots))
		{
			turnoffflag = true;						
			Print("25 This turn Own more than one "+1200*mylots+" USD,equal 3 order Close all");		
		}
		
		/*订单数量1\2个，且获利超过80美元，落袋为安*/
		if((all_ordercountwithprofit(-100) <= 2)&&(all_orderprofitall()>800*mylots))
		{
			turnoffflag = true;			
			Print("26 This turn Own more than one "+800*mylots+" USD,equal1 or 2 order Close all");		
		}			
		
	}	
	
	//本平台达到盈利关闭要求，设置文件标志
	if(turnoffflag == true)
	{	
		
		if((0<=curtradefileNum)&&(tradefileNum>curtradefileNum))
		{			
			ForceWriteFileInt(MyALLTradeFile[curtradefileNum],FILETRADEDFLAG);	
			Print("!!!Set ALLTraded Flag Now!!");						
		}				
		
	}
	

	
	
	
	if(turnoffflag == true)
	{			
		int j=0;
		int k = 0;
		/*一波做完后，手工禁止交易；第二天继续做*/
		subject = g_forexserver +":All Leaf Orders Closed Now,Please Close Other Oders quickly";
		SendMail( subject,some_text);				
		all_ordercloseallwithprofit(-100);
		Sleep(1000); 
		all_ordercloseall();
		Sleep(1000); 
		all_ordercloseall2();	
		Sleep(1000); 	
		all_ordercloseallwithprofit(-100);
		Sleep(1000); 
		all_ordercloseall();
		Sleep(1000); 
		all_ordercloseall2();			
		Sleep(1000); 	
		all_ordercloseallwithprofit(-100);
		Sleep(1000); 
		all_ordercloseall();
		Sleep(1000); 
		all_ordercloseall2();		
		Sleep(1000); 	
		all_ordercloseallwithprofit(-100);
		Sleep(1000); 
		all_ordercloseall();
		Sleep(1000); 
		all_ordercloseall2();	
			
		for(j = 0;j < 12; j++)
		{
			if(all_ordercountall()>0)
			{
				all_ordercloseallwithprofit(-100);
				Sleep(1000); 
				all_ordercloseall();
				Sleep(1000); 
				all_ordercloseall2();					
				Sleep(1000); 
				k++;				
			}
			
		}
		if(k>=(j-1))
		{		
			Print("!!all_monitoraccountprofit Something Serious Error by colse all order,pls close handly");			
			SendMail( "!!all_monitoraccountprofit Something Serious Error by colse all order,pls close handly","");		
		}		
						
	}
		
}


/*每周五的晚上强行清盘*/
void all_forcecloseall(void)
{

	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int j = 0;
	int k = 0;		
	datetime timelocal;	

	SymPos = 0;
	/*每隔五分钟算一次*/
	timeperiodnum = 1;
	
	my_symbol =   MySymbol[SymPos];	
	my_timeperiod = timeperiod[timeperiodnum];	
	
	
  /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/	
  timelocal = TimeCurrent() + globaltimezonediff*60*60;
	
	/*确保交易时间段，来临前开启全局交易交易标记*/
	if ((TimeHour(timelocal) == 4 )&& (TimeMinute(timelocal) >=  25) &&(TimeDayOfWeek(timelocal) == 6 ))
	{			
		//确保是每个周期五分钟计算一次，而不是每个tick计算一次
		if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
		{					

			//if(true == anti_getglobaltradeflag())
			{
				/*清盘所有当天开的单*/						
				if(anti_ordercountall()>0)
				{
					j = 0;
					k = 0;
									
					anti_setglobaltradeflag(false);				
					anti_ordercloseallwithprofit(-100);
					Sleep(1000); 
					anti_ordercloseall();
					Sleep(1000); 
					anti_ordercloseall2();		
					Sleep(1000); 
					anti_ordercloseallwithprofit(-100);
					Sleep(1000); 
					anti_ordercloseall();
					Sleep(1000); 
					anti_ordercloseall2();		
					Sleep(1000); 
					anti_ordercloseallwithprofit(-100);
					Sleep(1000); 
					anti_ordercloseall();
					Sleep(1000); 
					anti_ordercloseall2();		
					Sleep(1000); 
					anti_ordercloseallwithprofit(-100);
					Sleep(1000); 
					anti_ordercloseall();
					Sleep(1000); 
					anti_ordercloseall2();		
					Sleep(1000); 												
					for(j = 0;j < 12; j++)
					{
						if(anti_ordercountall()>0)
						{
							anti_ordercloseallwithprofit(-100);
							Sleep(1000); 
							anti_ordercloseall();
							Sleep(1000); 
							anti_ordercloseall2();			
							Sleep(1000); 
							k++;				
						}
						
					}
					if(k>=(j-1))
					{		
						Print("!!anti_forcecloseall Something Serious Error by colse all order,pls close handly");			
						SendMail( "!!anti_forcecloseall Something Serious Error by colse all order,pls close handly","");		
					}
																			
								
					Print("anti_forcecloseall Bad Solution anti-trade Force Close All Trade!");	 			
				}
				/*清盘所有当天开的单*/						
				if(ordercountall()>0)
				{								
				
					j = 0;
					k = 0;				
					setglobaltradeflag(false);				
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 
					ordercloseallwithprofit(-100);
					Sleep(1000); 
					ordercloseall();
					Sleep(1000); 
					ordercloseall2();		
					Sleep(1000); 												
												
					for(j = 0;j < 12; j++)
					{
						if(ordercountall()>0)
						{
							ordercloseallwithprofit(-100);
							Sleep(1000); 
							ordercloseall();
							Sleep(1000); 
							ordercloseall2();		
							Sleep(1000); 
							k++;				
						}
						
					}
					if(k>=(j-1))
					{		
						Print("!!forcecloseall Something Serious Error by colse all order,pls close handly");			
						SendMail( "!!forcecloseall Something Serious Error by colse all order,pls close handly","");		
					}
						
					Print("forcecloseall Bad Solution trade Force Close All Trade!");	 											

				}
				
				/*清盘所有前期遗留的单*/						
				if(all_ordercountall()>0)
				{		
					j=0;
					k = 0;			
					all_ordercloseallwithprofit(-100);
					Sleep(1000); 
					all_ordercloseall();
					Sleep(1000); 
					all_ordercloseall2();	
					Sleep(1000); 	
					all_ordercloseallwithprofit(-100);
					Sleep(1000); 
					all_ordercloseall();
					Sleep(1000); 
					all_ordercloseall2();			
					Sleep(1000); 	
					all_ordercloseallwithprofit(-100);
					Sleep(1000); 
					all_ordercloseall();
					Sleep(1000); 
					all_ordercloseall2();		
					Sleep(1000); 	
					all_ordercloseallwithprofit(-100);
					Sleep(1000); 
					all_ordercloseall();
					Sleep(1000); 
					all_ordercloseall2();	
						
					for(j = 0;j < 12; j++)
					{
						if(all_ordercountall()>0)
						{
							all_ordercloseallwithprofit(-100);
							Sleep(1000); 
							all_ordercloseall();
							Sleep(1000); 
							all_ordercloseall2();					
							Sleep(1000); 
							k++;				
						}
						
					}
					if(k>=(j-1))
					{		
						Print("!!forcecloseall Something Serious Error by colse all leaf order,pls close handly");			
						SendMail( "!!forcecloseall Something Serious Error by colse all leaf order,pls close handly","");		
					}
						
						Print("forcecloseall leaf Bad Solution trade Force Close All Trade!");	 	
										
				}			
			
			}
			
			
		}
	}	
	
}



///////////////////////////////////////////////////
//封装dll文件操作函数

bool WriteFileInt(string docName,int value)
{


   bool ret = true;
   if(false == MyDllCreateFile(docName))
   {
    Print("WriteFileInt MyDllCreateFile  wrong");
    ret = false;     
   
   }
   else
   {
      if(false == MyDllWriteFileIntFirst(docName,value))
      {
       ret = false;   
       Print("WriteFileInt MyDllWriteFileIntFirst  wrong");     
      
      }           
   }
   return ret;
}

void ForceWriteFileInt(string docName,unsigned short value)
{
   int count = 0;
   int ret = -1;
   int getvalue;
   while((ret <0)&&(count <10))
   {
      count++;      
      if(false == WriteFileInt(docName,value))
      {
         Print("ForceWriteFileInt WriteFileInt wrong");         
         ret = -1;
      }
      else
      {      
         getvalue = ReadFileInt(docName);
         if(getvalue<0)
         {
            ret = getvalue;
            Print("ForceWriteFileInt ReadFileInt wrong getvalue="+IntegerToString(getvalue));           
         }
         else
         {
            if (getvalue == value)
            {
               ret = 1;
               Print("ForceWriteFileInt write successful getvalue=" + IntegerToString(getvalue));
            }
            else
            {
               ret = -1;            
               Print("ReadWrite not same writevalue="+IntegerToString(value)
                + "readvalue = "+IntegerToString(getvalue));
            }            
         
         }     
      
      }
  
      if(ret<0)
      {
         Sleep(50);
      }      
   }
   if(count >= 9)
   {
      Print("ForceWriteFileInt Fator error occor during write value="
      + IntegerToString(value) + "to the file:"+docName );
   }
}

int ReadFileInt(string docName)
{
   int ret;
   ret=MyDllReadFileIntFirst(docName);
   if(ret<0)
   {
      //Print("ReadFileInt MyDllReadFileIntFirst wrong");
      ;
   }
   return ret;
}

void mydlltest()
{
   int mytest = 0;
   string myaddress2 = "C:\\mytest\\hkfy168.bin.txt";   
   string myaddress3 = "C:\\mytest\\tttt.bin";  
   int ret = 0;  
   mytest = GetTestIntValue();
   Print("this is = "+ IntegerToString(mytest)+"!!!!!!!!");
   if(false == MyDllFindFile(myaddress2))
   {
    Print("MyDllFindFile find wrong");     
   
   }
   else
   {
    Print("MyDllFindFile find OK");      
   }
   
   if(false == MyDllCreateFile(myaddress3))
   {
    Print("MyDllCreateFile  wrong");     
   
   }
   else
   {
      Print("MyDllCreateFile  OK");
      if(false == MyDllWriteFileIntFirst(myaddress3,8888))
      {
       Print("MyDllWriteFileIntFirst  wrong");     
      
      }
      else
      {
       Print("MyDllWriteFileIntFirst  OK");      
      }              
   }

   if(false == MyDllCreateFile(myaddress3))
   {
    Print("MyDllCreateFile  wrong");     
   
   }
   else
   {
      Print("MyDllCreateFile  OK");
      if(false == MyDllWriteFileIntFirst(myaddress3,9999))
      {
       Print("MyDllWriteFileIntFirst  wrong");     
      
      }
      else
      {
       Print("MyDllWriteFileIntFirst  OK");      
      }              
   }
   if(false == MyDllCreateFile(myaddress3))
   {
    Print("MyDllCreateFile  wrong");     
   
   }
   else
   {
      Print("MyDllCreateFile  OK");
      if(false == MyDllWriteFileIntFirst(myaddress3,666))
      {
       Print("MyDllWriteFileIntFirst  wrong");     
      
      }
      else
      {
       Print("MyDllWriteFileIntFirst  OK");      
      }              
   }
     
   ret = MyDllReadFileIntFirst(myaddress3);
   if(ret >0)
   {
   Print("MyDllReadFileIntFirst OK is = "+ IntegerToString(ret)+"!!!!!!!!");              
   }
   else
   {
   Print("MyDllReadFileIntFirst Wrong is = "+ IntegerToString(ret)+"!!!!!!!!");     
   }

}


/////////////////////
