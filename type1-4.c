/*
 * Copyright (c) 2009 Dukascopy (Suisse) SA. All Rights Reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * -Redistribution of source code must retain the above copyright notice, this
 *  list of conditions and the following disclaimer.
 * 
 * -Redistribution in binary form must reproduce the above copyright notice, 
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 * 
 * Neither the name of Dukascopy (Suisse) SA or the names of contributors may 
 * be used to endorse or promote products derived from this software without 
 * specific prior written permission.
 * 
 * This software is provided "AS IS," without a warranty of any kind. ALL 
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING
 * ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
 * OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. DUKASCOPY (SUISSE) SA ("DUKASCOPY")
 * AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE
 * AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS
 * DERIVATIVES. IN NO EVENT WILL DUKASCOPY OR ITS LICENSORS BE LIABLE FOR ANY LOST 
 * REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, 
 * INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY 
 * OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, 
 * EVEN IF DUKASCOPY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 */
package singlejartest;

import com.dukascopy.api.*;
import com.dukascopy.api.IEngine.OrderCommand;
import com.dukascopy.api.IIndicators.AppliedPrice;
import com.dukascopy.api.IIndicators.MaType;
import com.dukascopy.connector.engine.MQL4Connector;
import com.dukascopy.connector.engine.MQL4ConnectorIndicator;
import com.dukascopy.converter.lib.TimeWrapperMql;







//////////////////////////////////////////////
//new added 
import java.awt.Color;

import com.dukascopy.connector.engine.*;
import com.dukascopy.converter.helpers.*;
import com.dukascopy.converter.helpers.ref.*;
import com.dukascopy.converter.lib.*;
import com.dukascopy.converter.lib.objects.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.*; 

//end new added
//////////////////////////////////////////////

public class Test  implements IStrategy  {
    private IEngine engine = null;
    private IIndicators indicators = null;
    private IConsole console;
    private IHistory history;
    
    
      @Configurable("Stop Loss In Pips L")
    public int StopLossInPipsL = 4;
     @Configurable("Stop Loss In Pips H")
    public int StopLossInPipsH = 5;   
//    public Instrument instrument = Instrument.EURUSD;
    
//////////////////////////////////////////////
//new added 
    
    
    static String timeZone = "GMT+3";
    
     double MyLotsH = 0;
     double MyLotsL = 0;
     int Move_Av = 0;
     int iBoll_B = 0;
//     public int[] timeperiod;
     int TimePeriodNum = 0;

     double ma_pre = 0;
     double boll_up_B_pre = 0;
     double boll_low_B_pre = 0;
     double boll_mid_B_pre = 0;
     int MagicNumberOne = 0;

     int MagicNumberTwo = 0;
     int MagicNumberThree = 0;
     int MagicNumberFour = 0;
     int MagicNumberFive = 0;
     int MagicNumberSix = 0;
     int MagicNumberSeven = 0;
     int MagicNumberEight = 0;
     int MagicNumberNine = 0;
     int MagicNumberTen = 0;
     int MagicNumberEleven = 0;
     int MagicNumberTwelve = 0;
     int MagicNumberThirteen = 0;
     int MagicNumberFourteen = 0;
     int MagicNumberFifteen = 0;
     int MagicNumberSixteen = 0;
//     public String[] MySymbol;
     int symbolNum = 0;
     int Freq_Count = 0;
     int TwentyS_Freq = 0;
     int OneM_Freq = 0;
     int ThirtyS_Freq = 0;
     int FiveM_Freq = 0;
     int ThirtyM_Freq = 0;
     public stBuySellPosRecord[] BuySellPosRecord ;
     public stOrderRecord[] OrderRecord;
     public stBoolCrossRecord[][] BoolCrossRecord;
     boolean iddataoptflag = false;
     boolean iddatarecovflag = false;
     int ChartEvent = 0;
     boolean PrintFlag = false;

    
     
     //public Instrument instrument = Instrument.EURUSD;
     
     public Instrument[] MySymbol;
     public Period[] timeperiod;
     

     { try {
         MyLotsH=1;
         MyLotsL=1;
         Move_Av=3;
         iBoll_B=60;

         TimePeriodNum=6;
         ma_pre = 0.0;
         boll_up_B_pre = 0.0;
         boll_low_B_pre = 0.0;
         boll_mid_B_pre = 0.0;
         
         MagicNumberOne=10;
         MagicNumberTwo=20;
         MagicNumberThree=30;
         MagicNumberFour=40;
         MagicNumberFive=50;
         MagicNumberSix=60;
         MagicNumberSeven=70;
         MagicNumberEight=80;
         MagicNumberNine=90;
         MagicNumberTen=100;
         MagicNumberEleven=110;
         MagicNumberTwelve=120;
         MagicNumberThirteen=130;
         MagicNumberFourteen=140;
         MagicNumberFifteen=150;
         MagicNumberSixteen=160;
         //MySymbol = new String[50];
         symbolNum = 0;
         Freq_Count=0;
         TwentyS_Freq=0;
         OneM_Freq=0;
         ThirtyS_Freq=0;
         FiveM_Freq=0;
         ThirtyM_Freq=0;
         
         
         //BuySellPosRecord = new stBuySellPosRecord[50];
         //OrderRecord = new stOrderRecord[100];
         //BoolCrossRecord = new stBoolCrossRecord[50][16];
            BuySellPosRecord = new stBuySellPosRecord[50];
            OrderRecord= new stOrderRecord[100];
            BoolCrossRecord= new stBoolCrossRecord[50][16];        
            
                 
         for(int i = 0; i < 50; i ++)
         {
             BuySellPosRecord[i] = new stBuySellPosRecord();
             BuySellPosRecord[i].NextModifyPos = new int[20];
             BuySellPosRecord[i].TradeTimePos = new int[20];             
             BuySellPosRecord[i].NextModifyValue1 = new double[20];
             BuySellPosRecord[i].NextModifyValue2 = new double[20];             
             
             for(int j= 0; j < 16;j++)
             {
                 BoolCrossRecord[i][j] = new stBoolCrossRecord();
                 BoolCrossRecord[i][j].CrossFlag = new int[10];
                 BoolCrossRecord[i][j].CrossBoolPos = new int[10];        
                 BoolCrossRecord[i][j].CrossStrongWeak = new double[10];
                 BoolCrossRecord[i][j].CrossTrend = new double [10];          
                 
             }          
             
         }       
         for(int i = 0; i < 100; i ++)
         {
             OrderRecord[i] = new stOrderRecord();
         }
         
        
         
         iddataoptflag=false;
         iddatarecovflag=false;
         ChartEvent=0;
         PrintFlag=false;    
         MySymbol = new Instrument[50] ;
         timeperiod = new Period[16];
                  
        // timeperiod = new Period[10] ;
         
         } catch(JFException e) {throw new Error(e);}}     
//end new added      
////////////////////////////////////    
     
///////////////////////////////////////////////////    
     
////////////////////////////
//new added
//MT4函数适配层     
public int getsympos(Instrument my_symbol)     
{
    int SymPos;
    for(SymPos = 0; SymPos < symbolNum;SymPos++)
    {    
        if(my_symbol == MySymbol[SymPos])
        {
            break;
        }    
    }
    
    if(SymPos == symbolNum)
    {
 //       String s =  "test!!! = " + my_symbol +":bad:";
//        console.getOut().println(s); 
                 
//        console.getOut().println("getsympos error");
        SymPos = -1;
    }
    return SymPos;
}
    
public int gettimeperiod(Period my_timeperiod)     
{
    int timeperiodnum;
        for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
        {    
            if(my_timeperiod == timeperiod[timeperiodnum])
            {
                break;
            }                
            
        }
        if(timeperiodnum == TimePeriodNum)
        {          
            timeperiodnum = -1;
        }
        
    return timeperiodnum;
}

public int iBars(Instrument my_symbol,Period my_timeperiod) throws JFException
{
    int SymPos,timeperiodnum;
    SymPos = getsympos(my_symbol) ;
    timeperiodnum =gettimeperiod(my_timeperiod);
    if((-1 != SymPos)&&(-1 != timeperiodnum))
    {
        return BoolCrossRecord[SymPos][timeperiodnum].iBarPos;
    }
    else
    {
        return -1;
    }
}
//end new added     
////////////////////////////     


///////////////////////////////
//new added 
public void initsymbol(IContext context)
{
    int i;
    Set<Instrument> myinstruments = new HashSet<Instrument>(); 

     if(true)
    {            
    myinstruments.add(Instrument.EURUSD);
    myinstruments.add(Instrument.AUDUSD);
    myinstruments.add(Instrument.USDJPY);
    
    myinstruments.add(Instrument.XAUUSD);
    myinstruments.add(Instrument.GBPUSD); 
   
    myinstruments.add(Instrument.CADCHF);    
    myinstruments.add(Instrument.EURCAD);
      
    myinstruments.add(Instrument.GBPAUD);    
    myinstruments.add(Instrument.AUDJPY);    
    myinstruments.add(Instrument.EURJPY);    
    myinstruments.add(Instrument.GBPJPY);    
    myinstruments.add(Instrument.USDCAD);    
    myinstruments.add(Instrument.AUDCAD);
    myinstruments.add(Instrument.AUDCHF);    
    myinstruments.add(Instrument.CADJPY);    

    myinstruments.add(Instrument.EURAUD);    
    myinstruments.add(Instrument.GBPCHF);    
    myinstruments.add(Instrument.NZDCAD);    
    myinstruments.add(Instrument.NZDUSD);    

    myinstruments.add(Instrument.NZDJPY);    
    myinstruments.add(Instrument.USDCHF);    
    myinstruments.add(Instrument.EURGBP);    
    myinstruments.add(Instrument.EURCHF);    
    myinstruments.add(Instrument.AUDNZD);    
    myinstruments.add(Instrument.CHFJPY);    
    myinstruments.add(Instrument.EURNZD);    
    myinstruments.add(Instrument.GBPCAD);    
    myinstruments.add(Instrument.GBPNZD);    
    myinstruments.add(Instrument.USDSGD);    
    myinstruments.add(Instrument.USDZAR);
    
/////////////////////////////    
        
    
 //////////////////////////////////////////   
    
 //////////////////////////////////////////   
    }

    context.setSubscribedInstruments(myinstruments);

    // wait max 1 second for the instruments to get subscribed
    i = 20;
    while (!context.getSubscribedInstruments().containsAll(myinstruments) && i>=0) {
        try {
            console.getOut().println("Instruments not subscribed yet " + i);
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            console.getOut().println(e.getMessage());
        }
        i--;
    }    
        

    MySymbol[0] = Instrument.EURUSD;
    MySymbol[1] = Instrument.AUDUSD;

    MySymbol[2] = Instrument.USDJPY;         
    MySymbol[3] = Instrument.XAUUSD;         
    MySymbol[4] = Instrument.GBPUSD;  
           
    MySymbol[5] = Instrument.CADCHF; 
    MySymbol[6] = Instrument.EURCAD;     
    MySymbol[7] = Instrument.GBPAUD;     
    MySymbol[8] = Instrument.AUDJPY;         
    MySymbol[9] = Instrument.EURJPY; 
    MySymbol[10] = Instrument.GBPJPY;     
    MySymbol[11] = Instrument.USDCAD; 
    MySymbol[12] = Instrument.AUDCAD;     
    MySymbol[13] = Instrument.AUDCHF; 
    MySymbol[14] = Instrument.CADJPY; 
    MySymbol[15] = Instrument.EURAUD; 
    MySymbol[16] = Instrument.GBPCHF; 
    MySymbol[17] = Instrument.NZDCAD; 
    MySymbol[18] = Instrument.NZDUSD; 
    MySymbol[19] = Instrument.NZDJPY; 
    MySymbol[20] = Instrument.USDCHF;
     
    MySymbol[21] = Instrument.EURGBP;     
    MySymbol[22] = Instrument.EURCHF;     
    MySymbol[23] = Instrument.AUDNZD;     
    MySymbol[24] = Instrument.CHFJPY;     
    MySymbol[25] = Instrument.EURNZD;     
    
    MySymbol[26] = Instrument.GBPCAD;     
    MySymbol[27] = Instrument.GBPNZD;     
    
    MySymbol[28] = Instrument.USDSGD;     
    MySymbol[29] = Instrument.USDZAR;     


  
    symbolNum = 30;
    
    
    
}

public String MakeMagic(int SymPos,int Magic)
{
    String s;
    Instrument my_symbol;
   my_symbol =   MySymbol[SymPos];
   s = my_symbol.name()+ Magic;
   return s;
}


public void inittiimeperiod()
{
    timeperiod[0] = Period.ONE_MIN;
    timeperiod[1] = Period.FIVE_MINS;
    timeperiod[2] = Period.THIRTY_MINS;
    timeperiod[3] = Period.FOUR_HOURS;
    timeperiod[4] = Period.DAILY;
    timeperiod[5] = Period.WEEKLY;
    
    TimePeriodNum = 6;    
}



public void initmagicnumber()
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



public void InitBarPos()throws JFException
{
    int SymPos,timeperiodnum;
    Instrument my_symbol;
    Period my_timeperiod;
    for(SymPos = 0; SymPos < symbolNum;SymPos++)
    {   
        for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
        {

                
            
            my_symbol =   MySymbol[SymPos];
            my_timeperiod = timeperiod[timeperiodnum]; 
            
            long prevBarTime = history.getPreviousBarStart(my_timeperiod, 
                history.getLastTick(my_symbol).getTime()); 

            BoolCrossRecord[SymPos][timeperiodnum].iBarPos = 1000;
            BoolCrossRecord[SymPos][timeperiodnum].startTime = prevBarTime;
            
        }
    }
    
    
}



public void CalcuBarPos(int SymPos,int timeperiodnum,IBar bidBar)throws JFException
{

    Instrument my_symbol;
    Period my_timeperiod;
 
    my_symbol =   MySymbol[SymPos];    
    my_timeperiod = timeperiod[timeperiodnum];    
    //初始化为一个默认值


    long prevBarTime = bidBar.getTime(); 
    List<IBar> bars = history.getBars(my_symbol, my_timeperiod, 
    OfferSide.BID, BoolCrossRecord[SymPos][timeperiodnum].startTime, prevBarTime);

    int last = bars.size() -1;  
    
    BoolCrossRecord[SymPos][timeperiodnum].startTime = prevBarTime;
    BoolCrossRecord[SymPos][timeperiodnum].iBarPos += last;
        
    
}



public void InitBuySellPos()throws JFException
{
    int SymPos;
    int i ;
    Instrument my_symbol;
    Period my_timeperiod;
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
        
            
    
    return;
}

public void  InitcrossValue(int SymPos,int timeperiodnum) throws JFException
{    
    double myma,myboll_up_B,myboll_low_B,myboll_mid_B;
    double myma_pre,myboll_up_B_pre,myboll_low_B_pre,myboll_mid_B_pre;
    
    Instrument my_symbol;

    Period my_timeperiod;
    
    int crossflag;
    int j = 0;
    int i;
    double[] mybool = new double [10];
    
    my_symbol =   MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];    
    
    
    BoolCrossRecord[SymPos][timeperiodnum].startTime = 
            history.getPreviousBarStart(my_timeperiod, history.getLastTick(my_symbol).getTime());

    for (i = 1; i< 300;i++)
    {
        
        crossflag = 0;
        
    

        myma = indicators.ma(my_symbol, my_timeperiod, 
                OfferSide.BID, AppliedPrice.CLOSE,
                Move_Av, MaType.SMA, i-1);

        mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                iBoll_B, 2, 2, MaType.SMA, i-1);
        
        myboll_up_B = mybool[0];
        myboll_mid_B = mybool[1];
        myboll_low_B = mybool[2];
        

        myma_pre = indicators.ma(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                Move_Av, MaType.SMA, i);
        
        mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                iBoll_B, 2, 2, MaType.SMA, i);
        
        
        myboll_up_B_pre = mybool[0];
        myboll_mid_B_pre = mybool[1];
        myboll_low_B_pre = mybool[2];        

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
        
        if(0 !=     crossflag)        
        {
                BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[j] = crossflag;
                BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[j] = iBars(my_symbol,my_timeperiod)-i;
                j++;
                if (j >= 9)
                {
                    break;
                }
        }

    }
    
    return ;

}

public void InitMA(int SymPos,int timeperiodnum) throws JFException
{
    double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
    double MAThenPre,MAThentyOnePre,MASixtyPre;
    double StrongWeak;
    
    Period my_timeperiod;    
    Instrument my_symbol;
    
    my_symbol = MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];    

    MAThree = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            3, MaType.SMA, 0);    

    MAThen = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            10, MaType.SMA, 0);    
    
    MAThenPre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            10, MaType.SMA, 1);    
        

    MAFive = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            5, MaType.SMA, 0);    

    MAThentyOne = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 0);    
    
    MASixty = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 0);    
    

    MAThentyOnePre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 1);    
    
    MASixtyPre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 1);    
        

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

    BoolCrossRecord[SymPos][timeperiodnum].StrongWeak = StrongWeak;    
    
    
}




void ChangeCrossValue( int mvalue,double  mstrongweak,int SymPos,int timeperiodnum)throws JFException
{

    int i;
    Period my_timeperiod;
    Instrument symbol;
    symbol = MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];

        
    if (mvalue == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
    {
        BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] = mvalue;
    //    BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[0] = iBars(symbol,my_timeperiod);    
        
        BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0] = mstrongweak;        
    
        
        return;
    }
    for (i = 0 ; i <9; i++)
    {
        BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8-i];
    //    BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[9-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[8-i];
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[9-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[8-i] ;        
        BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[9-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[8-i];
    }
    
    BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] = mvalue;
    //BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
    BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[0] = iBars(symbol,my_timeperiod);
    
    BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0] = mstrongweak;

    return;
}



/*非Openday期间不新开单*/
boolean opendaycheck(int SymPos)
{
    //    int i;
    /*
    Instrument symbol;
    boolean tradetimeflag;
    datetime timelocal;

    symbol = MySymbol[SymPos];
    tradetimeflag = true;

    //原则上采用服务器交易时间，为了便于人性化处理，做了一个转换
    //OANDA 服务器时间为GMT + 2 ，北京时间为GMT + 8，相差6个小时        
    timelocal = TimeCurrent() + 5*60*60;


//    Print("opendaycheck:" + "timelocal=" + TimeToString(timelocal,TIME_DATE)
    //                 +"timelocal=" + TimeToString(timelocal,TIME_SECONDS));    

//    Print("opendaycheck:" + "timecur=" + TimeToString(TimeCurrent(),TIME_DATE)
//                     +"timecur=" + TimeToString(TimeCurrent(),TIME_SECONDS));    
        
            
        
    
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
    */
    return true;
}

/*欧美交易时间段多以趋势和趋势加强为主，非交易时间多以震荡为主，以此区分一些小周期的交易策略*/
boolean tradetimecheck(int SymPos)
{
//    int i;
    /*
    Instrument symbol;
    boolean tradetimeflag ;
    datetime timelocal;    
    symbol = MySymbol[SymPos];
    tradetimeflag = false;


    //原则上采用服务器交易时间，为了便于人性化处理，做了一个转换
    //OANDA 服务器时间为GMT + 2 ，北京时间为GMT + 8，相差6个小时        
    timelocal = TimeCurrent() + 5*60*60;


    //下午3点前不做趋势单，主要针对1分钟线，非欧美时间趋势不明显
    
    if ((TimeHour(timelocal) >= 16 )&& (TimeHour(timelocal) <22 )) 
    {
        tradetimeflag = true;        
    }    
    //测试期间全时间段交易
    tradetimeflag = true;        
    
    return tradetimeflag;
    */
    return true;
}



boolean accountcheck()
{
    /*
    boolean accountflag ;
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
        
        //现有杠杆之下至少还能交易两次
        if(AccountFreeMargin() < 2*MyLotsH*(100000/leverage))
        {
            Print("Account Money is not enough free margin = ",AccountFreeMargin() +";Leverage = "+leverage);        
            accountflag = false;
        }        
        
    }

    return accountflag;
    */
    return true;
    
}



//end new added    
//////////////////////////////////////
       
    
    public void onStart(IContext context) throws JFException {
        engine = context.getEngine();
        indicators = context.getIndicators();
        this.console = context.getConsole();
        history = context.getHistory();
//////////////////////////////        
//new added       


        int SymPos;
        int timeperiodnum;
        Period my_timeperiod;
        Instrument my_symbol;

        
        
        console.getOut().println("this is Started");
        
        
        initsymbol(context);    
        initmagicnumber();
        inittiimeperiod();  
        
        InitBarPos();        

        
        Freq_Count = 0;
        TwentyS_Freq = 0;
        OneM_Freq = 0;
        ThirtyS_Freq = 0;
        FiveM_Freq = 0;
        ThirtyM_Freq = 0;
        
        for(SymPos = 0; SymPos < symbolNum;SymPos++)
        {    
            try {Thread.sleep(1000);}
            catch (InterruptedException e) {}        
            
            for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
            {    
        
                my_symbol =   MySymbol[SymPos];
                my_timeperiod = timeperiod[timeperiodnum];

                InitcrossValue(SymPos,timeperiodnum);    
                
                InitMA(SymPos,timeperiodnum);
                
                String s;
              
                s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
                + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
                + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
                + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
                + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
                + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
                
                console.getOut().println(s);
                
            }
        
        }
        InitBuySellPos();    
          
        //Print("Server name is ", AccountServer());      
        //Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
        //Print("Account free margin = ",AccountFreeMargin());    
                    
          return ;       
               
        
//end new added
////////////////////////////////
        
    }

    public void onStop() throws JFException {
/*        
        for (IOrder order : engine.getOrders()) {
            order.close();
        }
        console.getOut().println("this is Stopped");
*/        
        return;
    }

 /////////////////////////////
//new added

public double getMinAmount(Instrument instrument){
    switch (instrument){
        case XAUUSD : return 0.000001;
        case XAGUSD : return 0.00005;
        default : return 0.001;
    }
}

public boolean SymOrderCloseStatus(String stSymMagic) throws JFException
{
    boolean status;
    status = false;
    
    IOrder order = engine.getOrder(stSymMagic);    

    if(null == order)
    {
        status = true;
    }
    
   return status;
}

    
 public  void calculateindicatorOnbar(int SymPos, int timeperiodnum)throws JFException
{
    
    
    
    Period my_timeperiod;
    Instrument my_symbol;
    
    double ma;
    double boll_up_B,boll_low_B,boll_mid_B,bool_length;
    
    double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
    double MAThenPre,MAThentyOnePre,MASixtyPre;
    double StrongWeak;
    
    double boolindex;
    
    int crossflag;    
    double[] mybool = new double[10];
    

   
    my_timeperiod = timeperiod[timeperiodnum];
    my_symbol =   MySymbol[SymPos];

                    
    ma = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            Move_Av, MaType.SMA, 1);
    
        // ma = Close[0];  
    mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
            iBoll_B, 2, 2, MaType.SMA, 1);
    
    boll_up_B = mybool[0];
    boll_mid_B = mybool[1];
    boll_low_B = mybool[2];
    /*point*/
    bool_length =(boll_up_B - boll_low_B )/2;


    
    ma_pre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            Move_Av, MaType.SMA, 2);
    
    // ma = Close[0];  
    mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
            iBoll_B, 2, 2, MaType.SMA, 2);
    
    boll_up_B_pre = mybool[0];
    boll_mid_B_pre = mybool[1];
    boll_low_B_pre = mybool[2];                
    

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


      
    
    MAThree = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            3, MaType.SMA, 0);

    MAThen = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            10, MaType.SMA, 0);
    
    MAThenPre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            10, MaType.SMA, 1);                
    
    

    
    MAFive = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            5, MaType.SMA, 0);

    MAThentyOne = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 0);
    
    MASixty = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 0);                
    


    MAThentyOnePre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 1);
    
    MASixtyPre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 1);                
                     



    
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


    BoolCrossRecord[SymPos][timeperiodnum].StrongWeak = StrongWeak;

    return;
}


     
    
 public  void calculateindicatorOntick(Instrument my_symbol, ITick tick)throws JFException
{
    
    int SymPos;
    int timeperiodnum;
    Period my_timeperiod;

    double boll_up_B,boll_low_B,boll_mid_B,bool_length;    
    double vbid,vask;     
    double boolindex;
      
    double[] mybool = new double[10];
    
    SymPos = getsympos(my_symbol);
    
    for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
    {

        my_timeperiod = timeperiod[timeperiodnum];


                        

        mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                iBoll_B, 2, 2, MaType.SMA, 1);
        
        boll_up_B = mybool[0];
        boll_mid_B = mybool[1];
        boll_low_B = mybool[2];
        bool_length = (boll_up_B-boll_low_B)/2;
          
         vask = tick.getAsk();
         vbid = tick.getBid();
         
        if(bool_length>0.01)
        {
            boolindex = ((vask + vbid)/2 - boll_mid_B)/bool_length;
            BoolCrossRecord[SymPos][timeperiodnum].BoolIndex = boolindex;
        }
        

    }    
                
    return;
}



 
 
 
 
public void orderbuyselltypeone(int SymPos, ITick tick)throws JFException
{
    
    int timeperiodnum;
    Period my_timeperiod;
    Instrument my_symbol;

    double boll_up_B,boll_low_B,bool_length;    
    double vbid,vask; 
    double MinValue3 = 100000;
    double MaxValue4=-1;


    double orderLots ;   
    double orderStopless ;
    double orderTakeProfit;
    double orderPrice;
    double[] mybool = new double[10];
    int i;
 
    
    timeperiodnum = 0;    


    orderLots = 0;   
    orderStopless = 0;
    orderTakeProfit = 0;
    orderPrice = 0;
        
    my_symbol =   MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];    

    
    mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
            iBoll_B, 2, 2, MaType.SMA, 1);
    
    boll_up_B = mybool[0];
    //boll_mid_B = mybool[1];
    boll_low_B = mybool[2];    
    
    /*point*/
    bool_length =(boll_up_B - boll_low_B )/2;    
    
    

           //大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
        //回调到中线买点1
    
    if(((BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[0]>0.8)
        ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
    
        &&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
    
       // &&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.20)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >-0.1)        
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag == 4)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange != -4)        


        &&(3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[5])
        &&(3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])    
        &&(3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7])    

        &&(    (-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[5])
            ||(-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])    
            ||(-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7]))        

            &&(opendaycheck(SymPos) == true)
        &&(SymOrderCloseStatus(MakeMagic(SymPos,MagicNumberOne))==true))
       {
                        
        if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
            &&(-4 == BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)              
            &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak>0.2)
            )                    
           {
                            
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            
               MinValue3 = 100000;
                for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                {
                    IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);  
                    if(MinValue3 > prevBar.getLow())
                    {
                        MinValue3 = prevBar.getLow();
                    }
                    
                }             
                    
            orderLots = MyLotsH;
            orderPrice = vask;                 

            orderStopless =MinValue3- bool_length*4;     
            //orderStopless = orderPrice - my_symbol.getPipValue() * StopLossInPipsH ;
            BuySellPosRecord[SymPos].NextModifyValue1[0] = orderStopless;
            
            orderStopless =MinValue3- bool_length*2; 
            //orderStopless = orderPrice - my_symbol.getPipValue() * StopLossInPipsL ;                
            BuySellPosRecord[SymPos].NextModifyValue2[0] = orderStopless;
            
            /*
            if((orderPrice - orderStopless)>bool_length*2)
            {
                orderStopless = orderPrice - bool_length*2;
            }
            */
            orderTakeProfit    =     orderPrice + bool_length*4;

            
            //orderTakeProfit = 0;
            String s;
            s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
            console.getOut().println(s);                                                                           
                        
            s = my_symbol+" MagicNumberOne OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
                        +orderPrice+"orderStopless="
                        +orderStopless +"orderTakeProfit="+orderTakeProfit;    
            console.getOut().println(s);

            
            if(true == accountcheck())
            {
                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
            
                IOrder order = engine.submitOrder(MakeMagic(SymPos,MagicNumberOne), 
                        my_symbol, OrderCommand.BUY, orderLots, orderPrice, 
                        5, orderStopless, orderTakeProfit);        
                
                
                 if(null != order)
                 {     
                    TwentyS_Freq++;
                    OneM_Freq++;
                    ThirtyS_Freq++;
                    FiveM_Freq++;
                    ThirtyM_Freq++;    
                    BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(my_symbol,my_timeperiod)+22;                     
                    BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);                                  
                    console.getOut().println(my_symbol+"OrderSend MagicNumberOne  successfully");
                 }                                                    
                 
            }                    
                
        }            
                    

    
    }            
    
       




    
           //大周期处于多头市场，本周期在下跌背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
        //回调到中线买点2
    
    if(((BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[0]>0.8)
        ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))
    
        &&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)
    
       // &&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.15)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >-0.15)        
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag <3.5)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag > -3.5)        

        &&(    (3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])    
            ||(3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2]))        
        
        &&(3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])
        &&(3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7])    
        &&(3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[8])    

        &&(    (-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])
            ||(-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7])    
            ||(-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[8]))        

            &&(opendaycheck(SymPos) == true)
        &&(SymOrderCloseStatus(MakeMagic(SymPos,MagicNumberThree))==true))
       {
                        
        if((-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
            &&(-4 == BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)            
           // &&(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])    
            &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak>0.2)
            )                    
           {
                            
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            
               MinValue3 = 100000;
                for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                {
                    IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);  
                    if(MinValue3 > prevBar.getLow())
                    {
                        MinValue3 = prevBar.getLow();
                    }
                    
                }             
                    
            orderLots = MyLotsH;
            orderPrice = vask;                 

            orderStopless =MinValue3- bool_length*4;     
            //orderStopless = orderPrice - my_symbol.getPipValue() * StopLossInPipsH ;
            BuySellPosRecord[SymPos].NextModifyValue1[2] = orderStopless;
            
            orderStopless =MinValue3- bool_length*2; 
            //orderStopless = orderPrice - my_symbol.getPipValue() * StopLossInPipsL ;                
            BuySellPosRecord[SymPos].NextModifyValue2[2] = orderStopless;
            
            /*
            if((orderPrice - orderStopless)>bool_length*2)
            {
                orderStopless = orderPrice - bool_length*2;
            }
            */
            orderTakeProfit    =     orderPrice + bool_length*4;

            
            //orderTakeProfit = 0;
            String s;
            s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
            console.getOut().println(s);                                                                           
                        
            s = my_symbol+" MagicNumberThree OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
                        +orderPrice+"orderStopless="
                        +orderStopless +"orderTakeProfit="+orderTakeProfit;    
            console.getOut().println(s);

            
            if(true == accountcheck())
            {
                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
            
                IOrder order = engine.submitOrder(MakeMagic(SymPos,MagicNumberThree), 
                        my_symbol, OrderCommand.BUY, orderLots, orderPrice, 
                        5, orderStopless, orderTakeProfit);        
                
                
                 if(null != order)
                 {     
                    TwentyS_Freq++;
                    OneM_Freq++;
                    ThirtyS_Freq++;
                    FiveM_Freq++;
                    ThirtyM_Freq++;    
                    BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,my_timeperiod)+22;                     
                    BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);                                  
                    console.getOut().println(my_symbol+"OrderSend MagicNumberThree  successfully");
                 }                                                    
                 
            }                    
                
        }            
                    

    
    }            
    
        
    
//////////////////////////////////////////////////////////////
//多空分界线    
//////////////////////////////////////////////////////////////    

          //大周期处于空头市场，本周期在上涨背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
        //回调中线卖点1

    if(((BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[0]<0.2)
        ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))    
        &&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)

        
        //&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.10)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >-0.20)        
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag == -4)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange != -4)        

        &&(-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[5])
        &&(-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])    
        &&(-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7])    

        &&(    (3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[5])
            ||(3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])    
            ||(3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7]))            
                

        &&(SymOrderCloseStatus(MakeMagic(SymPos,MagicNumberTwo))==true))
       {
            

        if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
            &&(4 == BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)            
           // &&(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])    
            &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak<0.8)
            )    
           {
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            
            MaxValue4 = -1;
            for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
            {
                IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);    
                
                if(MaxValue4 < prevBar.getHigh())
                {
                    MaxValue4 = prevBar.getHigh();
                }                    
            }                
        
            orderLots = MyLotsH;
            
            orderPrice = vbid;        
            
            orderStopless =MaxValue4 + bool_length*4; 
            
           // orderStopless = orderPrice + my_symbol.getPipValue() * StopLossInPipsH ;
            BuySellPosRecord[SymPos].NextModifyValue1[1] = orderStopless;
            
            orderStopless =MaxValue4 + bool_length*2; 
            //orderStopless = orderPrice + my_symbol.getPipValue() * StopLossInPipsL ;            
            BuySellPosRecord[SymPos].NextModifyValue2[1] = orderStopless;                
            
            /*
            if(( orderStopless- orderPrice)>bool_length*2)
            {
                orderStopless = orderPrice + bool_length*2;
            }
            */

                
            orderTakeProfit    =     orderPrice - bool_length*4;


            String s;
            s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
            console.getOut().println(s);
                                
            s= my_symbol+" MagicNumberTwo OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
                            +orderPrice+"orderStopless="+orderStopless
                            +"orderTakeProfit="+orderTakeProfit;    
            
            console.getOut().println(s);                                        
                    
            
             if(true == accountcheck())
             {

                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                    
         
                IOrder order = engine.submitOrder(MakeMagic(SymPos,MagicNumberTwo), 
                        my_symbol, OrderCommand.SELL, orderLots, orderPrice, 
                        5, orderStopless, orderTakeProfit);                        
                
                 if(null != order)
                 {                   
      
                    TwentyS_Freq++;
                    OneM_Freq++;
                    ThirtyS_Freq++;
                    FiveM_Freq++;
                    ThirtyM_Freq++;    
                    BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(my_symbol,my_timeperiod)+22;                     
                    BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);                                      
                    console.getOut().println(my_symbol+"OrderSend MagicNumberTwo  successfully");
                 }
                                                             
             }                     
                            
        
        }            
        
        

    }                        
    
                      
    
    
    
         //大周期处于空头市场，本周期在上涨背驰阶段买入，趋势交易，目的是为了优化比较好的入场点，和止损点
        //回调中线卖点2

    if(((BoolCrossRecord[SymPos][timeperiodnum+2].CrossStrongWeak[0]<0.2)
        ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))    
        &&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak<0.2)

        
        //&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex <0.15)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolIndex >-0.15)        
        
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag <3.5)
        &&(BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag > -3.5)        
        
        
        &&(    (-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[1])    
            ||(-3.5 > BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[2]))        
        
        &&(-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])
        &&(-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7])    
        &&(-3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[8])    

        &&(    (3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[6])
            ||(3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[7])    
            ||(3.5 < BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlag[8]))            
                

        &&(SymOrderCloseStatus(MakeMagic(SymPos,MagicNumberFour))==true))
       {
            

        if((4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
            &&(4 == BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)            
           // &&(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2])    
            &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak<0.8)
            )    
           {
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            
            MaxValue4 = -1;
            for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
            {
                IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);    
                
                if(MaxValue4 < prevBar.getHigh())
                {
                    MaxValue4 = prevBar.getHigh();
                }                    
            }                
        
            orderLots = MyLotsH;
            
            orderPrice = vbid;        
            
            orderStopless =MaxValue4 + bool_length*4; 
            
           // orderStopless = orderPrice + my_symbol.getPipValue() * StopLossInPipsH ;
            BuySellPosRecord[SymPos].NextModifyValue1[3] = orderStopless;
            
            orderStopless =MaxValue4 + bool_length*2; 
            //orderStopless = orderPrice + my_symbol.getPipValue() * StopLossInPipsL ;            
            BuySellPosRecord[SymPos].NextModifyValue2[3] = orderStopless;                
            
            /*
            if(( orderStopless- orderPrice)>bool_length*2)
            {
                orderStopless = orderPrice + bool_length*2;
            }
            */

                
            orderTakeProfit    =     orderPrice - bool_length*4;


            String s;
            s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
            console.getOut().println(s);
                                
            s= my_symbol+" MagicNumberFour OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
                            +orderPrice+"orderStopless="+orderStopless
                            +"orderTakeProfit="+orderTakeProfit;    
            
            console.getOut().println(s);                                        
                    
            
             if(true == accountcheck())
             {

                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                    
         
                IOrder order = engine.submitOrder(MakeMagic(SymPos,MagicNumberFour), 
                        my_symbol, OrderCommand.SELL, orderLots, orderPrice, 
                        5, orderStopless, orderTakeProfit);                        
                
                 if(null != order)
                 {                   
      
                    TwentyS_Freq++;
                    OneM_Freq++;
                    ThirtyS_Freq++;
                    FiveM_Freq++;
                    ThirtyM_Freq++;    
                    BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,my_timeperiod)+22;                     
                    BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);                                      
                    console.getOut().println(my_symbol+"OrderSend MagicNumberFour  successfully");
                 }
                                                             
             }                     
                            
        
        }            
        
        

    }                        
    
    
    
    
}

public void checkbuysellordertypeone(int SymPos, ITick tick)throws JFException
{
    
    int timeperiodnum;
    Period my_timeperiod;
    Instrument my_symbol;

    
    double boll_up_B,boll_low_B,bool_length;    
    double vbid,vask; 
    double MinValue3 = 100000;
    double MaxValue4 = -1;


    double orderLots ;   
    double orderStopless ;
    double orderTakeProfit;
    double orderPrice;
    
    int i;
 
    
    timeperiodnum = 0;    
    IOrder order;

    orderLots = 0;   
    orderStopless = 0;
    orderTakeProfit = 0;
    orderPrice = 0;
    my_timeperiod = timeperiod[timeperiodnum];    
    my_symbol =   MySymbol[SymPos];
 
     order = engine.getOrder(MakeMagic(SymPos,MagicNumberOne));        
    if(null != order)
    {    
        if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED)
        {
        
            double [] mybool = new double[10];
            
            mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                    iBoll_B, 2, 2, MaType.SMA, 1);
            
            boll_up_B = mybool[0];
            //boll_mid_B = mybool[1];
            boll_low_B = mybool[2];    
            
            bool_length = (boll_up_B - boll_low_B)/2;
            
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            

//////////////////////        
           
           
            if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[0]) > 0)
            {
                /*初始化一个超大值，该值不可能达到*/
                BuySellPosRecord[SymPos].NextModifyPos[0] = iBars(my_symbol,my_timeperiod)+10000000;    
                   MinValue3 = 100000;
                    for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                    {
                        IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);  
                        if(MinValue3 > prevBar.getLow())
                        {
                            MinValue3 = prevBar.getLow();
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
                
                orderTakeProfit    =     orderPrice  + bool_length*5;
 
                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                    
 
                order.setStopLossPrice(orderStopless);          
                order.setTakeProfitPrice(orderTakeProfit);    
                console.getOut().println(my_symbol+"Order Modify MagicNumberOne  0 successfully");                                                         
                
            }
            else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[0]) >-10)
                &&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
            {
                order.close();
                console.getOut().println(my_symbol+"Orderclose MagicNumberOne  1 successfully");
                
            }                        

                    
                                                                    
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
                ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8))
            {
                
                if(order.getTakeProfitPrice() < 0.1)
                {
                    
                       MinValue3 = 100000;
                        for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                        {
                            IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);  
                            if(MinValue3 > prevBar.getLow())
                            {
                                MinValue3 = prevBar.getLow();
                            }
                            
                        }                                 
                        
                    

                    orderPrice = vask;                 
                    orderStopless =MinValue3- bool_length*4;                         
                    orderTakeProfit    =     orderPrice  + bool_length*8;

                    
                        
                    
                    orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
          
                     order.setTakeProfitPrice(orderTakeProfit);
                    console.getOut().println(my_symbol+"Order Modify MagicNumberOne  1 successfully"); 

                            
                }
                
                
               /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
               if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[0])>800)
               {
                   order.close();
                   console.getOut().println(my_symbol+"Orderclose MagicNumberOne  3 successfully");
               }
               
               else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[0])>720)
               {          
                  if( order.getProfitLossInAccountCurrency()> 0)
                  {
                      order.close();
                      console.getOut().println(my_symbol+"Orderclose MagicNumberOne  4 successfully");
                  }   
                    else if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
                    {
                        order.close();
                        console.getOut().println(my_symbol+"Orderclose MagicNumberOne  5 successfully");
                        
                    }    

                  
               }  
               
                        
            }
            
            
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
                &&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))    
            {
                
                BuySellPosRecord[SymPos].TradeTimePos[0] = iBars(my_symbol,my_timeperiod);
                if(order.getTakeProfitPrice()> 0.1)
                {                                                                             
                    //order.setStopLossPrice(order.getStopLossPrice());           
                    order.setTakeProfitPrice(0); 
                    console.getOut().println(my_symbol+"Order Modify MagicNumberOne  2 successfully");                              
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


            if(-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)                       
         {
                                         
             order.close();   
             console.getOut().println(my_symbol+"Orderclose MagicNumberOne  6 successfully");                                                                                                                              
         }  

            if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
            
            &&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1])))                       
         {
             orderLots = order.getAmount()/2;
             
             /*三次完成出货*/
             if (orderLots <= MyLotsL*9/64)
             {
                 orderLots = order.getAmount();
             }                                           
             order.close(orderLots);   
             console.getOut().println(my_symbol+"Orderclose MagicNumberOne  7 successfully");                                                                                                                              
         }   
                                                                       
            
//////////////////////////            
        }
    }
    
      

    order = engine.getOrder(MakeMagic(SymPos,MagicNumberThree));        
    if(null != order)
    {    
        if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED)
        {
        
            double [] mybool = new double[10];
            
            mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                    iBoll_B, 2, 2, MaType.SMA, 1);
            
            boll_up_B = mybool[0];
            //boll_mid_B = mybool[1];
            boll_low_B = mybool[2];    
            
            bool_length = (boll_up_B - boll_low_B)/2;
            
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            

//////////////////////        
           
           
            if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[2]) > 0)
            {
                /*初始化一个超大值，该值不可能达到*/
                BuySellPosRecord[SymPos].NextModifyPos[2] = iBars(my_symbol,my_timeperiod)+10000000;    
                   MinValue3 = 100000;
                    for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                    {
                        IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);  
                        if(MinValue3 > prevBar.getLow())
                        {
                            MinValue3 = prevBar.getLow();
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
                
                orderTakeProfit    =     orderPrice  + bool_length*5;
 
                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                    
 
                order.setStopLossPrice(orderStopless);          
                order.setTakeProfitPrice(orderTakeProfit);    
                console.getOut().println(my_symbol+"Order Modify MagicNumberThree  0 successfully");                                                         
                
            }
            else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[2]) >-10)
                &&(-4.5 > BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
            {
                order.close();
                console.getOut().println(my_symbol+"Orderclose MagicNumberThree  1 successfully");
                
            }                        

                    
                                                                    
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.8)
                ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.8))
            {
                
                if(order.getTakeProfitPrice() < 0.1)
                {
                    
                       MinValue3 = 100000;
                        for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                        {
                            IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);  
                            if(MinValue3 > prevBar.getLow())
                            {
                                MinValue3 = prevBar.getLow();
                            }
                            
                        }                                 
                        
                    

                    orderPrice = vask;                 
                    orderStopless =MinValue3- bool_length*4;                         
                    orderTakeProfit    =     orderPrice  + bool_length*8;

                    
                        
                    
                    orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
          
                     order.setTakeProfitPrice(orderTakeProfit);
                    console.getOut().println(my_symbol+"Order Modify MagicNumberThree  1 successfully"); 

                            
                }
                
                
               /*在非多头向上的情况下，一分钟400个周期，理论上应该走完了,360周期开始监控时间控制*/
               if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[2])>800)
               {
                   order.close();
                   console.getOut().println(my_symbol+"Orderclose MagicNumberThree  3 successfully");
               }
               
               else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[2])>720)
               {          
                  if( order.getProfitLossInAccountCurrency()> 0)
                  {
                      order.close();
                      console.getOut().println(my_symbol+"Orderclose MagicNumberThree  4 successfully");
                  }   
                    else if(4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
                    {
                        order.close();
                        console.getOut().println(my_symbol+"Orderclose MagicNumberThree  5 successfully");
                        
                    }    

                  
               }  
               
                        
            }
            
            
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.8)
                &&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.8))    
            {
                
                BuySellPosRecord[SymPos].TradeTimePos[2] = iBars(my_symbol,my_timeperiod);
                if(order.getTakeProfitPrice()> 0.1)
                {                                                                             
                    //order.setStopLossPrice(order.getStopLossPrice());           
                    order.setTakeProfitPrice(0); 
                    console.getOut().println(my_symbol+"Order Modify MagicNumberThree  2 successfully");                              
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


            if(-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)                       
         {
                                         
             order.close();   
             console.getOut().println(my_symbol+"Orderclose MagicNumberThree  6 successfully");                                                                                                                              
         }  

            if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
            
            &&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1])))                       
         {
             orderLots = order.getAmount()/2;
             
             /*三次完成出货*/
             if (orderLots <= MyLotsL*9/64)
             {
                 orderLots = order.getAmount();
             }                                           
             order.close(orderLots);   
             console.getOut().println(my_symbol+"Orderclose MagicNumberThree  7 successfully");                                                                                                                              
         }   
                                                                       
            
//////////////////////////            
        }
    }
    


    order = engine.getOrder(MakeMagic(SymPos,MagicNumberTwo));        
    if(null != order)
    {    
        if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED)
        {
        
            double [] mybool = new double[10];
            
            mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                    iBoll_B, 2, 2, MaType.SMA, 1);
            
            boll_up_B = mybool[0];
            //boll_mid_B = mybool[1];
            boll_low_B = mybool[2];    
            
            bool_length = (boll_up_B - boll_low_B)/2;
            
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            

/////////////////////////////

           
            if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[1]) > 0)
            {
                /*初始化一个超大值，该值不可能达到*/
                BuySellPosRecord[SymPos].NextModifyPos[1] = iBars(my_symbol,my_timeperiod)+10000000;    
                        
                MaxValue4 = -1;
                for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                {
                    IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);                  
                    if(MaxValue4 < prevBar.getHigh())
                    {
                        MaxValue4 = prevBar.getHigh();
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
                
                orderTakeProfit    =     orderPrice -bool_length*5;

                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                    
                
                order.setStopLossPrice(orderStopless);          
                order.setTakeProfitPrice(orderTakeProfit);  
                console.getOut().println(my_symbol+"Order Modify MagicNumberTwo  0 successfully");      
                        
                
            }
            
            
            else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[1]) >-10)
                &&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
            {
                order.close();
                console.getOut().println(my_symbol+"Orderclose MagicNumberTwo  1 successfully");
                
            }                                               
                                                   
            
                                 
           
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
                ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
            {
                

                
                if(order.getTakeProfitPrice() < 0.1)
                {
                    
                    MaxValue4 = -1;
                    for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                    {
                        IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);                  
                        if(MaxValue4 < prevBar.getHigh())
                        {
                            MaxValue4 = prevBar.getHigh();
                        }                   
                    }   

                    orderPrice = vbid;                         
                    orderStopless =MaxValue4 + 4*bool_length;                             
                    orderTakeProfit    =     orderPrice -bool_length*6;

                    

                        orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
          
                        order.setTakeProfitPrice(orderTakeProfit);
                        console.getOut().println(my_symbol+"Order Modify MagicNumberTwo  1 successfully");                                   
                }
                

                /*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
                if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[1])>800)
                {
                    order.close();
                    console.getOut().println(my_symbol+"Orderclose MagicNumberTwo  3 successfully");
                }

                else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[1])>720)
                {          
                  if( order.getProfitLossInAccountCurrency()> 0)
                  {
                      order.close();
                      console.getOut().println(my_symbol+"Orderclose MagicNumberTwo  4 successfully");
                  }       
                   else if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
                    {
                        order.close();
                        console.getOut().println(my_symbol+"Orderclose MagicNumberTwo  5 successfully");
                        
                    }                              
                }                          
                
                
            }
            
            
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
                &&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))    
            {
                                        
                BuySellPosRecord[SymPos].TradeTimePos[1] = iBars(my_symbol,my_timeperiod);
                if(order.getTakeProfitPrice() > 0.1)
                {
                    
                    //order.setStopLossPrice(order.getStopLossPrice());           
                    order.setTakeProfitPrice(0);  
                    console.getOut().println(my_symbol+"Order Modify MagicNumberTwo  2 successfully"); 
                            
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
                

            if(4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)                       
         {
                                         
             order.close();   
             console.getOut().println(my_symbol+"Orderclose MagicNumberTwo  6 successfully");                                                                                                                              
         }  
           
                                 
            if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
            
            &&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1])))                       
         {
             orderLots = order.getAmount()/2;
             
             /*三次完成出货*/
             if (orderLots <= MyLotsL*9/64)
             {
                 orderLots = order.getAmount();
             }                                           
             order.close(orderLots); 
             console.getOut().println(my_symbol+"Orderclose MagicNumberTwo  7 successfully");                                                                                                                                
         }     
           
                        
            
////////////////////////////            
            
        }
    }
    

  

    order = engine.getOrder(MakeMagic(SymPos,MagicNumberFour));        
    if(null != order)
    {    
        if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED)
        {
        
            double [] mybool = new double[10];
            
            mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
                    iBoll_B, 2, 2, MaType.SMA, 1);
            
            boll_up_B = mybool[0];
            //boll_mid_B = mybool[1];
            boll_low_B = mybool[2];    
            
            bool_length = (boll_up_B - boll_low_B)/2;
            
              
             vask = tick.getAsk();
             vbid = tick.getBid();
            

/////////////////////////////

           
            if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[3]) > 0)
            {
                /*初始化一个超大值，该值不可能达到*/
                BuySellPosRecord[SymPos].NextModifyPos[3] = iBars(my_symbol,my_timeperiod)+10000000;    
                        
                MaxValue4 = -1;
                for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                {
                    IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);                  
                    if(MaxValue4 < prevBar.getHigh())
                    {
                        MaxValue4 = prevBar.getHigh();
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
                
                orderTakeProfit    =     orderPrice -bool_length*5;

                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                    
                
                order.setStopLossPrice(orderStopless);          
                order.setTakeProfitPrice(orderTakeProfit);  
                console.getOut().println(my_symbol+"Order Modify MagicNumberFour  0 successfully");      
                        
                
            }
            
            
            else if(((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].NextModifyPos[3]) >-10)
                &&(4.5 < BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]))
            {
                order.close();
                console.getOut().println(my_symbol+"Orderclose MagicNumberFour  1 successfully");
                
            }                                               
                                                   
            
                                 
           
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>0.2)
                ||(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak>0.2))
            {
                

                
                if(order.getTakeProfitPrice() < 0.1)
                {
                    
                    MaxValue4 = -1;
                    for (i= 0;i < (iBars(my_symbol,my_timeperiod) -BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[1]+5);i++)
                    {
                        IBar prevBar = history.getBar(my_symbol, my_timeperiod, OfferSide.ASK, i);                  
                        if(MaxValue4 < prevBar.getHigh())
                        {
                            MaxValue4 = prevBar.getHigh();
                        }                   
                    }   

                    orderPrice = vbid;                         
                    orderStopless =MaxValue4 + 4*bool_length;                             
                    orderTakeProfit    =     orderPrice -bool_length*6;

                    

                        orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
          
                        order.setTakeProfitPrice(orderTakeProfit);
                        console.getOut().println(my_symbol+"Order Modify MagicNumberFour  1 successfully");                                   
                }
                

                /*在非多头向下的情况下一分钟400个周期，理论上应该走完了,360分钟开始监控时间控制*/
                if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[3])>800)
                {
                    order.close();
                    console.getOut().println(my_symbol+"Orderclose MagicNumberFour  3 successfully");
                }

                else if((iBars(my_symbol,my_timeperiod)-BuySellPosRecord[SymPos].TradeTimePos[3])>720)
                {          
                  if( order.getProfitLossInAccountCurrency()> 0)
                  {
                      order.close();
                      console.getOut().println(my_symbol+"Orderclose MagicNumberFour  4 successfully");
                  }       
                   else if(-4 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
                    {
                        order.close();
                        console.getOut().println(my_symbol+"Orderclose MagicNumberFour  5 successfully");
                        
                    }                              
                }                          
                
                
            }
            
            
            if((BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<0.2)
                &&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<0.2))    
            {
                                        
                BuySellPosRecord[SymPos].TradeTimePos[3] = iBars(my_symbol,my_timeperiod);
                if(order.getTakeProfitPrice() > 0.1)
                {
                    
                    //order.setStopLossPrice(order.getStopLossPrice());           
                    order.setTakeProfitPrice(0);  
                    console.getOut().println(my_symbol+"Order Modify MagicNumberFour  2 successfully"); 
                            
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

            }                        
                

            if(4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)                       
         {
                                         
             order.close();   
             console.getOut().println(my_symbol+"Orderclose MagicNumberFour  6 successfully");                                                                                                                              
         }  
           
                                 
            if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
            
            &&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1])))                       
         {
             orderLots = order.getAmount()/2;
             
             /*三次完成出货*/
             if (orderLots <= MyLotsL*9/64)
             {
                 orderLots = order.getAmount();
             }                                           
             order.close(orderLots); 
             console.getOut().println(my_symbol+"Orderclose MagicNumberFour  7 successfully");                                                                                                                                
         }     
           
                        
            
////////////////////////////            
            
        }
    }
    

  
        
    
}
    









    
//end new added
//////////////////////////////
    
    
    public void onTick(Instrument instrument, ITick tick) throws JFException {
        
        int SymPos= 100;
        int timeperiodnum = 100;
        Period my_timeperiod;
        ///////////////////////////////////////////
        //new added
        
        SymPos = getsympos(instrument);
        if (SymPos <0)
        {
//            String s =  "test!!! = " + instrument +":good:"+SymPos;
//            console.getOut().println(s);              
            return;
        }


        if (null ==  tick)
        {
            console.getOut().println(instrument + "error: onTick input NULL tick!!!");              
            return;
        }        
                
//        console.getOut().println("hello world!!!!");          
 //       calculateindicator(instrument,tick);   
        
        calculateindicatorOntick(instrument, tick);       

        orderbuyselltypeone(SymPos,tick);
     //   orderbuyselltypetwo(SymPos,tick);
     //   orderbuyselltypethree(SymPos,tick);       
        

        checkbuysellordertypeone(SymPos,tick);
       // checkbuysellordertypetwo(SymPos,tick);
       // checkbuysellordertypethree(SymPos,tick);
        
        for(timeperiodnum = 0; timeperiodnum < TimePeriodNum;timeperiodnum++)
        {

            my_timeperiod = timeperiod[timeperiodnum];        
            BoolCrossRecord[SymPos][timeperiodnum].ChartEvent = iBars(instrument,my_timeperiod);
    
            
        }   
        
        
        
 //       timeperiodnum = gettimeperiod(timeperiod[3] );
 //       String s =  "test = " + instrument +":good:"+SymPos+"HH"+timeperiodnum;
 //       console.getOut().println(s);  
        
                
        
        //end new added
        ///////////////////////////////////////////////
        
    }

    public void onBar(Instrument instrument, Period period, IBar askBar, IBar bidBar)throws JFException {
        int SymPos= 100;
        int timeperiodnum = 100;

        ///////////////////////////////////////////
        //new added
        SymPos = getsympos(instrument);
        if (SymPos <0)
        {
//            String s =  "onBar!!! = " + instrument +":good:"+SymPos;
//            console.getOut().println(s);              
            return;
        }        
        
        timeperiodnum = gettimeperiod(period);
        if (timeperiodnum <0)
        {

                     
            return;
        }
        
            
        //CalcuBarPos(SymPos,timeperiodnum,bidBar);      
        BoolCrossRecord[SymPos][timeperiodnum].iBarPos += 1;
        
    //    String s =  "onBar = " + instrument +period+"barnum="
    //    +iBars(instrument,period);
    //    console.getOut().println(s);  
    
        calculateindicatorOnbar(SymPos,timeperiodnum);    
        
    }

    //count open positions
    protected int positionsTotal(Instrument instrument) throws JFException {
        int counter = 0;
        for (IOrder order : engine.getOrders(instrument)) {
            if (order.getState() == IOrder.State.FILLED) {
                counter++;
            }
        }
        return counter;
    }


    public void onMessage(IMessage message) throws JFException {
    }

    public void onAccount(IAccount account) throws JFException {
    }
}



//////////////////////////////////////////////
//new added 

///////////////////////////////////////////////////
class stBuySellPosRecord {
    public int TradeTimePos[];
    public int NextModifyPos[];
    public double NextModifyValue1[];
    public double NextModifyValue2[];
    public int ticket = 0;
    public stBuySellPosRecord() throws JFException {}


};
class stOrderRecord {
    int ticket = 0;
    int SymPos = 0;
    int buyselltype = 0;
    int buysellminor = 0;
    double stopless = 0;
    int number = 0;
    public stOrderRecord() throws JFException {};
};
class stBoolCrossRecord {
    int CrossFlag[];
    double CrossStrongWeak[];
    double CrossTrend[];
    int CrossBoolPos[];
    double StrongWeak = 0;
    double Trend = 0;
    double BoolIndex = 0;
    double BoolFlag = 0;
    int CrossFlagChange = 0;
    int CrossFlagTemp = 0;
    int CrossFlagTempPre = 0;
    int ChartEvent = 0;
    long startTime = 0;
    int iBarPos = 0;
    public stBoolCrossRecord() throws JFException {};
};



//end new added

///////////////////////////////////////////////////
