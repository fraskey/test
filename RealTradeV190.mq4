//+------------------------------------------------------------------+
//|                                       MutiPeriodAutoTradePro.mq4 |
//|                   Copyright 2005-2017, Copyright. Personal Keep  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2017, Xuejiayong."
#property link        "http://www.mql14.com"


//发送电子邮件，参数subject为邮件主题，some_text为邮件内容 void SendMail( string subject, string some_text)


//通用宏定义
//////////////////////////////////////////
// 定义boolcross数组的长度
#define HCROSSNUMBER  50


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


#define HEXNESSSERVERDEMO "Exness-Trial2"
#define HTHINKMARKETSSERVERDEMO "ThinkForexAU-Demo"
//#define HICMARKETSSERVER "ICMarkets-Demo03"


#define HOANDASERVER ""

//结束外汇商专用宏定义
//////////////////////////////////////////


/*定义全局交易指标，确保每天只会交易一波，true为使能，false为禁止全局交易*/
bool globaltradeflag = true;

//全局变量定义
//////////////////////////////////////////
//input double TakeProfit    =50;
double MyLotsH          =0.02;
double MyLotsL          =0.02; 
//input double TrailingStop  =30;	

//定义服务器时间和本地时间（北京时间）差
int globaltimezonediff = 5;	
	


// 外汇商服务器名称
string g_forexserver;



int Move_Av = 2;
int iBoll_B = 60;
//input int iBoll_S = 20;

// 定义时间周期
int timeperiod[16];
int TimePeriodNum = 6;

// 定义外汇对
string MySymbol[50];
int symbolNum;



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


//后面改为局部变量，尚未改动？？？？？
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





// 定义避免因错误导致的瞬间反复购买探测变量
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

// 定义每一次交易发生时所记录下来的相关变量
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



////////////////////////////////////////////////////////////////////////

// 定义每次均线交叉bool轨道期间对应的状态描述
struct stBoolCrossRecord
{	
	int CrossFlag[HCROSSNUMBER];//5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨
	double CrossStrongWeak[HCROSSNUMBER];	
	double CrossTrend[HCROSSNUMBER];
	int CrossBoolPos[HCROSSNUMBER];
	
	int CrossFlagL[HCROSSNUMBER];//5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨
	double CrossStrongWeakL[HCROSSNUMBER];	
	double CrossTrendL[HCROSSNUMBER];
	int CrossBoolPosL[HCROSSNUMBER];
	double BoolFlagL;	
	int CrossFlagChangeL;	
				
	
	double StrongWeak;	//多头空头状态
	double Trend;//定义上涨下跌趋势
	double MoreTrend;//定义上涨下跌加速趋势
	double BoolIndex;
	double BoolFlag;	
	int CrossFlagChange;
	int CrossFlagTemp;	
	int CrossFlagTempPre;	
	int ChartEvent;
};



stBoolCrossRecord BoolCrossRecord[50][16];



////////////////////////////////////////////////////////
// 废弃掉了
/*
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
*/
////////////////////////////////////////////



////////////////////////////////////////////
//结束结构体定义
//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


// 连接到不同外汇商的实体服务器上，并针对不同的外汇商定义对应的外汇操作集合
void initsymbol()
{
	string subject="";
	g_forexserver = AccountServer();

	subject = g_forexserver +"Init Email Send Test is Good!";
	SendMail( subject, "");
	//Print(subject);

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
	else if(AccountServer() == HEXNESSSERVERDEMO)
	{
		MySymbol[0] = "AUDCADm";
		MySymbol[1] = "AUDCHFm";
		MySymbol[2] = "AUDJPYm";         
		MySymbol[3] = "AUDNZDm";         
		MySymbol[4] = "AUDUSDm";         
		MySymbol[5] = "CADCHFm"; 
		MySymbol[6] = "CADJPYm"; 	
		MySymbol[7] = "CHFJPYm"; 	
		MySymbol[8] = "EURAUDk";         
		MySymbol[9] = "EURCADk"; 
		MySymbol[10] = "EURCHFk"; 	
		MySymbol[11] = "EURGBPf"; 
		MySymbol[12] = "EURJPYm"; 	
		MySymbol[13] = "EURNZDm"; 
		MySymbol[14] = "EURUSDk"; 
		MySymbol[15] = "GBPAUDk"; 
		MySymbol[16] = "GBPCADm"; 
		MySymbol[17] = "GBPCHFm"; 	
		MySymbol[18] = "GBPJPYm"; 
		MySymbol[19] = "GBPNZDm"; 
		MySymbol[20] = "GBPUSDm"; 	
		MySymbol[21] = "NZDJPYm"; 	
		MySymbol[22] = "NZDUSDm"; 	
		MySymbol[23] = "USDCADm"; 	
		MySymbol[24] = "USDCHFm"; 	
		MySymbol[25] = "USDJPYm"; 	
		MySymbol[26] = "USDSGDm"; 		
					
		MySymbol[27] = "XAUUSDm";  
					
		
		MySymbol[28] = "NZDCADm"; 
				
		symbolNum = 29;
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
	else if(AccountServer() == HTHINKMARKETSSERVERDEMO)
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


/*定义操作的时间周期集合*/
void inittiimeperiod()
{
	timeperiod[0] = PERIOD_M1;
	timeperiod[1] = PERIOD_M5;
	timeperiod[2] = PERIOD_M30;
	timeperiod[3] = PERIOD_H4;
	timeperiod[4] = PERIOD_D1;
	timeperiod[5] = PERIOD_W1;
	
	TimePeriodNum = 6;
	
}

// 定义买卖点标志值
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

	
	
}

// 外汇商服务器连接测试，针对不同的服务器配置不同的初始参数，如时差
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
	else if(AccountServer() == HEXNESSSERVERDEMO)
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
	else if(AccountServer() == HTHINKMARKETSSERVERDEMO)
	{
		MyLotsH          =0.01;
		MyLotsL          =0.01; 
	
		//定义服务器时间和本地时间（北京时间）差
		globaltimezonediff = 6;	
				
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
	
	//测试专用
	MyLotsH          =0.01;
	MyLotsL          =0.01; 

	return connectflag;

	
}



// 打开所有需要交易的外汇集合，打开后才能进行交易，ducascopy也是有同样要求
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

// 设置magicnumber，组合了外汇对、买卖点类型、星期几等三个因素
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


// 设置正常交易的全局交易开关，关闭的情况下不进行任何交易，一波交易完成后当天不再进行任何交易
void setglobaltradeflag(bool flag)
{

	globaltradeflag = flag;
}

// 获取正常交易的全局交易开关
bool getglobaltradeflag(void)
{

	return globaltradeflag ;
}


/*启动时初始化正常交易的全局交易标记*/
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
	//20:00打开如果发现没有交易存在，则定义为当天交易已经结束，不再发起新的交易
	if (((TimeHour(timelocal) >= 20 )&& (TimeHour(timelocal) <=24 )) ||(TimeHour(timelocal) <3 ))
	{
				
		/*在正常交易盘已经清空的情况下设置Flag*/
		if(ordercountall()<2)
		{		
			setglobaltradeflag(false);			
			Print("initglobaltradeflag  setglobaltradeflag false ");						
		}
								
	}		
}


/*在交易时间段来临前确保使能全局交易标记*/
// 下午13点开始使能正常交易
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
// 根据不同的账户金额值来定义不同的交易手数
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

	//测试专用
	MyLotsH          =0.01;
	MyLotsL          =0.01; 	
	Print("For Test Set init Amount is = "+MyLotsH+":"+MyLotsL);	 	
	
}


/*每天交易前计算交易手数，只在下午一点计算，每隔5分钟算一次*/
// 根据不同的账户金额值来定义不同的交易手数
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
			
		//测试专用
		MyLotsH          =0.01;
		MyLotsL          =0.01; 	
		Print("For Test auto adjust global Amount is = "+MyLotsH+":"+MyLotsL);	
	
		}		
		
	}


	
}

// 判断MagicNumber是否已经存在交易，没有交易时返回true
// 确保每个买卖点只有一个交易存在
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
   			//未平仓的订单和挂单交易的平仓时间等于0
			if((OrderCloseTime() == 0)&&(OrderMagicNumber()== MagicNumber))
			{

			  status= false;
			  break;

			}
                
       }
	}
   return status;
}

// 初始化定义boolcross的值
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
	else if(timeperiodnum==5)
	{
		countnumber = 400;
	}
	else
	{
		countnumber = 100;
	}
		
	if(iBars(my_symbol,my_timeperiod) <countnumber)
	{
		Print(my_symbol + ":"+my_timeperiod+":Bar Number less than "+countnumber+"which is :" + iBars(my_symbol,my_timeperiod));
		return -1;
	}


	j = 0;
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
	

	j = 0;
	for (i = 2; i< countnumber;i++)
	{
		
		crossflag = 0;     
		myma=iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,i-1);  
		myboll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_UPPER,i-1);   
		myboll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_LOWER,i-1);
		myboll_mid_B = (	myboll_up_B +  myboll_low_B)/2;

		myma_pre = iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,i); 
		myboll_up_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_UPPER,i);      
		myboll_low_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_LOWER,i);
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
				BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[j] = crossflag;
				//BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[j] = TimeCurrent() - i*Period()*60;
				BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPosL[j] = iBars(my_symbol,my_timeperiod)-i;
				j++;
				if (j >= (HCROSSNUMBER-1))
				{
					break;
				}
		}

	}
	
	return 0;

}

// 初始化定义买卖点所对应的ibar位置，当前策略没有用该参数，不排除以后会用
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

// 初始化定义当前的MA强弱情况，由trend和strongweak分别定义
void InitMA(int SymPos,int timeperiodnum)
{

	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAThreePre,MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double MAThreePrePre,MAThenPrePre;
	double StrongWeak;
	int my_timeperiod;	
	string my_symbol;
	
	my_symbol = MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];	
	
	MAThree=iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,1); 
	MAThen=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,1); 

	MAThreePre = iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,2); 
	MAThenPre=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,2); 

	MAThreePrePre = iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,3); 
	MAThenPrePre=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,3); 

	
	MAFive=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,1); 
	MAThentyOne=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,1); 
	MASixty=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,1); 
 
	MAFivePre=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,2); 
	MAThentyOnePre=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,2); 
	MASixtyPre=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,2); 
 



	//定义上升下降加速指标
 
 	StrongWeak =0.5;
 

	if(((MAThree-MAThreePre) > (MAThen-MAThenPre))&&((MAThenPre-MAThenPrePre)<(MAThen-MAThenPre)))
	{		
		StrongWeak =0.9;	
	}
	if(((MAThree-MAThreePre) < (MAThen-MAThenPre))&&((MAThenPre-MAThenPrePre)>(MAThen-MAThenPre)))
	{
		StrongWeak =0.1;
	
	}
	else
	{
		StrongWeak =0.5;

	}

	//MoreTrend用来定义加速上涨或者加速下跌 
	BoolCrossRecord[SymPos][timeperiodnum].MoreTrend = StrongWeak;


	//定义上升下降指标
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

	//Trend用来定义上涨，或者下跌趋势，非加速上涨或者加速下跌 
	BoolCrossRecord[SymPos][timeperiodnum].Trend = StrongWeak;

 
 	//定义多空状态指标
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



// 定义穿越bool点标准差为2时的值、位置、强弱值，并且保留前一个穿越位置的值
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


// 定义穿越bool点标准差为1.7时的值、位置、强弱值，并且保留前一个穿越位置的值
void ChangeCrossValueL( int mvalue,double  mstrongweak,int SymPos,int timeperiodnum)
{

	int i;
	int my_timeperiod;
	string symbol;
    symbol = MySymbol[SymPos];
	my_timeperiod = timeperiod[timeperiodnum];

		
	if (mvalue == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
	{
		BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[0] = mvalue;
	//	BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
		BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPosL[0] = iBars(symbol,my_timeperiod);	
		
		BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeakL[0] = mstrongweak;		
	
		
		return;
	}
	for (i = 0 ; i <(HCROSSNUMBER-1); i++)
	{
		BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[(HCROSSNUMBER-2)-i];
	//	BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[(HCROSSNUMBER-2)-i];
		BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPosL[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPosL[(HCROSSNUMBER-2)-i] ;		
		BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeakL[(HCROSSNUMBER-1)-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeakL[(HCROSSNUMBER-2)-i];
	}
	
	BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[0] = mvalue;
	//BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
	BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPosL[0] = iBars(symbol,my_timeperiod);
	
	BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeakL[0] = mstrongweak;

	return;
}



/*非Openday期间不新开单*/
// 考虑了周六和周日的特俗情况，约束不大
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
/*因为三倍佣金的问题，周三的交易策略比较保守*/
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

	if (TimeDayOfWeek(timelocal) == 3)
	{	
		/*周三为了规避三倍佣金问题，因此20点以后不交易*/
		if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <20 )) 
		{
			tradetimeflag = true;		
		}	
	}
	else
	{
		if ((TimeHour(timelocal) >= 13 )&& (TimeHour(timelocal) <22 )) 
		{
			tradetimeflag = true;		
		}			
		
	}
	/*测试期间全时间段交易*/
	tradetimeflag = true;		
	
	return tradetimeflag;
	
}



// exness外汇商显示的杠杆跟实际杠杆比是1:2，因此需要修正
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

/*仓位检测，确保账户总余额可以交易4次以上*/
// 正常交易的全局交易开关关闭的情况下不交易
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
		/*现有杠杆之下至少还能交易四次*/
		if((AccountFreeMargin()* leverage)<( 4*MyLotsH*100000))
		{
			Print("Account Money is not enough free margin = ",AccountFreeMargin() +";Leverage = "+leverage);		
			accountflag = false;
		}		
		
	}

	/*全局交易开关关闭的情况下不交易*/
	if(false == getglobaltradeflag())
	{
		//accountflag = false;
	}

	return accountflag;	
	
}


// 正常交易有效magicnumber，判断因素包括有效外汇、有效时间周一-周五、正常交易买卖点1-10
// 后面改进方式为将出现快速大幅变化的产生大幅盈利的交易排除在该交易点之外，处理起来比较复杂；也就是池塘捞到的大鱼要持续持有。
// 其中一个做法是如果当前大幅止损价格已经盈利，或者已经设置了大幅止损价格盈利的止损点。
bool isvalidmagicnumber(int magicnumber)
{
		
	bool flag = true;
	int SymPos,NowMagicNumber;
	
	SymPos = ((int)magicnumber) /1000;
	NowMagicNumber = magicnumber - SymPos *1000;

	if((SymPos<0)||(SymPos>=symbolNum))
	{
	 	flag = false;
	}	
	
	//周一到周五的单子
	if(6<=(NowMagicNumber%10))
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

// 所有正常交易单的盈亏情况，要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续改进
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


// 所有盈利的正常交易单的总盈利情况，要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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

// 所有正常交易单的盈利单的数量，要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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


// 正常交易单的总数量，要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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

// 正常交易单的特定盈利myprofit以上盈利单总数量，要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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

// 正常交易单盈利myprofit以上的单子，关闭掉；要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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


// 正常交易单全部关闭掉；要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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


// 正常交易单全部关闭掉；要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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


// 正常交易出现大幅盈利的情况下平掉所有交易，要去除止损点设置为盈利的单，这些单子已经转为手工单了，后续待改进
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
	if(ordercountall()<=8)
	{
		return;
	}

	/*短线获利清盘，长线后面再考虑*/
	//if(1 == Period())
	{
	
		if((ordercountall()>=(symbolNum/2))&&(ordercountall() == profitordercountall(0)))
		{
			Print("1 This turn Own more than "+(symbolNum/2)+" orders witch is "+ordercountall()+" all profit order,Close all");				
			turnoffflag = true;						
		}
		mylots0 = MyLotsH*6;
		mylots = MyLotsH*4;


		/*所有单的盈利总和超过500美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(orderprofitall() > 5000*mylots0)
		{				
			turnoffflag = true;			
			Print("2 This turn Own more than "+2500*mylots0+" USD,Close all");
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
		
		
	}	
	
	
	
	/*本币关闭时，直接关闭对冲币，损失手续费*/
	if(turnoffflag == true)
	{			
		int j=0;
		int k = 0;
				
		
		
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
						
	}
	
}


// 主程序初始化
int init()
{

	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int symbolvalue;

	string MailTitlle ="";

	symbolvalue = 0;

	// 判断链接的外汇服务器是否正确
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
	
	// 初始化外汇集合
	initsymbol();  
	// 打开外汇集合
	openallsymbo();
	
	//初始化交易手数
	initglobalamount();

	// 初始化magicnumber
	initmagicnumber();
	
	// 初始化时间周期
	inittiimeperiod();
	
	
	/*初始化正常交易全局交易指标，交易时间段使能，非交易时间段禁止*/
	initglobaltradeflag();	

	
	// 初始化买卖点的位置，当前未起作用
	InitBuySellPos();
	
	// 防止错误导致的重复交易
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

			// 初始化外汇集、周期集下的穿越bool集合
			InitcrossValue(SymPos,timeperiodnum);
			// 初始化当前外汇、周期下的短期强弱trend和多头强弱
			InitMA(SymPos,timeperiodnum);


			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);			

			Print(my_symbol+"BoolCrossRecordL["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlagL[9]);		
			
		}
	
	}
 
	// 打印账户信息情况
	Print("Server name is ", AccountServer());	  
	Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
	Print("Account Balance= ",AccountBalance());		
	Print("Account free margin = ",AccountFreeMargin());	  
	Print("!Truely Amount is = "+MyLotsH+":"+MyLotsL);	 		               
	return 0;
  
}


// 主程序退出
int deinit()
{

	return 0;
}



int ChartEvent = 0;
bool PrintFlag = false;



// 每个时间周期调用一次，计算当前周期强弱等相关值，寻找bool穿越点，并记录当时的值
void calculateindicator()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;

	double ma;
	double boll_up_B,boll_low_B,boll_mid_B,bool_length;
	
	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAThreePre,MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double MAThreePrePre,MAThenPrePre;	
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


				////////////////////////////////////////////////////////////////////////////
				
				ma=iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,1); 
				// ma = Close[0];  
				boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_UPPER,1);   
				boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_LOWER,1);
				boll_mid_B = (boll_up_B + boll_low_B )/2;
				/*point*/
				//bool_length =(boll_up_B - boll_low_B )/2;
	
				ma_pre = iMA(my_symbol,my_timeperiod,Move_Av,0,MODE_SMA,PRICE_CLOSE,2); 
				boll_up_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_UPPER,2);      
				boll_low_B_pre = iBands(my_symbol,my_timeperiod,iBoll_B,1.7,0,PRICE_CLOSE,MODE_LOWER,2);
				boll_mid_B_pre = (boll_up_B_pre + boll_low_B_pre )/2;
	
				crossflag = 0;
							
				StrongWeak = BoolCrossRecord[SymPos][timeperiodnum].StrongWeak;
				
				/*本周期突破高点，观察如小周期未衰竭可追高买入，或者等待回调买入*/
				/*原则上突破bool线属于偏离价值方向太大，是要回归价值中枢的*/
				if((ma >boll_up_B) && (ma_pre < boll_up_B_pre ) )
				{
				
					crossflag = 5;		
					ChangeCrossValueL(crossflag,StrongWeak,SymPos,timeperiodnum);
					//  Print(mMailTitlle + Symbol()+"::本周期突破高点，除(1M、5M周期bool口收窄且快速突破追高，移动止损），其他情况择机反向做空:"
					//  + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
	
				}
				
				/*本周期突破高点后回调，观察如小周期长时间筑顶，寻机卖出*/
				else if((ma <boll_up_B) && (ma_pre > boll_up_B_pre ) )
				{
					crossflag = 4;
					ChangeCrossValueL(crossflag,StrongWeak,SymPos,timeperiodnum);
					//   Print(mMailTitlle + Symbol()+"::本周期突破高点后回调，观察小周期如长时间筑顶，寻机做空:"
					//   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
	
		   
				}
					
				
				/*本周期突破低点，观察如小周期未衰竭可追低卖出，或者等待回调卖出*/
				else if((ma < boll_low_B) && (ma_pre > boll_low_B_pre ) )
				{
				
					
					crossflag = -5;
					ChangeCrossValueL(crossflag,StrongWeak,SymPos,timeperiodnum);
					//   Print(mMailTitlle + Symbol() + "::本周期突破低点，除(条件：1M、5M周期bool口收窄且快速突破追低，移动止损），其他情况择机反向做多:"
					//   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
		   
				}
					
				/*本周期突破低点后回调，观察如长时间筑底，寻机买入*/
				else if((ma > boll_low_B) && (ma_pre < boll_low_B_pre ) )
				{
					crossflag = -4;	
					ChangeCrossValueL(crossflag,StrongWeak,SymPos,timeperiodnum);
					//   Print(mMailTitlle + Symbol() + "::本周期突破低点后回调，观察如小周期长时间筑底，寻机买入:"
					//   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
	
				}
			
				/*本周期上穿中线，表明本周期趋势开始发生变化为上升，在下降大趋势下也可能是回调杀入机会*/
				else if((ma > boll_mid_B) && (ma_pre < boll_mid_B_pre ))
				{
				
					crossflag = 1;				
					ChangeCrossValueL(crossflag,StrongWeak,SymPos,timeperiodnum);			
					//    Print(mMailTitlle + Symbol() + "::本周期上穿中线变化为上升，大周期下降大趋势下可能是回调做空机会："
					//    + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
	   
				}	
				/*本周期下穿中线，表明趋势开始发生变化，在上升大趋势下也可能是回调杀入机会*/
				else if( (ma < boll_mid_B) && (ma_pre > boll_mid_B_pre ))
				{
					crossflag = -1;								
					ChangeCrossValueL(crossflag,StrongWeak,SymPos,timeperiodnum);			
					 //     Print(mMailTitlle + Symbol() + "::本周期下穿中线变化为下降，大周期上升大趋势下可能是回调做多机会："
					 //     + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
	
				}							
				else
				{
					 crossflag = 0;   
	       
				}
	
				BoolCrossRecord[SymPos][timeperiodnum].BoolFlagL = BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0];
				BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChangeL = crossflag;
				
				
				
				
				//////////////////////////////////////////////////////////////////////////////


				
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

				MAThreePre = iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,2); 
				MAThenPre=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,2); 

				MAThreePrePre = iMA(my_symbol,my_timeperiod,3,0,MODE_SMA,PRICE_CLOSE,3); 
				MAThenPrePre=iMA(my_symbol,my_timeperiod,10,0,MODE_SMA,PRICE_CLOSE,3); 
		 
					
				MAFive=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,1); 
				MAThentyOne=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,1); 
				MASixty=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,1); 
			 
				MAFivePre=iMA(my_symbol,my_timeperiod,5,0,MODE_SMA,PRICE_CLOSE,2); 
				MAThentyOnePre=iMA(my_symbol,my_timeperiod,21,0,MODE_SMA,PRICE_CLOSE,2); 
				MASixtyPre=iMA(my_symbol,my_timeperiod,60,0,MODE_SMA,PRICE_CLOSE,2); 
				 

				//定义上升下降加速指标
			 
			 	StrongWeak =0.5;
			 

				if(((MAThree-MAThreePre) > (MAThen-MAThenPre))&&((MAThenPre-MAThenPrePre)<(MAThen-MAThenPre)))
				{		
					StrongWeak =0.9;	
				}
				if(((MAThree-MAThreePre) < (MAThen-MAThenPre))&&((MAThenPre-MAThenPrePre)>(MAThen-MAThenPre)))
				{
					StrongWeak =0.1;
				
				}
				else
				{
					StrongWeak =0.5;

				}

				//MoreTrend用来定义加速上涨或者加速下跌 
				BoolCrossRecord[SymPos][timeperiodnum].MoreTrend = StrongWeak;

	
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
	datetime timelocal,timeexp;	
	int subvalue;
	double bool_length_upperiod;
	
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
	
	boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
	bool_length_upperiod = (boll_up_B - boll_low_B )/2;
	
	boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
	boll_mid_B = (boll_up_B + boll_low_B )/2;
	/*point*/
	bool_length =(boll_up_B - boll_low_B )/2;	
	

	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭
	/*4H、1D正平衡上涨，三十分钟多头排列强势，*/	



	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.55)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.55)
		&& (0 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	

		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)	

		&&((-4 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(1 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(5 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlag[0])
			)
		&&((-4 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(1 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(5 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlag[0])
			)				
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true))
		)
	{
		

		/*五分钟超级弱势，抓顶摸底，挂单小止损*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])				
			&& (-0.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			&& (0> BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])	
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)				
			)			
					
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = (vask+MinValue3)/2;				 			
			orderStopless =MinValue3 - bool_length*8; 		
			orderTakeProfit	= vask + bool_length_upperiod*8;
			
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

			//挂单4个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*4;
			
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
						
			if(true == accountcheck())
			{			
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					//orderPrice = vask;					
						
					ticket = OrderSend(my_symbol,OP_BUYLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberOne"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberOne),timeexp,Blue);
		
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

		
		/*五分钟弱势，确保1分钟已经调整了一段时间；一分钟bool背驰，利用空头陷阱挂单*/

		if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-1 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])				
			//&& (-0.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			//&& (0> BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])	
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)				
			)			
					
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);

			orderPrice = MinValue3;				 			
			orderStopless =MinValue3 - bool_length*8; 		
			orderTakeProfit	= vask + bool_length_upperiod*8;
			
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

			//挂单4个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*4;
			
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
						
			if(true == accountcheck())
			{			
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					//orderPrice = vask;					
						
					ticket = OrderSend(my_symbol,OP_BUYLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberThree"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberThree),timeexp,Blue);
		
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
						Print("OrderSend MagicNumberThree"+IntegerToString(subvalue)+"  successfully");
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

	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.45)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.45)
	
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)

		&&((4 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(-1 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(-5 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlag[0])
			)		

		&&((4 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(-1 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(-5 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlag[0])
			)	

		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)		
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)))
	{

		/*五分钟超级强势，抓顶摸底，挂单小止损*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])				
			&& (0.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			&& (0< BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])	
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)				
			)
		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}						

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = (vbid+MaxValue4)/2;		

			orderStopless =MaxValue4 + bool_length*8; 		
			orderTakeProfit	= vbid - bool_length_upperiod*8;			

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
			//挂单4个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*4;
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
			
			if(true == accountcheck())
			{		
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);	
					//orderPrice = vbid;		
															
			 
					 ticket = OrderSend(my_symbol,OP_SELLLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "MagicNumberTwo"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberTwo),timeexp,Blue);
			
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

		
		/*五分钟强势，确保1分钟已经调整了一段时间；一分钟bool背驰，利用多头陷阱挂单*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (1 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])				
			//&& (0.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			//&& (0< BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])	
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)				
			)
		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = MaxValue4;						 

			orderStopless =MaxValue4 + bool_length*8; 		
			orderTakeProfit	= vbid - bool_length_upperiod*8;			

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
			//挂单4个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*4;
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
											
					
			Print(my_symbol+" MagicNumberFour"+IntegerToString(subvalue)+"  OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{		
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vbid    = MarketInfo(my_symbol,MODE_BID);	
					//orderPrice = vbid;		
															
			 
					 ticket = OrderSend(my_symbol,OP_SELLLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   "MagicNumberFour"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberFour),timeexp,Blue);
			
					 if(ticket <0)
					 {
					 	ttick++;
						Print("OrderSend MagicNumberFour"+IntegerToString(subvalue)+"  failed with error #",GetLastError());
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
						Print("OrderSend MagicNumberFour"+IntegerToString(subvalue)+"   successfully");
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

// 寻找5分钟级别的买卖点，由高级别的某方向变强或者变强加速来缓解可能的买卖出错！
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
	datetime timelocal,timeexp;	
	int subvalue;
	double bool_length_upperiod;
			
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

	boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
	bool_length_upperiod = (boll_up_B - boll_low_B )/2;

	boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
	boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
	boll_mid_B = (boll_up_B + boll_low_B )/2;
	/*point*/
	bool_length =(boll_up_B - boll_low_B )/2;	
	
	
	

	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭




	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.55)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.55)
		&& (0 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	

		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)	
		&&((-4 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(1 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(5 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlag[0])
			)		

		&&((-4 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(1 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(5 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlag[0])
			)	

		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) == true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)))
	{


		/*30M超级弱势，抓顶摸底，挂单小止损*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])				
			&& (-0.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			&& (0> BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])	
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)			
			)	
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = (vask+MinValue3)/2;	

			orderStopless =MinValue3 - bool_length*4; 		
			orderTakeProfit	= vask + bool_length_upperiod*8;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			//挂单24个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*24;			

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
			
			if(true == accountcheck())
			{
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					//orderPrice = vask;						
				
					ticket = OrderSend(my_symbol,OP_BUYLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberFive"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberFive),timeexp,Blue);
		
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
			


		/*30M弱势，确保5分钟已经调整了一段时间；五分钟bool背驰，利用空头陷阱挂单*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-1 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])			
			//&& (-0.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			//&& (0> BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])	
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)			
			)	
		{
			
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
				{
					MinValue3 = iLow(my_symbol,my_timeperiod,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = MinValue3;				 

			orderStopless =MinValue3 - bool_length*4; 		
			orderTakeProfit	= vask + bool_length_upperiod*8;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			//挂单24个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*24;			

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
			
			if(true == accountcheck())
			{
				ttick = 0;
				ticket = -1;
				while((ticket<0)&&(ttick<20))
				{
					vask    = MarketInfo(my_symbol,MODE_ASK);	
					//orderPrice = vask;						
				
					ticket = OrderSend(my_symbol,OP_BUYLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   "MagicNumberSeven"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberSeven),timeexp,Blue);
		
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
					 	ttick =100;        
						TwentyS_Freq++;
						OneM_Freq++;
						ThirtyS_Freq++;
						FiveM_Freq++;
						ThirtyM_Freq++;	
						BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(my_symbol,my_timeperiod)+20;					 
						BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);			 				 
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

	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.45)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.45)
		
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)	
		&&((4 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(-1 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlagL[0])
			||(-5 == BoolCrossRecord[SymPos][timeperiodnum+3].CrossFlag[0])
			)
		&&((4 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(-1 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlagL[0])
			||(-5 == BoolCrossRecord[SymPos][timeperiodnum+4].CrossFlag[0])
			)
		

		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) == true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)))
	{
		
		
		/*30M超级强势，抓顶摸底，小止损*/		
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])				
			&& (0.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			&& (0< BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])												

			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)				
			)

		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = (vbid+MaxValue4)/2;						 
			
			orderStopless =MaxValue4 + bool_length*4; 		
			orderTakeProfit	= vbid - bool_length_upperiod*8;	
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			//挂单24个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*24;		
											
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
			 
			 if(true == accountcheck())
			 {
					ttick = 0;
					ticket = -1;
					while((ticket<0)&&(ttick<20))
					{
						vbid    = MarketInfo(my_symbol,MODE_BID);	
						//orderPrice = vbid;					
															 
						 ticket = OrderSend(my_symbol,OP_SELLLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
										   "MagicNumberSix"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberSix),timeexp,Blue);
				
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

		/*30M强势，确保五分钟已经调整了一段时间；五分钟bool背驰，多头陷阱*/		
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChangeL)				
			&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (1 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])				
			&& (0.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex)														
			&& (0< BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])												

			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)				
			)

		{
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[5]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
				{
					MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = MaxValue4;						 
			
			orderStopless =MaxValue4 + bool_length*4; 		
			orderTakeProfit	= vbid - bool_length_upperiod*8;	
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			//挂单24个小时，尽量成交
			timeexp = TimeCurrent() + 60*60*24;		
											
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
					
			Print(my_symbol+" MagicNumberEight"+IntegerToString(subvalue)+" OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
					ttick = 0;
					ticket = -1;
					while((ticket<0)&&(ttick<20))
					{
						vbid    = MarketInfo(my_symbol,MODE_BID);	
						//orderPrice = vbid;					
										
					 
						 ticket = OrderSend(my_symbol,OP_SELLLIMIT,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
										   "MagicNumberEight"+IntegerToString(subvalue)+my_symbol,MakeMagic(SymPos,MagicNumberEight),timeexp,Blue);
				
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


	
// 每秒调用一次，反复执行的主体函数
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
	


	/*自动调整交易手数，即下午1-2点之间每隔5分钟检查一次设计*/
	autoadjustglobalamount();
	


	/*在交易时间段来临前确保使能全局交易标记，即下午1-2点之间每隔5分钟检查一次设计*/
	enableglobaltradeflag();
	
	/*每周三的深夜晚上强行清盘*/
	/*原因是周三晚上要收三天的隔夜费用，对于短线操作来说不可接受*/
	//all_forcecloseall();	
	
	
	
	
	/*所有货币对所有周期指标计算*/	
	calculateindicator();
      
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{	
		
		
		/*特定货币一分钟寻找买卖点*/
		orderbuyselltypeone(SymPos);		
				
		/*特定货币五分钟寻找买卖点*/		
		orderbuyselltypetwo(SymPos);		

	}
   

  
   ////////////////////////////////////////////////////////////////////////////////////////////////
   //订单管理优化，包括移动止损、直接止损、订单时间管理
   //暂时还没有想清楚该如何移动止损优化  
   ////////////////////////////////////////////////////////////////////////////////////////////////

   /*短线获利清盘针对一分钟盘面*/
   monitoraccountprofit();

   checkbuysellorder();

	/////////////////////////////////////////////////
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



////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
void checkbuysellorder()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int NowMagicNumber,magicnumber;
	int subvalue;		
	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;

	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	double boll_up_B,boll_low_B,bool_length;		
	int i,ticket;
 
	int    vdigits ;
	int res;
	
	timeperiodnum = 0;	

	orderStopLevel=0;
	orderLots = 0;   
	orderStopless = 0;
	orderTakeProfit = 0;
	orderPrice = 0;
	my_timeperiod = timeperiod[timeperiodnum];	
	
	for (i = 0; i < OrdersTotal(); i++)
	{
   if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   {
   	
			magicnumber = OrderMagicNumber();
			SymPos = ((int)magicnumber) /1000;
			NowMagicNumber = magicnumber - SymPos *1000;
		
			if((SymPos<0)||(SymPos>=symbolNum))
			{
				Print("SymPos error 0");
				return;
			}

			my_symbol = MySymbol[SymPos];

			subvalue = (NowMagicNumber%10);  
			
			if(subvalue>5)
			{
				Print("subvalue error 0");
			}	
			
			NowMagicNumber = ((int)NowMagicNumber) /10;
			if((NowMagicNumber<=0)||(NowMagicNumber>=11))
			{
				Print("NowMagicNumber error 0");
			}			   	

			//确保寻找买卖点是每个一分钟周期计算一次，而不是每个tick计算一次
			if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum]))
			{
 				
				vbid    = MarketInfo(my_symbol,MODE_BID);		
				vask    = MarketInfo(my_symbol,MODE_ASK);												
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS); 	
	 
				if((NowMagicNumber == MagicNumberOne)&&(OrderType()==OP_BUY))
				{
					


					//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((5 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
						&&(5==BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vask;				 
						orderStopless = vask - bool_length*4;

						//不亏损的情况下，以小博大
						if(orderStopless>OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless>OrderStopLoss())
						{


							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberOne Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberOne OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberOne  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);		


						}						

						
					}



				 //强力突破前高后平仓，防止乐极生悲
				 if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
				 	&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))					 	
				 	)
					{

						MaxValue4 = -1;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[8]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,timeperiod[timeperiodnum+2],i))
							{
								MaxValue4 = iHigh(my_symbol,timeperiod[timeperiodnum+2],i);
							}					
						}		
						if(vask > MaxValue4)	
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);						
							if(ticket <0)
							{
								Print("OrderClose MagicNumberOne  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberOne   with up the high successfully");
							}    
							Sleep(1000);  	

						}	
		
					}


				}
				
				if((NowMagicNumber == MagicNumberTwo)&&(OrderType()==OP_SELL))
				{


					//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((-5 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
						&&(-5==BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vbid;				 
						orderStopless = vbid + bool_length*4;
						
						//不亏损的情况下，以小博大
						if(orderStopless<OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless<OrderStopLoss())
						{
							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberTwo Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberTwo OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberTwo  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);


						}						

		

						
					}



				 //强力突破前低后平仓，防止乐极生悲
				 if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
				 	&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))	
				 	)			 	
					{

						MinValue3 = 100000;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[8]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,timeperiod[timeperiodnum+2],i))
							{
								MinValue3 = iLow(my_symbol,timeperiod[timeperiodnum+2],i);
							}					
						}	

						if(vbid<MinValue3)
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							
							if(ticket <0)
							{
								Print("OrderClose MagicNumberTwo  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberTwo   successfully");
							}    
							Sleep(1000);  	

						}
  
					}
							
							
				   						   			   
				   
				}
				if((NowMagicNumber == MagicNumberThree)&&(OrderType()==OP_BUY))
				{
					
					//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((5 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
						&&(5==BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vask;				 
						orderStopless = vask - bool_length*4;
						
						//不亏损的情况下，以小博大
						if(orderStopless>OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless>OrderStopLoss())
						{
							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberThree Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberThree OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberThree  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);	


						}
	

						
					}



				 //强力突破前高后平仓，防止乐极生悲
				 if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
				 	&& (4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))					 	
				 	)
					{

						MaxValue4 = -1;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[8]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,timeperiod[timeperiodnum+2],i))
							{
								MaxValue4 = iHigh(my_symbol,timeperiod[timeperiodnum+2],i);
							}					
						}		
						if(vask > MaxValue4)	
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);						
							if(ticket <0)
							{
								Print("OrderClose MagicNumberThree  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberThree   with up the high successfully");
							}    
							Sleep(1000);  	

						}	
		
					}

			
				}
				
				if((NowMagicNumber == MagicNumberFour)&&(OrderType()==OP_SELL))
				{
				

					//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((-5 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
						&&(-5==BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+1],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vbid;				 
						orderStopless = vbid + bool_length*4;
						
						//不亏损的情况下，以小博大
						if(orderStopless<OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless<OrderStopLoss())
						{

							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberFour Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberFour OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberFour  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);	

							}
	

						
					}



				 //强力突破前低后平仓，防止乐极生悲
				 if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
				 	&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))	
				 	)			 	
					{

						MinValue3 = 100000;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+2]) -BoolCrossRecord[SymPos][timeperiodnum+2].CrossBoolPos[8]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,timeperiod[timeperiodnum+2],i))
							{
								MinValue3 = iLow(my_symbol,timeperiod[timeperiodnum+2],i);
							}					
						}	

						if(vbid<MinValue3)
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							
							if(ticket <0)
							{
								Print("OrderClose MagicNumberFour  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberFour   successfully");
							}    
							Sleep(1000);  	

						}
  
					}
							
													
				   						   			   
				   
				}


				if((NowMagicNumber == MagicNumberFive)&&(OrderType()==OP_BUY))
				{
					
					//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((5 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
						&&(5==BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vask;				 
						orderStopless = vask - bool_length*4;

						//不亏损的情况下，以小博大
						if(orderStopless>OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless>OrderStopLoss())
						{




							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberFive Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberFive OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberFive  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);		


						}						

						
					}



				 //强力突破前高后平仓，防止乐极生悲
				 if((4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
				 	&& (4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))					 	
				 	)
					{

						MaxValue4 = -1;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[8]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,timeperiod[timeperiodnum+3],i))
							{
								MaxValue4 = iHigh(my_symbol,timeperiod[timeperiodnum+3],i);
							}					
						}		
						if(vask > MaxValue4)	
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);						
							if(ticket <0)
							{
								Print("OrderClose MagicNumberFive  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberFive   with up the high successfully");
							}    
							Sleep(1000);  	

						}	
		
					}
			
					 
			
				}
				
				if((NowMagicNumber == MagicNumberSix)&&(OrderType()==OP_SELL))
				{				

					//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((-5 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
						&&(-5==BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vbid;				 
						orderStopless = vbid + bool_length*4;
						
						//不亏损的情况下，以小博大
						if(orderStopless<OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless<OrderStopLoss())
						{

							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberSix Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberSix OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberSix  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);	

							}
	

						
					}



				 //强力突破前低后平仓，防止乐极生悲
				 if((-4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
				 	&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))	
				 	)			 	
					{

						MinValue3 = 100000;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[8]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,timeperiod[timeperiodnum+3],i))
							{
								MinValue3 = iLow(my_symbol,timeperiod[timeperiodnum+3],i);
							}					
						}	

						if(vbid<MinValue3)
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							
							if(ticket <0)
							{
								Print("OrderClose MagicNumberSix  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberSix   successfully");
							}    
							Sleep(1000);  	

						}
  
					}
							
													
							
				   						   			   				   
				}
					
				if((NowMagicNumber == MagicNumberSeven)&&(OrderType()==OP_BUY))
				{
					
					//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((5 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
						&&(5==BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vask;				 
						orderStopless = vask - bool_length*4;
						//不亏损的情况下，以小博大
						if(orderStopless>OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless>OrderStopLoss())
						{



							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberSeven Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberSeven OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberSeven  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);		


						}						

						
					}



				 //强力突破前高后平仓，防止乐极生悲
				 if((4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
				 	&& (4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))					 	
				 	)
					{

						MaxValue4 = -1;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[8]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,timeperiod[timeperiodnum+3],i))
							{
								MaxValue4 = iHigh(my_symbol,timeperiod[timeperiodnum+3],i);
							}					
						}		
						if(vask > MaxValue4)	
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);						
							if(ticket <0)
							{
								Print("OrderClose MagicNumberSeven  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberSeven   with up the high successfully");
							}    
							Sleep(1000);  	

						}	
		
					}
			
			
				}
				
				if((NowMagicNumber == MagicNumberEight)&&(OrderType()==OP_SELL))
				{				


					//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。						
					if((-5 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
						&&(-5==BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag)
						&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))			
							)		
					{

						boll_up_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(my_symbol,timeperiod[timeperiodnum+2],iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						bool_length = (boll_up_B - boll_low_B )/2;			

						orderPrice = vbid;				 
						orderStopless = vbid + bool_length*4;
						
						//不亏损的情况下，以小博大
						if(orderStopless<OrderOpenPrice())
						{
							orderStopless = OrderOpenPrice();
						}
						
						orderTakeProfit	= 	OrderTakeProfit();
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

						//不扩大亏损额度
						if(orderStopless<OrderStopLoss())
						{

							//orderTakeProfit = 0;
							Print(my_symbol+" MagicNumberEight Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+OrderOpenPrice()+"orderStopless="+orderStopless);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,OrderTakeProfit(),0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberEight OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberEight  successfully "+OrderMagicNumber());
							 }								
							Sleep(1000);	

							}
	

						
					}



				 //强力突破前低后平仓，防止乐极生悲
				 if((-4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlagChange)
				 	&& (-4 == BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])
					&&( BoolCrossRecord[SymPos][timeperiodnum+2].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+2]))	
				 	)			 	
					{

						MinValue3 = 100000;
						for (i= (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[1]);
							  i < (iBars(my_symbol,timeperiod[timeperiodnum+3]) -BoolCrossRecord[SymPos][timeperiodnum+3].CrossBoolPos[8]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,timeperiod[timeperiodnum+3],i))
							{
								MinValue3 = iLow(my_symbol,timeperiod[timeperiodnum+3],i);
							}					
						}	

						if(vbid<MinValue3)
						{
							ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							
							if(ticket <0)
							{
								Print("OrderClose MagicNumberEight  failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberEight   successfully");
							}    
							Sleep(1000);  	

						}
  
					}
							
					
 
				}					
			
			}		
		
		}				
	}

}
	


	
/////////////////////
