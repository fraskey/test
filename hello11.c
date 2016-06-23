

//+------------------------------------------------------------------+
//|                                       MutiPeriodAutoTradePro.mq4 |
//|                   Copyright 2005-2016, Copyright. Personal Keep  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2016, Xuejiayong."
#property link        "http://www.mql14.com"

//input double TakeProfit    =50;
double MyLotsH          =0.04;
double MyLotsL          =0.01; 
//input double TrailingStop  =30;

int Move_Av = 3;
int iBoll_B = 60;
//input int iBoll_S = 20;


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

double ma_pre;
double boll_up_B_pre,boll_low_B_pre,boll_mid_B_pre;



int MagicNumberOne = 100;
int MagicNumberTwo = 200;
int MagicNumberThree = 300;
int MagicNumberFour = 400;
int MagicNumberFive = 500;
int MagicNumberSix = 600;
int MagicNumberSeven = 700;
int MagicNumberEight = 800;


string MySymbol[50];
int symbolNum;
double OneD_StrongWeak;
double FourH_StrongWeak;
double ThirtyM_StrongWeak;
double FiveM_StrongWeak;
double FourH_Trend;
double OneD_Trend;
double FiveM_BoolIndex;
double ThirtyM_BoolIndex;

struct stBoolCrossRecord
{
	int CrossFlag[10];//5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨
	int CrossValue;//线穿越时的Close值
	double CrossOneD_StrongWeak[10];
	double CrossFourH_StrongWeak[10];
	double CrossThirtyM_StrongWeak[10];
	double CrossFiveM_StrongWeak[10];
	double CrossFourH_Trend[10];
	double CrossOneD_Trend[10];
	datetime CrossDatetime[10];//线穿越时的时间点
	double CrossBoolLength;//线穿越时的布林带宽度
	double CrossBoolMidLine;//线穿越时的布林中线
	int CrossBoolPos[10];
	
};

struct stBuySellPosRecord
{
	int MagicNumberOnePos;
	int MagicNumberTwoPos;
	int MagicNumberThreePos;
	int MagicNumberFourPos;	
	int MagicNumberFivePos;
	int MagicNumberSixPos;
	int MagicNumberSevenPos;
	int MagicNumberEightPos;
	double TakeProfit[10];
	double RecentMin[10];
	double RecentMax[10];
	int TradeTimePos[10];
	int NextModifyPos[10];
	double NextModifyValue1[10];
	double NextModifyValue2[10];	
};

// 5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨

stBoolCrossRecord BoolCrossRecord[50];

stBuySellPosRecord BuySellPosRecord[50];



struct stTradeRecord
{
	int ticket;
	double stopless;
	int number;
};

stTradeRecord TradeRecord[100];



void initsymbol()
{

	MySymbol[0] = "EURUSD";
	MySymbol[1] = "AUDUSD";
	MySymbol[2] = "USDJPY";         
	MySymbol[3] = "XAUUSD";    //  GOLD   
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
	MySymbol[26] = "WTICOUSD"; 	
	MySymbol[27] = "AUDSGD"; 	
	MySymbol[28] = "CHFZAR"; 	
	MySymbol[29] = "GBPCAD"; 	
	MySymbol[30] = "GBPNZD"; 	
	MySymbol[31] = "GBPZAR"; 	
	MySymbol[32] = "USDSGD"; 	
	MySymbol[33] = "USDZAR"; 	
	MySymbol[34] = "CADSGD"; 	
	MySymbol[35] = "EURSGD"; 
	MySymbol[36] = "EURZAR"; 
	MySymbol[37] = "USDHKD"; 
		
	symbolNum = 38;
	
	
	
}


void initmagicnumber()
{

	MagicNumberOne = 100;
	MagicNumberTwo = 200;
	MagicNumberThree = 300;
	MagicNumberFour = 400;
	MagicNumberFive = 500;
	MagicNumberSix = 600;
	MagicNumberSeven = 700;
	MagicNumberEight = 800;	
}


void initbuysellpos(int SymPos)
{
	int i;
	BuySellPosRecord[SymPos].MagicNumberOnePos = BoolCrossRecord[SymPos].CrossBoolPos[0];
	BuySellPosRecord[SymPos].MagicNumberTwoPos = BoolCrossRecord[SymPos].CrossBoolPos[0];
	BuySellPosRecord[SymPos].MagicNumberThreePos = BoolCrossRecord[SymPos].CrossBoolPos[0];
	BuySellPosRecord[SymPos].MagicNumberFourPos = BoolCrossRecord[SymPos].CrossBoolPos[0];	
	for (i = 0; i < 10; i++)
	{	
		BuySellPosRecord[SymPos].TradeTimePos[i] = iBars(MySymbol[SymPos],0);
		
		/*初始化一个超大值，该值不可能达到*/
		BuySellPosRecord[SymPos].NextModifyPos[i] = iBars(MySymbol[SymPos],0)+10000000;
		BuySellPosRecord[SymPos].NextModifyValue1[i] = 0;
		BuySellPosRecord[SymPos].NextModifyValue2[i] = 0;
				
	}
}



int MakeMagic(int SymPos,int Magic)
{
   int symbolvalue;
   if(MySymbol[SymPos] == "EURUSD")
   {
      symbolvalue = 0;
   }
   else if (MySymbol[SymPos] == "AUDUSD")
   {
      symbolvalue = 1000;
   
   }
   else if (MySymbol[SymPos] == "USDJPY")
   {
      symbolvalue = 2000;
   
   }           
   else if (MySymbol[SymPos] == "XAUUSD")
   {
      symbolvalue = 3000;
   
   }   
   else if (MySymbol[SymPos] == "GBPUSD")
   {
      symbolvalue = 4000;
   
   }      
   else if (MySymbol[SymPos] == "CADCHF")
   {
      symbolvalue = 5000;
   
   }  
   else if (MySymbol[SymPos] == "EURCAD")
   {
      symbolvalue = 6000;
   
   }  
   else if (MySymbol[SymPos] == "GBPAUD")
   {
      symbolvalue = 7000;
   
   }     
   else if (MySymbol[SymPos] == "AUDJPY")
   {
      symbolvalue = 8000;
   
   }  
   else if (MySymbol[SymPos] == "EURJPY")
   {
      symbolvalue = 9000;
   
   }  
   else if (MySymbol[SymPos] == "GBPJPY")
   {
      symbolvalue = 10000;
   
   }  
   else if (MySymbol[SymPos] == "USDCAD")
   {
      symbolvalue = 11000;
   
   }     
   else if (MySymbol[SymPos] == "AUDCAD")
   {
      symbolvalue = 12000;
   
   }   
   else if (MySymbol[SymPos] == "AUDCHF")
   {
      symbolvalue = 13000;
   
   }   
   else if (MySymbol[SymPos] == "CADJPY")
   {
      symbolvalue = 14000;
   
   }   
   else if (MySymbol[SymPos] == "EURAUD")
   {
      symbolvalue = 15000;
   
   }      
   else if (MySymbol[SymPos] == "GBPCHF")
   {
      symbolvalue = 16000;
   
   }   
   else if (MySymbol[SymPos] == "NZDCAD")
   {
      symbolvalue = 17000;
   
   }   
   else if (MySymbol[SymPos] == "NZDUSD")
   {
      symbolvalue = 18000;
   
   }   
   else if (MySymbol[SymPos] == "NZDJPY")
   {
      symbolvalue = 19000;
   
   }  
    else if (MySymbol[SymPos] == "USDCHF")
   {
      symbolvalue = 20000;
   
   }     
  
   else if (MySymbol[SymPos] == "EURGBP")
   {
      symbolvalue = 21000;
   
   }   
   else if (MySymbol[SymPos] == "EURCHF")
   {
      symbolvalue = 22000;
   
   }   
   else if (MySymbol[SymPos] == "AUDNZD")
   {
      symbolvalue = 23000;
   
   }   
   else if (MySymbol[SymPos] == "CHFJPY")
   {
      symbolvalue = 24000;
   
   }   
   else if (MySymbol[SymPos] == "EURNZD")
   {
      symbolvalue = 25000;
   
   }   
   else if (MySymbol[SymPos] == "WTICOUSD")
   {
      symbolvalue = 26000;
   
   }   
   else if (MySymbol[SymPos] == "AUDSGD")
   {
      symbolvalue = 27000;
   
   }   
   else if (MySymbol[SymPos] == "CHFZAR")
   {
      symbolvalue = 28000;
   
   }   
   else if (MySymbol[SymPos] == "GBPCAD")
   {
      symbolvalue = 29000;
   
   }   
   else if (MySymbol[SymPos] == "GBPNZD")
   {
      symbolvalue = 30000;
   
   }   
   else if (MySymbol[SymPos] == "GBPZAR")
   {
      symbolvalue = 31000;
   
   }   
   else if (MySymbol[SymPos] == "USDSGD")
   {
      symbolvalue = 32000;
   
   }   
   else if (MySymbol[SymPos] == "USDZAR")
   {
      symbolvalue = 33000;
   
   }   
   else if (MySymbol[SymPos] == "CADSGD")
   {
      symbolvalue = 34000;
   
   }   
   else if (MySymbol[SymPos] == "EURSGD")
   {
      symbolvalue = 35000;
   
   }   
   else if (MySymbol[SymPos] == "EURZAR")
   {
      symbolvalue = 36000;
   
   }   
   else if (MySymbol[SymPos] == "USDHKD")
   {
      symbolvalue = 37000;
   
   }   
   else
   {
      symbolvalue = -1;
      return symbolvalue;
   
   }
   
   symbolvalue = symbolvalue + Magic;
   return symbolvalue;
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



int  InitcrossValue(int SymPos)
{	
	double myma,myboll_up_B,myboll_low_B,myboll_mid_B;
	double myma_pre,myboll_up_B_pre,myboll_low_B_pre,myboll_mid_B_pre;
	string symbol;

	int crossflag;
	int j ;
	int i;
	
	symbol = MySymbol[SymPos];   
	if(iBars(symbol,0) <500)
	{
		Print(symbol + "Bar Number less than 500");
		return -1;
	}

	for (i = 1; i< 500;i++)
	{
		
		crossflag = 0;     
		myma=iMA(symbol,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,i-1);  
		myboll_up_B = iBands(symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,i-1);   
		myboll_low_B = iBands(symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,i-1);
		myboll_mid_B = (	myboll_up_B +  myboll_low_B)/2;

		myma_pre = iMA(symbol,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,i); 
		myboll_up_B_pre = iBands(symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,i);      
		myboll_low_B_pre = iBands(symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,i);
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
				BoolCrossRecord[SymPos].CrossFlag[j] = crossflag;
				BoolCrossRecord[SymPos].CrossDatetime[j] = TimeCurrent() - i*Period()*60;
				BoolCrossRecord[SymPos].CrossBoolPos[j] = iBars(symbol,0)-i;
				j++;
				if (j >= 9)
				{
					break;
				}
		}

	}
	
	return 0;

}

void InitMA(int SymPos)
{

	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double StrongWeak;
	string my_symbol;
	my_symbol = MySymbol[SymPos];
	
	
	MAThree=iMA(my_symbol,0,3,0,MODE_SMA,PRICE_CLOSE,0); 
	MAThen=iMA(my_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,0);  
	MAThenPre=iMA(my_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,1); 

	
	MAFive=iMA(my_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,0); 
	MAThentyOne=iMA(my_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,0); 
	MASixty=iMA(my_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,0); 
 
	MAFivePre=iMA(my_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,1); 
	MAThentyOnePre=iMA(my_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,1); 
	MASixtyPre=iMA(my_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,1); 
 
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

 
	if (240 == Period() )
	{
		GlobalVariableSet("g_FourH_Trend"+my_symbol,StrongWeak);   	 
	}
	else if (1440 == Period() )
	{
		GlobalVariableSet("g_OneD_Trend"+my_symbol,StrongWeak);   	 
	}
	else
	{
		;   
	}  
		
 
 
 
	StrongWeak =0.5;

	if(MAFive > MAThentyOne)
	{
			
		/*多均线多头向上*/
		if((MASixty < MAThentyOne)&&(MAThentyOne>MAThentyOnePre)&&(MASixty>MASixtyPre))
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
		if((MASixty > MAThentyOne)&&(MAThentyOne<MAThentyOnePre)&&(MASixty<MASixtyPre))
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

	if (1440 == Period() )
	{
		GlobalVariableSet("g_OneD_SW"+my_symbol,StrongWeak);   	 
	}  
 
	else if (240 == Period() )
	{
		GlobalVariableSet("g_FourH_SW"+my_symbol,StrongWeak);   
	 
	}
	else if (30 == Period() )
	{
		GlobalVariableSet("g_ThirtyM_SW"+my_symbol,StrongWeak);   
	 
	}
	else if (5 == Period() )
	{
		GlobalVariableSet("g_FiveM_SW"+my_symbol,StrongWeak);   

	}
	else
	{
	;   
	}  
   			
	
	
	
}

void InitcrossSW(int SymPos)
{

	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double StrongWeak;
	int i,curpos,crosspos;
	string my_symbol;
	my_symbol = MySymbol[SymPos];
	
	if(1==Period())
	{
		curpos = iBars(my_symbol,0);
		
		for (i = 0; i< 9;i++)
		{
			crosspos = BoolCrossRecord[SymPos].CrossBoolPos[i];
			if(crosspos > 100)
			{				
				MAThree=iMA(my_symbol,PERIOD_M5,3,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+0); 
				MAThen=iMA(my_symbol,PERIOD_M5,10,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+0);  
				MAThenPre=iMA(my_symbol,PERIOD_M5,10,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+1); 

				
				MAFive=iMA(my_symbol,PERIOD_M5,5,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+0); 
				MAThentyOne=iMA(my_symbol,PERIOD_M5,21,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+0); 
				MASixty=iMA(my_symbol,PERIOD_M5,60,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+0); 
			 
				MAFivePre=iMA(my_symbol,PERIOD_M5,5,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+1); 
				MAThentyOnePre=iMA(my_symbol,PERIOD_M5,21,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+1); 
				MASixtyPre=iMA(my_symbol,PERIOD_M5,60,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/5+1); 
			 
				StrongWeak =0.5;	
				if(MAFive > MAThentyOne)
				{
						
					/*多均线多头向上*/
					if((MASixty < MAThentyOne)&&(MAThentyOne>MAThentyOnePre)&&(MASixty>MASixtyPre))
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
					if((MASixty > MAThentyOne)&&(MAThentyOne<MAThentyOnePre)&&(MASixty<MASixtyPre))
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
				BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[i] = StrongWeak;
				Print("Test ...BoolCrossRecord["+SymPos+"].CrossFiveM_StrongWeak["+i+"] = "+StrongWeak);				
			}
					
		}
		
		
	}

	else if(5==Period())
	{
		curpos = iBars(my_symbol,0);
		
		for (i = 0; i< 9;i++)
		{
			crosspos = BoolCrossRecord[SymPos].CrossBoolPos[i];
			if(crosspos > 100)
			{				
				MAThree=iMA(my_symbol,PERIOD_M30,3,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+0); 
				MAThen=iMA(my_symbol,PERIOD_M30,10,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+0);  
				MAThenPre=iMA(my_symbol,PERIOD_M30,10,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+1); 

				
				MAFive=iMA(my_symbol,PERIOD_M30,5,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+0); 
				MAThentyOne=iMA(my_symbol,PERIOD_M30,21,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+0); 
				MASixty=iMA(my_symbol,PERIOD_M30,60,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+0); 
			 
				MAFivePre=iMA(my_symbol,PERIOD_M30,5,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+1); 
				MAThentyOnePre=iMA(my_symbol,PERIOD_M30,21,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+1); 
				MASixtyPre=iMA(my_symbol,PERIOD_M30,60,0,MODE_SMA,PRICE_CLOSE,(curpos-crosspos)/6+1); 
			 
				StrongWeak =0.5;	
				if(MAFive > MAThentyOne)
				{
						
					/*多均线多头向上*/
					if((MASixty < MAThentyOne)&&(MAThentyOne>MAThentyOnePre)&&(MASixty>MASixtyPre))
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
					if((MASixty > MAThentyOne)&&(MAThentyOne<MAThentyOnePre)&&(MASixty<MASixtyPre))
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
				BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[i] = StrongWeak;
				Print("Test ...BoolCrossRecord["+SymPos+"].CrossThirtyM_StrongWeak["+i+"] = "+StrongWeak);
			}
					
		}
		
		
	}


	else
	{
		;
	}
	
		
}

void ChangeCrossValue( int mvalue,int SymPos)
{

	int i;
	string symbol;
    symbol = MySymbol[SymPos];

	OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+symbol);	
	FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+symbol);
	ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+symbol);
	FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+symbol);
		
	if (mvalue == BoolCrossRecord[SymPos].CrossFlag[0])
	{
		BoolCrossRecord[SymPos].CrossFlag[0] = mvalue;
		BoolCrossRecord[SymPos].CrossDatetime[0] = TimeCurrent();
		BoolCrossRecord[SymPos].CrossBoolPos[0] = iBars(symbol,0);	
		
		BoolCrossRecord[SymPos].CrossOneD_StrongWeak[0] = OneD_StrongWeak;
		BoolCrossRecord[SymPos].CrossFourH_StrongWeak[0] = FourH_StrongWeak;
		BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[0] = ThirtyM_StrongWeak;
		BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[0] = FiveM_StrongWeak;		
		
		return;
	}
	for (i = 0 ; i <9; i++)
	{
		BoolCrossRecord[SymPos].CrossFlag[9-i] = BoolCrossRecord[SymPos].CrossFlag[8-i];
		BoolCrossRecord[SymPos].CrossDatetime[9-i] = BoolCrossRecord[SymPos].CrossDatetime[8-i];
		BoolCrossRecord[SymPos].CrossBoolPos[9-i] = BoolCrossRecord[SymPos].CrossBoolPos[8-i] ;
		BoolCrossRecord[SymPos].CrossOneD_StrongWeak[9-i] = BoolCrossRecord[SymPos].CrossOneD_StrongWeak[8-i];
		BoolCrossRecord[SymPos].CrossFourH_StrongWeak[9-i] = BoolCrossRecord[SymPos].CrossFourH_StrongWeak[8-i] ;
		BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[9-i] = BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[8-i] ;
		BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[9-i] = BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[8-i];
	}
	
	BoolCrossRecord[SymPos].CrossFlag[0] = mvalue;
	BoolCrossRecord[SymPos].CrossDatetime[0] = TimeCurrent();
	BoolCrossRecord[SymPos].CrossBoolPos[0] = iBars(symbol,0);
	
	BoolCrossRecord[SymPos].CrossOneD_StrongWeak[0] = OneD_StrongWeak;
	BoolCrossRecord[SymPos].CrossFourH_StrongWeak[0] = FourH_StrongWeak;
	BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[0] = ThirtyM_StrongWeak;
	BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[0] = FiveM_StrongWeak;
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

    /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/
	/*OANDA 服务器时间为GMT + 2 ，北京时间为GMT + 8，相差6个小时*/		
    timelocal = TimeCurrent() + 5*60*60;


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
    timelocal = TimeCurrent() + 5*60*60;


	//下午3点前不做趋势单，主要针对1分钟线，非欧美时间趋势不明显
	
	if ((TimeHour(timelocal) >= 16 )&& (TimeHour(timelocal) <22 )) 
	{
		tradetimeflag = true;		
	}	
	/*测试期间全时间段交易*/
	tradetimeflag = true;		
	
	return tradetimeflag;
	
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

bool iddataoptflag = false;
bool iddatarecovflag = false;

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
//	int SymPos;

	/*本周无重大重要数据发布*/
	if(offset <= 0)
	{
		return false;
	}

    /*原则上采用服务器交易时间，为了便于人性化处理，做了一个转换*/
	/*OANDA 服务器时间为GMT + 2 ，北京时间为GMT + 8，相差6个小时*/		
    loctime = TimeCurrent() + 5*60*60;
	
	
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
		if (1 == Period() )
		{   	  




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
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
						{
							if(myMinValue3 > iLow(my_symbol,0,i))
							{
								myMinValue3 = iLow(my_symbol,0,i);
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
							Print(my_symbol+" importantdatatimeoptall Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);	
											
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
							Print(my_symbol+" importantdatatimeoptall close:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);								
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
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
						{
							if(myMaxValue4 < iHigh(my_symbol,0,i))
							{
								myMaxValue4 = iHigh(my_symbol,0,i);
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
							Print(my_symbol+" importantdatatimeoptall Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);	
											
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
							Print(my_symbol+" importantdatatimeoptall close:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);								
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



int init()
{

	int symbolvalue;
	bool flag;
	string MailTitlle ="";
	int i,j;
	
	symbolvalue = 0;
	initsymbol();    
	initmagicnumber();
	


	 for(i = 0; i < symbolNum;i++)
	 {

		if(tradetimecheck(i) ==false)
		{
			Print("Test this is not Eur US trade time");
		}
		else
		{
			
			Print("Test this is  Eur US trade time");
		}
		
		if(opendaycheck(i) ==false)
		{
			Print("Test this is not Open day");
		}
		else
		{		
			Print("Test this is  Open day");
		}
		
 

		if(1440 == Period() )
		{
		  if(GlobalVariableCheck("g_OneD_Trend"+MySymbol[i]) == TRUE)
		  {  
				GlobalVariableSet("g_OneD_Trend"+MySymbol[i],0.5);
			  OneD_Trend = GlobalVariableGet("g_OneD_Trend"+MySymbol[i]);    
			  Print("g_OneD_Trend already exist  = "+MySymbol[i]+DoubleToString(OneD_Trend));        
		  }
		  else
		  {

				GlobalVariableSet("g_OneD_Trend"+MySymbol[i],0.5);
			  if(GlobalVariableCheck("g_OneD_Trend"+MySymbol[i]) == FALSE)
			  {
				Print("init False due to g_OneD_Trend set false!"+MySymbol[i]);  
				return -1;     		      	  
			  }		    
			  else
			  {
				OneD_Trend = GlobalVariableGet("g_OneD_Trend"+MySymbol[i]);  
					Print("init g_OneD_Trend is OK  = "+MySymbol[i]+DoubleToString(OneD_Trend));  		          			      	  
			  }  

		  }
			
			

		  if(GlobalVariableCheck("g_OneD_SW"+MySymbol[i]) == TRUE)
		  {  
				GlobalVariableSet("g_OneD_SW"+MySymbol[i],0.5);
			  OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+MySymbol[i]);    
			  Print("g_OneD_SW already exist  = "+MySymbol[i]+DoubleToString(OneD_StrongWeak));        
		  }
		  else
		  {

				GlobalVariableSet("g_OneD_SW"+MySymbol[i],0.5);
			  if(GlobalVariableCheck("g_OneD_SW"+MySymbol[i]) == FALSE)
			  {
				Print("init False due to g_OneD_SW set false!"+MySymbol[i]);  
				return -1;     		      	  
			  }		    
			  else
			  {
				OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+MySymbol[i]);  
					Print("init g_OneD_SW is OK  = "+MySymbol[i]+DoubleToString(OneD_StrongWeak));  		          			      	  
			  }  

		  }
			
			
			
			


			
		
		}
		else if(240 == Period() )
		{
	 
		  if(GlobalVariableCheck("g_FourH_SW"+MySymbol[i]) == TRUE)
		  {  
				GlobalVariableSet("g_FourH_SW"+MySymbol[i],0.5);
			  FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[i]);    
			  Print("g_FourH_StrongWeak already exist  = "+MySymbol[i]+DoubleToString(FourH_StrongWeak));        
		  }
		  else
		  {

				GlobalVariableSet("g_FourH_SW"+MySymbol[i],0.5);
			  if(GlobalVariableCheck("g_FourH_SW"+MySymbol[i]) == FALSE)
			  {
				Print("init False due to g_FourH_StrongWeak set false!"+MySymbol[i]);  
				return -1;     		      	  
			  }		    
			  else
			  {
				FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[i]);  
					Print("init g_FourH_StrongWeak is OK  = "+MySymbol[i]+DoubleToString(FourH_StrongWeak));  		          			      	  
			  }  

		  }
					
		  if(GlobalVariableCheck("g_FourH_Trend"+MySymbol[i]) == TRUE)
		  {  
				GlobalVariableSet("g_FourH_Trend"+MySymbol[i],0.5);
			  FourH_Trend = GlobalVariableGet("g_FourH_Trend"+MySymbol[i]);    
			  Print("g_FourH_Trend already exist  = "+MySymbol[i]+DoubleToString(FourH_Trend));        
		  }
		  else
		  {

				GlobalVariableSet("g_FourH_Trend"+MySymbol[i],0.5);
			  if(GlobalVariableCheck("g_FourH_Trend"+MySymbol[i]) == FALSE)
			  {
				Print("init False due to g_FourH_Trend set false!"+MySymbol[i]);  
				return -1;     		      	  
			  }		    
			  else
			  {
				FourH_Trend = GlobalVariableGet("g_FourH_Trend"+MySymbol[i]);  
					Print("init g_FourH_Trend is OK  = "+MySymbol[i]+DoubleToString(FourH_Trend));  		          			      	  
			  }  

		  }
			
					
		
		
		
		}
		 else if (30 == Period() )
		 {
		  
		  



			  if(GlobalVariableCheck("g_ThirtyM_SW"+MySymbol[i]) == TRUE)
			  {  
					GlobalVariableSet("g_ThirtyM_SW"+MySymbol[i],0.5);
				  ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[i]);    
				  Print("g_ThirtyM_StrongWeak already exist  = "+MySymbol[i]+DoubleToString(ThirtyM_StrongWeak));        
			  }
			  else
			  {

					GlobalVariableSet("g_ThirtyM_SW"+MySymbol[i],0.5);
				  if(GlobalVariableCheck("g_ThirtyM_SW"+MySymbol[i]) == FALSE)
				  {
					Print("init False due to g_ThirtyM_StrongWeak set false!"+MySymbol[i]);  
					return -1;     		      	  
				  }		    
				  else
				  {
					ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[i]);  
						Print("init g_ThirtyM_StrongWeak is OK  = "+MySymbol[i]+DoubleToString(ThirtyM_StrongWeak));  		          			      	  
				  }  

			  }

			  if(GlobalVariableCheck("g_ThirtyM_BI"+MySymbol[i]) == TRUE)
			  {      
				Print("g_ThirtyM_BoolIndex already exist"+MySymbol[i] );        
			  }
			  else
			  {

					GlobalVariableSet("g_ThirtyM_BI"+MySymbol[i],0);
					  if(GlobalVariableCheck("g_ThirtyM_BI"+MySymbol[i]) == FALSE)
					  {
						Print("init False due to g_ThirtyM_BoolIndex set false!"+MySymbol[i]);  
						return -1;     		      	  
					  }		    
					  else
					  {
							Print("init g_ThirtyM_BoolIndex is OK  "+MySymbol[i]);  		          			      	  
					  }  

			  } 	
			  			  
	

		 
		 }
		 else if (5 == Period() )
		 {

		 


			  if(GlobalVariableCheck("g_FiveM_BI"+MySymbol[i]) == TRUE)
			  {      
				Print("g_FiveM_BoolIndex already exist"+MySymbol[i] );        
			  }
			  else
			  {

					GlobalVariableSet("g_FiveM_BI"+MySymbol[i],0);
					  if(GlobalVariableCheck("g_FiveM_BI"+MySymbol[i]) == FALSE)
					  {
						Print("init False due to g_FiveM_BoolIndex set false!"+MySymbol[i]);  
						return -1;     		      	  
					  }		    
					  else
					  {
							Print("init g_FiveM_BoolIndex is OK  "+MySymbol[i]);  		          			      	  
					  }  

			  } 	
			  


			  if(GlobalVariableCheck("g_FiveM_SW"+MySymbol[i]) == TRUE)
			  {      
				Print("g_FiveM_StrongWeak already exist"+MySymbol[i] );        
			  }
			  else
			  {

					GlobalVariableSet("g_FiveM_SW"+MySymbol[i],0);
				  if(GlobalVariableCheck("g_FiveM_SW"+MySymbol[i]) == FALSE)
				  {
					Print("init False due to g_FiveM_StrongWeak set false!"+MySymbol[i]);  
					return -1;     		      	  
				  }		    
				  else
				  {
						Print("init g_FiveM_StrongWeak is OK  "+MySymbol[i]);  		          			      	  
				  }  

			  } 	
			  
			  
		 
		 }
		 else if (1 == Period() )
		 {
			   
			//MailTitlle = MailTitlle +"1M";
			;
		 
		 }            
		 else
		 {
			MailTitlle = MailTitlle + "Bad Time period，should 1M 5M 30M 4H " + Period() ;
			Print(MailTitlle); 
			return -1;
		 }
		 //MailTitlle = "Init:" + MailTitlle +  +MySymbol[i];
		InitcrossValue(i);  		 
		InitMA(i);
		initbuysellpos(i);	
		InitcrossSW(i);		
	}

	/*test*/
	 for(i = 0; i < symbolNum;i++)
	 {
		Print(MySymbol[i]+"BoolCrossRecord["+i+"]:" + BoolCrossRecord[i].CrossFlag[0]+":" 
		+ BoolCrossRecord[i].CrossFlag[1]+":"+ BoolCrossRecord[i].CrossFlag[2]+":"
		+ BoolCrossRecord[i].CrossFlag[3]+":"+ BoolCrossRecord[i].CrossFlag[4]+":"
		+ BoolCrossRecord[i].CrossFlag[5]+":"+ BoolCrossRecord[i].CrossFlag[6]+":"
		+ BoolCrossRecord[i].CrossFlag[7]+":"+ BoolCrossRecord[i].CrossFlag[8]+":"
		+ BoolCrossRecord[i].CrossFlag[9]);

	}
	 
   	 
      
  	  
	  
	  
      //等待所有周期的全局参数起来
      
      for (i = 0; i < 500; i++)
      {
         flag = true;
         for(j = 0; j < symbolNum;j++)
         {     	
      	   	if((GlobalVariableCheck("g_ThirtyM_SW"+MySymbol[j]) == FALSE)
      	   	||(GlobalVariableCheck("g_FourH_SW"+MySymbol[j]) == FALSE)
      		   ||(GlobalVariableCheck("g_FiveM_SW"+MySymbol[j]) == FALSE)
      		   ||(GlobalVariableCheck("g_ThirtyM_BI"+MySymbol[j]) == FALSE)				   
      		   ||(GlobalVariableCheck("g_FiveM_BI"+MySymbol[j]) == FALSE)			   
			    ||(GlobalVariableCheck("g_FourH_Trend"+MySymbol[j]) == FALSE)
				||(GlobalVariableCheck("g_OneD_Trend"+MySymbol[j]) == FALSE)
				||(GlobalVariableCheck("g_OneD_SW"+MySymbol[j]) == FALSE))
      	   	{
      	   	   flag = false;
      
      	   	}
      	   	else
      	   	{
      	   		break;
      	   	}
      	  }
      	  if (true == flag)
      	  {
      	      break;
      	  }
      	  else
      	  {
   	   		Print(MySymbol[j] + "waiting for globle_Value init,another ten seconds......" ); 	   	
   	   		Sleep(5000);      	  
      	  }
      }
      //无法启动所有全局变量
      if(i ==500)
      {
            Print("init false due to open or set global_virable false"); 
            return -1;   	 
      }
      else
      {
             Print(MailTitlle + " init successful !!! ");   
   //         SendNotification(MailTitlle + " init successful !!! "); 
      
      }
                
      return 0;
}


int deinit()
{
   int i;
	//删除自己的全局变量
	
	
	
	
   for(i = 0; i < symbolNum;i++)
   {   
      
		if(1440 == Period() )
		{
			 if(GlobalVariableCheck("g_OneD_Trend"+MySymbol[i]) == TRUE)
			 {      
				 GlobalVariableDel("g_OneD_Trend"+MySymbol[i]);
		  
			 }     		 

			 if(GlobalVariableCheck("g_OneD_SW"+MySymbol[i]) == TRUE)
			 {      
				 GlobalVariableDel("g_OneD_SW"+MySymbol[i]);
		  
			 }   			 
			 		
		}

	  else if (240 == Period() )
      {     
         if(GlobalVariableCheck("g_FourH_SW"+MySymbol[i]) == TRUE)
         {      
             GlobalVariableDel("g_FourH_SW"+MySymbol[i]);
      
         }      
         if(GlobalVariableCheck("g_FourH_Trend"+MySymbol[i]) == TRUE)
         {      
             GlobalVariableDel("g_FourH_Trend"+MySymbol[i]);
      
         }     		 
		 
      }
      else if (30 == Period() )
      {     
      
         if(GlobalVariableCheck("g_ThirtyM_SW"+MySymbol[i]) == TRUE)
         {      
             GlobalVariableDel("g_ThirtyM_SW"+MySymbol[i]);
      
         }           
		  if(GlobalVariableCheck("g_ThirtyM_BI"+MySymbol[i]) == TRUE)
		  {      
			GlobalVariableDel("g_ThirtyM_BI"+MySymbol[i]);
		  
		  }		             
 
    
      }
      else if (5 == Period() )
      {
      		  
		  if(GlobalVariableCheck("g_FiveM_SW"+MySymbol[i]) == TRUE)
		  {      
			GlobalVariableDel("g_FiveM_SW"+MySymbol[i]);
		  
		  }			
		  
		  if(GlobalVariableCheck("g_FiveM_BI"+MySymbol[i]) == TRUE)
		  {      
			GlobalVariableDel("g_FiveM_BI"+MySymbol[i]);
		  
		  }		      		
						  
      }
      else if (1 == Period() )
      {
		;      
      }    	
	}
   return 0;
}





int ChartEvent = 0;
bool PrintFlag = false;




//int start()
void OnTick(void)
{
	int ticket;
	bool res;
	double ma;
	double boll_up_B,boll_low_B,boll_mid_B,bool_length;
	string mMailTitlle = "";
	int crossflag;
	int i,j;
	int SymPos;
	double orderStopLevel;
	double orderLots ;   
	double orderStopless ;
	double orderTakeProfit;
	double orderPrice;

	double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
	double MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
	double StrongWeak;
	string my_symbol;
	
	double MinValue3 = 100000;
	double MaxValue4=-1;


	
	
	double vbid,vask; 
	int    vdigits ;
	int NowMagicNumber;
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



	//美国非农数据发布时间
	if(importantdatatimeoptall(feinongtime,feilongtimeoffset,1)==true)
	{
		return;
	}

	//联储议息会议结果发布期间
	if(importantdatatimeoptall(yixitime,yixitimeoffset,1)==true)
	{
		return;
	}

	//重大黑天鹅事件期间，原则上关闭所有订单，期间不做任何交易
	if(importantdatatimeoptall(bigeventstime,bigeventstimeoffset,0)==true)
	{
		return;
	}


///////////////////////////////////////////////////////////////////////////////
	//前面的代码在每个周期的每个tick都会执行，基本是一秒执行一次
	if ( ChartEvent != iBars(NULL,0))
	{
	  PrintFlag = false;
	}   

	if ( PrintFlag == true)
	{
	 // return;
	 ;
	 
	}

   //后面的代码只在每个周期开始阶段执行。
//////////////////////////////////////////////////////////////////////////////


	if (1440 == Period() )
	{
	  mMailTitlle = mMailTitlle +"@" + "1D ";   	 
	}
	else if (240 == Period() )
	{
	  mMailTitlle = mMailTitlle +"@" + "4H ";
	  
	}
	else if (30 == Period() )
	{
	  mMailTitlle = mMailTitlle +"!" + "30M ";
	  
	}
	else if (5 == Period() )
	{
	  mMailTitlle = mMailTitlle +"$$!" +"5M ";

	}
	else if (1 == Period() )
	{
	  mMailTitlle = mMailTitlle +"$" +"1M ";

	}  
	else
	{
	  return;
	}

   for(SymPos = 0; SymPos < symbolNum;SymPos++)
   {
		orderStopLevel=0;
		orderLots = 0;   
		orderStopless = 0;
		orderTakeProfit = 0;
		orderPrice = 0;  

		my_symbol =   MySymbol[SymPos];

		ma=iMA(my_symbol,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,1); 
		// ma = Close[0];  
		boll_up_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
		boll_low_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
		boll_mid_B = (boll_up_B + boll_low_B )/2;
		/*point*/
		bool_length =(boll_up_B - boll_low_B )/2;

		ma_pre = iMA(my_symbol,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,2); 
		boll_up_B_pre = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,2);      
		boll_low_B_pre = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,2);
		boll_mid_B_pre = (boll_up_B_pre + boll_low_B_pre )/2;

		crossflag = 0;
		
	
             
   		/*本周期突破高点，观察如小周期未衰竭可追高买入，或者等待回调买入*/
   		/*原则上突破bool线属于偏离价值方向太大，是要回归价值中枢的*/
   		if((ma >boll_up_B) && (ma_pre < boll_up_B_pre ) )
   		{
   		
   			crossflag = 5;		
   			ChangeCrossValue(crossflag,SymPos);
   	    //  Print(mMailTitlle + Symbol()+"::本周期突破高点，除(1M、5M周期bool口收窄且快速突破追高，移动止损），其他情况择机反向做空:"
   	    //  + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
            PrintFlag = true;
   		}
   		
   		/*本周期突破高点后回调，观察如小周期长时间筑顶，寻机卖出*/
   		else if((ma <boll_up_B) && (ma_pre > boll_up_B_pre ) )
   		{
   				crossflag = 4;
   				ChangeCrossValue(crossflag,SymPos);
   	   //   Print(mMailTitlle + Symbol()+"::本周期突破高点后回调，观察小周期如长时间筑顶，寻机做空:"
   	   //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
            PrintFlag = true;
   
   		}
   			
   		
   		/*本周期突破低点，观察如小周期未衰竭可追低卖出，或者等待回调卖出*/
   		else if((ma < boll_low_B) && (ma_pre > boll_low_B_pre ) )
   		{
   		
   			
   				crossflag = -5;
   				ChangeCrossValue(crossflag,SymPos);	
   	   //   Print(mMailTitlle + Symbol() + "::本周期突破低点，除(条件：1M、5M周期bool口收窄且快速突破追低，移动止损），其他情况择机反向做多:"
   	   //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
            PrintFlag = true;
   
   		}
   			
   		/*本周期突破低点后回调，观察如长时间筑底，寻机买入*/
   		else if((ma > boll_low_B) && (ma_pre < boll_low_B_pre ) )
   		{
   				crossflag = -4;	
   				ChangeCrossValue(crossflag,SymPos);		
   	   //   Print(mMailTitlle + Symbol() + "::本周期突破低点后回调，观察如小周期长时间筑底，寻机买入:"
   	   //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
            PrintFlag = true;
   
   		}
   
   
    			
   			/*本周期上穿中线，表明本周期趋势开始发生变化为上升，在下降大趋势下也可能是回调杀入机会*/
   			else if((ma > boll_mid_B) && (ma_pre < boll_mid_B_pre ))
   			{
   			
   					crossflag = 1;				
   					ChangeCrossValue(crossflag,SymPos);				
   		  //    Print(mMailTitlle + Symbol() + "::本周期上穿中线变化为上升，大周期下降大趋势下可能是回调做空机会："
   		  //    + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
             PrintFlag = true;
   
   			}	
   			/*本周期下穿中线，表明趋势开始发生变化，在上升大趋势下也可能是回调杀入机会*/
   			else if( (ma < boll_mid_B) && (ma_pre > boll_mid_B_pre ))
   			{
   					crossflag = -1;								
   					ChangeCrossValue(crossflag,SymPos);				
   		 //     Print(mMailTitlle + Symbol() + "::本周期下穿中线变化为下降，大周期上升大趋势下可能是回调做多机会："
   		 //     + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
             PrintFlag = true;
   			}							
            else
            {
		         crossflag = 0;   
		         PrintFlag = true;         
            }
 

 
			if (5 == Period() )
			{
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vbid    = MarketInfo(my_symbol,MODE_BID);					
				FiveM_BoolIndex = ((vask + vbid)/2 - boll_mid_B)/bool_length;
				GlobalVariableSet("g_FiveM_BI"+my_symbol,FiveM_BoolIndex);   

			}
   
			if (30 == Period() )
			{
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vbid    = MarketInfo(my_symbol,MODE_BID);					
				ThirtyM_BoolIndex = ((vask + vbid)/2 - boll_mid_B)/bool_length;
				GlobalVariableSet("g_ThirtyM_BI"+my_symbol,ThirtyM_BoolIndex);   

			}
    
   
   
        MAThree=iMA(my_symbol,0,3,0,MODE_SMA,PRICE_CLOSE,0); 
        MAThen=iMA(my_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,0);  
        MAThenPre=iMA(my_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,1); 
 
   			
        MAFive=iMA(my_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,0); 
        MAThentyOne=iMA(my_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,0); 
        MASixty=iMA(my_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,0); 
   	 
        MAFivePre=iMA(my_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,1); 
        MAThentyOnePre=iMA(my_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,1); 
        MASixtyPre=iMA(my_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,1); 
   	   	 

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

	 
		if (240 == Period() )
		{
			GlobalVariableSet("g_FourH_Trend"+my_symbol,StrongWeak);   	 
		}
		else if (1440 == Period() )
		{
			GlobalVariableSet("g_OneD_Trend"+my_symbol,StrongWeak);   	 
		}
		else
		{
			;   
		}  
			
	 
	 
		 
		 
		 
     	StrongWeak =0.5;
   
     	if(MAFive > MAThentyOne)
     	{
     	 	  	
     		/*多均线多头向上*/
     		if((MASixty < MAThentyOne)&&(MAThentyOne>MAThentyOnePre)&&(MASixty>MASixtyPre))
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
     		if((MASixty > MAThentyOne)&&(MAThentyOne<MAThentyOnePre)&&(MASixty<MASixtyPre))
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
   
		if (1440 == Period() )
		{
			GlobalVariableSet("g_OneD_SW"+my_symbol,StrongWeak);   	 
		}     
		else if (240 == Period() )
		{
			GlobalVariableSet("g_FourH_SW"+my_symbol,StrongWeak);   

		}
		else if (30 == Period() )
		{
			GlobalVariableSet("g_ThirtyM_SW"+my_symbol,StrongWeak);   

		}
		else if (5 == Period() )
		{
			GlobalVariableSet("g_FiveM_SW"+my_symbol,StrongWeak);   

		}
		else
		{
			;   
		}  

	  
   							
   	/*1M下单买卖点*/	
   	if (1 == Period() )
   	{
      /*获取必要参数*/
		FourH_Trend = GlobalVariableGet("g_FourH_Trend"+my_symbol);  
		OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+my_symbol);
		FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+my_symbol);		
   		ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+my_symbol);
   		FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+my_symbol);
		FiveM_BoolIndex = GlobalVariableGet("g_FiveM_BI"+my_symbol);
		ThirtyM_BoolIndex = GlobalVariableGet("g_ThirtyM_BI"+my_symbol);		

		
		//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
		if((5 == crossflag)&&(5==BoolCrossRecord[SymPos].CrossFlag[0])
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==false)||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==false)))		
   		{
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,0,i))
				{
					MinValue3 = iLow(my_symbol,0,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vask;				 
			orderStopless =MinValue3- bool_length*4; 		
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
					if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree))
					{

						if(orderStopless >OrderStopLoss() )
						{
							
							Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
							+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	


							
							BuySellPosRecord[SymPos].MagicNumberThreePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
							
								
							Print(my_symbol+" MagicNumberThree1 Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+orderPrice+"orderStopless="+orderStopless
											+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberThree1 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberThree1  successfully ");
							 }								
						
						}
					
					}
				}
			  
			}
			Sleep(1000);
   		
   		}
		
		
		
   		//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了找到比较好的入场点，和止损点
		//突破型买点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重多头测试，最关键的一点还是要设置小止损
		//突破型买点止损设置值比较大，实际交易中先不启用该类型买点
   		if((ThirtyM_StrongWeak>0.8)&&(FourH_StrongWeak>0.8)
			&&(OneD_StrongWeak>0.8)
			&&(FiveM_StrongWeak>0.4)
			&&(FiveM_BoolIndex >1)
			&&(opendaycheck(SymPos) == true)
			//&&(tradetimecheck(SymPos) ==true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)))
   		{
   			if((5 == crossflag)&&(5==BoolCrossRecord[SymPos].CrossFlag[0])
			//&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberThreePos)>0)
			&&(4 > BoolCrossRecord[SymPos].CrossFlag[3])
			&&(4 > BoolCrossRecord[SymPos].CrossFlag[4])	
			&&(4 > BoolCrossRecord[SymPos].CrossFlag[5])				
			&&(FiveM_StrongWeak > BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[4])
			&&(FiveM_StrongWeak > BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[5])			
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[3])
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[4])
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[5]))							
   			{
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
				
   				orderLots = NormalizeDouble(MyLotsL,2);
   				orderPrice = vask;				 

				orderStopless =boll_low_B; 		

				BuySellPosRecord[SymPos].NextModifyValue1[0] = orderStopless;
				
				orderStopless =boll_mid_B; 				

				BuySellPosRecord[SymPos].NextModifyValue2[0] = orderStopless;
				
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
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	


				
				BuySellPosRecord[SymPos].MagicNumberOnePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
							
				Print(my_symbol+" MagicNumberOne1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
							+orderPrice+"orderStopless="+orderStopless
							+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);	
									
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberOne1",MakeMagic(SymPos,MagicNumberOne),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberOne1 failed with error #",GetLastError());
				 }
				 else
				 { 
					BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(MySymbol[SymPos],0);						            				 			 
					Print("OrderSend MagicNumberOne1  successfully");
				 }								
				 
   				 Sleep(1000);					
   							
   			}
						
   			else
   			{
   			;
   			}		
   		
   		}
		
		
   		//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
		//转折型买点
   		if((ThirtyM_StrongWeak>0.8)&&(FourH_StrongWeak>0.8)
			//&&(OneD_StrongWeak>0.8)			
			&&(FiveM_StrongWeak<0.8)
			&&(FiveM_BoolIndex <-0.8)			
			&&(opendaycheck(SymPos) == true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)))
   		{
			
			
			/*五分钟多头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
   			if((-4 == crossflag)&&(-4==BoolCrossRecord[SymPos].CrossFlag[0])
			&&(-4 ==BoolCrossRecord[SymPos].CrossFlag[2])
			&&(FiveM_StrongWeak<0.2)		
	
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[1])			
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[2]))				
   			{
				
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
   				{
   					if(MinValue3 > iLow(my_symbol,0,i))
   					{
   						MinValue3 = iLow(my_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vask;				 

				orderStopless =MinValue3- bool_length*2; 	

				BuySellPosRecord[SymPos].NextModifyValue1[2] = orderStopless;
				
				orderStopless =MinValue3- bool_length; 	
				BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;
				
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
																	
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	
				
				BuySellPosRecord[SymPos].MagicNumberThreePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
				Print(my_symbol+" MagicNumberThree3 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
							+orderPrice+"orderStopless="+orderStopless
							+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);	
									
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberThree3",MakeMagic(SymPos,MagicNumberThree),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberThree3 failed with error #",GetLastError());
				 }
				 else
				 {     
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(MySymbol[SymPos],0);				 				 
					Print("OrderSend MagicNumberThree3  successfully");
				 }													
				Sleep(1000);		
				
			}			
						
			
			/*五分钟非多头向下，一分钟bool背驰，空头陷阱*/
   			if((-4 == crossflag)&&(-4==BoolCrossRecord[SymPos].CrossFlag[0])
			&&(FiveM_StrongWeak>0.2)	
	
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[1])				
			&&(0.8>BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[2]))				
   			{
				
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
   				{
   					if(MinValue3 > iLow(my_symbol,0,i))
   					{
   						MinValue3 = iLow(my_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vask;				 

				orderStopless =MinValue3- bool_length*2; 	


				BuySellPosRecord[SymPos].NextModifyValue1[2] = orderStopless;
				
				
				orderStopless =MinValue3- bool_length; 	
				BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;				
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
																	
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	
				
				BuySellPosRecord[SymPos].MagicNumberThreePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
				Print(my_symbol+" MagicNumberThree4 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
							+orderPrice+"orderStopless="+orderStopless
							+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);	
									
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberThree4",MakeMagic(SymPos,MagicNumberThree),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberThree4 failed with error #",GetLastError());
				 }
				 else
				 {            
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(MySymbol[SymPos],0);				 				 
					Print("OrderSend MagicNumberThree4  successfully");
				 }													
				Sleep(1000);	


			}
		}			
		

		
		
   		//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
		if((-5 == crossflag)&&(-5==BoolCrossRecord[SymPos].CrossFlag[0])
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==false)||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==false)))
   		{
			
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,0,i))
				{
					MaxValue4 = iHigh(my_symbol,0,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vbid;						 
			orderStopless =MaxValue4 + bool_length*4; 
			
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
					if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour))
					{

						if(orderStopless < OrderStopLoss() )
						{
							
							Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
							+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[9]);	


							
							BuySellPosRecord[SymPos].MagicNumberFourPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
																			
							Print(my_symbol+" MagicNumberFour1 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberFour1 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {       
								//BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(MySymbol[SymPos],0)				 									 
								Print("OrderModify MagicNumberFour1  successfully ");
							 }								
						
						}
					
					}
				}
			  
			}			
			Sleep(1000);
			
   		}	
		


   		
   		//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了找到比较好的入场点，和止损点
		//突破型卖点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重空头测试，关键是减少止损
		//突破型卖点止损设置值比较大，实际交易中先不启用该类型卖点		
   		if((ThirtyM_StrongWeak<0.2)&&(FourH_StrongWeak<0.2)
			&&(OneD_StrongWeak<0.2)			
			&&(FiveM_StrongWeak<0.6)
			&&(FiveM_BoolIndex <-1)				
			&&(opendaycheck(SymPos) == true)
			//&&(tradetimecheck(SymPos) ==true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)))
   		{
   			if((-5 == crossflag)&&(-5==BoolCrossRecord[SymPos].CrossFlag[0])
			//&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberFourPos)>0)
			&&(-4 < BoolCrossRecord[SymPos].CrossFlag[3])
			&&(-4 < BoolCrossRecord[SymPos].CrossFlag[4])	
			&&(-4 < BoolCrossRecord[SymPos].CrossFlag[5])						
			&&(FiveM_StrongWeak < BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[4])
			&&(FiveM_StrongWeak < BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[5])			
			&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[3])
			&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[4])
			&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[5]))	
		
   			{
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
					
				orderLots = NormalizeDouble(MyLotsL,2);
				orderPrice = vbid;		
				

				
				orderStopless =boll_up_B; 
				BuySellPosRecord[SymPos].NextModifyValue1[1] = orderStopless;
				
				orderStopless =boll_mid_B; 	
				
				BuySellPosRecord[SymPos].NextModifyValue2[1] = orderStopless;				
				
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
				


				
				BuySellPosRecord[SymPos].MagicNumberTwoPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
														
				Print(my_symbol+" MagicNumberTwo1 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
									+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);							
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberTwo1",MakeMagic(SymPos,MagicNumberTwo),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberTwo failed with error #",GetLastError());
				 }
				 else
				 {   
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(MySymbol[SymPos],0);				 					 
					Print("OrderSend MagicNumberTwo1  successfully");
				 }					
				 
				Sleep(1000);
												
   			}
						
   			else
   			{
   			;
   			}		
   		
   		}	
		

		
   		//大周期处于空头市场，本周期在上涨背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
		//转折型卖点
   		if((ThirtyM_StrongWeak<0.2)&&(FourH_StrongWeak<0.2)
			//&&(OneD_StrongWeak<0.2)						

			&&(FiveM_StrongWeak>0.2)
			&&(FiveM_BoolIndex > 0.8)				
			&&(opendaycheck(SymPos) == true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)))
   		{
			

			/*五分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
   			if((4 == crossflag)&&(4==BoolCrossRecord[SymPos].CrossFlag[0])
				&&(4 ==BoolCrossRecord[SymPos].CrossFlag[2])
				&&(FiveM_StrongWeak>0.8)				
				&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[1])					
				&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[2]))
   			{
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
				
				MaxValue4 = -1;
				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
				{
					if(MaxValue4 < iHigh(my_symbol,0,i))
					{
						MaxValue4 = iHigh(my_symbol,0,i);
					}					
				}				
			
				orderLots = NormalizeDouble(MyLotsH,2);
				orderPrice = vbid;		
				
				orderStopless =MaxValue4 + bool_length*2; 
				

				BuySellPosRecord[SymPos].NextModifyValue1[3] = orderStopless;
				
				orderStopless =MaxValue4 + bool_length; 
				
				BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;				
				
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
				



				BuySellPosRecord[SymPos].MagicNumberFourPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
														
						
				Print(my_symbol+" MagicNumberFour3 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
									+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);							
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberFour3",MakeMagic(SymPos,MagicNumberFour),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFour3 failed with error #",GetLastError());
				 }
				 else
				 {   
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(MySymbol[SymPos],0);				 					 
					Print("OrderSend MagicNumberFour3  successfully");
				 }
													 
				 Sleep(1000);				
								
			
   			}			
			
			
			/*五分钟线未明显多头向上，一分钟线背驰就认为是多头陷阱*/
   			if((4 == crossflag)&&(4==BoolCrossRecord[SymPos].CrossFlag[0])
				&&(FiveM_StrongWeak<0.8)					
				&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[1])		
				&&(0.2<BoolCrossRecord[SymPos].CrossFiveM_StrongWeak[2]))
   			{
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
				
				MaxValue4 = -1;
				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
				{
					if(MaxValue4 < iHigh(my_symbol,0,i))
					{
						MaxValue4 = iHigh(my_symbol,0,i);
					}					
				}				
			

				orderLots = NormalizeDouble(MyLotsH,2);
				orderPrice = vbid;						 

				
				orderStopless =MaxValue4 + bool_length*2; 
				

				BuySellPosRecord[SymPos].NextModifyValue1[3] = orderStopless;	

				
				orderStopless =MaxValue4 + bool_length; 
				BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;
				
								
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
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	

				
				BuySellPosRecord[SymPos].MagicNumberFourPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
														
						
				Print(my_symbol+" MagicNumberFour4 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
									+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);							
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberFour4",MakeMagic(SymPos,MagicNumberFour),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFour4 failed with error #",GetLastError());
				 }
				 else
				 {   
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(MySymbol[SymPos],0);				 					 
					Print("OrderSend MagicNumberFour4  successfully");
				 }
													 
				 Sleep(1000);				
								
   			}
						
		}						

   	}
   

   	/*5M下单买卖点*/	
   	if (5 == Period() )
   	{
      /*获取必要参数*/
		FourH_Trend = GlobalVariableGet("g_FourH_Trend"+my_symbol);  
		OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+my_symbol);		
		FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+my_symbol);		
   		ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+my_symbol);
   		FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+my_symbol);
		FiveM_BoolIndex = GlobalVariableGet("g_FiveM_BI"+my_symbol);
		ThirtyM_BoolIndex = GlobalVariableGet("g_ThirtyM_BI"+my_symbol);		

		
		//每次突破bool上轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
		if((5 == crossflag)&&(5==BoolCrossRecord[SymPos].CrossFlag[0])
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==false)||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==false)))		
   		{
			vask    = MarketInfo(my_symbol,MODE_ASK);
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			MinValue3 = 100000;
			for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
			{
				if(MinValue3 > iLow(my_symbol,0,i))
				{
					MinValue3 = iLow(my_symbol,0,i);
				}
				
			}				
			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vask;				 
			orderStopless =MinValue3- bool_length*4; 		
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
					if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree))
					{

						if(orderStopless >OrderStopLoss() )
						{
							
							Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
							+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	


							
							BuySellPosRecord[SymPos].MagicNumberThreePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
							
								
							Print(my_symbol+" MagicNumberThree1 Modify:" + "orderLots=" + orderLots +"orderPrice ="
											+orderPrice+"orderStopless="+orderStopless
											+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);									
							
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberSeven1 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {          			 								 
								Print("OrderModify MagicNumberSeven1  successfully ");
							 }								
						
						}
					
					}
				}
			  
			}
			Sleep(1000);
   		
   		}
		
		
		
   		//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了找到比较好的入场点，和止损点
		//突破型买点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重多头测试，最关键的一点还是要设置小止损
		//突破型买点止损设置值比较大，实际交易中先不启用该类型买点
   		if((FourH_StrongWeak>0.8)&&(OneD_StrongWeak>0.8)
			&&(ThirtyM_StrongWeak>0.4)
			&&(ThirtyM_BoolIndex >1)
			&&(opendaycheck(SymPos) == true)
			//&&(tradetimecheck(SymPos) ==true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)))
   		{
   			if((5 == crossflag)&&(5==BoolCrossRecord[SymPos].CrossFlag[0])
			//&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberThreePos)>0)
			&&(4 > BoolCrossRecord[SymPos].CrossFlag[3])
			&&(4 > BoolCrossRecord[SymPos].CrossFlag[4])	
			&&(4 > BoolCrossRecord[SymPos].CrossFlag[5])				
			&&(ThirtyM_StrongWeak > BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[4])
			&&(ThirtyM_StrongWeak > BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[5])			
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[3])
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[4])
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[5]))							
   			{
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
				
   				orderLots = NormalizeDouble(MyLotsL,2);
   				orderPrice = vask;				 

				orderStopless =boll_low_B; 		

				BuySellPosRecord[SymPos].NextModifyValue1[4] = orderStopless;
				
				orderStopless =boll_mid_B; 				

				BuySellPosRecord[SymPos].NextModifyValue2[4] = orderStopless;
				
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
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	


				
				BuySellPosRecord[SymPos].MagicNumberFivePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
							
				Print(my_symbol+" MagicNumberFive1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
							+orderPrice+"orderStopless="+orderStopless
							+"MagicNumberFivePos="+BuySellPosRecord[SymPos].MagicNumberFivePos);	
									
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberFive1",MakeMagic(SymPos,MagicNumberFive),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberFive1 failed with error #",GetLastError());
				 }
				 else
				 { 
					BuySellPosRecord[SymPos].NextModifyPos[4] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(MySymbol[SymPos],0);						            				 			 
					Print("OrderSend MagicNumberFive1  successfully");
				 }								
				 
   				 Sleep(1000);					
   							
   			}
						
   			else
   			{
   			;
   			}		
   		
   		}
		
		
   		//大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
		//转折型买点
   		if((FourH_StrongWeak>0.8)&&(OneD_StrongWeak>0.8)		
			&&(ThirtyM_StrongWeak<0.8)
			&&(ThirtyM_BoolIndex <-0.8)			
			&&(opendaycheck(SymPos) == true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSeven))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFive))==true)))
   		{
			
			
			/*三十分钟多头向下，一而鼓，再而竭，三而衰由止损保障，空头陷阱*/
   			if((-4 == crossflag)&&(-4==BoolCrossRecord[SymPos].CrossFlag[0])
			&&(-4 ==BoolCrossRecord[SymPos].CrossFlag[2])
			&&(ThirtyM_StrongWeak<0.2)		
	
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[1])			
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[2]))				
   			{
				
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
   				{
   					if(MinValue3 > iLow(my_symbol,0,i))
   					{
   						MinValue3 = iLow(my_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vask;				 

				orderStopless =MinValue3- bool_length*2; 	

				BuySellPosRecord[SymPos].NextModifyValue1[6] = orderStopless;
				
				orderStopless =MinValue3- bool_length; 	
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
																	
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	
				
				BuySellPosRecord[SymPos].MagicNumberSevenPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
				Print(my_symbol+" MagicNumberSeven3 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
							+orderPrice+"orderStopless="+orderStopless
							+"MagicNumberSevenPos="+BuySellPosRecord[SymPos].MagicNumberSevenPos);	
									
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberSeven3",MakeMagic(SymPos,MagicNumberSeven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSeven3 failed with error #",GetLastError());
				 }
				 else
				 {     
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(MySymbol[SymPos],0);				 				 
					Print("OrderSend MagicNumberSeven3  successfully");
				 }													
				Sleep(1000);		
				
			}			
						
			
			/*三十分钟非多头向下，一分钟bool背驰，空头陷阱*/
   			if((-4 == crossflag)&&(-4==BoolCrossRecord[SymPos].CrossFlag[0])
			&&(ThirtyM_StrongWeak>0.2)	
	
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[1])				
			&&(0.8>BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[2]))				
   			{
				
				vask    = MarketInfo(my_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
   				{
   					if(MinValue3 > iLow(my_symbol,0,i))
   					{
   						MinValue3 = iLow(my_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vask;				 

				orderStopless =MinValue3- bool_length*2; 	


				BuySellPosRecord[SymPos].NextModifyValue1[6] = orderStopless;
				
				
				orderStopless =MinValue3- bool_length; 	
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
																	
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	
				
				BuySellPosRecord[SymPos].MagicNumberSevenPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
				Print(my_symbol+" MagicNumberSeven4 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
							+orderPrice+"orderStopless="+orderStopless
							+"MagicNumberSevenPos="+BuySellPosRecord[SymPos].MagicNumberSevenPos);	
									
				ticket = OrderSend(my_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
							   my_symbol+"MagicNumberSeven4",MakeMagic(SymPos,MagicNumberSeven),0,Blue);
	
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSeven4 failed with error #",GetLastError());
				 }
				 else
				 {            
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(MySymbol[SymPos],0);				 				 
					Print("OrderSend MagicNumberSeven4  successfully");
				 }													
				Sleep(1000);	


			}
		}			
		

		
		
   		//每次突破bool下轨的时候重新评估止损和止盈值，原则上止损和止盈值都不要轻易触发。
		if((-5 == crossflag)&&(-5==BoolCrossRecord[SymPos].CrossFlag[0])
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==false)||(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==false)))
   		{
			
			vbid    = MarketInfo(my_symbol,MODE_BID);	
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
			
			MaxValue4 = -1;
			for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
			{
				if(MaxValue4 < iHigh(my_symbol,0,i))
				{
					MaxValue4 = iHigh(my_symbol,0,i);
				}					
			}				
		

			orderLots = NormalizeDouble(MyLotsH,2);
			orderPrice = vbid;						 
			orderStopless =MaxValue4 + bool_length*4; 
			
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
					if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour))
					{

						if(orderStopless < OrderStopLoss() )
						{
							
							Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
							+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
							+ BoolCrossRecord[SymPos].CrossFlag[9]);	


							
							BuySellPosRecord[SymPos].MagicNumberFourPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
																			
							Print(my_symbol+" MagicNumberEight1 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);	
											
							res=OrderModify(OrderTicket(),OrderOpenPrice(),
								   orderStopless,orderTakeProfit,0,clrPurple);
								   
							 if(false == res)
							 {

								Print("Error in MagicNumberEight1 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {       			 									 
								Print("OrderModify MagicNumberEight1  successfully ");
							 }								
						
						}
					
					}
				}
			  
			}			
			Sleep(1000);
			
   		}	
		


   		
   		//大周期处于空头市场，本周期在上涨背驰阶段卖出，趋势交易，目的是为了找到比较好的入场点，和止损点
		//突破型卖点，在欧美交易时间交投活跃期间开突破类型单，防止假突破，采用三重空头测试，关键是减少止损
		//突破型卖点止损设置值比较大，实际交易中先不启用该类型卖点		
   		if((FourH_StrongWeak<0.2)&&(OneD_StrongWeak<0.2)		
			&&(ThirtyM_StrongWeak<0.6)
			&&(ThirtyM_BoolIndex <-1)				
			&&(opendaycheck(SymPos) == true)
			//&&(tradetimecheck(SymPos) ==true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)))
   		{
   			if((-5 == crossflag)&&(-5==BoolCrossRecord[SymPos].CrossFlag[0])
			//&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberFourPos)>0)
			&&(-4 < BoolCrossRecord[SymPos].CrossFlag[3])
			&&(-4 < BoolCrossRecord[SymPos].CrossFlag[4])	
			&&(-4 < BoolCrossRecord[SymPos].CrossFlag[5])						
			&&(ThirtyM_StrongWeak < BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[4])
			&&(ThirtyM_StrongWeak < BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[5])			
			&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[3])
			&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[4])
			&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[5]))	
		
   			{
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
					
				orderLots = NormalizeDouble(MyLotsL,2);
				orderPrice = vbid;		
				

				
				orderStopless =boll_up_B; 
				BuySellPosRecord[SymPos].NextModifyValue1[5] = orderStopless;
				
				orderStopless =boll_mid_B; 	
				
				BuySellPosRecord[SymPos].NextModifyValue2[5] = orderStopless;				
				
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
				


				
				BuySellPosRecord[SymPos].MagicNumberSixPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
														
				Print(my_symbol+" MagicNumberSix1 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
									+"MagicNumberSixPos="+BuySellPosRecord[SymPos].MagicNumberSixPos);							
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberSix1",MakeMagic(SymPos,MagicNumberSix),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberSix1 failed with error #",GetLastError());
				 }
				 else
				 {   
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[5] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(MySymbol[SymPos],0);				 					 
					Print("OrderSend MagicNumberSix1  successfully");
				 }					
				 
				Sleep(1000);
												
   			}
						
   			else
   			{
   			;
   			}		
   		
   		}	
		

		
   		//大周期处于空头市场，本周期在上涨背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
		//转折型卖点
   		if((FourH_StrongWeak<0.2)&&(OneD_StrongWeak<0.2)					
			&&(ThirtyM_StrongWeak>0.2)
			&&(FiveM_BoolIndex > 0.8)				
			&&(opendaycheck(SymPos) == true)
			&&((OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberEight))==true)&&(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberSix))==true)))
   		{
			

			/*三十分钟周期向上时，慎重做空，一而鼓，再而竭，三而衰由止损保障，确保多头陷阱*/
   			if((4 == crossflag)&&(4==BoolCrossRecord[SymPos].CrossFlag[0])
				&&(4 ==BoolCrossRecord[SymPos].CrossFlag[2])
				&&(ThirtyM_StrongWeak>0.8)				
				&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[1])					
				&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[2]))
   			{
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
				
				MaxValue4 = -1;
				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
				{
					if(MaxValue4 < iHigh(my_symbol,0,i))
					{
						MaxValue4 = iHigh(my_symbol,0,i);
					}					
				}				
			
				orderLots = NormalizeDouble(MyLotsH,2);
				orderPrice = vbid;		
				
				orderStopless =MaxValue4 + bool_length*2; 
				

				BuySellPosRecord[SymPos].NextModifyValue1[7] = orderStopless;
				
				orderStopless =MaxValue4 + bool_length; 
				
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
				



				BuySellPosRecord[SymPos].MagicNumberEightPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
														
						
				Print(my_symbol+" MagicNumberEight3 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
									+"MagicNumberEightPos="+BuySellPosRecord[SymPos].MagicNumberEightPos);							
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberEight3",MakeMagic(SymPos,MagicNumberEight),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEight3 failed with error #",GetLastError());
				 }
				 else
				 {   
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[7] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(MySymbol[SymPos],0);				 					 
					Print("OrderSend MagicNumberEight3  successfully");
				 }
													 
				 Sleep(1000);				
								
			
   			}			
			
			
			/*三十分钟线未明显多头向上，一分钟线背驰就认为是多头陷阱*/
   			if((4 == crossflag)&&(4==BoolCrossRecord[SymPos].CrossFlag[0])
				&&(ThirtyM_StrongWeak<0.8)					
				&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[1])		
				&&(0.2<BoolCrossRecord[SymPos].CrossThirtyM_StrongWeak[2]))
   			{
				vbid    = MarketInfo(my_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS);
				
				MaxValue4 = -1;
				for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
				{
					if(MaxValue4 < iHigh(my_symbol,0,i))
					{
						MaxValue4 = iHigh(my_symbol,0,i);
					}					
				}				
			

				orderLots = NormalizeDouble(MyLotsH,2);
				orderPrice = vbid;						 

				
				orderStopless =MaxValue4 + bool_length*2; 
				

				BuySellPosRecord[SymPos].NextModifyValue1[7] = orderStopless;	

				
				orderStopless =MaxValue4 + bool_length; 
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
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	

				
				BuySellPosRecord[SymPos].MagicNumberEightPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
														
						
				Print(my_symbol+" MagicNumberEight4 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
									+"MagicNumberEightPos="+BuySellPosRecord[SymPos].MagicNumberEightPos);							
				 ticket = OrderSend(my_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   my_symbol+"MagicNumberEight4",MakeMagic(SymPos,MagicNumberEight),0,Blue);
		
				 if(ticket <0)
				 {
					Print("OrderSend MagicNumberEight4 failed with error #",GetLastError());
				 }
				 else
				 {   
					/*过20个周期再重新评估一下止损值，可放大止损值*/
					BuySellPosRecord[SymPos].NextModifyPos[7] = iBars(my_symbol,0)+20;					 
					BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(MySymbol[SymPos],0);				 					 
					Print("OrderSend MagicNumberEight4  successfully");
				 }
													 
				 Sleep(1000);				
								
   			}
						
		}						

   	}
   
   
   
   
   } 	

   ////////////////////////////////////////////////////////////////////////////////////////////////
   //订单管理优化，包括移动止损、直接止损、订单时间管理
   //暂时还没有想清楚该如何移动止损优化  
   ////////////////////////////////////////////////////////////////////////////////////////////////
	
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
			boll_up_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
			boll_low_B = iBands(my_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
			bool_length = (boll_up_B - boll_low_B)/2;
			
			vbid    = MarketInfo(my_symbol,MODE_BID);		
			vask    = MarketInfo(my_symbol,MODE_ASK);												
			vdigits = (int)MarketInfo(my_symbol,MODE_DIGITS); 	

			
		  
			if(NowMagicNumber == MagicNumberOne)
			{
			
				if (1 == Period() )
				{   
					if((SymPos>=0)&&(SymPos<symbolNum))
					{
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[SymPos]);
						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);						
					}
					else
					{
						Print("SymPos error 1");
					}


				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[0]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(MySymbol[SymPos],0)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,0,i))
							{
								MinValue3 = iLow(my_symbol,0,i);
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
					
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[0]) >-10)
						&&(4.5 > BoolCrossRecord[SymPos].CrossFlag[0])
						&&0)
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
				   
				   				   

					if((FiveM_StrongWeak<0.8)||(ThirtyM_StrongWeak<0.8))
					{
						

						

						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,0,i))
								{
									MinValue3 = iLow(my_symbol,0,i);
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
								BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberOne11  successfully ");
							 }										 							
							
							Sleep(1000); 								
						}
						

						
					   /*在非多头向上的情况下，一分钟120个周期，理论上应该走完了,90周期开始监控时间控制*/
					   if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[0])>120)
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
					   
					   else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[0])>90)
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
							if(4 == BoolCrossRecord[SymPos].CrossFlag[0])
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
					
					
					if((FiveM_StrongWeak>0.8)&&(ThirtyM_StrongWeak>0.8))	
					{
						
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
								BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberOne22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(FiveM_StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[0] = BuySellPosRecord[SymPos].TradeTimePos[0]-
								1;
						  						  
						}   						
						/*							
							 vbid    = MarketInfo(MySymbol[SymPos],MODE_BID);
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
					
					
					
					
					
				}
			
				else if (5 == Period() )
				{   
				

					if((-1 == BoolCrossRecord[SymPos].CrossFlag[0])
						||(-1 == BoolCrossRecord[SymPos].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
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
			}
			
			if(NowMagicNumber == MagicNumberTwo)
			{
			
				if (1 == Period() )
				{   	   

				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[SymPos]);
						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
				   }
				   else
				   {
					  Print("SymPos error 2");
				   }


				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[1]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(MySymbol[SymPos],0)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,0,i))
							{
								MaxValue4 = iHigh(my_symbol,0,i);
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
					
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[1]) >-10)
						&&(-4.5 < BoolCrossRecord[SymPos].CrossFlag[0])
						&&0)
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
				   
				   
				   
				   
					if((FiveM_StrongWeak>0.2)||(ThirtyM_StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,0,i))
								{
									MaxValue4 = iHigh(my_symbol,0,i);
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
						

						/*在非多头向下的情况下一分钟120个周期，理论上应该走完了,90分钟开始监控时间控制*/
						if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[1])>120)
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

						else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[1])>90)
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

							if(-4 == BoolCrossRecord[SymPos].CrossFlag[0])
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
					
					
					if((FiveM_StrongWeak<0.2)&&(ThirtyM_StrongWeak<0.2))	
					{
												
						
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
								BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberTwo22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(FiveM_StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[1] = BuySellPosRecord[SymPos].TradeTimePos[1]-
								1;
						  						  
						}   						
						/*							
						 vask    = MarketInfo(MySymbol[SymPos],MODE_ASK);
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
			

			

			
								
				}					   

				else if (5 == Period() )
				{   
				
				   
					if((1 == BoolCrossRecord[SymPos].CrossFlag[0])||(1 == BoolCrossRecord[SymPos].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
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
				   				  	  					
			}
				
			if(NowMagicNumber == MagicNumberThree)
			{
				if (1 == Period() )
				{   
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
				  
				   }
				   else
				   {
					  Print("SymPos error 3");
				   }		

				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[2]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(MySymbol[SymPos],0)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,0,i))
							{
								MinValue3 = iLow(my_symbol,0,i);
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
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[2]) >-10)
						&&(-4.5 > BoolCrossRecord[SymPos].CrossFlag[0]))
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
									
									   				   				   		
					if((FiveM_StrongWeak<0.8)||(ThirtyM_StrongWeak<0.8))
					{
						

						

						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,0,i))
								{
									MinValue3 = iLow(my_symbol,0,i);
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

								Print("Error in MagicNumberThree11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberThree11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟120个周期，理论上应该走完了,90周期开始监控时间控制*/
					   if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[2])>120)
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
					   
					   else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[2])>90)
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
							if(4 == BoolCrossRecord[SymPos].CrossFlag[0])
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
					
					
					if((FiveM_StrongWeak>0.8)&&(ThirtyM_StrongWeak>0.8))	
					{
						
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
								BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberThree22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(FiveM_StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[2] = BuySellPosRecord[SymPos].TradeTimePos[2]-
								1;
						  						  
						}   						
						/*							
							 vbid    = MarketInfo(MySymbol[SymPos],MODE_BID);
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

				}			
				
			
				else if (5 == Period() )
				{   
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
				  
				   }
				   else
				   {
					  Print("SymPos error 33");
				   }	
					if(4 == BoolCrossRecord[SymPos].CrossFlag[0])
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberThree00 555 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberThree00 555  successfully");
						 }    
						 Sleep(1000); 																		
						
					}					   
				   
				   
				   
				}
			}  	
			
			if(NowMagicNumber == MagicNumberFour)
			{
			
				if (1 == Period() )
				{   	   

				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
				  
				   }
				   else
				   {
					  Print("SymPos error 4");
				   }	


				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[3]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(MySymbol[SymPos],0)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,0,i))
							{
								MaxValue4 = iHigh(my_symbol,0,i);
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
					
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[3]) >-10)
						&&(4.5 < BoolCrossRecord[SymPos].CrossFlag[0]))
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
				   										   
				   
				   
				   
				   
					if((FiveM_StrongWeak>0.2)||(ThirtyM_StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,0,i))
								{
									MaxValue4 = iHigh(my_symbol,0,i);
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

								Print("Error in MagicNumberFour11 OrderModify. Error code=",GetLastError());									
							 }
							 else
							 {            
								Print("OrderModify MagicNumberFour11  successfully ");
							 }										 
								 							
							
							Sleep(1000); 								
						}
						

						/*在非多头向下的情况下一分钟120个周期，理论上应该走完了,90分钟开始监控时间控制*/
						if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[3])>120)
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

						else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[3])>90)
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
							if(-4 == BoolCrossRecord[SymPos].CrossFlag[0])
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
					
					
					if((FiveM_StrongWeak<0.2)&&(ThirtyM_StrongWeak<0.2))	
					{
												
						
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
								BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberFour22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(FiveM_StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[3] = BuySellPosRecord[SymPos].TradeTimePos[3]-
								1;
						  						  
						}   						
						/*							
						 vask    = MarketInfo(MySymbol[SymPos],MODE_ASK);
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
						
				}  	 			 		
			
				else if (5 == Period() )
				{   
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
				  
				   }
				   else
				   {
					  Print("SymPos error 44");
				   }	
				   
					if(-4 == BoolCrossRecord[SymPos].CrossFlag[0])
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
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
		
		  
			if(NowMagicNumber == MagicNumberFive)
			{
			
				if (5 == Period() )
				{   
					if((SymPos>=0)&&(SymPos<symbolNum))
					{
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[SymPos]);
						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+MySymbol[SymPos]);	
					}
					else
					{
						Print("SymPos error 5");
					}


				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[4]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[4] = iBars(MySymbol[SymPos],0)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,0,i))
							{
								MinValue3 = iLow(my_symbol,0,i);
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
					
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[4]) >-10)
						&&(4.5 > BoolCrossRecord[SymPos].CrossFlag[0])
						&&0)
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
				   
				   				   

					if((ThirtyM_StrongWeak<0.8)||(FourH_StrongWeak<0.8))
					{
						

						

						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,0,i))
								{
									MinValue3 = iLow(my_symbol,0,i);
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
								BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberFive11  successfully ");
							 }										 							
							
							Sleep(1000); 								
						}
						

						
					   /*在非多头向上的情况下，一分钟120个周期，理论上应该走完了,90周期开始监控时间控制*/
					   if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[4])>120)
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
					   
					   else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[4])>90)
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
							if(4 == BoolCrossRecord[SymPos].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberFive22 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberFive22 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}	
						  
					   }  
					   
					   			
					}
					
					
					if((ThirtyM_StrongWeak>0.8)&&(FourH_StrongWeak>0.8))	
					{
						
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
								BuySellPosRecord[SymPos].TradeTimePos[4] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberFive22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(ThirtyM_StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[4] = BuySellPosRecord[SymPos].TradeTimePos[4]-
								1;
						  						  
						}   						

					}						
					
					
					
					
					
				}
			
				else if (30 == Period() )
				{   
				

					if((-1 == BoolCrossRecord[SymPos].CrossFlag[0])
						||(-1 == BoolCrossRecord[SymPos].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
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
			}
			
			if(NowMagicNumber == MagicNumberSix)
			{
			
				if (5 == Period() )
				{   	   

				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[SymPos]);
						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+MySymbol[SymPos]);
				   }
				   else
				   {
					  Print("SymPos error 6");
				   }


				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[5]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[5] = iBars(MySymbol[SymPos],0)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,0,i))
							{
								MaxValue4 = iHigh(my_symbol,0,i);
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
					
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[5]) >-10)
						&&(-4.5 < BoolCrossRecord[SymPos].CrossFlag[0])
						&&0)
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
				   
				   
				   
				   
					if((ThirtyM_StrongWeak>0.2)||(FourH_StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,0,i))
								{
									MaxValue4 = iHigh(my_symbol,0,i);
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
						

						/*在非多头向下的情况下一分钟120个周期，理论上应该走完了,90分钟开始监控时间控制*/
						if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[5])>120)
						{
						  ticket =OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
						  
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberSix11 333 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberSix11 333  successfully");
						 }    
						 Sleep(1000);  	   
						}

						else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[5])>90)
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
								Print("OrderClose MagicNumberSix11 444  successfully");
							 }    
							 Sleep(1000);     	           
						  }   

							if(-4 == BoolCrossRecord[SymPos].CrossFlag[0])
							{
								  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
								 if(ticket <0)
								 {
									Print("OrderClose MagicNumberSix11 000 failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderClose MagicNumberSix11 000  successfully");
								 }    
								 Sleep(1000); 																		
								
							}											   
					   
				   						  
						  
						  
						}  																		
					}
					
					
					if((ThirtyM_StrongWeak<0.2)&&(FourH_StrongWeak<0.2))	
					{
												
						
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
								BuySellPosRecord[SymPos].TradeTimePos[5] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberSix22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(ThirtyM_StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[5] = BuySellPosRecord[SymPos].TradeTimePos[5]-
								1;
						  						  
						}   						
	
					}	
			

			

			
								
				}					   
				   
				else if (30 == Period() )
				{   
				
				   
					if((1 == BoolCrossRecord[SymPos].CrossFlag[0])||(1 == BoolCrossRecord[SymPos].CrossFlag[0]))
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
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
			}
				
			if(NowMagicNumber == MagicNumberSeven)
			{
				if (5 == Period() )
				{   
				
				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[SymPos]);
						OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+MySymbol[SymPos]);
				  
				   }
				   else
				   {
					  Print("SymPos error 7");
				   }		

				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[6]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[6] = iBars(MySymbol[SymPos],0)+10000000;	
						MinValue3 = 100000;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MinValue3 > iLow(my_symbol,0,i))
							{
								MinValue3 = iLow(my_symbol,0,i);
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
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[6]) >-10)
						&&(-4.5 > BoolCrossRecord[SymPos].CrossFlag[0]))
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
									
									   				   				   		
					if((ThirtyM_StrongWeak<0.8)||(FourH_StrongWeak<0.8))
					{
						

						

						if(OrderTakeProfit() < 0.1)
						{
							
							MinValue3 = 100000;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MinValue3 > iLow(my_symbol,0,i))
								{
									MinValue3 = iLow(my_symbol,0,i);
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
								BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberSeven11  successfully ");
							 }										 
						 
							
							
							Sleep(1000); 								
						}
						
						
					   /*在非多头向上的情况下，一分钟120个周期，理论上应该走完了,90周期开始监控时间控制*/
					   if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[6])>120)
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
					   
					   else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[6])>90)
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
							if(4 == BoolCrossRecord[SymPos].CrossFlag[0])
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
					
					
					if((ThirtyM_StrongWeak>0.8)&&(FourH_StrongWeak>0.8))	
					{
						
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
								BuySellPosRecord[SymPos].TradeTimePos[6] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberSeven22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	
					if(ThirtyM_StrongWeak < 0.2)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[6] = BuySellPosRecord[SymPos].TradeTimePos[6]-
								1;
						  						  
						}   						
						/*							
							 vbid    = MarketInfo(MySymbol[SymPos],MODE_BID);
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

				}			
				
			
				else if (30 == Period() )
				{   
				
					if(4 == BoolCrossRecord[SymPos].CrossFlag[0])
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);
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
			}  	
			
			if(NowMagicNumber == MagicNumberEight)
			{
			
				if (5 == Period() )
				{   	   

				   if((SymPos>=0)&&(SymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[SymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[SymPos]);
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[SymPos]);
						OneD_StrongWeak = GlobalVariableGet("g_OneD_SW"+MySymbol[SymPos]);
				  
				   }
				   else
				   {
					  Print("SymPos error 8");
				   }	


				   
					if((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[7]) > 0)
					{
						/*初始化一个超大值，该值不可能达到*/
						BuySellPosRecord[SymPos].NextModifyPos[7] = iBars(MySymbol[SymPos],0)+10000000;	
								
						MaxValue4 = -1;
						for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
						{
							if(MaxValue4 < iHigh(my_symbol,0,i))
							{
								MaxValue4 = iHigh(my_symbol,0,i);
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
					
					else if(((iBars(my_symbol,0)-BuySellPosRecord[SymPos].NextModifyPos[7]) >-10)
						&&(4.5 < BoolCrossRecord[SymPos].CrossFlag[0]))
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
				   										   
				   
				   
				   
				   
					if((ThirtyM_StrongWeak>0.2)||(FourH_StrongWeak>0.2))
					{
						
		
						
						if(OrderTakeProfit() < 0.1)
						{
							
							
							MaxValue4 = -1;
							for (i= 0;i < (iBars(my_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]+5);i++)
							{
								if(MaxValue4 < iHigh(my_symbol,0,i))
								{
									MaxValue4 = iHigh(my_symbol,0,i);
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
						

						/*在非多头向下的情况下一分钟120个周期，理论上应该走完了,90分钟开始监控时间控制*/
						if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[7])>120)
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

						else if((iBars(MySymbol[SymPos],0)-BuySellPosRecord[SymPos].TradeTimePos[7])>90)
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
							if(-4 == BoolCrossRecord[SymPos].CrossFlag[0])
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
					
					
					if((ThirtyM_StrongWeak<0.2)&&(FourH_StrongWeak<0.2))	
					{
												
						
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
								BuySellPosRecord[SymPos].TradeTimePos[7] = iBars(MySymbol[SymPos],0);
								Print("OrderModify MagicNumberEight22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}
					if(ThirtyM_StrongWeak > 0.8)
					{
						
						//非激进处理
						if ( ChartEvent != iBars(NULL,0))
						{
							//后退一个时间周期
							BuySellPosRecord[SymPos].TradeTimePos[7] = BuySellPosRecord[SymPos].TradeTimePos[7]-
								1;
						  						  
						}   						
		
					}						
						
				}  	 			 		
			
				else if (30 == Period() )
				{   
				
				   
					if(-4 == BoolCrossRecord[SymPos].CrossFlag[0])
					{
						  ticket = OrderClose(OrderTicket(),OrderLots(),vask,5,Red);
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
			
			}  
		

		
		}				
	}

	
	/*超过100美金，直接关掉所有盈利订单，落袋为安，完成一次循环*/
	if(orderprofitall() > 100)
	{
		
		ordercloseallwithprofit(2);
		Print("1、This turn Own more than 100 USD,Close all");
	}

	/*三个以上20美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
	if(ordercountwithprofit(20)>= 3)
	{
		
		ordercloseallwithprofit(2);
		Print("2、This turn Own more than three 20 USD,Close all");
	}

	/*两个以上30美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
	if(ordercountwithprofit(30)>= 2)
	{
		
		ordercloseallwithprofit(4);
		Print("3、This turn Own more than two 30 USD,Close all");
	}

	/*一个以上40美金订单，直接关掉所有盈利订单，落袋为安，完成一次循环*/
	if(ordercountwithprofit(40)>= 1)
	{		
		ordercloseallwithprofit(20);
		Print("4、This turn Own more than one 40 USD,Close all");
	}

	/*订单数量4个，且获利超过60美元，落袋为安*/
	if((ordercountwithprofit(2)==4)&&(orderprofitall()>60))
	{
		ordercloseallwithprofit(4);		
		Print("5、This turn Own more than one 60 USD,equal 4 order Close all");		
	}	
	
	/*订单数量3个，且获利超过40美元，落袋为安*/
	if((ordercountwithprofit(2)==3)&&(orderprofitall()>40))
	{
		ordercloseallwithprofit(4);		
		Print("6、This turn Own more than one 40 USD,equal 3 order Close all");		
	}
	
	/*订单数量1\2个，且获利超过30美元，落袋为安*/
	if((ordercountwithprofit(2) <= 2)&&(orderprofitall()>30))
	{
		ordercloseallwithprofit(4);		
		Print("7、This turn Own more than one 30 USD,equal1 or 2 order Close all");		
	}	
	
	
/////////////////////////////////////////////////////////
	

   //OneMSaveOrder();
   PrintFlag = true;
   ChartEvent = iBars(NULL,0);     
   return;
   
}
//+------------------------------------------------------------------+
