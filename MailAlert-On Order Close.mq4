//+------------------------------------------------------------------+
//|                                               MailAlert TEST.mq4 |
//|                                                      Nicholishen |
//|                                                                  |
//+------------------------------------------------------------------+
//http://www.forex-tsd.com/metatrader-4/1125-code-send-email-alerts-when-closed-trades.html
#property copyright "Nicholishen"
#property link      ""
int k;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
for(int i=0;i<1000;i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
         if(OrderSymbol()==Symbol()  ){
            k++;
         }
      }else{
         break;
      }  
   }
   Comment("Init() Trades Count = ",k);
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----

int f =0;
   for(int i=0;i<10000;i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
         if(OrderSymbol()==Symbol() /*&& OrderMagicNumber()==MAGICMA && OrderComment() ==Cmt(Period())*/ ){
            f++;
          
         }
      }else{
         break;
      }  
   }
   Comment(" Trades in History ",f," Init cnt ",k  );
   if(k < f){
      string ordertyp;
      
      OrderSelect(f,SELECT_BY_POS,MODE_HISTORY);
      if(OrderType()==0)ordertyp="BUY";
      if(OrderType()==1)ordertyp="SELL";
     // SendMail("HI","HI");
      SendMail("CLOSED TRADE","  "+Symbol()+"    OpenTime: "+TimeToStr(OrderOpenTime())+"   Close Time: "+TimeToStr(OrderCloseTime())+"                     "+
      "Order Type "+ordertyp+"   Open "+DoubleToStr(OrderOpenPrice(),4)+"   Close "+DoubleToStr(OrderClosePrice(),4)+"  Profit ("+DoubleToStr(OrderProfit(),4)+")" );
      k++;
   }
 return;
} 


//----
  
//+------------------------------------------------------------------+