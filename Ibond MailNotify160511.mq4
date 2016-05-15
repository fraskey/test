
//+------------------------------------------------------------------+
//|                                             Ibond.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2016, Xuejiayong."
#property link        "http://www.mql14.com"

//input double TakeProfit    =50;
input double Lots          =0.1;
//input double TrailingStop  =30;

input int Move_Av = 2;
input int iBoll_B = 60;
input int iBoll_S = 20;

//input double MACDOpenLevel =3;
//input double MACDCloseLevel=2;
//input int    MATrendPeriod =26;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/////////////////////////////////////////////////////////////////////

//extern double g_HL_Direction ;
double ma_pre;
double boll_up_B_pre,boll_low_B_pre,boll_mid_B_pre;
double boll_up_S_pre,boll_low_S_pre,boll_mid_S_pre;


//当前周期，最大值上穿60 boll周期上轨，或者下穿boll周期下轨，邮件提醒关注。

int init()
{
			 
	
      string MailTitlle ="";

      if (240 == Period() )
      {
          MailTitlle = MailTitlle +"4H";
      
      }
      else if (30 == Period() )
      {
         MailTitlle = MailTitlle +"30M";
      
      }
      else if (5 == Period() )
      {
         MailTitlle = MailTitlle +"5M";
      
      }
      else if (1 == Period() )
      {
         MailTitlle = MailTitlle +"1M";
      
      }            
      else
      {
         MailTitlle = MailTitlle + "Bad Time period，should 1M 5M 30M or 4H" + Period();
      }
      MailTitlle = "Init:" + MailTitlle +  Symbol();
   // OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"macd sample",16384,0,Red);
//   SendMail("Start watching:"+Symbol()+IntegerToString(Period())," ");  	 
 

      SendNotification(MailTitlle);  
        
      return 0;
}


int deinit()
{
   return 0;
}

int ChartEvent = 0;
bool PrintFlag = false;

void OnTick(void)
{

   double ma;
   double boll_up_B,boll_low_B,boll_mid_B,bool_length;
   string mMailTitlle = "";
//---
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external 
// variables (Lots, StopLoss, TakeProfit, 
// TrailingStop) in our case, we check TakeProfit
// on a chart of less than 100 bars
//---

   if(iBars(NULL,0) <100)
   {
      Print("TimeFrame 5 min bars less than 10");
      return;
   }
   
   if ( ChartEvent != iBars(NULL,0))
   {
      PrintFlag = false;
   }   
   
   if ( PrintFlag == true)
   {
      return;
   }
   
   if (240 == Period() )
   {
      mMailTitlle = mMailTitlle +"!!"+"4H ";
   
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
		if((ma >boll_up_B) && (ma_pre < boll_up_B_pre ) )
		{
	      SendNotification(mMailTitlle + Symbol()+"::本周期突破高点，除(1M、5M周期bool口收窄且快速突破追高，移动止损），其他情况择机反向做空:"
	      + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
         PrintFlag = true;
		}
		
		/*本周期突破高点后回调，观察如小周期长时间筑顶，寻机卖出*/
		if((ma <boll_up_B) && (ma_pre > boll_up_B_pre ) )
		{
	      SendNotification(mMailTitlle + Symbol()+"::本周期突破高点后回调，观察小周期如长时间筑顶，寻机做空:"
	      + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      
         PrintFlag = true;

		}
			
		
		/*本周期突破低点，观察如小周期未衰竭可追低卖出，或者等待回调卖出*/
		if((ma < boll_low_B) && (ma_pre > boll_low_B_pre ) )
		{
	      SendNotification(mMailTitlle + Symbol() + "::本周期突破低点，除(条件：1M、5M周期bool口收窄且快速突破追低，移动止损），其他情况择机反向做多:"
	      + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
         PrintFlag = true;

		}
			
		/*本周期突破低点后回调，观察如长时间筑底，寻机买入*/
		if((ma > boll_low_B) && (ma_pre < boll_low_B_pre ) )
		{
	      SendNotification(mMailTitlle + Symbol() + "::本周期突破低点后回调，观察如小周期长时间筑底，寻机买入:"
	      + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
         PrintFlag = true;

		}

		/*一分钟周期太短*/
   if (1 != Period() )
   {
   			
				/*本周期上穿中线，表明本周期趋势开始发生变化为上升，在下降大趋势下也可能是回调杀入机会*/
				if((ma > boll_mid_B) && (ma_pre < boll_mid_B_pre ))
				{
			      SendNotification(mMailTitlle + Symbol() + "::本周期上穿中线变化为上升，大周期下降大趋势下可能是回调做空机会："
			      + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
               PrintFlag = true;

				}	
				/*本周期下穿中线，表明趋势开始发生变化，在上升大趋势下也可能是回调杀入机会*/
				if( (ma < boll_mid_B) && (ma_pre > boll_mid_B_pre ))
				{
			      SendNotification(mMailTitlle + Symbol() + "::本周期下穿中线变化为下降，大周期上升大趋势下可能是回调做多机会："
			      + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));  	  	      	      	      
               PrintFlag = true;

				}							
		}
		
		/*本周期短线突破高点，可能本周期趋势，小周期强势时短期可追*/
		//if((ma >boll_up_S) && (ma_pre < boll_up_S_pre ) && 0 )
		//{
	  //    SendNotification(mMailTitlle + Symbol()+" SH:"
	  //    +"::Short term Higher,If short term stornger ,Then Buy Little");  	  	      	      
		//}
		

		/*本周期短线突破低点，可能本周期趋势，小周期强势时短期可追*/
		//if((ma <boll_low_S) && (ma_pre > boll_low_S_pre ) && 0 )
		//{
	  //    SendNotification(mMailTitlle + Symbol()+" SL:"+"::Short term Lower,If short term stornger ,Then Sell Little");
		//}
		

   ChartEvent = iBars(NULL,0);
     
   return;

  }
//+------------------------------------------------------------------+
