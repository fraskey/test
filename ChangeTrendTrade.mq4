//+------------------------------------------------------------------+
//|                                                      MyTrade.mq4 |
//|                                                       xuejiayong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "xuejiayong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int MagicNumber;

//+------------------------------------------------------------------+
//| 定义外部变量                                                     |
//+------------------------------------------------------------------+


extern double TakeProfit = 100;//止赢点数
extern   double StopLoss = 20; //止损点数
extern double MyLots = 0.01;//交易手数
extern double TrailingStop =25;//跟踪止赢点数

extern bool UpTrendFlag = true;//上升标记
extern bool DownTrendFlag = true;//下降标记
extern double UpTrendValue = -10;//升突破值
extern double DownTrendValue = -10; //降突破值

extern double UpTrendStopLossValue = -10;//升止损值
extern double DownTrendStopLossValue = -10; //降止损值


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      string MailTitlle ="";

      if (5 == Period() )
      {
          MailTitlle = MailTitlle +"5M";
      
      }
      else
      {
         MailTitlle = MailTitlle + "Bad Time period，should 30M or 4H";
      }
      MailTitlle = "Init:" + MailTitlle +  Symbol();
      SendNotification(MailTitlle);   
   MagicNumber = 100;
	return(0);
//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   return;
  }
  
  
  
  bool CheckOpenUPTrade ( )
  {
     bool retval = false;
     if ((Ask > UpTrendValue)&&(iHigh(NULL,0,1) <  UpTrendValue))
     retval = true;
     return retval; 
  }
  
  
  bool CheckOpenDownTrade ( )
  {
     bool retval = false;
     if ((Bid < DownTrendValue)&&(iLow(NULL,0,1) >  DownTrendValue))
     retval = true;
     return retval; 
  }
  
  
  
   bool OrderUpFlag = false;
   bool OrderDownFlag = false;
   datetime UpTradeTime;
   datetime DownTradeTime;
   
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   bool bs = false;
   int i = 0;
   int ticket = -1;
   
   
   //输入参数有效性检测
   if((UpTrendFlag == true)&&((UpTrendValue <0)||(UpTrendStopLossValue<0)||(UpTrendValue <UpTrendStopLossValue)))
   {
     return ;
   }
   
   if((DownTrendFlag == true)&&((DownTrendValue <0)||(DownTrendStopLossValue<0)||(DownTrendValue >DownTrendStopLossValue)))
   {
     return ;
   }
   if((UpTrendFlag == false) &&(DownTrendFlag == false))
   {
     return ;
   }
   
   //Five minutes Period
   if (5 == Period() )
   {
   // MailTitlle = MailTitlle +"5M";
   ;
   }
   else
   {
  // MailTitlle = MailTitlle + "Bad Time period，should 30M or 4H";
   return ;
   }
   
   //向上拉升，点位确认，跟进做多
  if((CheckOpenUPTrade ( ) ==true) &&(UpTrendFlag == true)&&(OrderUpFlag == false))
  {
       Print("Uptrend  successfully");
      
      ticket = OrderSend(Symbol(),OP_BUY,MyLots,Ask,6,UpTrendStopLossValue,TakeProfit,"My Buy trade",MagicNumber,0,Blue);
      if(ticket <0)
      {
         Print("OrderSend failed with error #",GetLastError());
      }
      else
      {
         
         Print("OrderSend Buy placed successfully");
         UpTradeTime = TimeCurrent();
         OrderUpFlag = true;
      }
   }
       //向下突破，跟进卖空  
   if((CheckOpenDownTrade ( ) ==true) &&(DownTrendFlag == true)&&(OrderDownFlag == false))
  {
       Print("Downtrend  successfully");       
         ticket = OrderSend(Symbol(),OP_SELL,MyLots,Bid,6,DownTrendStopLossValue,TakeProfit,"My Sell trade",MagicNumber,0,Blue);
         if(ticket <0)
         {
            Print("OrderSend failed with error #",GetLastError());
         }
         else
         {
            Print("OrderSend Sell placed successfully");
            DownTradeTime = TimeCurrent();
            OrderDownFlag = true;
         }
  }
  
  //移动止损
   for (i = 0; i < OrdersTotal(); i++)
   {
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
     
     if ((OrderType() == OP_BUY)&&(OrderMagicNumber()== MagicNumber))
     {          
        //持仓时间不超过30分钟
        if(((TimeMinute(TimeCurrent()) - TimeMinute(UpTradeTime) >= -30 )&&(TimeMinute(TimeCurrent()) - TimeMinute(UpTradeTime) <0))
        ||(TimeMinute(TimeCurrent()) - TimeMinute(UpTradeTime) >= 30 ))
        {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
            {
               OrderUpFlag = false;
               Sleep(500);
            }
            else
            {
               Print("OrderClose failed with error #",GetLastError());
            
            }
          
        }
        else
        {

     
          if ((Bid - UpTrendStopLossValue) > (TrailingStop * Point))    //初始止损价格 当前止损和当前价格比较判断是否要修改跟踪止赢设置
          {
             if (OrderStopLoss() < Bid - TrailingStop * Point)
             {
               bs = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * Point, OrderTakeProfit(),0, Green);
             }
          }
        }
     }
     
     else if ((OrderType() == OP_SELL)&&(OrderMagicNumber()== MagicNumber))
     {
     
         //持仓时间不超过30分钟
        if(((TimeMinute(TimeCurrent()) - TimeMinute(DownTradeTime) >= -30 )&&(TimeMinute(TimeCurrent()) - TimeMinute(DownTradeTime) <0))
        ||(TimeMinute(TimeCurrent()) - TimeMinute(DownTradeTime) >= 30 ))
        {
            if( OrderClose(OrderTicket(),OrderLots(),Ask,3,White))                
            {
               OrderDownFlag = false;
               Sleep(500);
            }
            else
            {
               Print("OrderClose failed with error #",GetLastError());
            
            }
                          
                
        }
        else
        {
       
          if ((DownTrendStopLossValue - Ask) > (TrailingStop * Point))  //开仓价格 当前止损和当前价格比较判断是否要修改跟踪止赢设置
          {
             if ((OrderStopLoss()) > (Ask + TrailingStop * Point))
             {
               bs = OrderModify(OrderTicket(), OrderOpenPrice(),
                 Ask + TrailingStop * Point, OrderTakeProfit(),0, Tan);
            }
          }
        }
     }
     if((OrderCloseTime() != 0)&&(OrderMagicNumber()== MagicNumber))
     {
     
      OrderDownFlag = false;
      OrderUpFlag = false;
     
     }
   }
  
	return;
   
  }


