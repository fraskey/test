//+------------------------------------------------------------------+
//|                                       MutiPeriodAutoTradePro.mq4 |
//|                   Copyright 2005-2016, Copyright. Personal Keep  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2016, Xuejiayong."
#property link        "http://www.mql14.com"




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


#define HCROSSNUMBER  100





//input double TakeProfit    =50;
double MyLotsH          =0.02;
double MyLotsL          =0.02; 
//input double TrailingStop  =30;

int Move_Av = 2;
int iBoll_B = 60;
//input int iBoll_S = 20;


int timeperiod[16];
int TimePeriodNum = 6;



/*重大重要数据时间，每个周末落实第二周的情况*/
//重大重要数据期间，现有所有订单以一分钟周期重新设置止损，放大止盈，不做额外的买卖
datetime feinongtime= D'1980.07.19 12:30:27';  // Year Month Day Hours Minutes Seconds
int feilongtimeoffset = 0;
datetime yixitime =   D'1980.07.19 12:30:27'; 
int yixitimeoffset = 0;
datetime bigeventstime = D'1980.07.19 12:30:27'; 
int bigeventstimeoffset = 0;

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







struct stBuySellPosRecord
{	
	int TradeTimePos[20];
	int NextModifyPos[20];
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
	for(SymPos = 0; SymPos < symbolNum;SymPos++)
	{
		
		my_symbol =   MySymbol[SymPos];
		
		for(i = 0; i < 20;i++)
		{			
			BuySellPosRecord[SymPos].NextModifyPos[i] = 1000000000;
			
		}

		my_timeperiod = timeperiod[0];				
		BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);			
		
		my_timeperiod = timeperiod[1];				
		BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(my_symbol,my_timeperiod);			
		BuySellPosRecord[SymPos].TradeTimePos[12] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[13] = iBars(my_symbol,my_timeperiod);			
				
		my_timeperiod = timeperiod[2];				
		BuySellPosRecord[SymPos].TradeTimePos[8] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[9] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[10] = iBars(my_symbol,my_timeperiod);		
		BuySellPosRecord[SymPos].TradeTimePos[11] = iBars(my_symbol,my_timeperiod);			
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
		
			
		
	
	//周一早7点前不下单	
	if (TimeDayOfWeek(timelocal) == 1)
	{
		if (TimeHour(timelocal) < 7 ) 
		{
			tradetimeflag = false;
		}
	}
	
	//周六凌晨3点后不下单		
	if (TimeDayOfWeek(timelocal) == 6)
	{
		if (TimeHour(timelocal) > 3 )  
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
	/*OANDA 服务器时间为GMT + 2 ，北京时间为GMT + 8，相差6个小时*/		
    timelocal = TimeCurrent() + HTIMEZONEDIFF*60*60;


	//下午3点前不做趋势单，主要针对1分钟线，非欧美时间趋势不明显
	
	if ((TimeHour(timelocal) >= 16 )&& (TimeHour(timelocal) <22 )) 
	{
		tradetimeflag = true;		
	}	
	/*测试期间全时间段交易*/
	tradetimeflag = true;		
	
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
			
		/*超过250美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(orderprofitall() > 2500*MyLotsH)
		{
			
			ordercloseallwithprofit(100*MyLotsH);
			Print("1、This turn Own more than "+2500*MyLotsH+" USD,Close all");
		}

		/*三个以上50美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(ordercountwithprofit(500*MyLotsH)>= 3)
		{
			
			ordercloseallwithprofit(100*MyLotsH);
			Print("2、This turn Own more than three "+500*MyLotsH+" USD,Close all");
		}

		/*两个以上70美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(ordercountwithprofit(700*MyLotsH)>= 2)
		{
			
			ordercloseallwithprofit(200*MyLotsH);
			Print("3、This turn Own more than two "+700*MyLotsH+" USD,Close all");
		}

		/*一个以上100美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
		if(ordercountwithprofit(1000*MyLotsH)>= 1)
		{		
			ordercloseallwithprofit(200*MyLotsH);
			Print("4、This turn Own more than one "+1000*MyLotsH+" USD,Close all");
		}

		/*订单数量4个，且获利超过150美元，落袋为安*/
		if((ordercountwithprofit(2)==4)&&(orderprofitall()>1500*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("5、This turn Own more than one "+1500*MyLotsH+" USD,equal 4 order Close all");		
		}	
		
		/*订单数量3个，且获利超过120美元，落袋为安*/
		if((ordercountwithprofit(2)==3)&&(orderprofitall()>1200*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("6、This turn Own more than one "+1200*MyLotsH+" USD,equal 3 order Close all");		
		}
		
		/*订单数量1\2个，且获利超过80美元，落袋为安*/
		if((ordercountwithprofit(2) <= 2)&&(orderprofitall()>800*MyLotsH))
		{
			ordercloseallwithprofit(100*MyLotsH);		
			Print("7、This turn Own more than one "+800*MyLotsH+" USD,equal1 or 2 order Close all");		
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
				if(((bool_length <0.0001)&&(bool_length >0))||((bool_length >-0.0001)&&(bool_length <0))	)
				{
					Print("bool_length is Zero,ERROR!!");
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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==false)))		
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
		orderStopless = boll_low_B-bool_length;		
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*6;
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
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberOne))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberOne)))			
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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==false)))		
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
		orderStopless = boll_low_B-bool_length;		
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*6;
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
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree)))			
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
	
		
	
	
	//上上周期并未处于空头，通常是震荡，上周期处于空头市场，本周期持续下跌，出现第一次上涨突破的背驰，通常4是突破上轨
	//小周期突破，大周期追顶摸底
	//猜顶摸底的转折型买点
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
		&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])			
						
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag >-3.5)					  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex >-0.95)	
			
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.2)		
		
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		//&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true))
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

			BuySellPosRecord[SymPos].NextModifyValue1[2] = orderStopless;
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
	
	//趋势回调低点型买点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		&&(0.8<BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])	
		&&(0.8<BoolCrossRecord[SymPos][timeperiodnum+3].CrossStrongWeak[1])				
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true))
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
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1]))			
			
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
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
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
				
			
			Print(my_symbol+" MagicNumberThree3 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberThree3",MakeMagic(SymPos,MagicNumberThree),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberThree3 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberThree3  successfully");
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
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])	


			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])	

									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8)			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0]))			
					
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
			
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;				
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
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
				    			 	 		 			 	 		 			 	

			
			Print(my_symbol+" MagicNumberThree4 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
						
			if(true == accountcheck())
			{					
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberThree4",MakeMagic(SymPos,MagicNumberThree),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberThree4 failed with error #",GetLastError());
					
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
					Print("OrderSend MagicNumberThree4  successfully");
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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==false)))
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
		orderStopless = boll_up_B + bool_length;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*6;
		
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
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwo))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwo)))				

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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==false)))
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
		orderStopless = boll_up_B + bool_length;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*6;
		
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
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour)))				

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
	


					
			
	//上上周期并未处于多头，通常是震荡，上周期处于多头市场，本周期持续上涨，出现第一次下跌突破的背驰，通常是突破下轨
	//小周期突破，大周期追顶摸底
	//猜顶摸底的转折型卖点
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)

		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag <3.5)						  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex <0.95)
		
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.8)		
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)
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
			
			orderStopless =MaxValue4 + bool_length*2; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[1] = orderStopless;				
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
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
		&&(0.2>BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])	
		&&(0.2>BoolCrossRecord[SymPos][timeperiodnum+3].CrossStrongWeak[1])	
					
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)))
	{
		

		/*五分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.65)	

			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex > -0.15)		
											
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1]))	

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
			
			orderStopless =MaxValue4 + bool_length*2; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;				
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
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
			
													
					
			Print(my_symbol+" MagicNumberFour3 OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			 if(true == accountcheck())
			 {
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberFour3",MakeMagic(SymPos,MagicNumberFour),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFour3 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberFour3  successfully");
				 }
													 
				 Sleep(1000);		
			 }					 
							
		
		}					
		
		/*三十分钟强势，五分钟不若失，一分钟bool背驰，多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])	


			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])	
		
									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2)			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0]))
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

			
			orderStopless =MaxValue4 + bool_length*2; 
			BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;
			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
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
											
					
			Print(my_symbol+" MagicNumberFour4 OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{					
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberFour4",MakeMagic(SymPos,MagicNumberFour),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFour4 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberFour4  successfully");
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
			
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==false)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==false)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==false)))		
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
		orderStopless = boll_low_B - bool_length;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFive))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFive))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFive)))					
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
			
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==false)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==false)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==false)))		
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
		orderStopless = boll_low_B - bool_length;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSeven))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSeven))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSeven)))					
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
			
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==false)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==false)
		||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==false)))		
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
		orderStopless = boll_low_B - bool_length;
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThirteen))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThirteen))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThirteen)))					
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
	


			
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了找到比较好的入场点，和止损点
	//突破型买点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重多头测试，关键是要深度回调，
	//且五分钟以上突破相对稳定一点，最关键的一点还是要设置小止损
	//趋势回调突破型买点，	
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8)			
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		&&(0.8<BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])	
		&&(0.8<BoolCrossRecord[SymPos][timeperiodnum+3].CrossStrongWeak[1])	
	
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)))
	{

	

		if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1])	
			
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])	
												
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1]))	
			

										
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

			BuySellPosRecord[SymPos].NextModifyValue1[4] = orderStopless;
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[4] = orderStopless;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
	//趋势回调低点型买点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.4)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		&&(0.8<BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])	
		&&(0.8<BoolCrossRecord[SymPos][timeperiodnum+3].CrossStrongWeak[1])	
		
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)))
	{
		
		
		/*日线和四小时多头向上，五分钟空头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.45)	
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.15)		
											
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1]))			
			
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
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
			
																			
	    			 	 		 			 	 		 			 	

			Print(my_symbol+" MagicNumberSeven3 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberSeven3",MakeMagic(SymPos,MagicNumberSeven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSeven3 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberSeven3  successfully");
				 }													
				Sleep(1000);	
			}					
			
		}			
					
		
		/*四小时强势，三十分钟不若失，五分钟bool背驰，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])	


			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])	

									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8)			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0]))	
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
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
																				
			
			
			Print(my_symbol+" MagicNumberSeven4 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			
			if(true == accountcheck())
			{
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberSeven4",MakeMagic(SymPos,MagicNumberSeven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSeven4 failed with error #",GetLastError());
					
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
					Print("OrderSend MagicNumberSeven4  successfully");
				 }													
				Sleep(1000);	
			}


		}
	}			
	


	//上上周期并未处于空头，通常是震荡，上周期处于空头市场，本周期持续下跌，出现第一次上涨突破的背驰，通常4是突破上轨
	//小周期突破，大周期追顶摸底
	//猜顶摸底的转折型买点
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
		&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])			
						
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag >-3.5)					  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex >-0.95)	
			
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.2)		
		
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThirteen))==true)))
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
											
			)			

		{
			vask    = MarketInfo(my_symbol,MODE_ASK);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
		
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;		
			
			
			orderStopless =boll_low_B; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[12] = orderStopless;
			
			orderStopless =boll_mid_B; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[12] = orderStopless;				
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==false)))
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
		orderStopless = boll_up_B + bool_length;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSix))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSix))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSix)))					
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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==false)))
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
		orderStopless = boll_up_B + bool_length;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberEight))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberEight))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberEight)))					
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
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==false)))
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
		orderStopless = boll_up_B + bool_length;
		
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFourteen))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFourteen))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFourteen)))					
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
	


	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了找到比较好的入场点，和止损点
	//突破型卖点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重空头测试，关键是减少止损，，关键是要深度回调，
	//且五分钟以上突破相对稳定一点，最关键的一点还是要设置小止损
	//趋势回调突破型卖点，

	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.6)
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2)			
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
		&&(0.2>BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])	
		&&(0.2>BoolCrossRecord[SymPos][timeperiodnum+3].CrossStrongWeak[1])	
							

		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)))
	{


		if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1])	
			
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6])	
			&& (-3.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7])	
												
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1]))	
			
	
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
			
			orderStopless =MaxValue4 + bool_length*2; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[5] = orderStopless;				
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
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
		&&(0.2>BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[1])	
		&&(0.2>BoolCrossRecord[SymPos][timeperiodnum+3].CrossStrongWeak[1])
							
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)))
	{
		

		/*三十分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.65)	

			&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex > -0.15)		
											
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1]))	

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
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
			
																		


					
			Print(my_symbol+" MagicNumberEight3 OrderSend" + "orderLots=" + orderLots +"orderPrice ="
				+ orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
				 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberEight3",MakeMagic(SymPos,MagicNumberEight),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEight3 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberEight3  successfully");
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
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2])	


			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[0])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[1])	
			&& (3.5 > BoolCrossRecord[SymPos][timeperiodnum+2].CrossFlag[2])	
		
									
			&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2)			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0]))

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
			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
			
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
			
										
					
			Print(my_symbol+" MagicNumberEight4 OrderSend" + "orderLots=" + orderLots +"orderPrice ="
			+	 orderPrice+"orderStopless="+orderStopless);							
			 
			 if(true == accountcheck())
			 {
					 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberEight4",MakeMagic(SymPos,MagicNumberEight),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEight4 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberEight4  successfully");
				 }
													 
				 Sleep(1000);	
			 }					 
							
		}
					
	}						

			
			
	
	//上上周期并未处于多头，通常是震荡，上周期处于多头市场，本周期持续上涨，出现第一次下跌突破的背驰，通常是突破下轨
	//小周期突破，大周期追顶摸底
	//猜顶摸底的转折型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)

		&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolFlag <3.5)						  
		&&(BoolCrossRecord[SymPos][timeperiodnum+2].BoolIndex <0.95)
		
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.8)		
	
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFourteen))==true)))
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
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice - bool_length*4;
			
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


void orderbuyselltypethree(int SymPos)
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
	
	/*30分钟线寻找买卖点，最多用到周线*/
	timeperiodnum = 2;	

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

		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEleven))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFifteen))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberNine))==false)))		
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
		orderStopless = boll_low_B - bool_length;			
		/*
		if((orderPrice - orderStopless)>bool_length*2)
		{
			orderStopless = orderPrice - bool_length*2;
		}
		*/
		orderTakeProfit	= 	orderPrice + bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

		//orderTakeProfit = 0;
		

		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberEleven))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberNine))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFifteen)))					
				{

					if(orderStopless >OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
																		
															


							
						Print(my_symbol+" MagicNumberEleven/Nine/Fiifteen Modify:" + "orderLots=" + orderLots +"orderPrice ="
										+orderPrice+"orderStopless="+orderStopless);									
						
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberEleven/Nine/Fiifteen OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {          			 								 
							Print("OrderModify MagicNumberEleven/Nine/Fiifteen  successfully "+OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}
		
	
	}
	
	
	//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了找到比较好的入场点，和止损点
	//突破型买点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重多头测试，最关键的一点还是要设置小止损
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag >3.5)	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >0.8)	
			
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEleven))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberNine))==true)))
	{
		
		if(/*(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)*/
			(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (-4 !=BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	

			&&(1 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlagChange)
			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))
								
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

			BuySellPosRecord[SymPos].NextModifyValue1[8] = orderStopless;
			
			orderStopless =MinValue3- bool_length*2; 	
			BuySellPosRecord[SymPos].NextModifyValue2[8] = orderStopless;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
					BuySellPosRecord[SymPos].NextModifyPos[8] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[8] = iBars(my_symbol,my_timeperiod);						            				 			 
					Print("OrderSend MagicNumberNine  successfully");
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
	//转折型买点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <-0.85)		
	
		//&&((FourH_BoolFlag <0)&&(FourH_BoolFlag >-4.5))
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEleven))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberNine))==true)))
	{
		
		
		/*三十分钟多头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
						
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))
					
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
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
			
																		

			Print(my_symbol+" MagicNumberEleven3 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
								
			
			if(true == accountcheck())
			{
				
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberEleven3",MakeMagic(SymPos,MagicNumberEleven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEleven3 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberEleven3  successfully");
				 }													
				Sleep(1000);	
			}					
			
		}			
					
		
		/*三十分钟非多头向下，一分钟bool背驰，空头陷阱*/
		
		if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (-1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))
							
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
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
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
			
																		

			
			Print(my_symbol+" MagicNumberEleven4 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
								
			if(true == accountcheck())
			{
				
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberEleven4",MakeMagic(SymPos,MagicNumberEleven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEleven4 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberEleven4  successfully");
				 }													
				Sleep(1000);	
			}


		}
	}			
	


	//超级大周期处于空头市场，上周期多头市场，本周期在高位上涨回调小周期背驰阶段买入，趋势转折交易，猜底摸顶
	//大周期超级转折型买点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >0.8)	
		
				
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFifteen))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFifteen))==true)))
	{
		
		/*四小时多头向上，三十分钟上涨两次确认，回调空头陷阱*/

		if(/*(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)*/
			(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (4 !=BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])
			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)				
			
			&&(1 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlagChange)
			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))		
			
		{
			vask    = MarketInfo(my_symbol,MODE_ASK);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
		
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vask;		
			
			
			orderStopless =boll_low_B; 
			

			BuySellPosRecord[SymPos].NextModifyValue1[14] = orderStopless;
			
			orderStopless =boll_mid_B; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[14] = orderStopless;				
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice + bool_length*4;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);


					
			Print(my_symbol+" MagicNumberFifteen OrderSend" + "orderLots=" + orderLots +"orderPrice ="
					+	 orderPrice+"orderStopless="+orderStopless);							

					
			 if(true == accountcheck())
			 {
			 
				 ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberFifteen",MakeMagic(SymPos,MagicNumberFifteen),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFifteen failed with error #",GetLastError());
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
					BuySellPosRecord[SymPos].NextModifyPos[14] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[14] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberFifteen  successfully");
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
	
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwelve))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSixteen))==false)
			||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTen))==false)))
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
		orderStopless = boll_up_B + bool_length;
		/*
		if(( orderStopless- orderPrice)>bool_length*2)
		{
			orderStopless = orderPrice + bool_length*2;
		}
		*/

			
		orderTakeProfit	= 	orderPrice - bool_length*6;
		
		orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
		orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
		orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
		

		//orderTakeProfit = 0;
			
		for (j = 0; j < OrdersTotal(); j++)
		{
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
			{				
				if((((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwelve))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTen))
					||(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberSixteen)))					
				{

					if(orderStopless < OrderStopLoss() )
					{
						
						Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
						+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);
						
																		

						
						Print(my_symbol+" MagicNumberTwelve/Ten/Sixteen Modify:" + "orderLots=" 
							+ orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless);	
										
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {

							Print("Error in MagicNumberTwelve/Ten/Sixteen OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {       			 									 
							Print("OrderModify MagicNumberTwelve/Ten/Sixteen  successfully "+OrderMagicNumber());
						 }								
						Sleep(1000);
					}
				
				}
			}
		  
		}			
		
		
	}	
	

	
	//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了找到比较好的入场点，和止损点
	//突破型卖点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重空头测试，关键是减少止损
	//突破型卖点止损设置值比较大
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag <-3.5)	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <-0.8)	
		
		&&(opendaycheck(SymPos) == true)
		//&&(tradetimecheck(SymPos) ==true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwelve))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTen))==true)))
	{
		 

		if(/*(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)*/
			(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (4 !=BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	

			&&(-1 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlagChange)
			
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))					
	
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
			

			BuySellPosRecord[SymPos].NextModifyValue1[9] = orderStopless;
			
			orderStopless =MaxValue4 + bool_length*2; 
			
			BuySellPosRecord[SymPos].NextModifyValue2[9] = orderStopless;				
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
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
					BuySellPosRecord[SymPos].NextModifyPos[9] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[9] = iBars(my_symbol,my_timeperiod);				 					 
					Print("OrderSend MagicNumberTen  successfully");
				 }					
				 
				Sleep(1000);
			}
												
		}
					
		else
		{
		;
		}		
	
	}	
	

	
	//大周期处于空头市场，本周期在上涨背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
	//转折型卖点
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)
	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)	
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
		
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >0.85)	
		
		//&&((FourH_BoolFlag > 0)&&(FourH_BoolFlag < 4.5))
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwelve))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTen))==true)))
	{
		

		/*三十分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
		
			&& (4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])	
						
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))
		
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
			
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
			
			orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
			orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
			orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
			
			Print(my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
			+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9]);



			Print(my_symbol+" MagicNumberTwelve3 OrderSend" + "orderLots=" + orderLots +"orderPrice ="
				+	 orderPrice+"orderStopless="+orderStopless);							
			if(true == accountcheck())
			{
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberTwelve3",MakeMagic(SymPos,MagicNumberTwelve),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberTwelve3 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberTwelve3  successfully");
				 }
													 
				 Sleep(1000);		
			}					 
							
		
		}			
		
		
		/*三十分钟线未明显多头向上，一分钟线背驰就认为是多头陷阱*/
		
		if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
			&&(4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)		
			&& (1 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])				
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.2<BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))	
		
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
			
							
			/*
			if(( orderStopless- orderPrice)>bool_length*2)
			{
				orderStopless = orderPrice + bool_length*2;
			}
			*/

				
			orderTakeProfit	= 	orderPrice - bool_length*4;
			
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
			
																		

										
					
			Print(my_symbol+" MagicNumberTwelve4 OrderSend" + "orderLots=" + orderLots +"orderPrice ="
				+	 orderPrice+"orderStopless="+orderStopless);							
			
			if(true == accountcheck())
			{
			 
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberTwelve4",MakeMagic(SymPos,MagicNumberTwelve),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberTwelve4 failed with error #",GetLastError());
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
					Print("OrderSend MagicNumberTwelve4  successfully");
				 }
													 
				 Sleep(1000);	
			}					 
								
		}
					
	}						

	
	
	//超级大周期处于多头市场，上周期空头市场，本周期在低位下跌回调小周期背驰阶段卖出，趋势转折交易，猜底摸顶
	//大周期超级转折型卖点
	
	if((BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8)
		&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)		
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)			
		&&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <-0.8)	
		
		&&(opendaycheck(SymPos) == true)
		&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSixteen))==true)
		&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSixteen))==true)))
	{
		
		
		/*三十分钟空头向下，五分钟下跌两次确认，回调多头陷阱*/

		if(/*(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)*/
			(-4==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
			&& (-4 ==BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])	
			&& (-4 !=BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4])			
			&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)				
			
			&&(-1 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlagChange)
			
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[1])
			&&(0.8>BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[2]))			
						
		{
			
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			orderLots = NormalizeDouble(MyLotsL,2);
			orderPrice = vbid;				 

			orderStopless =boll_up_B; 	

			BuySellPosRecord[SymPos].NextModifyValue1[15] = orderStopless;
			
			orderStopless =boll_mid_B; 	
			BuySellPosRecord[SymPos].NextModifyValue2[15] = orderStopless;
			
			/*
			if((orderPrice - orderStopless)>bool_length*2)
			{
				orderStopless = orderPrice - bool_length*2;
			}
			*/
			orderTakeProfit	= 	orderPrice - bool_length*4;
			
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
			
																
			
			Print(my_symbol+" MagicNumberSixteen OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
						+orderPrice+"orderStopless="+orderStopless);	
			

			if(true == accountcheck())
			{
				
				ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberSixteen",MakeMagic(SymPos,MagicNumberSixteen),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSixteen failed with error #",GetLastError());
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
					BuySellPosRecord[SymPos].NextModifyPos[15] = iBars(my_symbol,my_timeperiod)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[15] = iBars(my_symbol,my_timeperiod);				 				 
					Print("OrderSend MagicNumberSixteen  successfully");
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
	double orderpoint;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;
	
	int i,res,ticket;
 
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
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[0]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[0])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[0];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[0])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[0];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberOne00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberOne00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[0]) >-10)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberOne00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberOne00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}									   
				   
	
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
						||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}	
							
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberOne11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberOne11  successfully ");
							 }										 							
							
							Sleep(1000); 								
						}
						
	
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[0])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberOne11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberOne11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[0])>360)
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
								Print("OrderClose MagicNumberOne11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
							if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberOne22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberOne22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						
						BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);						
						if(OrderTakeProfit() > 0.1)
						{
																					 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberOne22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
	
								Print("OrderModify MagicNumberOne22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[0] = BuySellPosRecord[SymPos].TradeTimePos[0]-
								1;
												  
						}   						
	
					}						
					
															
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
			
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
							Print("OrderClose MagicNumberOne00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberOne00 555  successfully");
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
	
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[1]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[1])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[1];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[1])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[1];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberTwo00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberTwo00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
																
						
					}
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[1]) >-10)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwo00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwo00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
				   
				   
			   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
						||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberTwo11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberTwo11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,90分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[1])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwo11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwo11 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[1])>360)
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
								Print("OrderClose MagicNumberTwo11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberTwo11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberTwo11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}											   
					   
										  
						  
						  
						}  																		
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
					   &&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
						
						BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);												
						
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberTwo22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberTwo22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
	
								Print("OrderModify MagicNumberTwo22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[1] = BuySellPosRecord[SymPos].TradeTimePos[1]-
								1;
												  
						}   						
	
					}	
			
					   
	
	  							   
	
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
						
						&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
			
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
							Print("OrderClose MagicNumberTwo00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwo00 555  successfully");
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
	
				   
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[2]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[2])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[2];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[2])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[2];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
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
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberThree00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberThree00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[2]) >-10)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThree00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThree00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
	
					if((-4.5 >BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag )
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[2]) < -1000))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThree00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThree00 666  successfully");
						 }    
						 Sleep(1000); 																								
					}						
																			
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
						||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8))
					{
						
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}	
							
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
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
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberThree11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberThree11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[2])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThree11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThree11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[2])>360)
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
								Print("OrderClose MagicNumberThree11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
							if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberThree22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberThree22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						
						BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
																					 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberThree22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberThree22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[2] = BuySellPosRecord[SymPos].TradeTimePos[2]-
								1;
												  
						}   						
	
					}	
	
	
	
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
					&&(OrderProfit()>200*OrderLots()))	
					{
						orderLots = OrderLots()/2;
						/*三次完成出货*/
						if (orderLots <= MyLotsH*9/64)
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
							Print("OrderClose MagicNumberThree00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThree00 555  with profit successfully");
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
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[3]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[3])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[3];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[3])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[3];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
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
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberFour00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberFour00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[3]) >-10)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFour00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
					
					if((4.5 <BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[3]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFour00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
						||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
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
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFour11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberFour11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[3])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFour11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour11 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[3])>360)
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
								Print("OrderClose MagicNumberFour11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberFour11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberFour11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberFour22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFour22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberFour22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[3] = BuySellPosRecord[SymPos].TradeTimePos[3]-
								1;
												  
						}   						
						/*							
						 vask    = MarketInfo(my_symbol,MODE_ASK);
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFour33  failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour33   successfully");
						 }       
						Sleep(1000); 						
						*/
					}						
						
	
				   
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
					&&(OrderProfit()>200*OrderLots()))							
					{
						orderLots = OrderLots()/2;
						/*三次完成出货*/
						if (orderLots <= MyLotsH*9/64)
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
							Print("OrderClose MagicNumberFour00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour00 555  successfully");
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
	
	int i,res,ticket;
 
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
	
									
					
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[4]) > 0)
					{
						
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[4] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[4])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[4];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[4])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[4];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberFive00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberFive00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[4]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[4]) <=-15)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFive00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFive00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
	
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[4]) >-15)
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFive00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFive00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
					else
					{
						;
					}
									
					if((-0.1 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[4]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFive00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFive00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
															
						
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8) 
						|| (BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak < 0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}								
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFive11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberFive11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[4])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFive11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFive11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[4])>360)
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
								Print("OrderClose MagicNumberFive11 444  successfully");
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
									Print("OrderClose MagicNumberFive11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
						&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(my_symbol,my_timeperiod);							
						if(OrderTakeProfit() > 0.1)
						{
													 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFive22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberFive22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
	
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)
						||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[4] = BuySellPosRecord[SymPos].TradeTimePos[4]-
								1;
												  
						}   						
	
					}	
				
				
	
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberFive00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFive00 555  successfully");
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
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[5]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[5] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[5])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[5];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[5])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[5];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberSix00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberSix00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[5]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[5]) <=-15)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSix00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
			
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[5]) >-15)
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))	
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSix00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
					else
					{
						;
					}
			
					
					if((0.1 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[5]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSix00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
																   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberSix11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberSix11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[5])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSix22 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix22 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[5])>360)
						{   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberSix22 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberSix22 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberSix22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberSix22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberSix22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberSix22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberSix22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak > 0.8))
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[5] = BuySellPosRecord[SymPos].TradeTimePos[5]-
								1;
												  
						}   						
		
					}						
	
			
								
				   
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberSix00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix00 555  successfully");
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
	
					if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])&&0)
					{
						orderLots = OrderLots()/2;
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = 0.01;
							orderLots = NormalizeDouble(orderLots,2);
						}
												
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSeven00 888 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSeven00 888  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[6]) > 0)
					{
						
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[6])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[6];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[6])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[6];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberSeven00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberSeven00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[6]) >-20)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSeven00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSeven00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
	
					if((-4.5 >BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[6]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSeven00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSeven00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
															
						
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}	
							
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberSeven11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberSeven11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[6])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSeven11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSeven11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[6])>360)
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
								Print("OrderClose MagicNumberSeven11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
							if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberSeven22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberSeven22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
																					 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberSeven22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberSeven22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[6] = BuySellPosRecord[SymPos].TradeTimePos[6]-
								1;
												  
						}   						
						/*							
							 vbid    = MarketInfo(my_symbol,MODE_BID);
							 ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberThree33  failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberThree33  successfully");
							 }    
							 Sleep(1000);
						*/
					}	
	  
				
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))		
					&&(OrderProfit()>200*OrderLots()))						
					{
						orderLots = OrderLots()/2;
						/*三次完成出货*/
						if (orderLots <= MyLotsH*9/64)
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
							Print("OrderClose MagicNumberSeven00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSeven00 555  successfully");
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
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])&&0)
					{
						orderLots = OrderLots()/2;
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = 0.01;
							orderLots = NormalizeDouble(orderLots,2);
						}						
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEight00 888 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEight00 888  successfully");
						 }    
						 Sleep(1000); 																		
						
					}	
				   
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[7]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[7] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[7])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[7];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[7])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[7];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberEight00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberEight00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[7]) >-20)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEight00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEight00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
				   
					
					if((4.5 <BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[7]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEight00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEight00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
				   
								   
				   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberEight11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberEight11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[7])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEight11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEight11 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[7])>360)
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
								Print("OrderClose MagicNumberEight11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberEight11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberEight11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberEight22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberEight22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberEight22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[7] = BuySellPosRecord[SymPos].TradeTimePos[7]-
								1;
												  
						}   						
		
					}						
						 
				
				   
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
					&&(OrderProfit()>200*OrderLots()))							
					{
						orderLots = OrderLots()/2;
						/*三次完成出货*/
						if (orderLots <= MyLotsH*9/64)
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
							Print("OrderClose MagicNumberEight00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEight00 555  successfully");
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
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[12]) > 0)
					{
						
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[12] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[12])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[12];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[12])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[12];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberThirteen00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberThirteen00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[12]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[12]) <=-15)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThirteen00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThirteen00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
	
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[12]) >-15)
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThirteen00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThirteen00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
					else
					{
						;
					}
									
					if((-0.1 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[12]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThirteen00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThirteen00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
															
						
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8) || (BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak < 0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}								
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberThirteen11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[12] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberThirteen11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[12])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThirteen11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThirteen11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[12])>360)
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
								Print("OrderClose MagicNumberThirteen11 444  successfully");
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
									Print("OrderClose MagicNumberThirteen11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						BuySellPosRecord[SymPos].TradeTimePos[12] = iBars(my_symbol,my_timeperiod);							
						if(OrderTakeProfit() > 0.1)
						{
													 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberThirteen22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberThirteen22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
	
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[12] = BuySellPosRecord[SymPos].TradeTimePos[12]-
								1;
												  
						}   						
						/*							
							 vbid    = MarketInfo(my_symbol,MODE_BID);
							 ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberThree33  failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberThree33  successfully");
							 }    
							 Sleep(1000);
						*/
					}	
	
					
					
								
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberThirteen00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThirteen00 555  successfully");
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
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[13]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[13] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[13])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[13];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[13])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[13];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberFourteen00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberFourteen00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[13]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[13]) <=-15)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFourteen00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFourteen00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
			
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[13]) >-15)
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))	
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFourteen00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFourteen00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
					else
					{
						;
					}
	
			
					
					if((0.1 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[13]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFourteen00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFourteen00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
				   
								   
				   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFourteen11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberFourteen11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[13])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFourteen22 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFourteen22 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[13])>360)
						{   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberFourteen22 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberFourteen22 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberFourteen22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberFourteen22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[13] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberFourteen22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFourteen22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberFourteen22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak > 0.8))
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[13] = BuySellPosRecord[SymPos].TradeTimePos[13]-
								1;
												  
						}   						
		
					}						
					
					  
				
				   
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberFourteen33 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFourteen33 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}	
					
				   
				}					
			
			}
		}				
	}

	

}	
	
	

void checkbuysellordertypethree()
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
	
	int i,res,ticket;
 
	int    vdigits ;
	
	timeperiodnum = 2;	

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
	
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[8]) > 0)
					{
						
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[8] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[8])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[8];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[8])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[8];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberNine00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberNine00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[8]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[8]) <=-15)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberNine00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberNine00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
	
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[8]) >-15)
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberNine00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberNine00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
					else
					{
						;
					}
									
					if((-0.1 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[8]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberNine00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberNine00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
															
						
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8) 
						|| (BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak < 0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}								
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberNine11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[8] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberNine11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[8])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberNine11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberNine11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[8])>360)
					   {   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberNine11 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberNine11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
							if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberNine11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberNine11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						BuySellPosRecord[SymPos].TradeTimePos[8] = iBars(my_symbol,my_timeperiod);							
						if(OrderTakeProfit() > 0.1)
						{
													 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberNine11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberNine11  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
	
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[8] = BuySellPosRecord[SymPos].TradeTimePos[8]-
								1;
												  
						}   						
	
					}	
	
	
				
					
				
	
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberNine00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberNine00 555  successfully");
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
				   
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[9]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[9] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[9])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[9];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[9])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[9];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberTen00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberTen00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[9]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[9]) <=-15)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTen00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTen00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
			
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[9]) >-15)
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))	
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTen00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTen00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
					else
					{
						;
					}
	
			
					
					if((0.1 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[9]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTen00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTen00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
								   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberTen11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberTen11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[9])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTen22 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTen22 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[9])>360)
						{   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberTen22 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberTen22 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberTen22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberTen22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[9] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberTen22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberTen22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberTen22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak > 0.8))
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[9] = BuySellPosRecord[SymPos].TradeTimePos[9]-
								1;
												  
						}   						
		
					}						
					
	
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberTen00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTen00 555  successfully");
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
					if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])&&0)
					{
						orderLots = OrderLots()/2;
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = 0.01;
							orderLots = NormalizeDouble(orderLots,2);
						}							
						  ticket = OrderClose(OrderTicket(),orderLots,vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEleven00 888 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEleven00 888  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[10]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[10] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[10])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[10];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[10])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[10];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberEleven00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberEleven00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[10]) >-20)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEleven00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEleven00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
					if((-4.5 >BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[10]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEleven00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEleven00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
			
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}	
							
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberEleven11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[10] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberEleven11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[10])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberEleven11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEleven11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[10])>360)
					   {   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberEleven11 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberEleven11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
							if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberEleven22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberEleven22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						
						BuySellPosRecord[SymPos].TradeTimePos[10] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
																					 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberEleven22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberEleven22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[10] = BuySellPosRecord[SymPos].TradeTimePos[10]-
								1;
												  
						}   						
	
					}	
	 
				
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
					&&(OrderProfit()>200*OrderLots()))							
					{
						orderLots = OrderLots()/2;
						/*三次完成出货*/
						if (orderLots <= MyLotsH*9/64)
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
							Print("OrderClose MagicNumberEleven00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberEleven00 555  successfully");
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
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])&&0)
					{
						orderLots = OrderLots()/2;
						orderLots = NormalizeDouble(orderLots,2);
						if (orderLots <= 0.008)
						{
							orderLots = 0.01;
							orderLots = NormalizeDouble(orderLots,2);
						}								
						  ticket = OrderClose(OrderTicket(),orderLots,vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwelve00 888 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwelve00 888  successfully");
						 }    
						 Sleep(1000); 																		
						
					}	
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[11]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[11] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[11])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[11];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[11])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[11];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberTwelve00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberTwelve00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[11]) >-20)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwelve00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwelve00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
				   
					if((4.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[11]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwelve00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwelve00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
								   
				   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberTwelve00 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberTwelve00  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[11])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwelve11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwelve11 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[11])>360)
						{   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberTwelve11 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberTwelve11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberTwelve11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberTwelve11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[11] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberTwelve22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberTwelve22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberTwelve22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[11] = BuySellPosRecord[SymPos].TradeTimePos[11]-
								1;
												  
						}   						
		
					}						
						
	
				   
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
					&&(OrderProfit()>200*OrderLots()))							
					{
						orderLots = OrderLots()/2;
						/*三次完成出货*/
						if (orderLots <= MyLotsH*9/64)
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
							Print("OrderClose MagicNumberTwelve00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwelve00 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}							   
				   
				}			
						
				if(NowMagicNumber == MagicNumberFifteen)
				{
					
	
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						;
				  
				   }
				   else
				   {
					  Print("SymPos error 15");
				   }		
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[14]) > 0)
					{
						
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[14] = iBars(my_symbol,my_timeperiod)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
							{
								MinValue3 = iLow(my_symbol,my_timeperiod,i);
							}
							
						}								
						
	
						orderPrice = vask;				 
						orderStopless =MinValue3- bool_length*3; 
	
	
						if(orderStopless <BuySellPosRecord[SymPos].NextModifyValue1[14])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[14];
						}						
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue2[14])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[14];
						}							
						
						orderTakeProfit	= 	orderPrice  + bool_length*5;
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
						
							
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberFifteen00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberFifteen00  successfully ");
						 }																	
						
						Sleep(1000); 											
						
					}
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[14]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[14]) <=-15)
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFifteen00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFifteen00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
	
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[14]) >-15)
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFifteen00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFifteen00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
					else
					{
						;
					}
									
					if((-0.1 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 > BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[14]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFifteen00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFifteen00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}						
									
															
						
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8) || (BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak < 0.8))
					{
						
	
						
	
						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,my_timeperiod,i))
								{
									MinValue3 = iLow(my_symbol,my_timeperiod,i);
								}
								
							}								
	
							orderPrice = vask;				 
							orderStopless =MinValue3- bool_length*4; 						
							orderTakeProfit	= 	orderPrice  + bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless < OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}							
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
														 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFifteen11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								//BuySellPosRecord[SymPos].TradeTimePos[14] = iBars(my_symbol,my_timeperiod);
								Print("OrderModify MagicNumberFifteen11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
					   if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[14])>400)
					   {
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFifteen11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFifteen11 333  successfully");
						 }    
						 Sleep(1000);  	   
					   }
					   
					   else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[14])>360)
					   {   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberFifteen11 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberFifteen11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   
							if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberFifteen11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberFifteen11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
	
						  
					   }  
					   
								
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))	
					{
						BuySellPosRecord[SymPos].TradeTimePos[14] = iBars(my_symbol,my_timeperiod);							
						if(OrderTakeProfit() > 0.1)
						{
													 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberFifteen22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {     
								
								Print("OrderModify MagicNumberFifteen22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
	
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak < 0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))
					{
						
						//非激进处理
											if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[14] = BuySellPosRecord[SymPos].TradeTimePos[14]-
								1;
												  
						}   						
	
					}	
	
					
					
	
				
					if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberFifteen22 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFifteen22 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}	
										
								   
				}
	
				
				if(NowMagicNumber == MagicNumberSixteen)
				{
				
		   
	
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
	
						;
				   }
				   else
				   {
					  Print("SymPos error 16");
				   }	
	
				   
					if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[15]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[15] = iBars(my_symbol,my_timeperiod)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
							{
								MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
							}					
						}								 
	
	
						orderPrice = vbid;						 
						orderStopless =MaxValue4 + 3*bool_length; 	
	
						if(orderStopless > BuySellPosRecord[SymPos].NextModifyValue1[15])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue1[15];
						}	
						if(orderStopless < BuySellPosRecord[SymPos].NextModifyValue2[15])
						{
							orderStopless = BuySellPosRecord[SymPos].NextModifyValue2[15];
						}	
						
						orderTakeProfit	= 	orderPrice -bool_length*5;
						
	
						
						orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
						orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
						orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	
						res=OrderModify(OrderTicket(),OrderOpenPrice(),
							   orderStopless,orderTakeProfit,0,clrPurple);
							   
						 if(false == res)
						 {
	
							Print("Error in MagicNumberSixteen00 OrderModify. Error code=",GetLastError());									
						 }
						 else
						 {            
							Print("OrderModify MagicNumberSixteen00  successfully ");
						 }										 
														
						
						Sleep(1000); 	
								
								
						
					}
					
					
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[15]) >-50)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[15]) <=-15)
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSixteen00 99999 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSixteen00 99999  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
			
	
					else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[15]) >-15)
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(4.5 < BoolCrossRecord[SymPos][timeperiodnum-1].BoolFlag))	
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSixteen00 000 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSixteen00 000  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
					else
					{
						;
					}
	
			
					
					if((0.1 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
						&&(-4.5 < BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
						&&((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[15]) < -1000))					
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSixteen00 666 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSixteen00 666  successfully");
						 }    
						 Sleep(1000); 																		
						
					}											   
														   
				   
								   
				   
				   
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,my_timeperiod,i))
								{
									MaxValue4 = iHigh(my_symbol,my_timeperiod,i);
								}					
							}								 
	
	
							orderPrice = vbid;						 
							orderStopless =MaxValue4 + 4*bool_length; 							
							orderTakeProfit	= 	orderPrice -bool_length*6;
							
							/*保护胜利果实*/
							if(orderStopless > OrderStopLoss() )
							{
								orderStopless = OrderStopLoss();
							}			
							
							orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
							orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
							orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
	 
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberSixteen11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberSixteen11  successfully ");
							 }										 
															
							
							Sleep(1000); 								
						}
						
	
						/*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
						if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[15])>400)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSixteen22 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSixteen22 333  successfully");
						 }    
						 Sleep(1000);  	   
						}
	
						else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[15])>360)
						{   	   
						  if( OrderProfit()> 0)
						  {
							   ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberSixteen22 444 failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberSixteen22 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   	
							if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberSixteen22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberSixteen22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}							  
						}  						
						
						
					}
					
					
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)&&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))	
					{
												
						BuySellPosRecord[SymPos].TradeTimePos[15] = iBars(my_symbol,my_timeperiod);
						if(OrderTakeProfit() > 0.1)
						{
							
	
							Print(my_symbol+" MagicNumberSixteen22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
											+OrderOpenPrice()+"OrderStopLoss="+OrderStopLoss()
											+"orderTakeProfit="+orderTakeProfit);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   OrderStopLoss(),0,0,clrPurple);
								   
							 if(false == res)
							 {
	
								Print("Error in MagicNumberSixteen22 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								
								Print("OrderModify MagicNumberSixteen22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak > 0.8)||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak > 0.8))
					{
						
						//非激进处理
						if ( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,my_timeperiod))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[15] = BuySellPosRecord[SymPos].TradeTimePos[15]-
								1;
												  
						}   						
		
					}						
					
	
	 
				
				   
					if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
					
					&&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
		
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
							Print("OrderClose MagicNumberSixteen33 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSixteen33 555  successfully");
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
