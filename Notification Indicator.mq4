#property indicator_chart_window
datetime dt;
int oldtemp;
int oldhist;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   dt = Time[0];
   oldtemp = 0;
   oldhist = OrdersHistoryTotal();
   Comment("\nNotification Indicator v.1\nWilson Lim"); 
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
 
 
    /////////////////////////////////
   //for opened and pending orders//
   ///////////////////////////////// 
  
   if (oldtemp < OrdersTotal())
   {
      string message;
   
      OrderSelect(OrdersTotal()-1, SELECT_BY_POS);
   
     //BUY
      if(OrderType()==OP_BUY && OrderCloseTime()==0 && OrderSymbol() == Symbol()) {
      message="OPEN BUY: "+Symbol()+" ticket:"+OrderTicket()+" size:"+DoubleToStr(OrderLots(),2)+" price:"+DoubleToStr(OrderOpenPrice(),5)+" equity:"+DoubleToStr(AccountEquity(),2);
      SendNotification(message);
      }
   
     //SELL
      if(OrderType()==OP_SELL && OrderCloseTime()==0 && OrderSymbol() == Symbol()) {
      message="OPEN SELL: "+Symbol()+" ticket:"+OrderTicket()+" size:"+DoubleToStr(OrderLots(),2)+" price:"+DoubleToStr(OrderOpenPrice(),5)+" equity:"+DoubleToStr(AccountEquity(),2);
      SendNotification(message);
      }
        
   }
      oldtemp = OrdersTotal();
  
  
   ////////////////////////////////
   //for closed or canceled orders//
   ////////////////////////////////

   if (oldhist < OrdersHistoryTotal())
   {
      OrderSelect(OrdersHistoryTotal()-1, SELECT_BY_POS,MODE_HISTORY);
	  
	  //BUY CLOSE
      if(OrderType()==OP_BUY && OrderCloseTime()>0 && OrderSymbol() == Symbol()) {
      message="CLOSE BUY: "+Symbol()+" ticket:"+OrderTicket()+" size:"+DoubleToStr(OrderLots(),2)+" close:"+DoubleToStr(OrderClosePrice(),5)+" profit:"+DoubleToStr(OrderProfit(),2)+" equity:"+DoubleToStr(AccountEquity(),2);
      SendNotification(message);	  
      }
		
	  //SELL CLOSE	
      if(OrderType()==OP_SELL && OrderCloseTime()>0 && OrderSymbol() == Symbol()) {
      message="CLOSE SELL: "+Symbol()+" ticket:"+OrderTicket()+" size:"+DoubleToStr(OrderLots(),2)+" close:"+DoubleToStr(OrderClosePrice(),5)+" profit:"+DoubleToStr(OrderProfit(),2)+" equity:"+DoubleToStr(AccountEquity(),2);
      SendNotification(message);	  
      }
   }
      oldhist = OrdersHistoryTotal();
 

   
//----
   return(0);
  }
//+------------------------------------------------------------------+