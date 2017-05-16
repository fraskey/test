//+------------------------------------------------------------------+
//|                                       MutiPeriodAutoTradePro.mq4 |
//|                   Copyright 2005-2016, Copyright. Personal Keep  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2017, Xuejiayong."
#property link        "http://www.mql14.com"


//通用宏定义
//////////////////////////////////////////

#define HCROSSNUMBER  100



//////////////////////////////////////////
//结束通用宏定义


//外汇商专用宏定义
//////////////////////////////////////////
/*程序运行时，选择外汇服务商*/
#define HXM




/*定义外汇服务商XM的宏特性*/
#ifdef HXM

	#define HTIMEZONEXMDIFF 5
	#define HTIMEZONEDIFF HTIMEZONEXMDIFF
#endif 	

/*定义外汇服务商OANDA的宏特性*/	
#ifdef  HOANDA

	/*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/
	/*OANDA 服务器时间为GMT + 3 ，北京时间为GMT + 8，相差3个小时*/
	#define HTIMEZONEOANDADIFF 5
	#define HTIMEZONEDIFF HTIMEZONEOANDADIFF

#endif 


//结束外汇商专用宏定义
//////////////////////////////////////////





//全局变量定义
//////////////////////////////////////////
//input double TakeProfit    =50;
double MyLotsH          =0.01;
double MyLotsL          =0.01; 
//input double TrailingStop  =30;

int Move_Av = 2;
int iBoll_B = 60;
//input int iBoll_S = 20;


int timeperiod[16];
int TimePeriodNum = 6;



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
int MagicNumberEleven = 110;
int MagicNumberTwelve = 120;



int MagicNumberThirteen = 130;
int MagicNumberFourteen = 140;
int MagicNumberFifteen = 150;
int MagicNumberSixteen = 160;




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



//结束结构体定义
//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////



void initsymbol()
{
#ifdef  HOANDA

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
#endif

#ifdef HXM
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
#endif	
	
	
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
 
   
   symbolvalue = SymPos*1000 + Magic;
   return symbolvalue;
}



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
	MagicNumberEleven = 110;
	MagicNumberTwelve = 120;
	MagicNumberThirteen = 130;
	MagicNumberFourteen = 140;
	MagicNumberFifteen = 150;
	MagicNumberSixteen = 160;	
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
		Print(my_symbol + ":"+my_timeperiod+":Bar Number less than "+countnumber);
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

		
    timelocal = TimeCurrent() + HTIMEZONEDIFF*60*60;


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
    timelocal = TimeCurrent() + HTIMEZONEDIFF*60*60;


	//上午午9点前不做趋势单，主要针对1分钟线和五分钟线，非欧美时间趋势不明显，针对趋势突破单，要用这个来检测
	//最原始的是下午4点前不做趋势单，通过扩大止损来寻找更多机会
	
	if ((TimeHour(timelocal) >= 9 )&& (TimeHour(timelocal) <21 )) 
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
    loctime = TimeCurrent() + HTIMEZONEDIFF*60*60;
	
	
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



/*仓位检测，确保总额可以交易2次以上*/
bool accountcheck()
{
	bool accountflag ;
	int leverage ;
	accountflag = true;
	leverage = AccountLeverage();
	if(leverage < 10)
	{
		Print("Account leverage is to low leverage = ",leverage);		
		accountflag = false;		
	}
	else
	{
		
		/*现有杠杆之下至少还能交易两次*/
		if((AccountFreeMargin()* leverage)<( 2*MyLotsH*100000))
		{
			Print("Account Money is not enough free margin = ",AccountFreeMargin() +";Leverage = "+leverage);		
			accountflag = false;
		}		
		
	}

	return accountflag;
	
	
}


double orderprofitall()
{
	double profit = 0;
	int i;
	for (i = 0; i < OrdersTotal(); i++)
	{
		if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
		{
			profit = profit + OrderProfit();
			
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
			if(OrderProfit()>0)
			{			
				profit = profit + OrderProfit();
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
			if(OrderProfit()>myprofit)
			{
				count++;
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
			//if(OrderProfit()>myprofit)
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
			if(OrderProfit()>myprofit)
			{
				count++;
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

			SymPos = ((int)OrderMagicNumber()) /1000;
			NowMagicNumber = OrderMagicNumber() - SymPos *1000;

			if((SymPos<0)||(SymPos>=symbolNum))
			{
			 Print(" ordercloseall SymPos error 0");
			}
				
			my_symbol = MySymbol[SymPos];
			
			vbid    = MarketInfo(my_symbol,MODE_BID);						  
			vask    = MarketInfo(my_symbol,MODE_ASK);	
			
			if((OrderType()==OP_BUY)&&(OrderProfit()>myprofit))
			{
				ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
				  
				if(ticket <0)
				{
					Print("OrderClose buy ordercloseall  failed with error #",GetLastError());
				}
				else
				{            
					Print("OrderClose buy ordercloseall   successfully");
				}    	
				Sleep(1000); 

			}
			

			if((OrderType()==OP_SELL)&&(OrderProfit()>myprofit))
			{
				ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
				  
				 if(ticket <0)
				 {
					Print("OrderClose sell ordercloseall  failed with error #",GetLastError());
				 }
				 else
				 {            
					Print("OrderClose sell ordercloseall   successfully");
				 }    		
				Sleep(1000); 
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
					Print("OrderClose buy ordercloseall  failed with error #",GetLastError());
				 }
				 else
				 {            
					Print("OrderClose buy ordercloseall   successfully");
				 }    	
				Sleep(1000); 
		
			}
			

			if(OrderType()==OP_SELL)
			{
				ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
				  
				 if(ticket <0)
				 {
					Print("OrderClose sell ordercloseall  failed with error #",GetLastError());
				 }
				 else
				 {            
					Print("OrderClose sell ordercloseall   successfully");
				 }  
				Sleep(1000);				 
		
			}
			

			
		}
	}
	
	return;
}



void monitoraccountprofit()
{

	/*短线获利清盘，长线后面再考虑*/
	//if(1 == Period())
	{
		
		
		/*超过5个订单，且每个订单都盈利的情况下，直接关掉所有盈利订单*/
		/*
		if((ordercountall()>5)&&(ordercountall() == profitordercountall(0)))
		{
			ordercloseallwithprofit(0);
			Print("1、This turn Own more than "+ordercountall()+" all profit order,Close all");			
			
		}
			*/
		
		
		/*盈利单的盈利总和超过500美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(profitorderprofitall() > 5000*MyLotsH)
		{			
			ordercloseallwithprofit(0);
			Print("2、This turn Own more than "+5000*MyLotsH+" USD,Close all");
		}
			
		/*所有单的盈利总和超过250美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(orderprofitall() > 2500*MyLotsH)
		{
			
			ordercloseallwithprofit(100*MyLotsH);
			Print("3、This turn Own more than "+2500*MyLotsH+" USD,Close all");
		}

		/*三个以上50美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(ordercountwithprofit(500*MyLotsH)>= 3)
		{
			
			ordercloseallwithprofit(100*MyLotsH);
			Print("4、This turn Own more than three "+500*MyLotsH+" USD,Close all");
		}

		/*两个以上70美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(ordercountwithprofit(700*MyLotsH)>= 2)
		{
			
			ordercloseallwithprofit(200*MyLotsH);
			Print("5、This turn Own more than two "+700*MyLotsH+" USD,Close all");
		}

		/*一个以上100美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(ordercountwithprofit(1000*MyLotsH)>= 1)
		{		
			ordercloseallwithprofit(200*MyLotsH);
			Print("6、This turn Own more than one "+1000*MyLotsH+" USD,Close all");
		}

		/*订单数量5个，且获利超过180美元，落袋为安*/
		if((ordercountwithprofit(2)==5)&&(orderprofitall()>1800*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("7、This turn Own more than one "+1800*MyLotsH+" USD,equal 5 order Close all");		
		}	

		/*订单数量4个，且获利超过150美元，落袋为安*/
		if((ordercountwithprofit(2)==4)&&(orderprofitall()>1500*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("8、This turn Own more than one "+1500*MyLotsH+" USD,equal 4 order Close all");		
		}	
		
		/*订单数量3个，且获利超过120美元，落袋为安*/
		if((ordercountwithprofit(2)==3)&&(orderprofitall()>1200*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("9、This turn Own more than one "+1200*MyLotsH+" USD,equal 3 order Close all");		
		}
		
		/*订单数量1\2个，且获利超过80美元，落袋为安*/
		if((ordercountwithprofit(2) <= 2)&&(orderprofitall()>800*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("10、This turn Own more than one "+800*MyLotsH+" USD,equal1 or 2 order Close all");		
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
	
	initsymbol();    
	openallsymbo();
	initmagicnumber();
	inittiimeperiod();
	
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
	Print("Account free margin = ",AccountFreeMargin());	  
	               
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
	
	int i,j,res,ticket;
 
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
	
	
	//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==false)
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
		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 	
		orderStopless = boll_low_B-bool_length*3;		
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
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
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberOne)))	
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
						

							
						Print(my_symbol+" MagicNumberOne Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberOne OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {          			 								 
							Print("OrderModify MagicNumberOne  successfully " + OrderMagicNumber());
						 }	
						Sleep(1000);
					
					}
				
				}
			}
		  
		}		
	
	}
	
	
	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==false)
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
		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 	
		orderStopless = boll_low_B-bool_length*3;		
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
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
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree))			
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
						

							
						Print(my_symbol+" MagicNumberThree Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberThree OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {          			 								 
							Print("OrderModify MagicNumberThree  successfully " + OrderMagicNumber());
						 }	
						Sleep(1000);
					
					}
				
				}
			}
		  
		}		
	
	}
	

	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberNine))==false)
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
		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 	
		orderStopless = boll_low_B-bool_length*3;		
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
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
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberNine))			
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
						

							
						Print(my_symbol+" MagicNumberNine Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberNine OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {          			 								 
							Print("OrderModify MagicNumberNine  successfully " + OrderMagicNumber());
						 }	
						Sleep(1000);
					
					}
				
				}
			}
		  
		}		
	
	}
	









	
	//上上上周期为多头,上上周期并未处于空头，通常是深度调整，上周期处于空头市场，本周期持续下跌，出现第一次上涨突破的背驰，通常是突破上轨
	//小周期突破，大周期回调结束
	//属于中周期深度调整型
	//做多的时间控制在下午2点到晚上10点之间，这个时间段通常能形成趋势，对冲高点买入的风险
	//小周期突破的中周期深度回调型买点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
		&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])			

		&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])							
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag >-3.5)					  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex >-0.95)	
			
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)		
		
		&&(opendaycheck(SymPos) == true)
		
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)))
	{
		if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (1 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1])	
						
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9])	
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[10])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[11])	
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[12])						
				
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

			BuySellPosRecord[SymPos].NextModifyValue1[0] = orderStopless;
			
			orderStopless =boll_low_B; 	
			BuySellPosRecord[SymPos].NextModifyValue2[0] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[0] = orderPrice;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*16;
			
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
			    			 	 		 			 	 		 			 	

						
			Print(my_symbol+" MagicNumberOne OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			if(true == accountcheck())
			{					
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberOne",MakeMagic(SymPos,MagicNumberOne),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberOne failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					
					BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(my_symbol,my_timeperiod)+22;					 
					BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);						            				 			 
					Print("OrderSend MagicNumberOne  successfully");
				 }								
				 
				 Sleep(1000);
			}					 
						
		}
					
		else
		{
		;
		}		
	
	}
	
	
	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
					
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)
				
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberNine))==true))
		)
	{
		
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
			
			orderStopless =MinValue3- bool_length*3; 	
			BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[2] = orderPrice;
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*16;
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
				
			
			Print(my_symbol+" MagicNumberThree OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberThree",MakeMagic(SymPos,MagicNumberThree),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberThree failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,my_timeperiod)+22;					 
					BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);				 				 
					Print("OrderSend MagicNumberThree  successfully");
				 }													
				Sleep(1000);
			}					
				
		}			
					
		
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
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberNine))==true)				
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


			BuySellPosRecord[SymPos].NextModifyValue1[8] = orderStopless;
			
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[8] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[8] = orderPrice;		
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*16;
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
				    			 	 		 			 	 		 			 	

			
			Print(my_symbol+" MagicNumberNine OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
						
			if(true == accountcheck())
			{					
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberNine",MakeMagic(SymPos,MagicNumberNine),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberNine failed with error #",GetLastError());
					
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[8] = iBars(my_symbol,my_timeperiod)+22;					 
					BuySellPosRecord[SymPos].TradeTimePos[8] = iBars(my_symbol,my_timeperiod);				 				 
					Print("OrderSend MagicNumberNine  successfully");
				 }													
				Sleep(1000);	
			}


		}
	}			
	
////////////////////////////////////////////////////////////////////////
//多空分界线
////////////////////////////////////////////////////////////////////////
	
	
	//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
	
	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)	
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
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
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{		
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwo))			

				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						


																		
						Print(my_symbol+" MagicNumberTwo Modify:" + "orderLots=" + orderLots +"orderPrice ="
						+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberTwo OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {       
							//BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod)				 									 
							Print("OrderModify MagicNumberTwo  successfully " + OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}			
		
		
	}	
	
	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)	
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
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
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{		
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour))		

				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
																		
						Print(my_symbol+" MagicNumberFour Modify:" + "orderLots=" + orderLots +"orderPrice ="
						+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberFour OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {       
							//BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod)				 									 
							Print("OrderModify MagicNumberFour  successfully " + OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}			
		
		
	}	
	

	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)	
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTen))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
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
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{		
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTen))			

				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						

																		
						Print(my_symbol+" MagicNumberTen Modify:" + "orderLots=" + orderLots +"orderPrice ="
						+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberTen OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {       
							//BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod)				 									 
							Print("OrderModify MagicNumberTen  successfully " + OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}			
		
		
	}	
	



			
	//上上上周期处于空头，上上周期并未处于多头，通常是震荡，上周期处于多头市场，本周期持续上涨，出现第一次下跌突破的背驰，通常是突破下轨
	//小周期突破，中周期追顶摸底，大周期顺势
	//做空的时间控制在下午2点到晚上10点之间，这个时间段通常能形成趋势，对冲低点卖出的风险
	//小周期突破的中周期转折型卖点
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
		&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])		
		
		&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])			
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag <3.5)						  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex <0.95)
		
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)		
		&&(opendaycheck(SymPos) == true)

		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)))
	{
		
		if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (-1 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1])	
						
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[10])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[11])	
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[12])				
																			
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
			

			BuySellPosRecord[SymPos].NextModifyValue1[1] = orderStopless;
			
			orderStopless =boll_up_B; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[1] = orderStopless;	
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[1] = orderPrice;			
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*16;
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
			

			Print(my_symbol+" MagicNumberTwo OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 
			orderPrice+"orderStopless="+orderStopless);		
			
			 if(true == accountcheck())
			 {
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberTwo",MakeMagic(SymPos,MagicNumberTwo),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberTwo failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(my_symbol,my_timeperiod)+22;					 
					BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberTwo  successfully");
				 }					
				 
				Sleep(1000);
			 }
											
		}
					
		else
		{
		;
		}		
	
	}	
	


	
	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了优化比较好的入场点，和止损点
	//趋势回调高点型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
					
		&&(opendaycheck(SymPos) == true)
		&&(tradetimecheck(SymPos) ==true)		
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTen))==true)))
	{
		

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
			
			orderStopless =MaxValue4 + bool_length*3; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[3] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*16;
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
			
													
					
			Print(my_symbol+" MagicNumberFour OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			 if(true == accountcheck())
			 {
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberFour",MakeMagic(SymPos,MagicNumberFour),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFour failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,my_timeperiod)+22;					 
					BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberFour  successfully");
				 }
													 
				 Sleep(1000);		
			 }					 
							
		
		}					
		
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
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTen))==true)				
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
			

			BuySellPosRecord[SymPos].NextModifyValue1[9] = orderStopless;	

			
			orderStopless =MaxValue4 + bool_length*2; 
			BuySellPosRecord[SymPos].NextModifyValue2[9] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[9] = orderPrice;

			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*16;
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
											
					
			Print(my_symbol+" MagicNumberTen OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{					
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberTen",MakeMagic(SymPos,MagicNumberTen),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberTen failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[9] = iBars(my_symbol,my_timeperiod)+22;					 
					BuySellPosRecord[SymPos].TradeTimePos[9] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberTen  successfully");
				 }
													 
				 Sleep(1000);	
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
	double orderpoint;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	
	int i,j,res,ticket;
 
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
	
	
	
	//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
		
	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)			
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==false)
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

		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 
		orderStopless = boll_low_B - bool_length*3;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFive))			
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						


						Print(my_symbol+" MagicNumberFive Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
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
			}
		  
		}
		
	
	}
	
	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==false)
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

		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 
		orderStopless = boll_low_B - bool_length*3;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSeven))
			
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						


						Print(my_symbol+" MagicNumberSeven Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
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
			}
		  
		}
		
	
	}
	
	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==false)
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

		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 
		orderStopless = boll_low_B - bool_length*3;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThirteen))
				
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						


						Print(my_symbol+" MagicNumberThirteen Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberThirteen OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {          			 								 
							Print("OrderModify MagicNumberThirteen  successfully "+OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}
		
	
	}
	
	if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEleven))==false)
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

		orderPrice = vask;				 
		//orderStopless =MinValue3- bool_length*4; 
		orderStopless = boll_low_B - bool_length*3;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberEleven))
				
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						


						Print(my_symbol+" MagicNumberEleven Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberEleven OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {          			 								 
							Print("OrderModify MagicNumberEleven  successfully "+OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}
		
	
	}
	






	
	//上上上周期为多头,上上周期并未处于空头，通常是深度调整，上周期处于空头市场，本周期持续下跌，出现第一次上涨突破的背驰，通常是突破上轨
	//小周期突破，大周期回调结束
	//属于中周期深度调整型
	//做多的时间控制在下午2点到晚上10点之间，这个时间段通常能形成趋势，对冲高点买入的风险
	//小周期突破的中周期深度回调型买点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
		&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])			

		&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])							
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag >-3.5)					  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex >-0.95)	
			
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)		
		
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)))
	{
		if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (1 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1])	
						
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9])	
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[10])							
			
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

			orderStopless =MinValue3- bool_length*8; 	

			BuySellPosRecord[SymPos].NextModifyValue1[4] = orderStopless;
			
			orderStopless =boll_low_B; 	
			BuySellPosRecord[SymPos].NextModifyValue2[4] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[4] = orderPrice;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*16;
			
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
			

			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
																				

						
			Print(my_symbol+" MagicNumberFive OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
								
			if(true == accountcheck())
			{
			
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberFive",MakeMagic(SymPos,MagicNumberFive),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFive failed with error #",GetLastError());
					
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[4] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(my_symbol,my_timeperiod);						            				 			 
					Print("OrderSend MagicNumberFive  successfully");
				 }								
				 
				 Sleep(1000);	
			}					 
						
		}
					
		else
		{
		;
		}		
	
	}
	


	
	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	
	//趋势回调低点型买点，小周期低点衰竭
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEleven))==true)))
	{
		
		
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
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[6] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[6] = orderPrice;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*16;
			
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
			
																			
	    			 	 		 			 	 		 			 	

			Print(my_symbol+" MagicNumberSeven OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberSeven",MakeMagic(SymPos,MagicNumberSeven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSeven failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);				 				 
					Print("OrderSend MagicNumberSeven  successfully");
				 }													
				Sleep(1000);	
			}					
			
		}			
					
		
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
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEleven))==true)			
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


			BuySellPosRecord[SymPos].NextModifyValue1[10] = orderStopless;
			
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[10] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[10] = orderPrice;		
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*16;
			
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
																				
			
			
			Print(my_symbol+" MagicNumberEleven OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberEleven",MakeMagic(SymPos,MagicNumberEleven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEleven failed with error #",GetLastError());
					
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[10] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[10] = iBars(my_symbol,my_timeperiod);				 				 
					Print("OrderSend MagicNumberEleven  successfully");
				 }													
				Sleep(1000);	
			}


		}
	}			
	


	//小周期持续走低后突破，表现为持续多个节点才上碰bool上轨，在五分钟级别上的假突破会少一点，突破回调买入；属于典型的赌反弹行为。约束条件是超大周期未走坏。
	//猜顶摸底的转折型买点
	if((BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.2)		
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.8)
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)						
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==true)
		)
	{
		
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (1 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
						
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[10])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[11])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[12])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[13])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[14])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[15])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[16])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[17])		
			&& (3 >BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[18])		
																					
			)			

		{
			vask    = MarketInfo(my_symbol,MODE_ASK);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
		
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;		
			
			
			orderStopless =boll_low_B-bool_length*2; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[12] = orderStopless;
			
			orderStopless =boll_low_B-bool_length; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[12] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[12] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

			orderStopless =boll_mid_B; 				
			orderTakeProfit	= 	orderPrice + bool_length*16;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			


			Print(my_symbol+" MagicNumberThirteen OrderSend" + "orderLots=" 
			+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
				 ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberThirteen",MakeMagic(SymPos,MagicNumberThirteen),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberThirteen failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;				 
					BuySellPosRecord[SymPos].NextModifyPos[12] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[12] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberThirteen  successfully");
				 }
													 
				 Sleep(1000);		
			 }					 
							
		
		}			
					
		
	}		
	
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////		
	//多空分界		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////		
			
	
	//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
	
	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSix))
				
				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
	
																		
						Print(my_symbol+" MagicNumberSix Modify:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
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
			}
		  
		}			
		
		
	}	
	
	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberEight))				
				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
	
																		
						Print(my_symbol+" MagicNumberEight Modify:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
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
			}
		  
		}			
		
		
	}	
	
	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFourteen))				
				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
	
																		
						Print(my_symbol+" MagicNumberFourteen Modify:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberFourteen OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {       			 									 
							Print("OrderModify MagicNumberFourteen  successfully "+OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}			
		
		
	}	
	
	if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
		&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwelve))==false)
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
	

		orderPrice = vbid;						 
		//orderStopless =MaxValue4 + bool_length*4; 
		orderStopless = boll_up_B + bool_length*3;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*9;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwelve))				
				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
	
																		
						Print(my_symbol+" MagicNumberTwelve Modify:" + "orderLots=" 
						+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberTwelve OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {       			 									 
							Print("OrderModify MagicNumberTwelve  successfully "+OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}			
		
		
	}	
	


			



	//上上上周期处于空头，上上周期并未处于多头，通常是震荡，上周期处于多头市场，本周期持续上涨，出现第一次下跌突破的背驰，通常是突破下轨
	//小周期突破，中周期追顶摸底，大周期顺势
	//做空的时间控制在下午2点到晚上10点之间，这个时间段通常能形成趋势，对冲低点卖出的风险
	//小周期突破的中周期转折型卖点
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
		&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])		
		
		&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])			
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag <3.5)						  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex <0.95)
		
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)		
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)))
	{
		
		if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (-1 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1])	
						
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[10])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[11])	
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[12])				
																			
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
			

			BuySellPosRecord[SymPos].NextModifyValue1[5] = orderStopless;
			
			orderStopless =boll_up_B; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[5] = orderStopless;			
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[5] = orderPrice;	
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*16;
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
			
																			

	
													
			Print(my_symbol+" MagicNumberSix OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
				 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberSix",MakeMagic(SymPos,MagicNumberSix),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSix failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[5] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberSix  successfully");
				 }					
				 
				Sleep(1000);
			 }
											
		}
					
		else
		{
		;
		}		
	
	}	
	


	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了优化比较好的入场点，和止损点
	//趋势回调探高型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
							
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwelve))==true)))
	{
		

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
			
			orderStopless =MaxValue4 + bool_length*2; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[7] = orderStopless;		
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[7] = orderPrice;		
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*16;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
																		


					
			Print(my_symbol+" MagicNumberEight OrderSend" + "orderLots=" + orderLots +"orderPrice ="
				+ orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
				 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberEight",MakeMagic(SymPos,MagicNumberEight),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEight failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;				 
					BuySellPosRecord[SymPos].NextModifyPos[7] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberEight  successfully");
				 }
													 
				 Sleep(1000);	
			 }					 
								
		
		}			
		
		
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
			&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwelve))==true)				
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
			

			BuySellPosRecord[SymPos].NextModifyValue1[11] = orderStopless;	

			
			orderStopless =MaxValue4 + bool_length*2; 
			BuySellPosRecord[SymPos].NextModifyValue2[11] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[11] = orderPrice;
			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*16;
			
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
			
										
					
			Print(my_symbol+" MagicNumberTwelve OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
					 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberTwelve",MakeMagic(SymPos,MagicNumberTwelve),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberTwelve failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;				 
					BuySellPosRecord[SymPos].NextModifyPos[11] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[11] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberTwelve  successfully");
				 }
													 
				 Sleep(1000);	
			 }					 
							
		}
					
	}						

						
	
	//小周期持续走高后突破，表现为持续多个节点才下碰bool下轨，在五分钟级别上的假突破会少一点，突破回调买入；属于典型的赌反弹行为。约束条件是超大周期未走坏。
	//猜顶摸底的转折型卖点
	if((BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.8)				
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.2)
		//&&(tradetimecheck(SymPos) ==true)					
		&&(opendaycheck(SymPos) == true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==true)
		)
	{
		
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (-1 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
						
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[10])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[11])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[12])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[13])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[14])			
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[15])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[16])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[17])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[18])	
			
			
			//&& (3 >BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])		
			&& (-3 <BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])		
			//&& (-3 <BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[3])				
																						
			)			
					
		{
			
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vbid;				 

			orderStopless =boll_up_B; 	

			BuySellPosRecord[SymPos].NextModifyValue1[13] = orderStopless;
			
			orderStopless =boll_mid_B; 	
			BuySellPosRecord[SymPos].NextModifyValue2[13] = orderStopless;
			
			BuySellPosRecord[SymPos].CurrentOpenPrice[13] = orderPrice;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			
			orderStopless =boll_mid_B; 				
			orderTakeProfit	= 	orderPrice - bool_length*16;
			
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
			
	    			 	 		 			 	 		 			 	
			
			Print(my_symbol+" MagicNumberFourteen OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
								
			
			if(true == accountcheck())
			{
				
				ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberFourteen",MakeMagic(SymPos,MagicNumberFourteen),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFourteen failed with error #",GetLastError());
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
					TwentyS_Freq++;
					OneM_Freq++;
					ThirtyS_Freq++;
					FiveM_Freq++;
					ThirtyM_Freq++;	
					BuySellPosRecord[SymPos].NextModifyPos[13] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[13] = iBars(my_symbol,my_timeperiod);				 				 
					Print("OrderSend MagicNumberFourteen  successfully");
				 }													
				Sleep(1000);	
			}					
			
		}									
	}		
				
						
	
}




void checkbuysellordertypeone()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int NowMagicNumber;
	
	double boll_up_B,boll_low_B,bool_length;	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;

	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	
	int i,ticket;
 
	int    vdigits ;
	
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
	   
			SymPos = ((int)OrderMagicNumber()) /1000;
			
			NowMagicNumber = OrderMagicNumber() - SymPos *1000;

			if((SymPos<0)||(SymPos>=symbolNum))
			{
				Print("SymPos error 0");
			}

			my_symbol =   MySymbol[SymPos];


			//确保寻找买卖点是每个周期计算一次，而不是每个tick计算一次
			if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
			{
 
				boll_up_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
				boll_low_B = iBands(my_symbol,my_timeperiod,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
				bool_length = (boll_up_B - boll_low_B)/2;
				
				vbid    = MarketInfo(my_symbol,MODE_BID);		
				vask    = MarketInfo(my_symbol,MODE_ASK);												
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS); 	
	 
 
				if(NowMagicNumber == MagicNumberOne)
				{
				
					  
					if((SymPos>=0)&&(SymPos<symbolNum))
					{
						;
					}
					else
					{
						Print("SymPos error 1");
					}
				   
						
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[0])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberOne11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberOne11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[0])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberOne11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberOne11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberOne11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberOne11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[0] = BuySellPosRecord[SymPos].TradeTimePos[0]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[0])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberOne11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberOne11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							


			
				}
				
				if(NowMagicNumber == MagicNumberTwo)
				{
				
		   
	
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						;
				   }
				   else
				   {
					  Print("SymPos error 2");
				   }
	
	
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[1])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberTwo11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberTwo11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[1])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberTwo11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberTwo11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberTwo11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberTwo11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[1] = BuySellPosRecord[SymPos].TradeTimePos[1]+
								1;																						
					}


					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[1]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwo11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwo11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
				   						   			   
				   
				}
					
				if(NowMagicNumber == MagicNumberThree)
				{
	
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
	
					;
				  
				   }
				   else
				   {
					  Print("SymPos error 3");
				   }		
	
				   
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[2])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberOne11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberOne11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[2])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberThree11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberThree11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberThree11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberThree11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[2] = BuySellPosRecord[SymPos].TradeTimePos[2]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[2])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThree11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThree11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
								   		
			
				}  	
				
				if(NowMagicNumber == MagicNumberFour)
				{

				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
					;
				   }
				   else
				   {
					  Print("SymPos error 4");
				   }	
	
				   
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[3])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberFour11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberFour11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[3])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberFour11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberFour11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberFour11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberFour11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[3] = BuySellPosRecord[SymPos].TradeTimePos[3]+
								1;																						
					}


					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[3]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFour11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
			
			
				
				}  
			
				if(NowMagicNumber == MagicNumberNine)
				{
				
					  
					if((SymPos>=0)&&(SymPos<symbolNum))
					{
						;
					}
					else
					{
						Print("SymPos error 9");
					}
				   
						
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[8])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberNine 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberNine 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[8])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberNine 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberNine 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberNine 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberNine 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[8] = BuySellPosRecord[SymPos].TradeTimePos[8]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[8])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberNine 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberNine 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							


			
				}
				
				if(NowMagicNumber == MagicNumberTen)
				{
				
		   
	
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						;
				   }
				   else
				   {
					  Print("SymPos error 10");
				   }
	
	
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[9])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberTen 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberTen 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[9])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberTen 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberTen 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberTen 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberTen 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[9] = BuySellPosRecord[SymPos].TradeTimePos[9]+
								1;																						
					}


					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[9]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTen 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTen 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
				   						   			   
				   
				}
								
			
			
			}		

		
		}				
	}

	
	
}
	


void checkbuysellordertypetwo()
{
	
	int SymPos;
	int timeperiodnum;
	int my_timeperiod;
	string my_symbol;
	int NowMagicNumber;
	
	double boll_up_B,boll_low_B,bool_length;	
	double vbid,vask; 
	double MinValue3 = 100000;
	double MaxValue4=-1;

	double orderStopLevel;

	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	
	int i,ticket;
 
	int    vdigits ;
	
	timeperiodnum = 1;	

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
	   
			SymPos = ((int)OrderMagicNumber()) /1000;
			
			NowMagicNumber = OrderMagicNumber() - SymPos *1000;

			if((SymPos<0)||(SymPos>=symbolNum))
			{
				Print("SymPos error 0");
			}

			my_symbol =   MySymbol[SymPos];
			
			//确保寻找买卖点是每个周期计算一次，而不是每个tick计算一次
			if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
			{			
				boll_up_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
				boll_low_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
				bool_length = (boll_up_B - boll_low_B)/2;
				
				vbid    = MarketInfo(my_symbol,MODE_BID);		
				vask    = MarketInfo(my_symbol,MODE_ASK);												
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS); 	
				
		  		  
				if(NowMagicNumber == MagicNumberFive)
				{
				 
					if((SymPos>=0)&&(SymPos<symbolNum))
					{
						;
					}
					else
					{
						Print("SymPos error 5");
					}
	
									
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[4])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberFive11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberFive11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[4])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberFive11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberFive11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberFive11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberFive11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[4] = BuySellPosRecord[SymPos].TradeTimePos[4]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[4])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFive11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFive11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
					
				   
	
					
				}			
						
				
				if(NowMagicNumber == MagicNumberSix)
				{
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						;
				   }
				   else
				   {
					  Print("SymPos error 6");
				   }
	
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[5])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberSix11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberSix11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[5])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberSix11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberSix11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberSix11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberSix11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[5] = BuySellPosRecord[SymPos].TradeTimePos[5]+
								1;																						
					}


					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[5]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSix11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
					
				   
				}				   				  	  					
			
						
				if(NowMagicNumber == MagicNumberSeven)
				{
					
	
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
	
						;
				  
				   }
				   else
				   {
					  Print("SymPos error 7");
				   }		
	
						
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[6])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberSeven11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberSeven11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[6])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberSeven11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberSeven11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberSeven11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberSeven11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[6] = BuySellPosRecord[SymPos].TradeTimePos[6]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[6])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSeven11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSeven11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
									
								   
				}
					
				
				if(NowMagicNumber == MagicNumberEight)
				{
				   
	
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
	
						;
				  
				   }
				   else
				   {
					  Print("SymPos error 8");
				   }	

					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[7])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberEight11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberEight11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[7])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberEight11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberEight11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberEight11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberEight11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[7] = BuySellPosRecord[SymPos].TradeTimePos[7]+
								1;																						
					}


					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[7]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEight11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEight11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
				   						   			   
					
				   
				}			
			


				if(NowMagicNumber == MagicNumberEleven)
				{
				 
					if((SymPos>=0)&&(SymPos<symbolNum))
					{
						;
					}
					else
					{
						Print("SymPos error 11");
					}
	
									
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[10])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberEleven 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberEleven 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[10])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberEleven 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberEleven 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberEleven 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberEleven 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[10] = BuySellPosRecord[SymPos].TradeTimePos[10]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[10])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEleven 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEleven 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
					
				   
	
					
				}			
						
				
				if(NowMagicNumber == MagicNumberTwelve)
				{
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						;
				   }
				   else
				   {
					  Print("SymPos error 12");
				   }
	
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[11])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberTwelve 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberTwelve 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[11])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberTwelve 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberTwelve 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberTwelve 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberTwelve 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[11] = BuySellPosRecord[SymPos].TradeTimePos[11]+
								1;																						
					}



					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[11]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwelve 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwelve 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
					
				   
				}				   				  	  					
			




					
				if(NowMagicNumber == MagicNumberThirteen)
				{
	
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
	
						;
				  
				   }
				   else
				   {
					  Print("SymPos error 13");
				   }		
	
					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[12])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberThirteen11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberThirteen11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[12])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberThirteen11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberThirteen11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberThirteen11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberThirteen11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*多头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[12] = BuySellPosRecord[SymPos].TradeTimePos[12]+
								1;																						
					}


					/*高周期上涨加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((vbid-BuySellPosRecord[SymPos].CurrentOpenPrice[12])> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberOne11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberOne11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
									
								   
				}
	 	
				
				if(NowMagicNumber == MagicNumberFourteen)
				{
				
		   
	
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
	
						;
				  
				   }
				   else
				   {
					  Print("SymPos error 14");
				   }	
	

					/*一分钟1200个周期，理论上应该走完了,960周期开始监控时间控制*/
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[13])>1200)
					{
						ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						
						if(ticket <0)
						{
							Print("OrderClose MagicNumberFourtee11 333 failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberFourtee11 333  successfully,Usually lose");
						}    
						Sleep(1000);  	   
					}
					
					else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[13])>960)
					{  
						 	   
						if( OrderProfit()> 0)
						{
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							if(ticket <0)
							{
								Print("OrderClose MagicNumberFourtee11 444 failed with error #",GetLastError());
							}
							else
							{            
								Print("OrderClose MagicNumberFourtee11 444  successfully,no profit and no lose");
							}    
							Sleep(1000);     	           
						} 
						  
						if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						{
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberFourtee11 000 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberFourtee11 000  successfully,Usually lose");
							 }    
							 Sleep(1000); 																		
						
						}	
					
					}  
					else
					{
						;
					}
					
				  /*空头之下保持持有时间加长*/
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
							//持平一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[13] = BuySellPosRecord[SymPos].TradeTimePos[13]+
								1;																						
					}


					/*高周期下跌加速，分批出货*/
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
						&&((BuySellPosRecord[SymPos].CurrentOpenPrice[13]-vbid)> bool_length*8)			
						&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						
						/*三次完成出货*/
						if (orderLots <= MyLotsL*9/64)
						{
							orderLots = OrderLots();
						}
													
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = OrderLots();
							orderLots = NormalizeDouble(orderLots,2);
						}
													
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFourtee11 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFourtee11 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					
							
				   						   			   		   

				   
				}					
			
			}
		}				
	}

	

}	
	
	


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

	if(TwentyS_Freq > 5)
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

	if(ThirtyS_Freq > 8)
	{
      Print("detect ordersend unnormal");
		 return;
	}
	else
	{
		if (0== (Freq_Count%30))
		{
			 ThirtyS_Freq = 0;
		}
	}

	if(OneM_Freq > 10)
	{
      Print("detect ordersend unnormal");
		 return;
	}
	else
	{
		if (0== (Freq_Count%60))
		{
			 OneM_Freq = 0;
		}
	}

	if(FiveM_Freq > 20)
	{
      Print("detect ordersend unnormal");
		 return;
	}
	else
	{
		if (0== (Freq_Count%300))
		{
			 FiveM_Freq = 0;
		}
	}

	if(ThirtyM_Freq > 30)
	{
      Print("detect ordersend unnormal");
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




	
	/*所有货币对所有周期指标计算*/	
	calculateindicator();
      


	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{	
		/*特定货币一分钟寻找买卖点*/
		orderbuyselltypeone(SymPos);
		/*特定货币五分钟寻找买卖点*/		
		orderbuyselltypetwo(SymPos);
		/*特定货币三十分钟寻找买卖点*/		
		//orderbuyselltypethree(SymPos);
	}
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////////
   //订单管理优化，包括移动止损、直接止损、订单时间管理
   //暂时还没有想清楚该如何移动止损优化  
   ////////////////////////////////////////////////////////////////////////////////////////////////
	 /*一分钟订单处理*/
   checkbuysellordertypeone();
	 /*五分钟订单处理*/   
   checkbuysellordertypetwo();
	 /*三十分钟订单处理*/   
  // checkbuysellordertypethree();
   
   
   /*短线获利清盘针对一分钟盘面*/
   monitoraccountprofit();

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
