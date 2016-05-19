
//+------------------------------------------------------------------+
//|                                             Ibond.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2016, Xuejiayong."
#property link        "http://www.mql14.com"

//input double TakeProfit    =50;
double MyLots          =0.1;
//input double TrailingStop  =30;

input int Move_Av = 2;
input int iBoll_B = 60;
//input int iBoll_S = 20;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/////////////////////////////////////////////////////////////////////

double ma_pre;
double boll_up_B_pre,boll_low_B_pre,boll_mid_B_pre;
double boll_up_S_pre,boll_low_S_pre,boll_mid_S_pre;




int MagicNumberOne = 100;
int MagicNumberTwo = 200;
int MagicNumberThree = 300;
int MagicNumberFour = 400;
int MagicNumberFive = 500;
int MagicNumberSix = 600;



double FiveM_BuySellFlag;
double FiveM_BoolDistance;
double FiveM_BoolMidLine;



double ThirtyM_Direction;
double ThirtyM_BoolDistance;
double ThirtyM_BoolMidLine;



double FourH_StrongWeak;
double ThirtyM_StrongWeak;



////////////////////////////////////////////////

struct  OrderTradesRecord           //持仓单信息结构体
        {
         int        myTicket;       //订单号
         datetime   myOpenTime;     //开仓时间
         int        myType;         //订单类型
         double     myLots;         //开仓量
         string     mySymbol;       //商品名称
         double     myOpenPrice;    //建仓价
         double     myStopLoss;     //止损价
         double     myTakeProfit;   //止盈价
         double     myCommission;   //佣金
         double     mySwap;         //利息
         double     myProfit;       //利润
         string     myComment;      //注释
         int        myMagicNumber;  //程序识别码
         double     myAsk;          //买入报价
         double     myBid;          //卖出报价
         bool       myPreOrderFlag;   //定义开仓标志
        };

OrderTradesRecord OneMOrderKeepValue[200]; //定义持仓单变量

OrderTradesRecord OneMPreOrderMagicOne;
OrderTradesRecord OneMPreOrderMagicTwo;


int OneMOrderKeepNumber = 0;

////////////////////////////////////////////////

void OneMSaveOrder()
{
	int i;
	OneMOrderKeepNumber =OrdersTotal();
	if (OneMOrderKeepNumber >200)
	{
		Print("OneMOrderKeepNumber exceed 200");
	}
	
	for (i = 0; i < OneMOrderKeepNumber; i++)
	{
    if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
    {
        OneMOrderKeepValue[i].myTicket=OrderTicket();               //订单号
        OneMOrderKeepValue[i].myOpenTime=OrderOpenTime();           //开仓时间
        OneMOrderKeepValue[i].myType=OrderType();                   //订单类型
        OneMOrderKeepValue[i].myLots=OrderLots();                   //开仓量
        OneMOrderKeepValue[i].mySymbol=OrderSymbol();               //商品名称
        OneMOrderKeepValue[i].myOpenPrice=OrderOpenPrice();         //建仓价
        OneMOrderKeepValue[i].myStopLoss=OrderStopLoss();           //止损价
        OneMOrderKeepValue[i].myTakeProfit=OrderTakeProfit();       //止盈价
        OneMOrderKeepValue[i].myCommission=OrderCommission();       //佣金
        OneMOrderKeepValue[i].mySwap=OrderSwap();                   //利息
        OneMOrderKeepValue[i].myProfit=OrderProfit();               //利润
        OneMOrderKeepValue[i].myComment=OrderComment();             //注释
        OneMOrderKeepValue[i].myMagicNumber=OrderMagicNumber();     //程序识别码
        
 //       Print(i+" "+OneMOrderKeepValue[i].myTicket+" "+OneMOrderKeepValue[i].myOpenTime+" "+OneMOrderKeepValue[i].myType+" "+OneMOrderKeepValue[i].myLots+" "+OneMOrderKeepValue[i].mySymbol+
 //       " "+OneMOrderKeepValue[i].myOpenPrice+" "+OneMOrderKeepValue[i].myStopLoss+" "+OneMOrderKeepValue[i].myTakeProfit+" "+OneMOrderKeepValue[i].myCommission+" "+OneMOrderKeepValue[i].mySwap+
 //       " "+OneMOrderKeepValue[i].myProfit+" "+OneMOrderKeepValue[i].myComment+" "+OneMOrderKeepValue[i].myMagicNumber);
    }

	}

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



int  InitcrossValue()
{	
   double myma,myboll_up_B,myboll_low_B,myboll_mid_B;
   double myma_pre,myboll_up_B_pre,myboll_low_B_pre,myboll_mid_B_pre;
   
   int crossflag = 0;
   int j = 0;
   int i;
   if(iBars(NULL,0) <500)
   {
      Print("Bar Number less than 500");
      return -1;
   }
   
	for (i = 1; i< 500;i++)
	{
		
     crossflag = 0;     
	   myma=iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,i-1);  
	   myboll_up_B = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,i-1);   
	   myboll_low_B = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,i-1);
	   myboll_mid_B = (	myboll_up_B +  myboll_low_B)/2;
	    
	   myma_pre = iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,i); 
	   myboll_up_B_pre = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,i);      
	   myboll_low_B_pre = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,i);
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
				CrossValue[j] = crossflag;
				j++;
				if (j >= 9)
				{
					break;
				}
		}

	}
	
	return 0;

}



//当前周期，最大值上穿60 boll周期上轨，或者下穿boll周期下轨，邮件提醒关注。

int init()
{

      int symbolvalue = 0;

      string MailTitlle ="";
      int i;
      
			InitcrossValue();


         if(Symbol() == "EURUSD")
         {
            symbolvalue = 100000;
         }
         else if (Symbol() == "AUSUSD")
         {
            symbolvalue = 200000;
         
         }
         else if (Symbol() == "USDJPY")
         {
            symbolvalue = 300000;
         
         }       
         else if (Symbol() == "XAUUSD")
         {
            symbolvalue = 400000;
         
         }      
         else if (Symbol() == "GOLD")
         {
            symbolvalue = 500000;
         
         }                     
         else
         {
            symbolvalue = 0;
         
         }
         Print("symbolvalue:="+ symbolvalue);
         MagicNumberOne = MagicNumberOne + symbolvalue;
         MagicNumberTwo = MagicNumberTwo + symbolvalue;
         MagicNumberThree = MagicNumberThree + symbolvalue;
         MagicNumberFour = MagicNumberFour + symbolvalue;
         MagicNumberFive = MagicNumberFive + symbolvalue;
         MagicNumberSix = MagicNumberSix + symbolvalue;


			if(240 == Period() )
			{
      
		      if(GlobalVariableCheck("g_FourH_StrongWeak") == TRUE)
		      {  
		      		GlobalVariableSet("g_FourH_StrongWeak",0.5);
		          FourH_StrongWeak = GlobalVariableGet("g_FourH_StrongWeak");    
		          Print("g_FourH_StrongWeak already exist  = "+DoubleToString(FourH_StrongWeak));        
		      }
		      else
		      {

		      		GlobalVariableSet("g_FourH_StrongWeak",0.5);
		      	  if(GlobalVariableCheck("g_FourH_StrongWeak") == FALSE)
		      	  {
		          	Print("init False due to g_FourH_StrongWeak set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
		          	FourH_StrongWeak = GlobalVariableGet("g_FourH_StrongWeak");  
          			Print("init g_FourH_StrongWeak is OK  = "+DoubleToString(FourH_StrongWeak));  		          			      	  
		      	  }  

		      }
            			
			
			}
      else if (30 == Period() )
      {



		      if(GlobalVariableCheck("g_ThirtyM_StrongWeak") == TRUE)
		      {  
		      		GlobalVariableSet("g_ThirtyM_StrongWeak",0.5);
		          ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_StrongWeak");    
		          Print("g_ThirtyM_StrongWeak already exist  = "+DoubleToString(ThirtyM_StrongWeak));        
		      }
		      else
		      {

		      		GlobalVariableSet("g_ThirtyM_StrongWeak",0.5);
		      	  if(GlobalVariableCheck("g_ThirtyM_StrongWeak") == FALSE)
		      	  {
		          	Print("init False due to g_ThirtyM_StrongWeak set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
		          	ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_StrongWeak");  
          			Print("init g_ThirtyM_StrongWeak is OK  = "+DoubleToString(ThirtyM_StrongWeak));  		          			      	  
		      	  }  

		      }



      
		      if(GlobalVariableCheck("g_ThirtyM_Direction") == TRUE)
		      {    
		      	 GlobalVariableSet("g_ThirtyM_Direction",CrossValue[0]);		        
		          ThirtyM_Direction = GlobalVariableGet("g_ThirtyM_Direction");    
		          Print("g_ThirtyM_Direction already exist  = "+DoubleToString(ThirtyM_Direction));        
		      }
		      else
		      {

		      	  GlobalVariableSet("g_ThirtyM_Direction",CrossValue[0]);
		      	  if(GlobalVariableCheck("g_ThirtyM_Direction") == FALSE)
		      	  {
		          	Print("init False due to g_ThirtyM_Direction set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
		          	ThirtyM_Direction = GlobalVariableGet("g_ThirtyM_Direction");  
          			Print("init g_ThirtyM_Direction is OK  = "+DoubleToString(ThirtyM_Direction));  		          			      	  
		      	  }  

		      }
            
            
		      if(GlobalVariableCheck("g_ThirtyM_BoolDistance") == TRUE)
		      {      
		          ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");		          
		          Print("g_ThirtyM_BoolDistance already exist  = "+DoubleToString(ThirtyM_BoolDistance));        
		      }
		      else
		      {

		      		GlobalVariableSet("g_ThirtyM_BoolDistance",0);
		      	  if(GlobalVariableCheck("g_ThirtyM_BoolDistance") == FALSE)
		      	  {
		          	Print("init False due to g_ThirtyM_BoolDistance set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
		          	ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");  
          			Print("init g_ThirtyM_BoolDistance is OK  = "+DoubleToString(ThirtyM_BoolDistance));  		          			      	  
		      	  }  

		      }            
            

		      if(GlobalVariableCheck("g_ThirtyM_BoolMidLine") == TRUE)
		      {      
		          ThirtyM_BoolMidLine = GlobalVariableGet("g_ThirtyM_BoolMidLine");		              
		          Print("g_ThirtyM_BoolMidLine already exist  = "+DoubleToString(ThirtyM_BoolMidLine));        
		      }
		      else
		      {

		      		GlobalVariableSet("g_ThirtyM_BoolMidLine",0);
		      	  if(GlobalVariableCheck("g_ThirtyM_BoolMidLine") == FALSE)
		      	  {
		          	Print("init False due to g_ThirtyM_BoolMidLine set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
		          	ThirtyM_BoolMidLine = GlobalVariableGet("g_ThirtyM_BoolMidLine");  
          			Print("init g_ThirtyM_BoolMidLine is OK  = "+DoubleToString(ThirtyM_BoolMidLine));  		          			      	  
		      	  }  

		      }            
                        
            
            
            
            
          MailTitlle = MailTitlle +"30M";

      
      }
      else if (5 == Period() )
      {
  
      


		      if(GlobalVariableCheck("g_FiveM_BuySellFlag") == TRUE)
		      {      
		          FiveM_BuySellFlag = GlobalVariableGet("g_FiveM_BuySellFlag");
		             
		          Print("g_FiveM_BuySellFlag already exist  = "+DoubleToString(FiveM_BuySellFlag));        
		      }
		      else
		      {

		      		GlobalVariableSet("g_FiveM_BuySellFlag",0);
		      	  if(GlobalVariableCheck("g_FiveM_BuySellFlag") == FALSE)
		      	  {
		          	Print("init False due to g_FiveM_BuySellFlag set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
		          	FiveM_BuySellFlag = GlobalVariableGet("g_FiveM_BuySellFlag");  
          			Print("init g_FiveM_BuySellFlag is OK  = "+DoubleToString(FiveM_BuySellFlag));  		          			      	  
		      	  }  

		      }      
      
         

          if(GlobalVariableCheck("g_FiveM_BoolDistance") == TRUE)
		      {      
	          Print("g_FiveM_BoolDistance already exist" );        
		      }
		      else
		      {

		      		GlobalVariableSet("g_FiveM_BoolDistance",0);
		      	  if(GlobalVariableCheck("g_FiveM_BoolDistance") == FALSE)
		      	  {
		          	Print("init False due to g_FiveM_BoolDistance set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
          			Print("init g_FiveM_BoolDistance is OK  ");  		          			      	  
		      	  }  

		      } 
      
      
          if(GlobalVariableCheck("g_FiveM_BoolMidLine") == TRUE)
		      {      
	          Print("g_FiveM_BoolMidLine already exist" );        
		      }
		      else
		      {

		      		GlobalVariableSet("g_FiveM_BoolMidLine",0);
		      	  if(GlobalVariableCheck("g_FiveM_BoolMidLine") == FALSE)
		      	  {
		          	Print("init False due to g_FiveM_BoolMidLine set false!");  
		          	return -1;     		      	  
		      	  }		    
		      	  else
		      	  {
          			Print("init g_FiveM_BoolMidLine is OK  ");  		          			      	  
		      	  }  

		      } 
            
      
				      
      
      
           
         MailTitlle = MailTitlle +"5M";
      
      }
      else if (1 == Period() )
      {
      
					OneMPreOrderMagicOne.myPreOrderFlag = false;
					OneMPreOrderMagicTwo.myPreOrderFlag = false;

	   
         MailTitlle = MailTitlle +"1M";
      
      }            
      else
      {
         MailTitlle = MailTitlle + "Bad Time period，should 1M 5M 30M 4H " + Period() ;
         Print(MailTitlle); 
         return -1;
      }
      
      MailTitlle = "Init:" + MailTitlle +  Symbol();
	 
   
   //等待所有周期的全局参数起来
   
   for (i = 0; i < 100; i++)
   {
   	
	   	if((GlobalVariableCheck("g_ThirtyM_Direction") == FALSE)||(GlobalVariableCheck("g_ThirtyM_BoolDistance") == FALSE)
	   	||(GlobalVariableCheck("g_ThirtyM_BoolMidLine") == FALSE)||(GlobalVariableCheck("g_FiveM_BuySellFlag") == FALSE)
	   	||(GlobalVariableCheck("g_FiveM_BoolDistance") == FALSE)||(GlobalVariableCheck("g_FiveM_BoolMidLine") == FALSE)
	   	||(GlobalVariableCheck("g_ThirtyM_StrongWeak") == FALSE)||(GlobalVariableCheck("g_FourH_StrongWeak") == FALSE))
	   	{
	   		Print(MailTitlle + "waiting for globle_Value init,another ten seconds......" ); 	   	
	   		Sleep(5000);

	   	}
	   	else
	   	{
	   		break;
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

	//删除自己的全局变量
	
	    if (240 == Period() )
      {     
		      if(GlobalVariableCheck("g_FourH_StrongWeak") == TRUE)
		      {      
		          GlobalVariableDel("g_FourH_StrongWeak");

		      }      
      }
      else if (30 == Period() )
      {     
      
		      if(GlobalVariableCheck("g_ThirtyM_StrongWeak") == TRUE)
		      {      
		          GlobalVariableDel("g_ThirtyM_StrongWeak");

		      }           
       
		      if(GlobalVariableCheck("g_ThirtyM_Direction") == TRUE)
		      {      
		          GlobalVariableDel("g_ThirtyM_Direction");

		      }


		      if(GlobalVariableCheck("g_ThirtyM_BoolDistance") == TRUE)
		      {      
		          GlobalVariableDel("g_ThirtyM_BoolDistance");

		      }
		      		      
			      if(GlobalVariableCheck("g_ThirtyM_BoolMidLine") == TRUE)
		      {      
		          GlobalVariableDel("g_ThirtyM_BoolMidLine");

		      }	      

      
      }
      else if (5 == Period() )
      {

			      if(GlobalVariableCheck("g_FiveM_BuySellFlag") == TRUE)
		      {      
		          GlobalVariableDel("g_FiveM_BuySellFlag");

		      }	   
			      if(GlobalVariableCheck("g_FiveM_BoolDistance") == TRUE)
		      {      
		          GlobalVariableDel("g_FiveM_BoolDistance");

		      }	   
			      if(GlobalVariableCheck("g_FiveM_BoolMidLine") == TRUE)
		      {      
		          GlobalVariableDel("g_FiveM_BoolMidLine");

		      }	      
		      		      
      }
      else if (1 == Period() )
      {
      ;

      }    	
	
   return 0;
}



// 5 表示上穿上轨；4表示下穿上轨 1表示上穿中线 -1表示下穿中线 -5表示下穿下轨 -4表示上穿下轨
int CrossValue[10];


void ChangeCrossValue( int mvalue)
{

	int i;

	if (mvalue == CrossValue[0])
	{
		return;
	}
	for (i = 0 ; i <9; i++)
	{
		CrossValue[9-i] = CrossValue[8-i];

	}
	
	CrossValue[0] = mvalue;
	return;
}

int ChartEvent = 0;
bool PrintFlag = false;


double MaxValue1=-1;
double MinValue1 = 100000;

double MaxValue2=-1;
double MinValue2 = 100000;



bool FiveMStrongTrendChangeDown()
{

	bool status = false;
	int i;
	int j = 0;	
	
	for( i = 0; i < 10; i++)
	{
		if ((CrossValue[i] == 5)||(CrossValue[i] == 4))
		{
			break;
		}	

		j++;
		
		if ((3==j)&&((CrossValue[0] == -5)||(CrossValue[0] == -1)))
		{
			status = true;			
			break;
		}
	
	

	}
	return status;
}

bool FiveMStrongTrendChangeUp()
{

	bool status = false;
	int i;
	int j = 0;	
	
	for( i = 0; i < 10; i++)
	{
		if ((CrossValue[i] == -5)||(CrossValue[i] == -4))
		{
			break;
		}	

		j++;
		if ((3==j)&&((CrossValue[0] == 5)||(CrossValue[0] == 1)))
		{
			status = true;			
			break;
		}
		

	}
	return status;
}



bool FiveMWeakTrendChangeDown()
{

	bool status = false;
	int i;
	int j = 0;	
	
	for( i = 0; i < 10; i++)
	{
		if (CrossValue[i] == 5)
		{
			break;
		}	
		if((CrossValue[i] == -5)||(CrossValue[i] == -1))
		{

			j++;
			if ((2==j)&&((CrossValue[0] == -5)||(CrossValue[0] == -1)))
			{
				status = true;			
				break;
			}
		
		}
		

	}
	return status;
}



bool FiveMWeakTrendChangeUp()
{

	bool status = false;
	int i;
	int j = 0;	
	
	for( i = 0; i < 10; i++)
	{
		if (CrossValue[i] == -5)
		{
			break;
		}	
		if((CrossValue[i] == 5)||(CrossValue[i] == 1))
		{

			j++;
			if ((2==j)&&((CrossValue[0] == 5)||(CrossValue[0] == 1)))
			{
				status = true;			
				break;
			}
		
		}

	}
	return status;
}


/*确保不是1分钟上涨中继*/
bool OneMFastUp()
{

	bool status = false;

	if ((CrossValue[0] == 5) &&((CrossValue[1] != 4)&&(CrossValue[1] != 5)) &&  ((CrossValue[2] != 4)&&(CrossValue[2] != 5)))
	{
		status = true;
	}
	
	return status;
}

/*确保不是1分钟下跌中继*/
bool OneMFastDown()
{
	bool status = false;

	if ((CrossValue[0] == -5) &&((CrossValue[1] != -4)&&(CrossValue[1] != -5)) &&  ((CrossValue[2] != -4)&&(CrossValue[2] != -5)))
	{
		status = true;
	}
	return status;
}



datetime OneMCrossTime;


void OnTick(void)
{
	int ticket;
   double ma;
   double boll_up_B,boll_low_B,boll_mid_B,bool_length;
   string mMailTitlle = "";
   int crossflag = 0;
   int i;
   
   double orderStopLevel=0;
   double orderLots = 0;   
   double orderStopless = 0;
   double orderTakeProfit = 0;
   double orderPrice = 0;
   
  	double MAThird,MATen,MAThentyOne;
   
   

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
   
   
   else if (1 == Period() )
   {
   
      if((OneMPreOrderMagicOne.myPreOrderFlag == true)
      &&(Ask >= OneMPreOrderMagicOne.myOpenPrice))
      {
         if ((TimeCurrent()-OneMPreOrderMagicOne.myOpenTime)<80)
         {
 
             orderLots = OneMPreOrderMagicOne.myLots;
             orderPrice = Ask;
             orderStopless = Ask -(OneMPreOrderMagicOne.myOpenPrice - OneMPreOrderMagicOne.myStopLoss);
             orderTakeProfit = Ask + (OneMPreOrderMagicOne.myTakeProfit - OneMPreOrderMagicOne.myOpenPrice);
 
   		 	    /*参数修正*/ 
  	         orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	
             orderStopLevel = 2*orderStopLevel;
             if(orderStopLevel < 1)
             {
             		orderStopLevel = 100;
             }
 		 	 
        		 if ((orderPrice - orderStopless) < orderStopLevel*Point)
      		 	 {
      		 	 		orderStopless = orderPrice - orderStopLevel*Point;
      		 	 }
      		 	 if ((orderTakeProfit - orderPrice) < orderStopLevel*Point)
      		 	 {
      		 	 		orderTakeProfit = orderPrice + orderStopLevel*Point;
      		 	 }

   		 	 
   		 	 
             
            orderLots = NormalizeDouble(orderLots,2);          
            orderPrice = NormalizeDouble(orderPrice,Digits);		 	
            orderStopless = NormalizeDouble(orderStopless,Digits);		 	
            orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 			 	 		 			 	 		 			 			 	 		 				 
      
   		 	   
   			Print("MagicNumberOne OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
   							+"orderTakeProfit="+orderTakeProfit);	
   										 		 	 
 				Print("MagicNumberOne OrderSend:" + "OneMCrossTime=" + TimeToString(OneMPreOrderMagicOne.myOpenTime,TIME_SECONDS)
				 +"orderDatetime=" + TimeToString(TimeCurrent(),TIME_SECONDS));
  								 		 	 

   				 		 	 
      	    ticket = OrderSend(Symbol(),OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
      	                       Symbol()+"MagicNumberOne",MagicNumberOne,0,CLR_NONE);
      	                       
      	    OneMPreOrderMagicOne.myPreOrderFlag = false;  
      	                     
            if(ticket <0)
            {
               Print("OrderSend MagicNumberOne failed with error #",GetLastError());
            }
            else
            {            
               Print("OrderSend MagicNumberOne  successfully");
            }
            Sleep(1000);
         }
         else
         {
      	    OneMPreOrderMagicOne.myPreOrderFlag = false;  
         
         }
      }
   
   
      if((OneMPreOrderMagicTwo.myPreOrderFlag == true)
      &&(Bid <= OneMPreOrderMagicTwo.myOpenPrice))
      {
         if ((TimeCurrent()-OneMPreOrderMagicTwo.myOpenTime)<80)
         {
           
             orderLots = OneMPreOrderMagicTwo.myLots;
             orderPrice = Bid;
             orderStopless = Bid -(OneMPreOrderMagicTwo.myOpenPrice - OneMPreOrderMagicTwo.myStopLoss);
             orderTakeProfit = Bid + (OneMPreOrderMagicTwo.myTakeProfit - OneMPreOrderMagicTwo.myOpenPrice);
             
			 	  /*参数修正*/ 
	 	       orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	
	 	 		 	 orderStopLevel= orderStopLevel*2;
					if(orderStopLevel < 1)
					{
						orderStopLevel = 100;
					}

	   		 	 if ((orderStopless-orderPrice ) < orderStopLevel*Point)
	   		 	 {
	   		 	 		orderStopless = orderPrice + orderStopLevel*Point;
	   		 	 }
	   		 	 if ((orderPrice-orderTakeProfit) < orderStopLevel*Point)
	   		 	 {
	   		 	 		orderTakeProfit = orderPrice - orderStopLevel*Point;
	   		 	 }

		 	 	
             
            orderLots = NormalizeDouble(orderLots,2);          
            orderPrice = NormalizeDouble(orderPrice,Digits);		 	
            orderStopless = NormalizeDouble(orderStopless,Digits);		 	
            orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 			 	 		 			 	 		 			 			 	 		 				 
      
   		 	   
   			Print("MagicNumberTwo OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
   							+"orderTakeProfit="+orderTakeProfit);			
   							
 				Print("MagicNumberTwo OrderSend:" + "OneMCrossTime=" + TimeToString(OneMPreOrderMagicTwo.myOpenTime,TIME_SECONDS)
				 +"orderDatetime=" + TimeToString(TimeCurrent(),TIME_SECONDS));
  								 		 	 
   				 		 	 
      	    ticket = OrderSend(Symbol(),OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
      	                       Symbol()+"MagicNumberTwo",MagicNumberTwo,0,CLR_NONE);
      	                       
      	    OneMPreOrderMagicTwo.myPreOrderFlag = false;  
      	                     
            if(ticket <0)
            {
               Print("OrderSend MagicNumberTwo failed with error #",GetLastError());
            }
            else
            {            
               Print("OrderSend MagicNumberTwo  successfully");
            }		
            Sleep(1000);

         }
         else
         {
      	    OneMPreOrderMagicTwo.myPreOrderFlag = false;  
         
         }
         
         
         
         
         
      }
   
   
   
   
   
   
   }
   
   
   



///////////////////////////////////////////////////////////////////////////////
//前面的代码在每个周期的每个tick都会执行，基本是一秒执行一次
   if ( ChartEvent != iBars(NULL,0))
   {
      PrintFlag = false;
   }   
   
   if ( PrintFlag == true)
   {
      return;
   }
   
   //后面的代码只在每个周期开始阶段执行。
//////////////////////////////////////////////////////////////////////////////

   if (240 == Period() )
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
   
   
      
   ma=iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,0); 
   // ma = Close[0];  
   boll_up_B = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,0);   
   boll_low_B = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,0);
   boll_mid_B = (boll_up_B + boll_low_B )/2;
   /*point*/
   bool_length =(boll_up_B - boll_low_B )/2;
   
   
   ma_pre = iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,1); 
   boll_up_B_pre = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);      
   boll_low_B_pre = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);
   boll_mid_B_pre = (boll_up_B_pre + boll_low_B_pre )/2;

   

       
		/*本周期突破高点，观察如小周期未衰竭可追高买入，或者等待回调买入*/
		/*原则上突破bool线属于偏离价值方向太大，是要回归价值中枢的*/
		if((ma >boll_up_B) && (ma_pre < boll_up_B_pre ) )
		{
		
				crossflag = 5;		
			  ChangeCrossValue(crossflag);
	    //  Print(mMailTitlle + Symbol()+"::本周期突破高点，除(1M、5M周期bool口收窄且快速突破追高，移动止损），其他情况择机反向做空:"
	    //  + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
         PrintFlag = true;
		}
		
		/*本周期突破高点后回调，观察如小周期长时间筑顶，寻机卖出*/
		if((ma <boll_up_B) && (ma_pre > boll_up_B_pre ) )
		{
				crossflag = 4;
				ChangeCrossValue(crossflag);
	   //   Print(mMailTitlle + Symbol()+"::本周期突破高点后回调，观察小周期如长时间筑顶，寻机做空:"
	   //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
         PrintFlag = true;

		}
			
		
		/*本周期突破低点，观察如小周期未衰竭可追低卖出，或者等待回调卖出*/
		if((ma < boll_low_B) && (ma_pre > boll_low_B_pre ) )
		{
		
			
				crossflag = -5;
				ChangeCrossValue(crossflag);	
	   //   Print(mMailTitlle + Symbol() + "::本周期突破低点，除(条件：1M、5M周期bool口收窄且快速突破追低，移动止损），其他情况择机反向做多:"
	   //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
         PrintFlag = true;

		}
			
		/*本周期突破低点后回调，观察如长时间筑底，寻机买入*/
		if((ma > boll_low_B) && (ma_pre < boll_low_B_pre ) )
		{
				crossflag = -4;	
				ChangeCrossValue(crossflag);		
	   //   Print(mMailTitlle + Symbol() + "::本周期突破低点后回调，观察如小周期长时间筑底，寻机买入:"
	   //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
         PrintFlag = true;

		}


 			
			/*本周期上穿中线，表明本周期趋势开始发生变化为上升，在下降大趋势下也可能是回调杀入机会*/
			if((ma > boll_mid_B) && (ma_pre < boll_mid_B_pre ))
			{
			
					crossflag = 1;				
					ChangeCrossValue(crossflag);				
		  //    Print(mMailTitlle + Symbol() + "::本周期上穿中线变化为上升，大周期下降大趋势下可能是回调做空机会："
		  //    + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
          PrintFlag = true;

			}	
			/*本周期下穿中线，表明趋势开始发生变化，在上升大趋势下也可能是回调杀入机会*/
			if( (ma < boll_mid_B) && (ma_pre > boll_mid_B_pre ))
			{
					crossflag = -1;								
					ChangeCrossValue(crossflag);				
		 //     Print(mMailTitlle + Symbol() + "::本周期下穿中线变化为下降，大周期上升大趋势下可能是回调做多机会："
		 //     + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
          PrintFlag = true;
			}							

	
	
	/*传递4H最大周期的上升下降趋势评估值，该值用来优化买单卖单的手数、获利预期*/
	if (240 == Period() )
  {		
  	
  
     MAThird=iMA(NULL,0,3,0,MODE_SMA,PRICE_CLOSE,0); 
     MATen=iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,0); 
     MAThentyOne=iMA(NULL,0,21,0,MODE_SMA,PRICE_CLOSE,0); 
  	 FourH_StrongWeak =0.5;

  	if(MAThird > MATen)
  	{
  	 	  	
  		/*多均线多头向上*/
  		if(MAThentyOne < MATen)
  		{
  			 FourH_StrongWeak =0.9;
  		}
  		else if ((MAThentyOne >= MATen) &&(MAThentyOne <MAThird))
  		{
  			 FourH_StrongWeak =0.6;
  		}
  		else
  		{
  			 FourH_StrongWeak =0.5;
  		}
  	
  	}
  	else if (MAThird < MATen)
  	{
  		/*多均线多头向下*/
  		if(MAThentyOne > MATen)
  		{
  			 FourH_StrongWeak =0.1;
  		}
  		else if ((MAThentyOne <= MATen) &&(MAThentyOne > MAThird))
  		{
  			 FourH_StrongWeak =0.4;
  		}
  		else
  		{
  			 FourH_StrongWeak =0.5;
  		}  	
  	
  	}
  	else
  	{
  	  			 FourH_StrongWeak =0.5;

  	}
  
    GlobalVariableSet("g_FourH_StrongWeak",FourH_StrongWeak);   
  
  }
	
	
	
		
	/*传递30M的大周期全局参数*/	
	if (30 == Period() )
  {		
  		/*三十分钟脱离上轨或者脱离下轨在五分钟线上寻找机会反向下单*/
  		GlobalVariableSet("g_ThirtyM_Direction",CrossValue[0]);
 
  	  
  		/*将30分钟线的bool_distance传递给1分钟线,作为止盈参考值*/
  		GlobalVariableSet("g_ThirtyM_BoolDistance",bool_length);
   	  
  
    	/*将30分钟线的g_ThirtyM_BoolMidLine传递给1分钟线,作为止盈参考值*/
  		GlobalVariableSet("g_ThirtyM_BoolMidLine",boll_mid_B);
  		
  		
  
     MAThird=iMA(NULL,0,3,0,MODE_SMA,PRICE_CLOSE,0); 
     MATen=iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,0); 
     MAThentyOne=iMA(NULL,0,21,0,MODE_SMA,PRICE_CLOSE,0); 
  	 ThirtyM_StrongWeak =0.5;

  	if(MAThird > MATen)
  	{
  	 	  	
  		/*多均线多头向上*/
  		if(MAThentyOne < MATen)
  		{
  			 ThirtyM_StrongWeak =0.9;
  		}
  		else if ((MAThentyOne >= MATen) &&(MAThentyOne <MAThird))
  		{
  			 ThirtyM_StrongWeak =0.6;
  		}
  		else
  		{
  			 ThirtyM_StrongWeak =0.5;
  		}
  	
  	}
  	else if (MAThird < MATen)
  	{
  		/*多均线多头向下*/
  		if(MAThentyOne > MATen)
  		{
  			 ThirtyM_StrongWeak =0.1;
  		}
  		else if ((MAThentyOne <= MATen) &&(MAThentyOne > MAThird))
  		{
  			 ThirtyM_StrongWeak =0.4;
  		}
  		else
  		{
  			 ThirtyM_StrongWeak =0.5;
  		}  	
  	
  	}
  	else
  	{
  	  			 ThirtyM_StrongWeak =0.5;

  	}
  
    GlobalVariableSet("g_ThirtyM_StrongWeak",ThirtyM_StrongWeak);   
    		
  		
  		  		
 	  
  	  
	}
		
		
	/*5M确定买卖机会点的区域*/	
	if (5 == Period() )
   {
   /*获取必要参数*/
   
   	 ThirtyM_Direction = GlobalVariableGet("g_ThirtyM_Direction");
   	 ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");
   	 ThirtyM_BoolMidLine = GlobalVariableGet("g_ThirtyM_BoolMidLine");
   	 


		 if((-5==crossflag)&&(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point < bool_length)
		 	&&(OneMOrderCloseStatus(MagicNumberFive)==true)&&(CrossValue[1]==-1))
   	 {

					ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_StrongWeak");
					orderLots = NormalizeDouble(MyLots*ThirtyM_StrongWeak,2);
					orderPrice = Ask;				 
					orderStopless =orderPrice - bool_length; 
   				orderTakeProfit = orderPrice+bool_length;
						    		 	 	 	  			 	 		 			 	 		 	
					orderPrice = NormalizeDouble(orderPrice,Digits);		 	
					orderStopless = NormalizeDouble(orderStopless,Digits);		 	
					orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 			 	 		 			 	 		 			 	
	
   					Print("MagicNumberFive OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
   								+"orderTakeProfit="+orderTakeProfit);
   					 		 	 				 		 	 
      	      ticket = OrderSend(Symbol(),OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
      	                       Symbol()+"MagicNumberFive",MagicNumberFive,0,Blue);
   	
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



		 if((5==crossflag)&&(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point < bool_length)
		 	&&(OneMOrderCloseStatus(MagicNumberFive)==true)&&(CrossValue[1]==1))
   	 {

					ThirtyM_StrongWeak = GlobalVariableGet("g_ThirtyM_StrongWeak");
					orderLots = NormalizeDouble(MyLots*ThirtyM_StrongWeak,2);
					orderPrice = Bid;				 
					orderStopless =orderPrice + bool_length; 
   				orderTakeProfit = orderPrice - bool_length;
						    		 	 	 	  			 	 		 			 	 		 	
					orderPrice = NormalizeDouble(orderPrice,Digits);		 	
					orderStopless = NormalizeDouble(orderStopless,Digits);		 	
					orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 			 	 		 			 	 		 			 	
	
   					Print("MagicNumberSix OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
   								+"orderTakeProfit="+orderTakeProfit);
   					 		 	 				 		 	 
      	      ticket = OrderSend(Symbol(),OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
      	                       Symbol()+"MagicNumberSix",MagicNumberSix,0,Blue);
   	
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


		
			GlobalVariableSet("g_FiveM_BoolMidLine",boll_mid_B);
			GlobalVariableSet("g_FiveM_BoolDistance",bool_length);			
	 	 
   	  	 
   	 /*30M上升阶段，突破上轨，通过5分钟寻找背驰状态*/
   	 if(5==ThirtyM_Direction)
   	 {
   	 		//Print("5==ThirtyM_Direction");
   	 		/*5分钟转为下跌，在1分钟线上寻找下单机会*/
	   	 	if (true == FiveMStrongTrendChangeDown())
	   	 	{
   	 				Print("0true == FiveMStrongTrendChangeDown()");
	   	 			GlobalVariableSet("g_FiveM_BuySellFlag",-2);
	   	 	}
				else
				{
	   	 			GlobalVariableSet("g_FiveM_BuySellFlag",0);
				}
   	 
   	 }
   
     /*30M 突破下轨，通过5分钟寻找背驰状态*/
   	 else if(-5==ThirtyM_Direction)
   	 {
   	 	//	Print("-5==ThirtyM_Direction");
   	 
   	 		/*5分钟转为上升，在1分钟线上寻找下单机会*/
	   	 	if (true == FiveMStrongTrendChangeUp())
	   	 	{
   	 				Print("1true == FiveMStrongTrendChangeUp()");
	   	 	
	   	 			GlobalVariableSet("g_FiveM_BuySellFlag",2);
	   	 	}
				else
				{
	   	 			GlobalVariableSet("g_FiveM_BuySellFlag",0);
				}
	   	 	
   	 
   	 }
	   	 
	   /*落回上轨内且在上半带*/
	   else if ((4==ThirtyM_Direction)&&(Bid >(ThirtyM_BoolMidLine+ThirtyM_BoolDistance*0.4)))
	   {
   	 	//	Print("4==ThirtyM_Direction");
	   
	   	   	if (true == FiveMStrongTrendChangeDown())
		   	 	{
   	 				Print("2true == FiveMStrongTrendChangeDown()");
		   	 	
		   	 			GlobalVariableSet("g_FiveM_BuySellFlag",-1);
		   	 	}
				else
				{
	   	 			GlobalVariableSet("g_FiveM_BuySellFlag",0);
				}
		   	 	
		   	 	
	      
	   }
	   
	    /*落回下轨内且在下半带*/
	   else if ((-4==ThirtyM_Direction)&&(Ask <(ThirtyM_BoolMidLine-ThirtyM_BoolDistance*0.4)))
	   {
   	 	//	Print("-4==ThirtyM_Direction");
	   
	   	   	if (true == FiveMStrongTrendChangeUp())
		   	 	{
   	 				Print("3true == FiveMStrongTrendChangeUp()");
		   	 	
		   	 			GlobalVariableSet("g_FiveM_BuySellFlag",1);
		   	 	}
				else
				{
	   	 			GlobalVariableSet("g_FiveM_BuySellFlag",0);
				}
	      
	   }
	   else
	   {
	   
	   	   	GlobalVariableSet("g_FiveM_BuySellFlag",0);
	   }
      
   }
			

	/*1M下单买卖*/	
	if (1 == Period() )
	{
	
	
	
	/*获取必要参数*/

	 ThirtyM_Direction = GlobalVariableGet("g_ThirtyM_Direction");

	   //寻找最大值，作为本周期做空的止损参考值  
	   if (ThirtyM_Direction == 5)
	   {
	   		if(MaxValue1 < iHigh(NULL,0,0))
	   		{
	   			MaxValue1 = iHigh(NULL,0,0);
	   		}
	   }
		else
		{
			MaxValue1 = -1;
		} 
		
			//寻找最大值，作为本周期做空的止损参考值  
	   if (ThirtyM_Direction == 4)
	   {
	   		if(MaxValue2 < iHigh(NULL,0,0))
	   		{
	   			MaxValue2 = iHigh(NULL,0,0);
	   		}
	   }
		else
		{
			MaxValue2 = -1;
		} 

		
	   //寻找最小值，作为本周期做多的止损参考值  
	   if (ThirtyM_Direction == -5)
	   {
	   		if(MinValue1 > iLow(NULL,0,0))
	   		{
	   			MinValue1 = iLow(NULL,0,0);
	   		}
	   }
		else
		{
			MinValue1 = 100000;
		} 

	   //寻找最小值，作为本周期做多的止损参考值  
	   if (ThirtyM_Direction == -4)
	   {
	   		if(MinValue2 > iLow(NULL,0,0))
	   		{
	   			MinValue2 = iLow(NULL,0,0);
	   		}
	   }
		else
		{
			MinValue2 = 100000;
		} 
//////////////////////////////////////////////////////////////
/*一分钟线上开订单*/	

	 	/* 下单思想是小周期快速变化的过程中会出现跨周期的极度不平衡
	 	 /*利用这种不平衡实现以小博大*/	
		/*1M线快速上升，短期内突破五分钟上轨认为是小转大的行为，挂限时BuyStop买单，买单成交后，通过移动止损和5分钟线优化订单*/	
		if ((OneMFastUp() ==true) &&(crossflag == 5)&&(OneMOrderCloseStatus(MagicNumberOne)==true))
		{
		
   
		
			 FiveM_BoolDistance = GlobalVariableGet("g_FiveM_BoolDistance");
			 FiveM_BoolMidLine = GlobalVariableGet("g_FiveM_BoolMidLine");

				orderLots = MyLots*0.2;
				
				orderPrice =  FiveM_BoolMidLine + FiveM_BoolDistance;
						
			   orderStopless = boll_up_B;
			   
		 	 /*防止止损点位太大，保证止损和止盈比小于1：1；*/
		 	 if((orderPrice-orderStopless )>FiveM_BoolDistance)
		 	 {
		 	   orderStopless = FiveM_BoolMidLine;
		 	 }		 	 
		 	 /*还有一种思路就是以1分钟的bool_lenth和5分钟的bool_lenth作为止损和止盈比*/
		 	 if(2*bool_length < FiveM_BoolDistance)
		 	 {
		 	   orderStopless = FiveM_BoolMidLine+FiveM_BoolDistance-2*bool_length;		 	 
		 	 }
		 	 
		 	 orderTakeProfit = FiveM_BoolMidLine + 2*FiveM_BoolDistance;	
 	  			 	 		 			 	 		 	
			 OneMCrossTime = TimeCurrent();
			 
			OneMPreOrderMagicOne.myLots = orderLots;
			OneMPreOrderMagicOne.myOpenPrice = orderPrice;
			OneMPreOrderMagicOne.myStopLoss = orderStopless;
			OneMPreOrderMagicOne.myTakeProfit = orderTakeProfit;
			OneMPreOrderMagicOne.myOpenTime = OneMCrossTime;
			OneMPreOrderMagicOne.myPreOrderFlag = true;
		 		 					 	 			 	 
		}
			   		  
	 	/* 下单思想是小周期快速变化的过程中会出现跨周期的极度不平衡
	 	 /*利用这种不平衡实现以小博大*/	
		/*1M线快速下降，短期内突破五分钟下轨认为是小转大的行为，挂限时SellStop卖单，卖单成交后，通过移动止损和5分钟线优化订单*/	
		if ((crossflag == -5 )&&(OneMFastDown() ==true)
		&&(OneMOrderCloseStatus(MagicNumberTwo)==true))
		{
			 FiveM_BoolDistance = GlobalVariableGet("g_FiveM_BoolDistance");
			 FiveM_BoolMidLine = GlobalVariableGet("g_FiveM_BoolMidLine");
			 

				orderLots = MyLots*0.2;

				orderPrice = FiveM_BoolMidLine-FiveM_BoolDistance;

				orderTakeProfit = FiveM_BoolMidLine -2*FiveM_BoolDistance;
					
				orderStopless = boll_low_B;
				
		 	 /*防止止损点位太大，保证止损和止盈比小于1：1；*/
		 	 if((orderStopless -(FiveM_BoolMidLine -FiveM_BoolDistance))>FiveM_BoolDistance)
		 	 {
		 	   orderStopless = FiveM_BoolMidLine;
		 	 }
		 	 /*还有一种思路就是以1分钟的bool_lenth和5分钟的bool_lenth作为止损和止盈比*/
		 	 if(2*bool_length < FiveM_BoolDistance)
		 	 {
		 	   orderStopless = FiveM_BoolMidLine - FiveM_BoolDistance + 2*bool_length;		 	 
		 	 }			   			   	 	 		 	 
		 	 	 	  			 	 		 			 	 		 	
		 	 OneMCrossTime = TimeCurrent();
		 	 
			OneMPreOrderMagicTwo.myLots = orderLots;
			OneMPreOrderMagicTwo.myOpenPrice = orderPrice;
			OneMPreOrderMagicTwo.myStopLoss = orderStopless;
			OneMPreOrderMagicTwo.myTakeProfit = orderTakeProfit;
			OneMPreOrderMagicTwo.myOpenTime = OneMCrossTime;
			OneMPreOrderMagicTwo.myPreOrderFlag = true;
			 	 		 
			 	 			 	 
		}
	
	

	  FiveM_BuySellFlag = GlobalVariableGet("g_FiveM_BuySellFlag");

		/*30M线突破上轨后背驰，5分钟盘整或者下跌，一分钟向下，下卖单*/				
		if (FiveM_BuySellFlag <-1.5)
		{
		
			if (((crossflag == -5 )||(crossflag == -1 ))&&(OneMOrderCloseStatus(MagicNumberThree)==true))
			{
				 FiveM_BoolDistance = GlobalVariableGet("g_FiveM_BoolDistance");
				 FiveM_BoolMidLine = GlobalVariableGet("g_FiveM_BoolMidLine");
   	       ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");
      		 FourH_StrongWeak = GlobalVariableGet("g_FourH_StrongWeak");    
		 	 

				 orderLots = NormalizeDouble(MyLots*(1-FourH_StrongWeak),2);
				 
				orderPrice = Bid;				 
			 	orderStopless =MaxValue1; 
		 	   if((orderPrice + 2*FiveM_BoolDistance)< orderStopless)
		 	   {
		 	      orderStopless = orderPrice + 2*FiveM_BoolDistance;
		 	   }		
		 	   else
		 	   {
		 	      orderStopless = orderStopless + 30*Point;
		 	   }		 
				 orderTakeProfit = orderPrice-ThirtyM_BoolDistance;

	
			 	 /*参数修正*/	
	        orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	
          orderStopLevel = orderStopLevel*2;	
					if(orderStopLevel < 1)
					{
						orderStopLevel = 100;
					}	
					
					orderStopless = orderStopless + orderStopLevel*Point;

   		 	 if ((orderStopless-orderPrice ) < orderStopLevel*Point)
   		 	 {
   		 	 		orderStopless = orderPrice + orderStopLevel*Point;
   		 	 }
   		 	 if ((orderPrice-orderTakeProfit) < orderStopLevel*Point)
   		 	 {
   		 	 		orderTakeProfit = orderPrice - orderStopLevel*Point;
   		 	 }
		 	 			 	 		 	 
		 	 	 	  			 	 		 			 	 		 	
		 	 orderPrice = NormalizeDouble(orderPrice,Digits);		 	
		 	 orderStopless = NormalizeDouble(orderStopless,Digits);		 	
		 	 orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 

	
	
	
					Print("MagicNumberThree1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"orderTakeProfit="+orderTakeProfit);
					 		 	 				 		 	 
   	      ticket = OrderSend(Symbol(),OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
   	                       Symbol()+"MagicNumberThree1",MagicNumberThree,0,Blue);
	         if(ticket <0)
	         {
	            Print("OrderSend MagicNumberThree 1 failed with error #",GetLastError());
	         }
	         else
	         {            
	            Print("OrderSend MagicNumberThree 1  successfully");
	         }
	         Sleep(1000);

       }
					 	 			 	 
		}
	
	
   		/*30M线突破上轨后回落到上轨内的上半带，5分钟盘整或者下跌，一分钟向下，下卖单*/				
   		if ((FiveM_BuySellFlag <-0.5)&&(FiveM_BuySellFlag >-1.5))
   		{
   		
   			if (((crossflag == -5 )||(crossflag == -1 ))&&(OneMOrderCloseStatus(MagicNumberThree)==true))
   			{
   				 FiveM_BoolDistance = GlobalVariableGet("g_FiveM_BoolDistance");
   				 FiveM_BoolMidLine = GlobalVariableGet("g_FiveM_BoolMidLine");
   		 	   ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");
       		   FourH_StrongWeak = GlobalVariableGet("g_FourH_StrongWeak");    

	          orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	




				 orderLots = NormalizeDouble(MyLots*(1-FourH_StrongWeak),2);
				 
				orderPrice = Bid;				 
			 	orderStopless =MaxValue2; 
		 	   if((orderPrice + 2*FiveM_BoolDistance)< orderStopless)
		 	   {
		 	      orderStopless = orderPrice + 2*FiveM_BoolDistance;
		 	   }		
		 	   else
		 	   {
		 	      orderStopless = orderStopless + 30*Point;
		 	   }		 
				 orderTakeProfit = orderPrice-ThirtyM_BoolDistance;
	
   		
			 	 /*参数修正*/	
	        orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	
          orderStopLevel = orderStopLevel*2;	
 
					if(orderStopLevel < 1)
					{
						orderStopLevel = 100;
					}	
   			 	 
					orderStopless = orderStopless + orderStopLevel*Point;
   			 	 
    		 	 if ((orderStopless-orderPrice ) < orderStopLevel*Point)
    		 	 {
    		 	 		orderStopless = orderPrice + orderStopLevel*Point;
    		 	 }
    		 	 if ((orderPrice-orderTakeProfit) < orderStopLevel*Point)
    		 	 {
    		 	 		orderTakeProfit = orderPrice - orderStopLevel*Point;
    		 	 }
   		 	 	 	  			 	 		 			 	 		 	
   		 	 orderPrice = NormalizeDouble(orderPrice,Digits);		 	
   		 	 orderStopless = NormalizeDouble(orderStopless,Digits);		 	
   		 	 orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 
   
   	

					Print("MagicNumberThree2 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"orderTakeProfit="+orderTakeProfit);
					 		 	 				 		 	 
   	         ticket = OrderSend(Symbol(),OP_SELL,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
   	                       Symbol()+"MagicNumberThree2",MagicNumberThree,0,Blue);
	
					
 	            if(ticket <0)
   	         {
   	            Print("OrderSend MagicNumberThree 2 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderSend MagicNumberThree 2  successfully");
   	         }
   	         Sleep(1000);

          }						 	 			 	 
   		}
   		
   
   		/*30M线突破下轨后背驰，5分钟盘整或者上升，一分钟向上，下买单*/				
   		if (FiveM_BuySellFlag > 1.5)
   		{
   		
   			if (((crossflag == 5 )||(crossflag == 1 ))&&(OneMOrderCloseStatus(MagicNumberFour)==true))
   			{
               FiveM_BoolDistance = GlobalVariableGet("g_FiveM_BoolDistance");
               FiveM_BoolMidLine = GlobalVariableGet("g_FiveM_BoolMidLine");
               ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");
               FourH_StrongWeak = GlobalVariableGet("g_FourH_StrongWeak");    
    				orderLots = NormalizeDouble(MyLots*FourH_StrongWeak,2);
               orderPrice = Ask;				 
               orderStopless =MinValue1; 
   		 	   if((orderPrice - 2*FiveM_BoolDistance)> orderStopless)
   		 	   {
   		 	      orderStopless = orderPrice - 2*FiveM_BoolDistance;
   		 	   }		
   		 	   else
   		 	   {
   		 	      orderStopless = orderStopless - 30*Point;
   		 	   }		 
   				 orderTakeProfit = orderPrice+ThirtyM_BoolDistance;
   	
    
			 	 /*参数修正*/	
	        orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	
          orderStopLevel = orderStopLevel*2;	
					if(orderStopLevel < 1)
					{
						orderStopLevel = 100;
					}		
					orderStopless = orderStopless - orderStopLevel*Point;

   		 	   if ((orderPrice - orderStopless) < orderStopLevel*Point)
     		 	 {
     		 	 		orderStopless = orderPrice - orderStopLevel*Point;
     		 	 }
     		 	 if ((orderTakeProfit - orderPrice) < orderStopLevel*Point)
     		 	 {
     		 	 		orderTakeProfit = orderPrice + orderStopLevel*Point;
     		 	 }
	 	 		 	 
      		 	 	 	  			 	 		 			 	 		 	
      		 	 orderPrice = NormalizeDouble(orderPrice,Digits);		 	
      		 	 orderStopless = NormalizeDouble(orderStopless,Digits);		 	
      		 	 orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 			 	 		 			 	 		 			 	

	
   					Print("MagicNumberFour1 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
   								+"orderTakeProfit="+orderTakeProfit);
   					 		 	 				 		 	 
      	      ticket = OrderSend(Symbol(),OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
      	                       Symbol()+"MagicNumberFour",MagicNumberFour,0,Blue);
   	
      	         if(ticket <0)
      	         {
      	            Print("OrderSend MagicNumberFour 1 failed with error #",GetLastError());
      	         }
      	         else
      	         {            
      	            Print("OrderSend MagicNumberFour 1  successfully");
      	         }
      	         Sleep(1000);
             }
   					 	 			 	 
   		}
			
   		/*30M线突破下轨后回落到下轨内的下半带，5分钟盘整或者上升，一分钟向上，下买单*/				
   		if ((FiveM_BuySellFlag >0.5)&&(FiveM_BuySellFlag <1.5))
   		{
   		
   			if (((crossflag == 5 )||(crossflag == 1 ))&&(OneMOrderCloseStatus(MagicNumberFour)==true))
   			{
   				 FiveM_BoolDistance = GlobalVariableGet("g_FiveM_BoolDistance");
   				 FiveM_BoolMidLine = GlobalVariableGet("g_FiveM_BoolMidLine");
       		   FourH_StrongWeak = GlobalVariableGet("g_FourH_StrongWeak");    
       	      ThirtyM_BoolDistance = GlobalVariableGet("g_ThirtyM_BoolDistance");
    				orderLots = NormalizeDouble(MyLots*FourH_StrongWeak,2);
               orderPrice = Ask;				 
               orderStopless =MinValue2; 
   		 	   if((orderPrice - 2*FiveM_BoolDistance)> orderStopless)
   		 	   {
   		 	      orderStopless = orderPrice - 2*FiveM_BoolDistance;
   		 	   }		
   		 	   else
   		 	   {
   		 	      orderStopless = orderStopless - 30*Point;
   		 	   }		 
   				 orderTakeProfit = orderPrice+ThirtyM_BoolDistance;

			 	 /*参数修正*/	
	        orderStopLevel =MarketInfo(Symbol(),MODE_STOPLEVEL);			 	 		 			 	 		 	
          orderStopLevel = orderStopLevel*2;	
					if(orderStopLevel < 1)
					{
						orderStopLevel = 100;
					}	
					
					orderStopless = orderStopless - orderStopLevel*Point;
   	
   		 	    if ((orderPrice - orderStopless) < orderStopLevel*Point)
     		 	 {
     		 	 		orderStopless = orderPrice - orderStopLevel*Point;
     		 	 }
     		 	 if ((orderTakeProfit - orderPrice) < orderStopLevel*Point)
     		 	 {
     		 	 		orderTakeProfit = orderPrice + orderStopLevel*Point;
     		 	 }
  		 	 	 	  			 	 		 			 	 		 	
      		 	 orderPrice = NormalizeDouble(orderPrice,Digits);		 	
      		 	 orderStopless = NormalizeDouble(orderStopless,Digits);		 	
      		 	 orderTakeProfit = NormalizeDouble(orderTakeProfit,Digits);	 			 	 		 			 	 		 			 	
      
   	  	
   	   		 	 
 					Print("MagicNumberFour2 OrderSend:" + "orderLots=" + orderLots +"orderPrice ="+	 orderPrice+"orderStopless="+orderStopless
								+"orderTakeProfit="+orderTakeProfit);
					 		 	 				 		 	 
      	      ticket = OrderSend(Symbol(),OP_BUY,orderLots,orderPrice,3,orderStopless,orderTakeProfit,
      	                       Symbol() + "MagicNumberFour2",MagicNumberFour,0,Blue);
   		 	 
     		 	 
   	         if(ticket <0)
   	         {
   	            Print("OrderSend MagicNumberFour 2 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderSend MagicNumberFour 2  successfully");
   	         }
   	         Sleep(1000);
          }						 	 			 	 
	   }

	}

   ////////////////////////////////////////////////////////////////////////////////////////////////
   //订单管理优化，包括移动止损、直接止损、订单时间管理
   //暂时还没有想清楚该如何移动止损优化  
   ////////////////////////////////////////////////////////////////////////////////////////////////
	
	for (i = 0; i < OrdersTotal(); i++)
	{
	
		//OrderType()??
   	if(OrderMagicNumber() == MagicNumberOne)
   	{
   	
      	if (1 == Period() )
      	{   	   
      	   /*五分钟16个周期，理论上应该走完了,时间控制*/
      	   if((TimeCurrent()-OrderOpenTime())>4800)
      	   {
      	      ticket =OrderClose(OrderTicket(),OrderLots(),Bid,5,Red);
      	      
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberOne 1 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberOne 1  successfully");
   	         }    
   	         Sleep(1000);  	   
   	       }
      	   
      	   else if((TimeCurrent()-OrderOpenTime())>3600)
      	   {   	   
      	      if( OrderProfit()> 0)
      	      {
      	           ticket = OrderClose(OrderTicket(),OrderLots(),Bid,5,Red);
      	         if(ticket <0)
      	         {
      	            Print("OrderClose MagicNumberOne 2 failed with error #",GetLastError());
      	         }
      	         else
      	         {            
      	            Print("OrderClose MagicNumberOne 2  successfully");
      	         }    
      	         Sleep(1000);     	           
      	      }   	   
      	   }  	
      	
      	}
       	if (5 == Period() )
      	{   	   
      	   /*五分钟明显处于下行*/
      	   if(((crossflag ==-1 )||(crossflag ==-5))
      	   	&&((CrossValue[1]!=4)&&(CrossValue[1]!=5)))
      	   {
	      	      ticket = OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
	      	      
	    	        if(ticket <0)
	   	         {
	   	            Print("OrderClose MagicNumberOne 3 failed with error #",GetLastError());
	   	         }
	   	         else
	   	         {            
	   	            Print("OrderClose MagicNumberOne 3  successfully");
	   	         }   
	   	         Sleep(1000);     	      
      	   }
      	    	
      	}  	  		
   	
   	}
   	
   	if(OrderMagicNumber() == MagicNumberTwo)
   	{
   	
      	if (1 == Period() )
      	{   	   
      	   /*五分钟16个周期，理论上应该走完了,时间控制*/
      	   if((TimeCurrent()-OrderOpenTime())>4800)
      	   {
      	      ticket = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberTwo 1  failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberTwo 1   successfully");
   	         }   
   	         Sleep(1000);      	      
      	      
      	   }
      	   
      	   else if((TimeCurrent()-OrderOpenTime())>3600)
      	   {   	   
      	      if( OrderProfit()> 0)
      	      {
      	          ticket = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
	      	           
	      	         if(ticket <0)
	      	         {
	      	            Print("OrderClose MagicNumberTwo 2 failed with error #",GetLastError());
	      	         }
	      	         else
	      	         {            
	      	            Print("OrderClose MagicNumberTwo 2   successfully");
	      	         }       
	      	         Sleep(1000);  	           
      	      }   	   
      	   }  	
      	
      	}
       	if (5 == Period() )
      	{   	   
      	   /*五分钟明显处于上行行*/
      	   if(((crossflag ==1 )||(crossflag ==5))
      	   	&&((CrossValue[1]!=-4)&&(CrossValue[1]!=-5)))
      	   
      	   {
	      	     ticket = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
    	         if(ticket <0)
	   	         {
	   	            Print("OrderClose MagicNumberTwo 3 failed with error #",GetLastError());
	   	         }
	   	         else
	   	         {            
	   	            Print("OrderClose MagicNumberTwo 3  successfully");
	   	         }       
	   	         Sleep(1000); 	      
      	      
      	   }
      	    	
      	}  	  		
   	
   	}
   		
    if(OrderMagicNumber() == MagicNumberThree)
   	{
   	
      	if (1 == Period() )
      	{   	   
      	   /*30分钟16个周期，理论上应该走完了,时间控制*/
      	   if((TimeCurrent()-OrderOpenTime())>28800)
      	   {
      	      ticket = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberThree 1 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberThree 1  successfully");
   	         }         
   	         Sleep(1000);	      
      	      
      	   }
      	   
      	   else if((TimeCurrent()-OrderOpenTime())>21600)
      	   {   	   
      	      if( OrderProfit()> 0)
      	      {
      	           ticket = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
      	           
          	         if(ticket <0)
         	         {
         	            Print("OrderClose MagicNumberThree 2 failed with error #",GetLastError());
         	         }
         	         else
         	         {            
         	            Print("OrderClose MagicNumberThree 2  successfully");
         	         }    
         	         Sleep(1000);    	           
         	    }   	   
      	   }  	
      	
      	}
       	if (30 == Period() )
      	{   	   
      	   if((crossflag ==1 )||(crossflag ==5))
      	   {
      	      ticket = OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
      	      
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberThree 2 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberThree 2  successfully");
   	         }    
   	         Sleep(1000);     	      
      	   }
      	    	
      	}  	  		
   	
   	}  	
   	
	   if(OrderMagicNumber() == MagicNumberFour)
   	{
   	
      	if (1 == Period() )
      	{   	   
      	   /*30分钟16个周期，理论上应该走完了,时间控制*/
      	   if((TimeCurrent()-OrderOpenTime())>28800)
      	   {
      	      ticket = OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberFour 1 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberFour 1  successfully");
   	         }   
   	         Sleep(1000);      	      
      	      
      	   }
      	   
      	   else if((TimeCurrent()-OrderOpenTime())>21600)
      	   {   	   
      	      if( OrderProfit()> 0)
      	      {
      	           ticket = OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
      	           
      	         if(ticket <0)
      	         {
      	            Print("OrderClose MagicNumberFour 2 failed with error #",GetLastError());
      	         }
      	         else
      	         {            
      	            Print("OrderClose MagicNumberFour 2  successfully");
      	         }   
      	         Sleep(1000);       	           
      	      }   	   
      	   }  	
      	
      	}
       	if (30 == Period() )
      	{   	   
      	   if((crossflag ==-1 )||(crossflag ==-5))
      	   {
      	      ticket = OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
      	      
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberFour 3 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberFour 3  successfully");
   	         }   
   	         Sleep(1000);       	      
      	   }
      	    	
      	}  	  		
   	
   	}  	
   	
   	if(OrderMagicNumber() == MagicNumberFive)
   	{
   	
      	if (5 == Period() )
      	{   	   
      	   /*五分钟10个周期，理论上应该走完了,时间控制*/
      	   if((TimeCurrent()-OrderOpenTime())>3000)
      	   {
      	      ticket =OrderClose(OrderTicket(),OrderLots(),Bid,5,Red);
      	      
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberFive 1 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberFive 1  successfully");
   	         }    
   	         Sleep(1000);  	   
   	       }
      	   
      	   else if((TimeCurrent()-OrderOpenTime())>4500)
      	   {   	   
      	      if( OrderProfit()> 0)
      	      {
      	           ticket = OrderClose(OrderTicket(),OrderLots(),Bid,5,Red);
      	         if(ticket <0)
      	         {
      	            Print("OrderClose MagicNumberFive 2 failed with error #",GetLastError());
      	         }
      	         else
      	         {            
      	            Print("OrderClose MagicNumberFive 2  successfully");
      	         }    
      	         Sleep(1000);     	           
      	      }   	   
      	   }  	
      	
      	}
  	
   	}   	
   	
   	
   	
   	if(OrderMagicNumber() == MagicNumberSix)
   	{
   	
      	if (5 == Period() )
      	{   	   
      	   /*五分钟10个周期，理论上应该走完了,时间控制*/
      	   if((TimeCurrent()-OrderOpenTime())>3000)
      	   {
      	      ticket =OrderClose(OrderTicket(),OrderLots(),Ask,5,Red);
      	      
   	         if(ticket <0)
   	         {
   	            Print("OrderClose MagicNumberSix 1 failed with error #",GetLastError());
   	         }
   	         else
   	         {            
   	            Print("OrderClose MagicNumberSix 1  successfully");
   	         }    
   	         Sleep(1000);  	   
   	       }
      	   
      	   else if((TimeCurrent()-OrderOpenTime())>4500)
      	   {   	   
      	      if( OrderProfit()> 0)
      	      {
      	           ticket = OrderClose(OrderTicket(),OrderLots(),Ask,5,Red);
      	         if(ticket <0)
      	         {
      	            Print("OrderClose MagicNumberSix 2 failed with error #",GetLastError());
      	         }
      	         else
      	         {            
      	            Print("OrderClose MagicNumberSix 2  successfully");
      	         }    
      	         Sleep(1000);     	           
      	      }   	   
      	   }  	
      	
      	}
  	
   	}   	
   	

   	
   	

	}
			
			
/////////////////////////////////////////////////////////
	

   OneMSaveOrder();
   PrintFlag = true;
   ChartEvent = iBars(NULL,0);
     
   return;

  }
//+------------------------------------------------------------------+
