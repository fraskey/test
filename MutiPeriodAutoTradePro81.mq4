
//+------------------------------------------------------------------+
//|                                       MutiPeriodAutoTradePro.mq4 |
//|                   Copyright 2005-2016, Copyright. Personal Keep  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2016, Xuejiayong."
#property link        "http://www.mql14.com"

//input double TakeProfit    =50;
double MyLotsH          =0.01;
double MyLotsL          =0.01; 
//input double TrailingStop  =30;

int Move_Av = 3;
int iBoll_B = 60;
//input int iBoll_S = 20;


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



string MySymbol[20];
int symbolNum;

double FourH_StrongWeak;
double ThirtyM_StrongWeak;
double FiveM_StrongWeak;
double FourH_Trend;
double OneD_Trend;

struct stBoolCrossRecord
{
	int CrossFlag[10];//5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨
	int CrossValue;//线穿越时的Close值
	datetime CrossDatetime[10];//线穿越时的时间点
	double CrossBoolLength;//线穿越时的布林带宽度
	double CrossBoolMidLine;//线穿越时的布林中线
	double CrossBoolPos[10];
	
};

struct stBuySellPosRecord
{
	int MagicNumberOnePos;
	int MagicNumberTwoPos;
	int MagicNumberThreePos;
	int MagicNumberFourPos;	
	double TakeProfit[10];
	double RecentMin[10];
	double RecentMax[10];
	
};

// 5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨

stBoolCrossRecord BoolCrossRecord[20];

stBuySellPosRecord BuySellPosRecord[20];



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


	
	symbolNum = 12;

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
	BuySellPosRecord[SymPos].MagicNumberOnePos = BoolCrossRecord[SymPos].CrossBoolPos[0];
	BuySellPosRecord[SymPos].MagicNumberTwoPos = BoolCrossRecord[SymPos].CrossBoolPos[0];
	BuySellPosRecord[SymPos].MagicNumberThreePos = BoolCrossRecord[SymPos].CrossBoolPos[0];
	BuySellPosRecord[SymPos].MagicNumberFourPos = BoolCrossRecord[SymPos].CrossBoolPos[0];	
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
   bool status = true;
	int i;
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

	g_symbol = MySymbol[SymPos];
	
	
	MAThree=iMA(g_symbol,0,3,0,MODE_SMA,PRICE_CLOSE,0); 
	MAThen=iMA(g_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,0);  
	MAThenPre=iMA(g_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,1); 

	
	MAFive=iMA(g_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,0); 
	MAThentyOne=iMA(g_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,0); 
	MASixty=iMA(g_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,0); 
 
	MAFivePre=iMA(g_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,1); 
	MAThentyOnePre=iMA(g_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,1); 
	MASixtyPre=iMA(g_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,1); 
 
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
		GlobalVariableSet("g_FourH_Trend"+g_symbol,StrongWeak);   	 
	}
	else if (1440 == Period() )
	{
		GlobalVariableSet("g_OneD_Trend"+g_symbol,StrongWeak);   	 
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

 
  if (240 == Period() )
  {
	GlobalVariableSet("g_FourH_SW"+g_symbol,StrongWeak);   
	 
  }
  else if (30 == Period() )
  {
	GlobalVariableSet("g_ThirtyM_SW"+g_symbol,StrongWeak);   
	 
  }
   else if (5 == Period() )
  {
	GlobalVariableSet("g_FiveM_SW"+g_symbol,StrongWeak);   
  
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
	if (mvalue == BoolCrossRecord[SymPos].CrossFlag[0])
	{
		return;
	}
	for (i = 0 ; i <9; i++)
	{
		BoolCrossRecord[SymPos].CrossFlag[9-i] = BoolCrossRecord[SymPos].CrossFlag[8-i];
		BoolCrossRecord[SymPos].CrossDatetime[9-i] = BoolCrossRecord[SymPos].CrossDatetime[8-i];
		BoolCrossRecord[SymPos].CrossBoolPos[9-i] = BoolCrossRecord[SymPos].CrossBoolPos[8-i] ;
	}
	
	BoolCrossRecord[SymPos].CrossFlag[0] = mvalue;
	BoolCrossRecord[SymPos].CrossDatetime[0] = TimeCurrent();
	BoolCrossRecord[SymPos].CrossBoolPos[0] = iBars(symbol,0);
	return;
}


bool opendaycheck(int SymPos)
{
//	int i;
	string symbol;
	bool tradetimeflag;
	
   symbol = MySymbol[SymPos];
   tradetimeflag = true;
	if (TimeDayOfWeek(TimeLocal()) == 1)
	{
		if (TimeHour(TimeLocal()) < 10 ) //周一早10点前不做
		{
			tradetimeflag = false;
		}
	}
	if (TimeDayOfWeek(TimeLocal()) == 5)
	{
		if (TimeHour(TimeLocal()) > 23 )  //周五晚11点后不做
		{
			tradetimeflag = false;		
		}
	}	
	return tradetimeflag;
}

bool tradetimecheck(int SymPos)
{
//	int i;
	string symbol;
	bool tradetimeflag ;
	
    symbol = MySymbol[SymPos];
	tradetimeflag = true;
	
	
	if ((TimeHour(TimeLocal()) < 16 )&& (TimeHour(TimeLocal()) >2 )) //下午4点前不做单，主要针对1分钟线，非欧美时间趋势不明显
	{
		tradetimeflag = false;		
	}	
	return tradetimeflag;
	
}


bool iddataoptflag = false;
bool iddatarecovflag = false;

void importantdatatimeoptall(datetime idtime,int offset)
{
	datetime loctime;
//	int SymPos;
	loctime = TimeLocal();
	offset = 30*60;
	
	//时间标记初始化
	if (((idtime-loctime)<2*offset)&&((idtime-loctime)>offset))
	{
		iddataoptflag = false;
		iddatarecovflag = false;
	
	}
	
		
	
	//执行现有订单的止损优化
	if (((idtime-loctime)<offset)&&((idtime-loctime)>0)&&(iddataoptflag == false))
	{
		iddataoptflag = true;
		iddatarecovflag = false;

		
		
	
	}

	
	
	//恢复订单的止损值到之前状态
	if (((loctime-idtime)<2*offset)&&((loctime-idtime)>offset)
	&&(iddatarecovflag == false)&&(iddataoptflag == true))
	{
		iddatarecovflag = true;
		iddataoptflag = false;
		
		
		
	
	
	}	
	
	
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



		 
		 }
		 else if (5 == Period() )
		 {

		 


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
      
      for (i = 0; i < 100; i++)
      {
         flag = true;
         for(j = 0; j < symbolNum;j++)
         {     	
      	   	if((GlobalVariableCheck("g_ThirtyM_SW"+MySymbol[j]) == FALSE)
      	   	||(GlobalVariableCheck("g_FourH_SW"+MySymbol[j]) == FALSE)
      		   ||(GlobalVariableCheck("g_FiveM_SW"+MySymbol[j]) == FALSE)
			    ||(GlobalVariableCheck("g_FourH_Trend"+MySymbol[j]) == FALSE)
				||(GlobalVariableCheck("g_OneD_Trend"+MySymbol[j]) == FALSE))
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
      if(i ==100)
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
             
      
      }
      else if (5 == Period() )
      {
      
      
      if(GlobalVariableCheck("g_FiveM_SW"+MySymbol[i]) == TRUE)
      {      
      GlobalVariableDel("g_FiveM_SW"+MySymbol[i]);
      
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


double MinValue3 = 100000;
double MaxValue4=-1;

string g_symbol;

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


	
	
	double vbid,vask,vclose; 
	int    vdigits ;
	int NowMagicNumber,NowSymPos;
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
   
      g_symbol =   MySymbol[SymPos];
	  
       ma=iMA(g_symbol,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,1); 
      // ma = Close[0];  
      boll_up_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
      boll_low_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
      boll_mid_B = (boll_up_B + boll_low_B )/2;
      /*point*/
      bool_length =(boll_up_B - boll_low_B )/2;
            
      ma_pre = iMA(g_symbol,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,2); 
      boll_up_B_pre = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,2);      
      boll_low_B_pre = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,2);
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
   
        MAThree=iMA(g_symbol,0,3,0,MODE_SMA,PRICE_CLOSE,0); 
        MAThen=iMA(g_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,0);  
        MAThenPre=iMA(g_symbol,0,10,0,MODE_SMA,PRICE_CLOSE,1); 
 
   			
        MAFive=iMA(g_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,0); 
        MAThentyOne=iMA(g_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,0); 
        MASixty=iMA(g_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,0); 
   	 
        MAFivePre=iMA(g_symbol,0,5,0,MODE_SMA,PRICE_CLOSE,1); 
        MAThentyOnePre=iMA(g_symbol,0,21,0,MODE_SMA,PRICE_CLOSE,1); 
        MASixtyPre=iMA(g_symbol,0,60,0,MODE_SMA,PRICE_CLOSE,1); 
   	   	 

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
			GlobalVariableSet("g_FourH_Trend"+g_symbol,StrongWeak);   	 
		}
		else if (1440 == Period() )
		{
			GlobalVariableSet("g_OneD_Trend"+g_symbol,StrongWeak);   	 
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
   
     
      if (240 == Period() )
      {
   		GlobalVariableSet("g_FourH_SW"+g_symbol,StrongWeak);   
         
      }
      else if (30 == Period() )
      {
   		GlobalVariableSet("g_ThirtyM_SW"+g_symbol,StrongWeak);   
         
      }
       else if (5 == Period() )
      {
   		GlobalVariableSet("g_FiveM_SW"+g_symbol,StrongWeak);   
      
      }
      else
      {
   		;   
      }  
   		
   							
   		
   	/*5M寻找买卖点*/	
   	if (5 == Period() )
      {
      /*获取必要参数*/
		OneD_Trend = GlobalVariableGet("g_OneD_Trend"+g_symbol);      
		FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+g_symbol);
		ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+g_symbol);

      
   		//大周期处于多头市场，本周期在下跌背驰阶段买入，目的是为了找到比较好的入场点，和止损点
   		if((FourH_StrongWeak>0.8)&&(ThirtyM_StrongWeak>0.8)&&(OneD_Trend>0.8))
   		{
   			if((-4 == crossflag)&&(-5==BoolCrossRecord[SymPos].CrossFlag[1])
			&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberOnePos)>0))			
   			{

				vask    = MarketInfo(g_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
   				{
   					if(MinValue3 > iLow(g_symbol,0,i))
   					{
   						MinValue3 = iLow(g_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vask;				 
   				orderStopless =MinValue3- bool_length; 		
				/*
   				if((orderPrice - orderStopless)>bool_length)
   				{
   					orderStopless = orderPrice - bool_length;
   				}		
				
				if( orderStopless > MinValue3)
				{
					orderStopless = MinValue3-bool_length*0.5;
				}
				*/		
						
				orderTakeProfit	= 	orderPrice  + bool_length*2;
				
   				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
   				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
				
				BuySellPosRecord[SymPos].TakeProfit[0] = orderTakeProfit;
				BuySellPosRecord[SymPos].RecentMin[0] = MinValue3;
				
				orderTakeProfit = 0;
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	

				
				BuySellPosRecord[SymPos].MagicNumberOnePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
			
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)
				{
					
					Print(g_symbol+" MagicNumberOne1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);		
								
					ticket = OrderSend(g_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,0,
								   g_symbol+"MagicNumberOne1",MakeMagic(SymPos,MagicNumberOne),0,Blue);
		
					 if(ticket <0)
					 {
						Print("OrderSend MagicNumberOne1 failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderSend MagicNumberOne1  successfully");
					 }
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
					    if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberOne))
							{

								if(orderStopless >OrderStopLoss() )
								{
									Print(g_symbol+" MagicNumberOne1 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
													+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);										
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberOne1 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberOne1  successfully ");
									 }								
								
								}
							
							}
						}
					  
					}

				
				}
					 
   				 Sleep(1000);					
   							
   			}
   			else if((1==crossflag)&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[2])||(BoolCrossRecord[SymPos].CrossFlag[2]==5))&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[3])||(BoolCrossRecord[SymPos].CrossFlag[3]==5))&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[4])||(BoolCrossRecord[SymPos].CrossFlag[4]==5))&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[5])||(BoolCrossRecord[SymPos].CrossFlag[5]==5))
			&&((BoolCrossRecord[SymPos].CrossBoolPos[5]-BuySellPosRecord[SymPos].MagicNumberOnePos)>0))			
   			{
				vask    = MarketInfo(g_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
   				{
   					if(MinValue3 > iLow(g_symbol,0,i))
   					{
   						MinValue3 = iLow(g_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vask;				 
   				orderStopless =MinValue3- bool_length; 	
				/*
   				if((orderPrice - orderStopless)>bool_length)
   				{
   					orderStopless = orderPrice - bool_length;
   				}		
				
				if( orderStopless > MinValue3)
				{
					orderStopless = MinValue3-bool_length*0.5;
				}
				*/		
				
				orderTakeProfit	= 	orderPrice +	bool_length*2;
				
   				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
   				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
				
				BuySellPosRecord[SymPos].TakeProfit[0] = orderTakeProfit;
				BuySellPosRecord[SymPos].RecentMin[0] = MinValue3;
				orderTakeProfit = 0;
				
   				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	
				
				BuySellPosRecord[SymPos].MagicNumberOnePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
			
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true)
				{
					
					Print(g_symbol+" MagicNumberOne2 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);	
								
					ticket = OrderSend(g_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,0,
								   g_symbol+"MagicNumberOne2",MakeMagic(SymPos,MagicNumberOne),0,Blue);
		
					 if(ticket <0)
					 {
						Print("OrderSend MagicNumberOne2 failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderSend MagicNumberOne2  successfully");
					 }
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
					    if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberOne))
							{

								if(orderStopless >OrderStopLoss() )
								{
									Print(g_symbol+" MagicNumberOne2 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
													+"MagicNumberOnePos="+BuySellPosRecord[SymPos].MagicNumberOnePos);										
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberOne2 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberOne2  successfully ");
									 }								
								
								}
							
							}
						}
					  
					}

				
				}
								 
   				 Sleep(1000);					
   									
   			}
   			else
   			{
   			;
   			}				
   		}
   
   		
   		//大周期处于空头市场，本周期在上涨背驰阶段买入，，目的是为了找到比较好的入场点，和止损点
   		if((FourH_StrongWeak<0.2)&&(ThirtyM_StrongWeak<0.2)&&(OneD_Trend<0.2))
   		{
   			if((4 == crossflag)&&(5==BoolCrossRecord[SymPos].CrossFlag[1])
			&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberTwoPos)>0))			
   			{
				vbid    = MarketInfo(g_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
				MaxValue4 = -1;
				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
				{
					if(MaxValue4 < iHigh(g_symbol,0,i))
					{
						MaxValue4 = iHigh(g_symbol,0,i);
					}					
				}				
			

				orderLots = NormalizeDouble(MyLotsH,2);
				orderPrice = vbid;						 
				orderStopless =MaxValue4 + bool_length; 
				
				/*
				if(( orderStopless- orderPrice)>bool_length)
				{
					orderStopless = orderPrice + bool_length;
				}							
											
				if( orderStopless < MaxValue4)
				{
					orderStopless = MaxValue4+bool_length*0.5;
				}
				*/								
							
				orderTakeProfit	= 	orderPrice -bool_length*2;
				
   				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
   				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
				
				BuySellPosRecord[SymPos].TakeProfit[1] = orderTakeProfit;
				BuySellPosRecord[SymPos].RecentMax[1] = MaxValue4;
				
				orderTakeProfit = 0;				
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);						



				
				BuySellPosRecord[SymPos].MagicNumberTwoPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				

								
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)
				{
						
					Print(g_symbol+" MagicNumberTwo1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"MagicNumberTwoPos="+BuySellPosRecord[SymPos].MagicNumberTwoPos);							
					  ticket = OrderSend(g_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   g_symbol+"MagicNumberTwo1",MakeMagic(SymPos,MagicNumberTwo),0,Blue);
			
					 if(ticket <0)
					 {
						Print("OrderSend MagicNumberTwo1 failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderSend MagicNumberTwo1  successfully");
					 }
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
						if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwo))
							{

								if(orderStopless < OrderStopLoss() )
								{
									
									Print(g_symbol+" MagicNumberTwo1 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
													+"MagicNumberTwoPos="+BuySellPosRecord[SymPos].MagicNumberTwoPos);										
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberTwo1 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberTwo1  successfully ");
									 }								
								
								}
							
							}
						}
					  
					}

				
				}


				Sleep(1000);
   												
   			}
   			else if((-1==crossflag)&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[2])||(BoolCrossRecord[SymPos].CrossFlag[2]==-5))&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[3])||(BoolCrossRecord[SymPos].CrossFlag[3]==-5))&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[4])||(BoolCrossRecord[SymPos].CrossFlag[4]==-5))&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[5])||(BoolCrossRecord[SymPos].CrossFlag[5]==-5))
			&&((BoolCrossRecord[SymPos].CrossBoolPos[5]-BuySellPosRecord[SymPos].MagicNumberTwoPos)>0))			
   			{
				vbid    = MarketInfo(g_symbol,MODE_BID);	
				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
   				MaxValue4 = -1;
   				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
   				{
   					if(MaxValue4 < iHigh(g_symbol,0,i))
   					{
   						MaxValue4 = iHigh(g_symbol,0,i);
   					}					
   				}				
   			
   
   				orderLots = NormalizeDouble(MyLotsH,2);
   				orderPrice = vbid;						 
   				orderStopless =MaxValue4 + bool_length; 
   				
				/*
   				if(( orderStopless- orderPrice)>bool_length)
   				{
   					orderStopless = orderPrice + bool_length;
   				}
   								
				if( orderStopless < MaxValue4)
				{
					orderStopless = MaxValue4+bool_length*0.5;
				}
				*/								
								
				orderTakeProfit	= 	orderPrice -bool_length*2;
				
   				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
   				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

				BuySellPosRecord[SymPos].TakeProfit[1] = orderTakeProfit;
				BuySellPosRecord[SymPos].RecentMax[1] = MaxValue4;
				orderTakeProfit = 0;				
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	



				
				BuySellPosRecord[SymPos].MagicNumberTwoPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				

								
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true)
				{
					
					Print(g_symbol+" MagicNumberTwo2 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"MagicNumberTwoPos="+BuySellPosRecord[SymPos].MagicNumberTwoPos);																 
					ticket = OrderSend(g_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
								   g_symbol+"MagicNumberTwo2",MakeMagic(SymPos,MagicNumberTwo),0,Blue);

					if(ticket <0)
					{
						Print("OrderSend MagicNumberTwo2 failed with error #",GetLastError());
					}
					else
					{            
						Print("OrderSend MagicNumberTwo2  successfully");
					}
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
					    if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberTwo))
							{

								if(orderStopless < OrderStopLoss() )
								{
									Print(g_symbol+" MagicNumberTwo2 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
													+"MagicNumberTwoPos="+BuySellPosRecord[SymPos].MagicNumberTwoPos);	
								
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberTwo2 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberTwo2  successfully ");
									 }								
								
								}
							
							}
						}
					  
					}

				
				}


   				 Sleep(1000);			
   										
   			}
   			else
   			{
   			;
   			}		
   		
   		}
   
         
      }
   			
   
   	/*1M下单买卖点*/	
   	if (1 == Period() )
   	{
      /*获取必要参数*/
		FourH_Trend = GlobalVariableGet("g_FourH_Trend"+g_symbol);      
   		ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+g_symbol);
   		FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+g_symbol);
         
   		//大周期处于多头市场，本周期在下跌背驰阶段买入，目的是为了找到比较好的入场点，和止损点
   		if((ThirtyM_StrongWeak>0.8)&&(FiveM_StrongWeak>0.8)&&(FourH_Trend>0.8))
   		{
   			if((-4 == crossflag)&&(-5==BoolCrossRecord[SymPos].CrossFlag[1])
			&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberThreePos)>0))			
   			{
				vask    = MarketInfo(g_symbol,MODE_ASK);
				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
   				{
   					if(MinValue3 > iLow(g_symbol,0,i))
   					{
   						MinValue3 = iLow(g_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsL,2);
   				orderPrice = vask;				 
   				orderStopless =MinValue3- bool_length; 		
				/*
   				if((orderPrice - orderStopless)>bool_length)
   				{
   					orderStopless = orderPrice - bool_length;
   				}
				
				if( orderStopless > MinValue3)
				{
					orderStopless = MinValue3-bool_length*0.5;
				}
				*/
				orderTakeProfit	= 	orderPrice + bool_length*2;
				
   				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
   				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

				BuySellPosRecord[SymPos].TakeProfit[2] = orderTakeProfit;
				BuySellPosRecord[SymPos].RecentMin[2] = MinValue3;
				orderTakeProfit = 0;
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	    			 	 		 			 	 		 			 	


				
				BuySellPosRecord[SymPos].MagicNumberThreePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				
	
								
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)
				{
					
					Print(g_symbol+" MagicNumberThree1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
				                +orderPrice+"orderStopless="+orderStopless
								+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);	
										
					ticket = OrderSend(g_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,0,
								   g_symbol+"MagicNumberThree1",MakeMagic(SymPos,MagicNumberThree),0,Blue);
		
					 if(ticket <0)
					 {
						Print("OrderSend MagicNumberThree1 failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderSend MagicNumberThree1  successfully");
					 }
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
					    if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree))
							{

								if(orderStopless >OrderStopLoss() )
								{
									Print(g_symbol+" MagicNumberThree1 Modify:" + "orderLots=" + orderLots +"orderPrice ="
													+orderPrice+"orderStopless="+orderStopless
													+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);									
									
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
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

				
				}


				
				 
   				 Sleep(1000);					
   							
   			}
			
			//一分钟的买点非常不稳定
			/*
   			else if((1==crossflag)&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[2])||(BoolCrossRecord[SymPos].CrossFlag[2]==5))&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[3])||(BoolCrossRecord[SymPos].CrossFlag[3]==5))&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[4])||(BoolCrossRecord[SymPos].CrossFlag[4]==5))&&
   			((4==BoolCrossRecord[SymPos].CrossFlag[5])||(BoolCrossRecord[SymPos].CrossFlag[5]==5))
			&&((BoolCrossRecord[SymPos].CrossBoolPos[5]-BuySellPosRecord[SymPos].MagicNumberThreePos)>0))			
   			{
   				vask    = MarketInfo(g_symbol,MODE_ASK);	
   				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
   				MinValue3 = 100000;
   				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
   				{
   					if(MinValue3 > iLow(g_symbol,0,i))
   					{
   						MinValue3 = iLow(g_symbol,0,i);
   					}
   					
   				}				
   				orderLots = NormalizeDouble(MyLotsL,2);
   				orderPrice = vask;				 
   				orderStopless =MinValue3- bool_length*0.5; 		
   				if((orderPrice - orderStopless)>bool_length)
   				{
   					orderStopless = orderPrice - bool_length;
   				}	
				
				orderTakeProfit	= 	orderPrice + bool_length;
				
   				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
   				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

				BuySellPosRecord[SymPos].TakeProfit[2] = orderTakeProfit;
				orderTakeProfit = 0;
				
				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	



				
				BuySellPosRecord[SymPos].MagicNumberThreePos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
				Print(g_symbol+" MagicNumberThree2 OrderSend/Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"MagicNumberThreePos="+BuySellPosRecord[SymPos].MagicNumberThreePos);				
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true)
				{
															 
					ticket = OrderSend(g_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,0,
								   g_symbol+"MagicNumberThree2",MakeMagic(SymPos,MagicNumberThree),0,Blue);
		
					 if(ticket <0)
					 {
						Print("OrderSend MagicNumberThree2 failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderSend MagicNumberThree2  successfully");
					 }
				 
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
					    if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberThree))
							{

								if(orderStopless >OrderStopLoss() )
								{
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberThree2 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberThree2  successfully ");
									 }								
								
								}
							
							}
						}
					  
					}

				
				}

				 
   				 Sleep(1000);					
   							
   			
   			}
			*/
   			else
   			{
   			;
   			}		
   		
   		}
   
   		
   		//大周期处于空头市场，本周期在上涨背驰阶段买入，，目的是为了找到比较好的入场点，和止损点
   		if((ThirtyM_StrongWeak<0.2)&&(FiveM_StrongWeak<0.2)&&(FourH_Trend<0.2))
   		{
   			if((4 == crossflag)&&(5==BoolCrossRecord[SymPos].CrossFlag[1])
			&&((BoolCrossRecord[SymPos].CrossBoolPos[1]-BuySellPosRecord[SymPos].MagicNumberFourPos)>0))
   			{
   					vbid    = MarketInfo(g_symbol,MODE_BID);	
   					vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
   					
   					MaxValue4 = -1;
   					for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[1]);i++)
   					{
   						if(MaxValue4 < iHigh(g_symbol,0,i))
   						{
   							MaxValue4 = iHigh(g_symbol,0,i);
   						}					
   					}				
   				
   
   					orderLots = NormalizeDouble(MyLotsL,2);
   					orderPrice = vbid;						 
   					orderStopless =MaxValue4 + bool_length; 
   					
					/*
   					if(( orderStopless- orderPrice)>bool_length)
   					{
   						orderStopless = orderPrice + bool_length;
   					}

					if( orderStopless < MaxValue4)
					{
						orderStopless = MaxValue4+bool_length*0.5;
					}
					*/														
						
					orderTakeProfit	= 	orderPrice - bool_length*2;
					
					orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
					orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
					orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
					
					BuySellPosRecord[SymPos].TakeProfit[3] = orderTakeProfit;
					BuySellPosRecord[SymPos].RecentMax[3] = MaxValue4;
					orderTakeProfit = 0;
						
					
					Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
					+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
					+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
					+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
					+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
					+ BoolCrossRecord[SymPos].CrossFlag[9]);	


					
					BuySellPosRecord[SymPos].MagicNumberFourPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];	
															
					if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)
					{
							
						Print(g_symbol+" MagicNumberFour1 OrderSend" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
											+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);							
						 ticket = OrderSend(g_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
										   g_symbol+"MagicNumberFour1",MakeMagic(SymPos,MagicNumberFour),0,Blue);
				
						 if(ticket <0)
						 {
							Print("OrderSend MagicNumberFour1 failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderSend MagicNumberFour1  successfully");
						 }
						 
					}
					else
					{
						for (j = 0; j < OrdersTotal(); j++)
						{
							if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
							{				
								if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour))
								{

									if(orderStopless < OrderStopLoss() )
									{
										Print(g_symbol+" MagicNumberFour1 Modify:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
														+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);	
														
										res=OrderModify(OrderTicket(),OrderOpenPrice(),
											   orderStopless,OrderTakeProfit(),0,clrPurple);
											   
										 if(false == res)
										 {

											Print("Error in MagicNumberFour1 OrderModify. Error code=",GetLastError());									
										 }
										 else
										 {            
											Print("OrderModify MagicNumberFour1  successfully ");
										 }								
									
									}
								
								}
							}
						  
						}

					
					}
					 
   					 Sleep(1000);
   												
   			}
			//一分钟的买点非常不稳定
/*			
   			else if((-1==crossflag)&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[2])||(BoolCrossRecord[SymPos].CrossFlag[2]==-5))&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[3])||(BoolCrossRecord[SymPos].CrossFlag[3]==-5))&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[4])||(BoolCrossRecord[SymPos].CrossFlag[4]==-5))&&
   			((-4==BoolCrossRecord[SymPos].CrossFlag[5])||(BoolCrossRecord[SymPos].CrossFlag[5]==-5))
			&&((BoolCrossRecord[SymPos].CrossBoolPos[5]-BuySellPosRecord[SymPos].MagicNumberFourPos)>0))		
   			{
   				vbid    = MarketInfo(g_symbol,MODE_BID);	
   				vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);				
   				MaxValue4 = -1;
   				for (i= 0;i < (iBars(g_symbol,0) -BoolCrossRecord[SymPos].CrossBoolPos[5]);i++)
   				{
   					if(MaxValue4 < iHigh(g_symbol,0,i))
   					{
   						MaxValue4 = iHigh(g_symbol,0,i);
   					}					
   				}				
   			
   
   				orderLots = NormalizeDouble(MyLotsL,2);
   				orderPrice = vbid;						 
   				orderStopless =MaxValue4 + bool_length*0.5; 
   				
   
   				if(( orderStopless- orderPrice)>bool_length)
   				{
   					orderStopless = orderPrice + bool_length;
   				}
					orderTakeProfit	= 	orderPrice - bool_length;
					
				orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
				orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
				orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);

				BuySellPosRecord[SymPos].TakeProfit[3] = orderTakeProfit;
				orderTakeProfit = 0;				

				Print(MySymbol[SymPos]+"BoolCrossRecord["+SymPos+"]:" + BoolCrossRecord[SymPos].CrossFlag[0]+":" 
				+ BoolCrossRecord[SymPos].CrossFlag[1]+":"+ BoolCrossRecord[SymPos].CrossFlag[2]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[3]+":"+ BoolCrossRecord[SymPos].CrossFlag[4]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[5]+":"+ BoolCrossRecord[SymPos].CrossFlag[6]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[7]+":"+ BoolCrossRecord[SymPos].CrossFlag[8]+":"
				+ BoolCrossRecord[SymPos].CrossFlag[9]);	

				
				BuySellPosRecord[SymPos].MagicNumberFourPos	= BoolCrossRecord[SymPos].CrossBoolPos[0];					
				Print(g_symbol+" MagicNumberFour2 OrderSend/Modify:" + "orderLots=" + orderLots +"orderPrice ="
				                +orderPrice+"orderStopless="+orderStopless
								+"MagicNumberFourPos="+BuySellPosRecord[SymPos].MagicNumberFourPos);	
								
				if(OneMOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true)
				{
															 
					  ticket = OrderSend(g_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
									   g_symbol+"MagicNumberFour2",MakeMagic(SymPos,MagicNumberFour),0,Blue);
			
					 if(ticket <0)
					 {
						Print("OrderSend MagicNumberFour2 failed with error #",GetLastError());
					 }
					 else
					 {            
						Print("OrderSend MagicNumberFour2  successfully");
					 }
					 
			 
					 
				}
				else
				{
					for (j = 0; j < OrdersTotal(); j++)
					{
						if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
						{				
							if(((int)OrderMagicNumber()) == MakeMagic(SymPos,MagicNumberFour))
							{

								if(orderStopless < OrderStopLoss() )
								{
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   orderStopless,OrderTakeProfit(),0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberFour2 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberFour2  successfully ");
									 }								
								
								}
							
							}
						}
					  
					}

				
				}

   				 Sleep(1000);			
   										
   			}
			*/
   			else
   			{
   			;
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
	   
		  NowSymPos = ((int)OrderMagicNumber()) /1000;
		  NowMagicNumber = OrderMagicNumber() - NowSymPos *1000;
		  
		  if((NowSymPos<0)||(NowSymPos>=symbolNum))
		  {
			 Print("NowSymPos error 0");
		  }

			if(NowMagicNumber == MagicNumberOne)
			{
			
				if (5 == Period() )
				{   
				   if((NowSymPos>=0)&&(NowSymPos<symbolNum))
				   {
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[NowSymPos]);
						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[NowSymPos]);
				   }
				   else
				   {
					  Print("NowSymPos error 1");
				   }
					/*
					if(FourH_StrongWeak<0.8)
					{
						vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
						if(ticket <0)
						{
							Print("OrderClose MagicNumberOne  FourH_StrongWeak failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberOne  FourH_StrongWeak successfully");
						}    
						Sleep(1000); 				
										
					}	
					*/
					if((ThirtyM_StrongWeak<0.8)||(FourH_StrongWeak<0.8))
					{

						g_symbol =   MySymbol[NowSymPos];
						boll_up_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
						vclose  = iClose(g_symbol,0,1);
						
						if((vclose <BuySellPosRecord[NowSymPos].RecentMin[0])&&(-5==BoolCrossRecord[NowSymPos].CrossFlag[0]))
						{
							 vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
							 ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberOne  failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberOne  successfully");
							 }    
							 Sleep(1000);  	
							 
							if(OneMOrderCloseStatus(MakeMagic(NowSymPos,MagicNumberFive))==true)
							{
							    //OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
								MaxValue4 = -1;
								for (j= 0;j < (iBars(g_symbol,0) -BoolCrossRecord[NowSymPos].CrossBoolPos[1]);j++)
								{
									if(MaxValue4 < iHigh(g_symbol,0,j))
									{
										MaxValue4 = iHigh(g_symbol,0,j);
									}					
								}				
							
								vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
								orderLots = NormalizeDouble(MyLotsL,2);
								orderPrice = vbid;						 
								orderStopless =MaxValue4 + bool_length*0.5; 
								
								/*
								if(( orderStopless- orderPrice)>bool_length)
								{
									orderStopless = orderPrice + bool_length;
								}
								
								if( orderStopless < MaxValue4)
								{
									orderStopless = MaxValue4+bool_length*0.5;
								}
								*/
								orderTakeProfit	= 	orderPrice - 2*bool_length;
								
								orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
								orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
								
								BuySellPosRecord[NowSymPos].TakeProfit[4] = orderTakeProfit;
								BuySellPosRecord[NowSymPos].RecentMax[4] = MaxValue4;									
								
								Print(MySymbol[NowSymPos]+"BoolCrossRecord["+NowSymPos+"]:" + BoolCrossRecord[NowSymPos].CrossFlag[0]+":" 
								+ BoolCrossRecord[NowSymPos].CrossFlag[1]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[2]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[3]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[4]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[5]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[6]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[7]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[8]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[9]);	
								
								Print(g_symbol+" MagicNumberFive OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
								                +orderPrice+"orderStopless="+orderStopless
												+"orderTakeProfit="+orderTakeProfit);								
											
								  ticket = OrderSend(g_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
												   g_symbol+"MagicNumberFive",MakeMagic(NowSymPos,MagicNumberFive),0,Blue);
						
								 if(ticket <0)
								 {
									Print("OrderSend MagicNumberFive failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderSend MagicNumberFive  successfully");
								 }								
								Sleep(1000); 
							}
							OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
							
						}
						else
						{
							if(OrderTakeProfit() < 0.1)
							{
								
								vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS); 
								orderTakeProfit = BuySellPosRecord[NowSymPos].TakeProfit[0];
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
								
								vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
								
								if (vbid >= orderTakeProfit)
								{
									 ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
									 if(ticket <0)
									 {
										Print("OrderClose MagicNumberOne11  failed with error #",GetLastError());
									 }
									 else
									 {            
										Print("OrderClose MagicNumberOne11  successfully");
									 }    									
											
								}
								else
								{
									
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   OrderStopLoss(),orderTakeProfit,0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberOne11 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberOne11  successfully ");
									 }										
								}
								
								
								Sleep(1000); 								
							}
							
							
						}
			
					}
					
					if((FourH_StrongWeak>0.8)&&(ThirtyM_StrongWeak>0.8))	
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
								Print("OrderModify MagicNumberOne22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}						
								
				}		
			
			}
			
			if(NowMagicNumber == MagicNumberTwo)
			{
			
				if (5 == Period() )
				{   	   

				   if((NowSymPos>=0)&&(NowSymPos<symbolNum))
				   {
						FourH_StrongWeak = GlobalVariableGet("g_FourH_SW"+MySymbol[NowSymPos]);
						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[NowSymPos]);
				   }
				   else
				   {
					  Print("NowSymPos error 2");
				   }
				//////////////////////////////////////////   
				/*
					if(FourH_StrongWeak>0.2)
					{
						vask    = MarketInfo(MySymbol[NowSymPos],MODE_ASK);
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberTwo FourH_StrongWeak failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberTwo FourH_StrongWeak  successfully");
						 }       
						Sleep(1000); 	 
										
										
					}			
				*/					
					if((ThirtyM_StrongWeak>0.2)||(FourH_StrongWeak>0.2))
					{
						
						g_symbol =   MySymbol[NowSymPos];
						boll_up_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						vask    = MarketInfo(g_symbol,MODE_ASK);
						vclose  = iClose(g_symbol,0,1);
						
						if((vclose > BuySellPosRecord[NowSymPos].RecentMax[1])&&(5==BoolCrossRecord[NowSymPos].CrossFlag[0]))
						{
							vask    = MarketInfo(MySymbol[NowSymPos],MODE_ASK);
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberTwo  failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberTwo   successfully");
							 }       
							Sleep(1000); 
							
							if(OneMOrderCloseStatus(MakeMagic(NowSymPos,MagicNumberSix))==true)
							{
								
								vask    = MarketInfo(g_symbol,MODE_ASK);
								vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
								MinValue3 = 100000;
								for (j= 0;j < (iBars(g_symbol,0) -BoolCrossRecord[NowSymPos].CrossBoolPos[1]);j++)
								{
									if(MinValue3 > iLow(g_symbol,0,j))
									{
										MinValue3 = iLow(g_symbol,0,j);
									}
									
								}				
								orderLots = NormalizeDouble(MyLotsH,2);
								orderPrice = vask;				 
								orderStopless =MinValue3- bool_length*0.5; 		
								/*
								if((orderPrice - orderStopless)>bool_length)
								{
									orderStopless = orderPrice - bool_length;
								}		

								if( orderStopless > MinValue3)
								{
									orderStopless = MinValue3-bool_length*0.5;
								}
								*/								
								orderTakeProfit	= 	orderPrice  + bool_length*2;
								
								orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
								orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);		


								Print(MySymbol[NowSymPos]+"BoolCrossRecord["+NowSymPos+"]:" + BoolCrossRecord[NowSymPos].CrossFlag[0]+":" 
								+ BoolCrossRecord[NowSymPos].CrossFlag[1]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[2]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[3]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[4]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[5]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[6]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[7]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[8]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[9]);	
								
								Print(g_symbol+" MagicNumberSix OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
								                +orderPrice+"orderStopless="+orderStopless
												+"orderTakeProfit="+orderTakeProfit);								
												
								ticket = OrderSend(g_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
											   g_symbol+"MagicNumberSix",MakeMagic(NowSymPos,MagicNumberSix),0,Blue);
					
								 if(ticket <0)
								 {
									Print("OrderSend MagicNumberSix failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderSend MagicNumberSix  successfully");
								 }								
								
							
								Sleep(1000); 
							}
							OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
							
						}
						else
						{
							if(OrderTakeProfit() < 0.1)
							{
								vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);								 
								orderTakeProfit = BuySellPosRecord[NowSymPos].TakeProfit[1];
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
								vask    = MarketInfo(MySymbol[NowSymPos],MODE_ASK);
								 
								if(vask <= orderTakeProfit) 
								{
									 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
									 if(ticket <0)
									 {
										Print("OrderClose MagicNumberTwo11  failed with error #",GetLastError());
									 }
									 else
									 {            
										Print("OrderClose MagicNumberTwo11   successfully");
									 }    									
									
								}
								else
								{
									
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   OrderStopLoss(),orderTakeProfit,0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberTwo11 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberTwo11  successfully ");
									 }										
									
								}
								
								
								Sleep(1000); 								
							}
							
							
						}
			
					}
					
					if((FourH_StrongWeak<0.2)&&(ThirtyM_StrongWeak<0.2))	
					{
						
						if(OrderTakeProfit() > 0.1)
						{
														 							 
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
								
				}					   
				   
				   				  	  		
			
			}
				
			if(NowMagicNumber == MagicNumberThree)
			{
				if (1 == Period() )
				{   
				
				   if((NowSymPos>=0)&&(NowSymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[NowSymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[NowSymPos]);
				  
				   }
				   else
				   {
					  Print("NowSymPos error 3");
				   }		

/////////////////////////////////////////
				/*
					if(ThirtyM_StrongWeak<0.8)
					{
						vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
						ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
						if(ticket <0)
						{
							Print("OrderClose MagicNumberThree  ThirtyM_StrongWeak failed with error #",GetLastError());
						}
						else
						{            
							Print("OrderClose MagicNumberThree  ThirtyM_StrongWeak successfully");
						}    
						Sleep(1000); 				
										
					}		
				*/
					if((FiveM_StrongWeak<0.8)||(ThirtyM_StrongWeak<0.8))
					{
						
						g_symbol =   MySymbol[NowSymPos];
						boll_up_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
						vclose  = iClose(g_symbol,0,1);
						if((vclose <BuySellPosRecord[NowSymPos].RecentMin[2])&&(-5==BoolCrossRecord[NowSymPos].CrossFlag[0]))
						{
							 vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
							 ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberThree  failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberThree  successfully");
							 }    
							 Sleep(1000);  	
							 
							if(OneMOrderCloseStatus(MakeMagic(NowSymPos,MagicNumberSeven))==true)
							{
							    //OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
								MaxValue4 = -1;
								for (j= 0;j < (iBars(g_symbol,0) -BoolCrossRecord[NowSymPos].CrossBoolPos[1]);j++)
								{
									if(MaxValue4 < iHigh(g_symbol,0,j))
									{
										MaxValue4 = iHigh(g_symbol,0,j);
									}					
								}				
							
								vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
								orderLots = NormalizeDouble(MyLotsL,2);
								orderPrice = vbid;						 
								orderStopless =MaxValue4 + bool_length*0.5; 
								
								/*
								if(( orderStopless- orderPrice)>bool_length)
								{
									orderStopless = orderPrice + bool_length;
								}
											
								if( orderStopless < MaxValue4)
								{
									orderStopless = MaxValue4+bool_length*0.5;
								}
								*/											
								orderTakeProfit	= 	orderPrice - bool_length*2;
								
								orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
								orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
								
								BuySellPosRecord[NowSymPos].TakeProfit[6] = orderTakeProfit;
								BuySellPosRecord[NowSymPos].RecentMax[6] = MaxValue4;									
								
								Print(MySymbol[NowSymPos]+"BoolCrossRecord["+NowSymPos+"]:" + BoolCrossRecord[NowSymPos].CrossFlag[0]+":" 
								+ BoolCrossRecord[NowSymPos].CrossFlag[1]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[2]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[3]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[4]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[5]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[6]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[7]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[8]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[9]);	
								
								Print(g_symbol+" MagicNumberSeven OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
								                +orderPrice+"orderStopless="+orderStopless
												+"orderTakeProfit="+orderTakeProfit);								
											
								  ticket = OrderSend(g_symbol,OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
												   g_symbol+"MagicNumberSeven",MakeMagic(NowSymPos,MagicNumberSeven),0,Blue);
						
								 if(ticket <0)
								 {
									Print("OrderSend MagicNumberSeven failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderSend MagicNumberSeven  successfully");
								 }								
								Sleep(1000); 
							}
							OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
							
						}
						else
						{
							if(OrderTakeProfit() < 0.1)
							{
								
								vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
								orderTakeProfit = BuySellPosRecord[NowSymPos].TakeProfit[2];
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
								 vbid    = MarketInfo(MySymbol[NowSymPos],MODE_BID);
								 if(vbid >= orderTakeProfit)
								 {
									 ticket =OrderClose(OrderTicket(),OrderLots(),vbid,5,Red);					  
									 if(ticket <0)
									 {
										Print("OrderClose MagicNumberThree11  failed with error #",GetLastError());
									 }
									 else
									 {            
										Print("OrderClose MagicNumberThree11  successfully");
									 }  									 
									 
								 }
								 else
								 {
									 
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   OrderStopLoss(),orderTakeProfit,0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberThree11 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberThree11  successfully ");
									 }										 
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
								Print("OrderModify MagicNumberThree22  successfully ");
							 }									
							
							Sleep(1000); 								
						}																		
						
					}	


				}			
				
			
			}  	
			
			if(NowMagicNumber == MagicNumberFour)
			{
			
				if (1 == Period() )
				{   	   

				   if((NowSymPos>=0)&&(NowSymPos<symbolNum))
				   {

						ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_SW"+MySymbol[NowSymPos]);
						FiveM_StrongWeak = GlobalVariableGet("g_FiveM_SW"+MySymbol[NowSymPos]);
				  
				   }
				   else
				   {
					  Print("NowSymPos error 4");
				   }	

					/*
					if(ThirtyM_StrongWeak>0.2)
					{
						vask    = MarketInfo(MySymbol[NowSymPos],MODE_ASK);
						 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
						 if(ticket <0)
						 {
							Print("OrderClose MagicNumberFour ThirtyM_StrongWeak failed with error #",GetLastError());
						 }
						 else
						 {            
							Print("OrderClose MagicNumberFour ThirtyM_StrongWeak  successfully");
						 }       
						Sleep(1000); 	 
										
										
					}		
					*/
					if((FiveM_StrongWeak>0.2)||(ThirtyM_StrongWeak>0.2))
					{
						
						g_symbol =   MySymbol[NowSymPos];
						boll_up_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
						boll_low_B = iBands(g_symbol,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);	
						vask    = MarketInfo(g_symbol,MODE_ASK);
						vclose  = iClose(g_symbol,0,1);
						if((vclose > BuySellPosRecord[NowSymPos].RecentMax[3])&&(5==BoolCrossRecord[NowSymPos].CrossFlag[0]))
						{
							vask    = MarketInfo(MySymbol[NowSymPos],MODE_ASK);
							 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
							 if(ticket <0)
							 {
								Print("OrderClose MagicNumberFour22  failed with error #",GetLastError());
							 }
							 else
							 {            
								Print("OrderClose MagicNumberFour22   successfully");
							 }       
							Sleep(1000); 
							
							if(OneMOrderCloseStatus(MakeMagic(NowSymPos,MagicNumberEight))==true)
							{
								
								vask    = MarketInfo(g_symbol,MODE_ASK);
								vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);
								MinValue3 = 100000;
								for (j= 0;j < (iBars(g_symbol,0) -BoolCrossRecord[NowSymPos].CrossBoolPos[1]);j++)
								{
									if(MinValue3 > iLow(g_symbol,0,j))
									{
										MinValue3 = iLow(g_symbol,0,j);
									}
									
								}				
								orderLots = NormalizeDouble(MyLotsH,2);
								orderPrice = vask;				 
								orderStopless =MinValue3- bool_length*0.5; 	
								/*
								if((orderPrice - orderStopless)>bool_length)
								{
									orderStopless = orderPrice - bool_length;
								}		

								if( orderStopless > MinValue3)
								{
									orderStopless = MinValue3-bool_length*0.5;
								}
								*/										
								
								orderTakeProfit	= 	orderPrice  + bool_length*2;
								
								orderPrice = NormalizeDouble(orderPrice,vdigits);		 	
								orderStopless = NormalizeDouble(orderStopless,vdigits);		 	
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);		


								Print(MySymbol[NowSymPos]+"BoolCrossRecord["+NowSymPos+"]:" + BoolCrossRecord[NowSymPos].CrossFlag[0]+":" 
								+ BoolCrossRecord[NowSymPos].CrossFlag[1]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[2]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[3]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[4]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[5]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[6]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[7]+":"+ BoolCrossRecord[NowSymPos].CrossFlag[8]+":"
								+ BoolCrossRecord[NowSymPos].CrossFlag[9]);	
								
								Print(g_symbol+" MagicNumberEight OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
								                +orderPrice+"orderStopless="+orderStopless
												+"orderTakeProfit="+orderTakeProfit);								
												
								ticket = OrderSend(g_symbol,OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
											   g_symbol+"MagicNumberEight",MakeMagic(NowSymPos,MagicNumberEight),0,Blue);
					
								 if(ticket <0)
								 {
									Print("OrderSend MagicNumberEight failed with error #",GetLastError());
								 }
								 else
								 {            
									Print("OrderSend MagicNumberEight  successfully");
								 }								
								
							
								Sleep(1000); 
							}
							OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
							
						}
						else
						{
							if(OrderTakeProfit() < 0.1)
							{
								vdigits = (int)MarketInfo(g_symbol,MODE_DIGITS);								 
								orderTakeProfit = BuySellPosRecord[NowSymPos].TakeProfit[3];
								orderTakeProfit = NormalizeDouble(orderTakeProfit,vdigits);
								 vask    = MarketInfo(MySymbol[NowSymPos],MODE_ASK);
								 if (vask <= orderTakeProfit)
								 {

									 ticket = OrderClose(OrderTicket(),OrderLots(),vask,3,Red);
									 if(ticket <0)
									 {
										Print("OrderClose MagicNumberFour111  failed with error #",GetLastError());
									 }
									 else
									 {            
										Print("OrderClose MagicNumberFour111   successfully");
									 }  							 
									 
								 }
								 else
								 {
									 
									res=OrderModify(OrderTicket(),OrderOpenPrice(),
										   OrderStopLoss(),orderTakeProfit,0,clrPurple);
										   
									 if(false == res)
									 {

										Print("Error in MagicNumberFour11 OrderModify. Error code=",GetLastError());									
									 }
									 else
									 {            
										Print("OrderModify MagicNumberFour11  successfully ");
									 }										 
										 
								 }
								
								
								Sleep(1000); 								
							}
							
							
						}
			
					}
					
					if((FiveM_StrongWeak<0.2)&&(ThirtyM_StrongWeak<0.2))	
					{
						
						if(OrderTakeProfit() > 0.1)
						{
							

							Print(g_symbol+" MagicNumberFour22 OrderSend:" + "OrderTicket=" + OrderTicket() +"OrderOpenPrice ="
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
						
				}  	 			 		
			
			}  	
		}				
	}
			
			
/////////////////////////////////////////////////////////
	

   //OneMSaveOrder();
   PrintFlag = true;
   ChartEvent = iBars(NULL,0);     
   return;
   
}
//+------------------------------------------------------------------+
