
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
import static com.dukascopy.api.IOrder.State.*;






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

public class Z2  implements IStrategy  {
    private IEngine engine = null;
    private IIndicators indicators = null;
    private IConsole console;
    private IHistory history;
    

    public int StopLossInPipsL = 4;
    // @Configurable("Stop Loss In Pips H")
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

     int MagicNumberSeventeen = 0;
     int MagicNumberEighteen= 0;
     int MagicNumberNineteen= 0;   
     int MagicNumberTwenty = 0; 

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
     public stInputParamater[][] InputParamater; 
     public stSelfLearnMidPara[][][][] SelfLearnMidPara;   
     boolean iddataoptflag = false;
     boolean iddatarecovflag = false;
     int ChartEvent = 0;
     boolean PrintFlag = false;

    
     
     //public Instrument instrument = Instrument.EURUSD;
     
     public Instrument[] MySymbol;
     public Period[] timeperiod;
     

     { try {
         MyLotsH=10;
         MyLotsL=10;
         Move_Av=3;
         iBoll_B=43;

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

         MagicNumberSeventeen = 170;
         MagicNumberEighteen= 180;
         MagicNumberNineteen= 190;   
         MagicNumberTwenty = 200; 

         symbolNum = 0;
         Freq_Count=0;
         TwentyS_Freq=0;
         OneM_Freq=0;
         ThirtyS_Freq=0;
         FiveM_Freq=0;
         ThirtyM_Freq=0;
         
         

            BuySellPosRecord = new stBuySellPosRecord[100];
            OrderRecord= new stOrderRecord[100];
            BoolCrossRecord= new stBoolCrossRecord[100][6];   
            
            //later to use
            //InputParamater= new stInputParamater[2][6];    

            //Input1 BigBool  1.2--1.6  step 0.01  count 42
            //Input2 LittleBool  0.8--1.2  step 0.01  count 42
            //Input3 OrderKeepTime  60--120  step 1  count 62
            //Input4 StopLessSTBool  2--4  step 0.1  count 22
                        
            //SelfLearnMidPara= new stSelfLearnMidPara[2][6][42][22]; 
            //SelfLearnMidPara= new stSelfLearnMidPara[100][16];                 

         for(int i = 0; i < 100; i ++)
         {

                          
             BuySellPosRecord[i] = new stBuySellPosRecord();
             
             //这个指标非常重要，是下单的持有时间周期
             BuySellPosRecord[i].NextModifyPos = new int[300];
             
             //理论上每个下单都有对应的数量，这个值根据顺势逆势、基本面、资金量不同可以动态变化
             BuySellPosRecord[i].orderamount = new double[300]; 
                          
             BuySellPosRecord[i].TradeTimePos = new int[300];             
             BuySellPosRecord[i].StopLossL = new double[300];
             BuySellPosRecord[i].StopLossH = new double[300]; 

             BuySellPosRecord[i].BSChangeFlag = new int[300]; 
             
             
             for(int j= 0; j < 6;j++)
             {
                 BoolCrossRecord[i][j] = new stBoolCrossRecord();

                 BoolCrossRecord[i][j].CrossFlag = new int[30];
                 BoolCrossRecord[i][j].CrossBoolPos = new int[30];        
                 BoolCrossRecord[i][j].CrossStrongWeak = new int[30];
                 BoolCrossRecord[i][j].CrossTrend = new double [30];   
                 BoolCrossRecord[i][j].CrossBoolValue = new double[30];
                 BoolCrossRecord[i][j].CrossBoolLength = new double[30];                 

 
 /*  
                 //InputParamater[i][j] = new stInputParamater();   
              
                 for(int k= 0; k < 42;k++)
                 {

                     for(int l= 0; l < 42;l++)
                     {
                        //暂时先不处理    
                        if(false)
                        {
                                 SelfLearnMidPara[i][j][k][l] = new stSelfLearnMidPara();  

                                 SelfLearnMidPara[i][j][k][l].SelfOrderPrice = new double [502];
                                 SelfLearnMidPara[i][j][k][l].SelfOrderPos = new double [502];
                                 SelfLearnMidPara[i][j][k][l].SelfLongShort = new double [502];
                                 SelfLearnMidPara[i][j][k][l].SelfCutOrderPrice = new double [502];
                                 SelfLearnMidPara[i][j][k][l].SelfStopLossLength = new double [502];
                                 SelfLearnMidPara[i][j][k][l].SelfSltopLossFlag = new int [502];
                                 SelfLearnMidPara[i][j][k][l].SelfBigBoolLossFlag = new int [502];
                                 SelfLearnMidPara[i][j][k][l].SelfCatKeepOrderPeriodFlag = new int [502];
                                 SelfLearnMidPara[i][j][k][l].SelfBoolTakeProfitCutFlag = new int [502];
                        }

                     }

                 }

*/
                 
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
         MySymbol = new Instrument[2] ;
         timeperiod = new Period[6];
                  
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
     }
     
     else
    {            
        myinstruments.add(Instrument.EURUSD);
        myinstruments.add(Instrument.AUDUSD);
        myinstruments.add(Instrument.USDJPY);
        
        myinstruments.add(Instrument.USDZAR);
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
        myinstruments.add(Instrument.XAUUSD);
    
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

    if(true)
    {
        MySymbol[0] = Instrument.EURUSD;     
        symbolNum = 1;                                        
    }
    else
    {
        
        MySymbol[0] = Instrument.EURUSD;
        MySymbol[1] = Instrument.AUDUSD;
    
        MySymbol[2] = Instrument.USDJPY;         
        MySymbol[3] = Instrument.USDZAR;         
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
        MySymbol[29] = Instrument.XAUUSD;     
    
    
      
        symbolNum = 30;
    }    
    
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

//输入参数初始化，这个函数非常重要，很多参数需要做进一步优化，或者通过自学习来优化参数
public void InitInputParamater() throws JFException
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

            InputParamater[SymPos][timeperiodnum].StandardHBoolParam = 1.2;
            InputParamater[SymPos][timeperiodnum].StandardLBoolParam = 0.95;
            InputParamater[SymPos][timeperiodnum].StopLessSTBool = 3;
            InputParamater[SymPos][timeperiodnum].KeepOrderBarPeriod = 60;
 
             //在5分钟、30分钟、4小时周期上通过自学习确定参数
             if((1==timeperiodnum)||(2==timeperiodnum)||(3==timeperiodnum))
             {

                 SelfLearnInputParamata(SymPos,timeperiodnum);
             }                                     
            
        }
    }
    
}

public void SelfLearnInputParamata(int SymPos,int timeperiodnum)throws JFException
{

    return ;

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

    MagicNumberSeventeen = 170;
    MagicNumberEighteen= 180;
    MagicNumberNineteen= 190;   
    MagicNumberTwenty = 200; 

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
            
//            long prevBarTime = history.getPreviousBarStart(my_timeperiod, 
//                history.getLastTick(my_symbol).getTime()); 

            BoolCrossRecord[SymPos][timeperiodnum].iBarPos = 1000;
 //           BoolCrossRecord[SymPos][timeperiodnum].startTime = prevBarTime;
            
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

public double getMinAmount(Instrument instrument){
    switch (instrument){
        case XAUUSD : return 0.000001;
        case XAGUSD : return 0.00005;
        default : return 0.001;
    }
}


public void InitBuySellPos()throws JFException
{
    int SymPos;
    int i ;
    Instrument my_symbol;
    Period my_timeperiod;
    double mylots; 

    for(SymPos = 0; SymPos < symbolNum;SymPos++)
    {        
         my_symbol =   MySymbol[SymPos];
         mylots = getMinAmount(my_symbol)*MyLotsH;
        for(i = 0; i < 300;i++)
        {            
            BuySellPosRecord[SymPos].NextModifyPos[i] = 1000000000;
            BuySellPosRecord[SymPos].orderamount[i] = mylots;
            BuySellPosRecord[SymPos].BSChangeFlag[i] = 8; 
            BuySellPosRecord[SymPos].TradeTimePos[i] = 0;                       
            
        }
        
                                                               
    }
        
            
    
    return;
}

public void  InitcrossValue(int SymPos,int timeperiodnum) throws JFException
{    
    double myma,myboll_up_B,myboll_low_B,myboll_mid_B;
    double myma_pre,myboll_up_B_pre,myboll_low_B_pre,myboll_mid_B_pre;
    double bool_length;
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



    mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
        iBoll_B, 2, 2, MaType.SMA, 0);
    myboll_up_B = mybool[0];
    myboll_mid_B = mybool[1];
    myboll_low_B = mybool[2];


    bool_length = (myboll_up_B-myboll_low_B)/2;
    BoolCrossRecord[SymPos][timeperiodnum].BoolLength = bool_length;


    for (i = 1; i< 800;i++)
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
                BoolCrossRecord[SymPos][timeperiodnum].CrossBoolValue[j] = myma;
                BoolCrossRecord[SymPos][timeperiodnum].CrossBoolLength[j] =  bool_length;            
                
                j++;
                if (j >= 29)
                {
                    break;
                }
        }

    }
    
    return ;

}

public void InitMA(int SymPos,int timeperiodnum) throws JFException
{
    double MAFive,MAThentyOne,MASixty;
    double MAFivePre,MAThentyOnePre,MASixtyPre;
    int StrongWeak;
    
    Period my_timeperiod;    
    Instrument my_symbol;
    
    my_symbol = MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];    


    MAFive = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            5, MaType.SMA, 0);    

    MAThentyOne = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 0);    
    
    MASixty = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 0);    
    
    MAFivePre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            5, MaType.SMA, 1); 

    MAThentyOnePre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 1);    
    
    MASixtyPre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 1);            

    StrongWeak =5;

    if(MAFivePre > MAThentyOnePre)
    {
            
        /*多均线多头向上*/
        if(MASixtyPre < MAThentyOnePre)
        {
             StrongWeak =9;
        }
        else if (MASixtyPre <= MAFivePre)
        {
             StrongWeak =8;
        }
        else
        {
             StrongWeak =7;
        }
    
    }
    else if (MAFivePre < MAThentyOnePre)
    {
        /*多均线多头向下*/
        if(MASixtyPre > MAThentyOnePre)
        {
             StrongWeak =1;
        }
        else if (MASixtyPre >= MAFivePre)
        {
             StrongWeak =2;
        }
        else
        {
             StrongWeak =3;
        }      
    
    }
    else
    {
        StrongWeak =5;

    }
    BoolCrossRecord[SymPos][timeperiodnum].PreStrongWeak = StrongWeak;
    
////////////////////////////////////////////////////////////////////   
    StrongWeak =5;

    if(MAFive > MAThentyOne)
    {
            
        /*多均线多头向上*/
        if(MASixty < MAThentyOne)
        {
             StrongWeak =9;
        }
        else if (MASixty <= MAFive)
        {
             StrongWeak = 8;
        }
        else
        {
             StrongWeak =7;
        }
    
    }
    else if (MAFive < MAThentyOne)
    {
        /*多均线多头向下*/
        if(MASixty > MAThentyOne)
        {
             StrongWeak =1;
        }
        else if (MASixty >= MAFive)
        {
             StrongWeak =2;
        }
        else
        {
             StrongWeak =3;
        }      
    
    }
    else
    {
        StrongWeak =5;

    }

    BoolCrossRecord[SymPos][timeperiodnum].StrongWeak = StrongWeak;    
    
    
}




void ChangeCrossValue( int flagvalue,double mvalue,double bool_length,int  mstrongweak,int SymPos,int timeperiodnum)throws JFException
{

    int i;
    Period my_timeperiod;
    Instrument symbol;
    symbol = MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];

        
    if (flagvalue == BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0])
    {
        BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] = flagvalue;
    //    BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[0] = iBars(symbol,my_timeperiod);    
        
        BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0] = mstrongweak; 
               
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolValue[0] = mvalue;     
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolLength[0] = bool_length; 
        
        return;
    }
    for (i = 0 ; i <29; i++)
    {
        BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[29-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[28-i];
    //    BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[29-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[28-i];
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[29-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[28-i] ;        
        BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[29-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[28-i];
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolValue[29-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossBoolValue[28-i];  
        BoolCrossRecord[SymPos][timeperiodnum].CrossBoolLength[29-i] = BoolCrossRecord[SymPos][timeperiodnum].CrossBoolLength[28-i];           
    }
    
    BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] = flagvalue;
    //BoolCrossRecord[SymPos][timeperiodnum].CrossDatetime[0] = TimeCurrent();
    BoolCrossRecord[SymPos][timeperiodnum].CrossBoolPos[0] = iBars(symbol,my_timeperiod);
    
    BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0] = mstrongweak;

    BoolCrossRecord[SymPos][timeperiodnum].CrossBoolValue[0] = mvalue;
    BoolCrossRecord[SymPos][timeperiodnum].CrossBoolLength[0] = bool_length;
        
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
            //try {Thread.sleep(1000);}
           // catch (InterruptedException e) {}        
            
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
          
       // Print("Server name is ", AccountServer());      
       // Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
       // Print("Account free margin = ",AccountFreeMargin());    
                    
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


public boolean SymOrderCloseStatus(String stSymMagic) throws JFException
{
    boolean status;
    status = true;
    
    IOrder order = engine.getOrder(stSymMagic);    
    if(null != order)
    {    
        if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED
            ||(order.getState() == IOrder.State.CREATED) )
        {
            status = false;
        }
    }
    
   return status;
}

    
 public  void calculateindicatorOnbar(int SymPos, int timeperiodnum, IBar askBar, IBar bidBar)throws JFException
{
    
    
    
    Period my_timeperiod;
    Instrument my_symbol;
    
    double ma;
    double boll_up_B,boll_low_B,boll_mid_B,bool_length;
    
    double MAThree,MAFive,MAThen,MAThentyOne,MASixty;
    double MAFivePre,MAThenPre,MAThentyOnePre,MASixtyPre;
    int StrongWeak;
    
    
    int crossflag;    
    double[] mybool = new double[10];
    

    
   
    my_timeperiod = timeperiod[timeperiodnum];
    my_symbol =   MySymbol[SymPos];

                    
    ma = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            Move_Av, MaType.SMA, 0);
    
        // ma = Close[0];  
    mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
            iBoll_B, 2, 2, MaType.SMA, 0);
    
    boll_up_B = mybool[0];
    boll_mid_B = mybool[1];
    boll_low_B = mybool[2];
    /*point*/
    bool_length =(boll_up_B - boll_low_B )/2;


    
    ma_pre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            Move_Av, MaType.SMA, 1);
    
    // ma = Close[0];  
    mybool = indicators.bbands(my_symbol, my_timeperiod, OfferSide.BID, AppliedPrice.CLOSE,
            iBoll_B, 2, 2, MaType.SMA, 1);
    
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
        ChangeCrossValue(crossflag,ma,bool_length,StrongWeak,SymPos,timeperiodnum);
        //  Print(mMailTitlle + Symbol()+"::本周期突破高点，除(1M、5M周期bool口收窄且快速突破追高，移动止损），其他情况择机反向做空:"
        //  + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));                  

    }
    
    /*本周期突破高点后回调，观察如小周期长时间筑顶，寻机卖出*/
    else if((ma <boll_up_B) && (ma_pre > boll_up_B_pre ) )
    {
        crossflag = 4;
        ChangeCrossValue(crossflag,ma,bool_length,StrongWeak,SymPos,timeperiodnum);
        //   Print(mMailTitlle + Symbol()+"::本周期突破高点后回调，观察小周期如长时间筑顶，寻机做空:"
        //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));                  


    }
        
    
    /*本周期突破低点，观察如小周期未衰竭可追低卖出，或者等待回调卖出*/
    else if((ma < boll_low_B) && (ma_pre > boll_low_B_pre ) )
    {
    
        
        crossflag = -5;
        ChangeCrossValue(crossflag,ma,bool_length,StrongWeak,SymPos,timeperiodnum);
        //   Print(mMailTitlle + Symbol() + "::本周期突破低点，除(条件：1M、5M周期bool口收窄且快速突破追低，移动止损），其他情况择机反向做多:"
        //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));                                      


    }
        
    /*本周期突破低点后回调，观察如长时间筑底，寻机买入*/
    else if((ma > boll_low_B) && (ma_pre < boll_low_B_pre ) )
    {
        crossflag = -4;    
        ChangeCrossValue(crossflag,ma,bool_length,StrongWeak,SymPos,timeperiodnum);
        //   Print(mMailTitlle + Symbol() + "::本周期突破低点后回调，观察如小周期长时间筑底，寻机买入:"
        //   + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));                                      


    }


            
    /*本周期上穿中线，表明本周期趋势开始发生变化为上升，在下降大趋势下也可能是回调杀入机会*/
    else if((ma > boll_mid_B) && (ma_pre < boll_mid_B_pre ))
    {
    
        crossflag = 1;                
        ChangeCrossValue(crossflag,ma,bool_length,StrongWeak,SymPos,timeperiodnum);            
        //    Print(mMailTitlle + Symbol() + "::本周期上穿中线变化为上升，大周期下降大趋势下可能是回调做空机会："
        //    + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));                                      


    }    
    /*本周期下穿中线，表明趋势开始发生变化，在上升大趋势下也可能是回调杀入机会*/
    else if( (ma < boll_mid_B) && (ma_pre > boll_mid_B_pre ))
    {
        crossflag = -1;                                
        ChangeCrossValue(crossflag,ma,bool_length,StrongWeak,SymPos,timeperiodnum);            
         //     Print(mMailTitlle + Symbol() + "::本周期下穿中线变化为下降，大周期上升大趋势下可能是回调做多机会："
         //     + DoubleToString(bool_length)+":"+DoubleToString(bool_length/Point));                                      

    }                            
    else
    {
         crossflag = 0;   

    }

    BoolCrossRecord[SymPos][timeperiodnum].BoolFlag = BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0];
    BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange = crossflag;

    BoolCrossRecord[SymPos][timeperiodnum].BoolLength = bool_length;
      

    
    MAFive = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            5, MaType.SMA, 0);

    MAThentyOne = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 0);
    
    MASixty = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 0);                
    
    
    MAFivePre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            5, MaType.SMA, 1);


    MAThentyOnePre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            21, MaType.SMA, 1);
    
    MASixtyPre = indicators.ma(my_symbol, my_timeperiod, 
            OfferSide.BID, AppliedPrice.CLOSE,
            60, MaType.SMA, 1);                
                     

    StrongWeak =5;

    if(MAFivePre > MAThentyOnePre)
    {
            
        /*多均线多头向上*/
        if(MASixtyPre < MAThentyOnePre)
        {
             StrongWeak =9;
        }
        else if (MASixtyPre <= MAFivePre)
        {
             StrongWeak =8;
        }
        else
        {
             StrongWeak =7;
        }
    
    }
    else if (MAFivePre < MAThentyOnePre)
    {
        /*多均线多头向下*/
        if(MASixtyPre > MAThentyOnePre)
        {
             StrongWeak =1;
        }
        else if (MASixtyPre >= MAFivePre)
        {
             StrongWeak =2;
        }
        else
        {
             StrongWeak =3;
        }      
    
    }
    else
    {
        StrongWeak =5;

    }
    BoolCrossRecord[SymPos][timeperiodnum].PreStrongWeak = StrongWeak;
    
////////////////////////////////////////////////////////////////////   
    StrongWeak =5;

    if(MAFive > MAThentyOne)
    {
            
        /*多均线多头向上*/
        if(MASixty < MAThentyOne)
        {
             StrongWeak =9;
        }
        else if (MASixty <= MAFive)
        {
             StrongWeak = 8;
        }
        else
        {
             StrongWeak =7;
        }
    
    }
    else if (MAFive < MAThentyOne)
    {
        /*多均线多头向下*/
        if(MASixty > MAThentyOne)
        {
             StrongWeak =1;
        }
        else if (MASixty >= MAFive)
        {
             StrongWeak =2;
        }
        else
        {
             StrongWeak =3;
        }      
    
    }
    else
    {
        StrongWeak =5;

    }

    BoolCrossRecord[SymPos][timeperiodnum].StrongWeak = StrongWeak;    
    
    
    if(timeperiodnum ==2)
    {
 //       console.getOut().println("TEST: StongWeak:"+"BoolCrossRecord[SymPos]["+timeperiodnum+"].StrongWeak="+BoolCrossRecord[SymPos][timeperiodnum].StrongWeak
 //       +"bar"+iBars(my_symbol,timeperiod[timeperiodnum])); 
    } 
    
    
    
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
         
        if(bool_length>0.0001)
        {
            boolindex = ((vask + vbid)/2 - boll_mid_B)/bool_length;
            BoolCrossRecord[SymPos][timeperiodnum].BoolIndex = boolindex;
        }
        

    }    
                
    return;
}



 public int GetOrderFreeSubNumber(int SymPos, int timeperiodnum,int startnum,int endnum)throws JFException
{
   int res ;
   int i;
   res = -1;
   
    for(i = startnum; i <= endnum; i=i+2)
    {
        
        if(SymOrderCloseStatus(MakeMagic(SymPos,(timeperiodnum*32+i)*10))==true)
        {
            res = i;
            break;
        }
    }        
    return res;
  
}

 public int GetOrderNoFreeSubNumber(int SymPos, int timeperiodnum,int startnum)throws JFException
{
   int res ;
   int i;
   res = -1;
   
    for(i = startnum; i <= 32; i=i+2)
    {
        
        if(SymOrderCloseStatus(MakeMagic(SymPos,(timeperiodnum*32+i)*10))==false)
        {
            res = i;
            break;
        }
    }        
    return res;
  
}
   
 public int GetOrderNoFreeCount(int SymPos, int timeperiodnum,int startnum)throws JFException
{
   int res ;
   int i;
   res = 0;
   
    for(i = startnum; i <= 32; i=i+2)
    {
        
        if(SymOrderCloseStatus(MakeMagic(SymPos,(timeperiodnum*32+i)*10))==false)
        {
            res =res +1;
        }
    }        
    return res;
  
}
    
 
public void orderbuyselltypeone(int SymPos, int timeperiodnum,ITick tick)throws JFException
{
    

    Period my_timeperiod;
    Instrument my_symbol;

    double boll_up_B,boll_low_B,bool_length,boll_mid_B;    
    double vbid,vask; 
    double MinValue3 = 100000;
    double MaxValue4=-1;

    double equalboollength;
    double orderLots ;   
    double orderStopless ;
    double orderTakeProfit;
    double orderPrice;
    int Pos1,Pos2,j,Pos3;

    int i,res;
    res = -1;
    orderLots = 0;   
    orderStopless = 0;
    orderTakeProfit = 0;
    orderPrice = 0;
        
    my_symbol =   MySymbol[SymPos];
    my_timeperiod = timeperiod[timeperiodnum];    
   
   
//////////////////////
   
///////////////////////////////////////////////////////////
//完全重构，开多单，次周期形态转为正向积极，本周期处于可能转型的问题，上周期为多头
    if((5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlagChange)
        &&(5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[0])                                                                                   
        &&( BoolCrossRecord[SymPos][timeperiodnum-1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum-1]))
        ){
            res = GetOrderFreeSubNumber(SymPos,timeperiodnum,1,31);
            //还有位置可以开多单
            if(res>0)
            {
                Pos1 = -1;
                Pos2 = -1;
                Pos3 = -1;
                for(j = 1 ; j <28;j++)
                {
                    if(-5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[j])
                    {
                        Pos1 = j;
                        break;
                    }
                }
                 if(Pos1 > 0)
                 {
                     
                    for(j = Pos1+1 ; j <28;j++)
                    {
                        if(-5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[j])
                        {
                            Pos2 = j;
                            break;
                        }
                    }                                
                                           
                                                                 
                 }

                 if(Pos2 > 0)
                 {
                     
                    for(j = Pos2+1 ; j <28;j++)
                    {
                        if(-5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[j])
                        {
                            Pos3 = j;
                            break;
                        }
                    }                                
                                           
                                                                 
                 }
                                                   
                 
                 //出现过3次跌破下轨线
                 if((Pos1>0)&&(Pos2>0)&&(Pos3>0))
                 {
                     

                    //大周期多头向上，本周期跌破下轨比上一次高，反应不是改变形态，上一次比上上一次低，反应调整充分
                     if(
                     
                        //次周期近期曾经下探过新低
                        (( BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos3]
                             > BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos1])  
                        ||( BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos3]
                             > BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos2]))
                            && (Pos3 < 18)
                                                          
                        //次周期从均线看开始转强
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[3]+0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[4]+0.01)                                             
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[5]+0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[6]+0.01)                               
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[7]+0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[8]+0.01)                                             
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[9]+0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak>BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[10]+0.01)
                        
                        //次周期Bool线看开始转强                                                                                                                                                                                                                                                                                                        
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[3])  
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[4])   
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[5]) 
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[6])  
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[7])   
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[8]) 
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[9])   
                        &&(3 >= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[10]) 
                                                                               
                        //本周期处于平缓态势
                        //&&(BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0]<8)     
                        &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak<8.5)                        
                        //&&(BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0]>2)     
                        &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak> 1.5)
                        
                        //本周期处于回调可能变点的位置
                        &&((((BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] == -1)     
                        ||(BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==1))                           
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex >-0.2  )         
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex <0.2  ) )                           
                        ||
                        (((BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] == -1)     
                        ||(BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==-4))                           
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex >-0.9  )         
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex <-0.7  ) )  )
                        
                        //大周期为多头
                        &&(BoolCrossRecord[SymPos][timeperiodnum+2].StrongWeak<6)
                        //&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak<9)                        
                        //&&(BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0]>8)
                        
                        //&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)                        
                        )                                                                                                                    
                          
                        {
                               
                            equalboollength = 0;
                            for(j = 0 ; j <28;j++)
                            {
                                equalboollength = equalboollength + BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolLength[j];
            
                            }                
                            equalboollength = equalboollength/28;
                                                           
                            double[] mybool1 = new double[10];                                    
                    
                            mybool1 = indicators.bbands(my_symbol, timeperiod[timeperiodnum-1], OfferSide.BID, AppliedPrice.CLOSE,
                                    iBoll_B, 2, 2, MaType.SMA, 1);
                            
                            boll_up_B = mybool1[0];
                            boll_mid_B = mybool1[1];
                            boll_low_B = mybool1[2];    
                            
                            /*point*/
                            bool_length =(boll_up_B - boll_low_B )/2;   
                                                  
                             vask = tick.getAsk();
                             vbid = tick.getBid();
                            
                            //原则上不设置止盈，bool为5时分批止盈，同时持有时间到一定时间后直接平仓
                            orderTakeProfit = 0; 
                            
                            //原则上止损足够大，不要触发止损，bool为5时分批止盈，同时持有时间到一定时间后直接平仓
                            //设置止损是为了防止黑天鹅事件的影响
                            orderStopless = boll_low_B-bool_length*5;
                                              
                            //大周期的顺势和逆势，基本面的判断，最终可以只体现在下单的数量上面，理论上每一单的下单数量都可以不同，以后调整                                
                            orderLots = BuySellPosRecord[SymPos].orderamount[timeperiodnum*32+res];
                            orderPrice = vask;                 
                    
                            //小周期移动止损
                            orderStopless = orderPrice-equalboollength*2;   
                            BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+res] = equalboollength*6;
                            BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+res] = orderPrice - equalboollength*6;                                                      
                            orderStopless = 0;
                            
                            String s;
                            s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
                            //console.getOut().println(s);                                                                           
                                        
                            s = my_symbol+" MagicNumber"+(timeperiodnum*32+res)*10+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
                                        +orderPrice+"orderStopless="
                                        +orderStopless +"orderTakeProfit="+orderTakeProfit;    
                           // console.getOut().println(s);
                    
                            
                            if(true == accountcheck())
                            {
                                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                            
                                IOrder order = engine.submitOrder(MakeMagic(SymPos,(timeperiodnum*32+res)*10), 
                                        my_symbol, OrderCommand.BUY, orderLots, orderPrice, 
                                        5, orderStopless,0 );                                
                                order.waitForUpdate(2000, OPENED, FILLED);
                                 if(null != order)
                                 {     
                                    TwentyS_Freq++;
                                    OneM_Freq++;
                                    ThirtyS_Freq++;
                                    FiveM_Freq++;
                                    ThirtyM_Freq++;    
                                    BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+res] = iBars(my_symbol,timeperiod[timeperiodnum])+64;                     
                                    BuySellPosRecord[SymPos].TradeTimePos[timeperiodnum*32+res] = iBars(my_symbol,timeperiod[timeperiodnum]);                                  
                                   // console.getOut().println(my_symbol+"OrderSend MagicNumber"+(timeperiodnum*2+1)*10+"  successfully");
                                 }                                                    
                                 
                            }                    
                            
                                                                              
                        }                                                                                                                                                                                                          
                                                                                        
                    }
            }
        }
                    
   

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//多空分界线    
//////////////////////////////////////////////////////////////  
///////////////////////////////////////////////////////////
//完全重构，开空单，次周期形态转为空方向积极，本周期处于可能转型的位置，上周期为空头
    if((-5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlagChange)
        &&(-5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[0])                                                                                   
        &&( BoolCrossRecord[SymPos][timeperiodnum-1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum-1]))
        ){
            res = GetOrderFreeSubNumber(SymPos,timeperiodnum,2,32);
            //还有位置可以开空单
            if(res>0)
            {
                Pos1 = -1;
                Pos2 = -1;
                Pos3 = -1;
                for(j = 1 ; j <28;j++)
                {
                    if(5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[j])
                    {
                        Pos1 = j;
                        break;
                    }
                }
                 if(Pos1 > 0)
                 {
                     
                    for(j = Pos1+1 ; j <28;j++)
                    {
                        if(5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[j])
                        {
                            Pos2 = j;
                            break;
                        }
                    }                                
                                           
                                                                 
                 }

                 if(Pos2 > 0)
                 {
                     
                    for(j = Pos2+1 ; j <28;j++)
                    {
                        if(5 == BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[j])
                        {
                            Pos3 = j;
                            break;
                        }
                    }                                
                                           
                                                                 
                 }
                                                   
                 
                 //出现过3次升破上轨线
                 if((Pos1>0)&&(Pos2>0)&&(Pos3>0))
                 {
                     

                    //大周期多头向上，本周期跌破下轨比上一次高，反应不是改变形态，上一次比上上一次低，反应调整充分
                     if(
                     
                        //次周期近期曾经上探过新高
                        (( BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos3]
                             < BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos1])  
                        ||( BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos3]
                             < BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolValue[Pos2]))
                            && (Pos3 < 18)
                                                          
                        //次周期从均线看开始转弱
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[3]-0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[4]-0.01)                                             
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[5]-0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[6]-0.01)                               
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[7]-0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[8]-0.01)                                             
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[9]-0.01)
                        &&(BoolCrossRecord[SymPos][timeperiodnum-1].StrongWeak<BoolCrossRecord[SymPos][timeperiodnum-1].CrossStrongWeak[10]-0.01)
                        
                        //次周期Bool线看开始转弱                                                                                                                                                                                                                                                                                                        
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[3])  
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[4])   
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[5]) 
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[6])  
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[7])   
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[8]) 
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[9])   
                        &&(-3 <= BoolCrossRecord[SymPos][timeperiodnum-1].CrossFlag[10]) 
                                                                               
                        //本周期处于平缓态势
                        //&&(BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0]<8)     
                        &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak<8.5)                      
                        //&&(BoolCrossRecord[SymPos][timeperiodnum].CrossStrongWeak[0]>2)     
                        &&(BoolCrossRecord[SymPos][timeperiodnum].StrongWeak> 1.5) 
                        
                        //本周期处于回调可能变点的位置
                        &&((((BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] == -1)     
                        ||(BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==1))                           
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex >-0.2  )         
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex <0.2  ) )                           
                        ||
                        (((BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0] == 1)     
                        ||(BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==4))                           
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex <0.9  )         
                        &&(BoolCrossRecord[SymPos][timeperiodnum].BoolIndex >0.7  ) )  )
                        
                        //大周期为空头
                        &&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>4)
                        //&&(BoolCrossRecord[SymPos][timeperiodnum+1].StrongWeak>1)                        
                        //&&(BoolCrossRecord[SymPos][timeperiodnum+1].CrossStrongWeak[0]<8)
                        
                        //&&(BoolCrossRecord[SymPos][timeperiodnum+3].StrongWeak>0.8)                        
                        )                                                                                                                    
                          
                        {
                               
                            equalboollength = 0;
                            for(j = 0 ; j <28;j++)
                            {
                                equalboollength = equalboollength + BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolLength[j];
            
                            }                
                            equalboollength = equalboollength/28;
                                                           
                            double[] mybool1 = new double[10];                                    
                    
                            mybool1 = indicators.bbands(my_symbol, timeperiod[timeperiodnum-1], OfferSide.BID, AppliedPrice.CLOSE,
                                    iBoll_B, 2, 2, MaType.SMA, 1);
                            
                            boll_up_B = mybool1[0];
                            boll_mid_B = mybool1[1];
                            boll_low_B = mybool1[2];    
                            
                            /*point*/
                            bool_length =(boll_up_B - boll_low_B )/2;   
                                                  
                             vask = tick.getAsk();
                             vbid = tick.getBid();
                            
                             //原则上不设置止盈，bool为5时分批止盈，同时持有时间到一定时间后直接平仓
                            orderTakeProfit = 0; 
                            
                            //原则上止损足够大，不要触发止损，bool为5时分批止盈，同时持有时间到一定时间后直接平仓
                            //设置止损是为了防止黑天鹅事件的影响
                            orderStopless = boll_up_B+bool_length*5;
                                              
                            //大周期的顺势和逆势，基本面的判断，最终可以只体现在下单的数量上面，理论上每一单的下单数量都可以不同，以后调整                                
                            orderLots = BuySellPosRecord[SymPos].orderamount[timeperiodnum*32+res];
                            orderPrice = vbid;
                                             
                            orderStopless = orderPrice +  equalboollength*2;
                            //采用软止损，而不是硬止损；并且采用分段止损的方式，第一阶段止损是确认买入点的正确性，第二阶段止损原则上不触发
                            BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+res] = equalboollength*6;
                            BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+res] = orderPrice + equalboollength*6;
                            orderStopless = 0;
                            String s;
                            s = my_symbol+"BoolCrossRecord["+SymPos+"][" +timeperiodnum+"]:"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]+":" 
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[1]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[2]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[3]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[4]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[5]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[6]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[7]+":"+ BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[8]+":"
                            + BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[9];
                           // console.getOut().println(s);
                                                
                            s= my_symbol+" MagicNumber"+(timeperiodnum*32+res)*10+" OrderSend:" + "orderLots=" + orderLots +"orderPrice ="
                                            +orderPrice+"orderStopless="+orderStopless
                                            +"orderTakeProfit="+orderTakeProfit;    
                    
                            
                            if(true == accountcheck())
                            {
                                orderTakeProfit = ((int) (orderTakeProfit*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                                orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);
                            
                                IOrder order = engine.submitOrder(MakeMagic(SymPos,(timeperiodnum*32+res)*10), 
                                        my_symbol, OrderCommand.SELL, orderLots, orderPrice, 
                                        5, orderStopless,0 );                                
                                order.waitForUpdate(2000, OPENED, FILLED);
                                 if(null != order)
                                 {     
                                    TwentyS_Freq++;
                                    OneM_Freq++;
                                    ThirtyS_Freq++;
                                    FiveM_Freq++;
                                    ThirtyM_Freq++;    
                                    BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+res] = iBars(my_symbol,timeperiod[timeperiodnum])+64;                     
                                    BuySellPosRecord[SymPos].TradeTimePos[timeperiodnum*32+res] = iBars(my_symbol,timeperiod[timeperiodnum]);                                  
                                   // console.getOut().println(my_symbol+"OrderSend MagicNumber"+(timeperiodnum*2+1)*10+"  successfully");
                                 }                                                    
                                 
                            }                    
                            
                                                                              
                        }                                                                                                                                                                                                          
                                                                                        
                    }
            }
        }
                    
   


}


public void checkbuysellordertypeone(int SymPos, int timeperiodnum,ITick tick)throws JFException
{
    
    Period my_timeperiod;
    Instrument my_symbol;

    
    double boll_up_B,boll_low_B,bool_length,boll_mid_B;    
    double vbid,vask; 
    double MinValue3 = 100000;
    double MaxValue4 = -1;

    double temprice =0;
    int     temcount =0;
    double orderLots ;   
    double orderStopless ;
    double orderTakeProfit;
    double orderPrice;
    int countnumber = 0;
    int i;
       
    IOrder order;
    int res;
    orderLots = 0;   
    orderStopless = 0;
    orderTakeProfit = 0;
    orderPrice = 0;
    my_timeperiod = timeperiod[timeperiodnum];    
    my_symbol =   MySymbol[SymPos];
    
    vbid = tick.getBid();
    vask = tick.getAsk();

    //处理持有的多单
    for(i =  1; i <= 32; i=i+2)
    {
        
        order = engine.getOrder(MakeMagic(SymPos,(timeperiodnum*32+i)*10));        
        if(null != order)
        {    
            if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED)
            {
                            
                  
                    //标明这是一个前些时候下的订单，且程序被重启过，将持有时间修改为默认的32个周期，如果要关闭以前的单就手工吧    
                    if(BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i]- (iBars(my_symbol,my_timeperiod)) > 100000)
                    {
                        BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i] = iBars(my_symbol,my_timeperiod) + 32;
                    }    
                 
        
                    //止损未触及成本之前采用移动止损
                    orderPrice = vask; 
                    if(((orderPrice-BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+i])> BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+i] )
                      &&((orderPrice-BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+i])< order.getOpenPrice() ))
                      {
                          BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+i] = orderPrice-BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+i];
                      }
                    
                    //触发手动止损
                    if(orderPrice<BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+i])
                    {
                        order.close();
                        order.waitForUpdate(2000, CLOSED, CANCELED);
                      //  console.getOut().println(order.getProfitLossInUSD());                        
                        console.getOut().println("shut Long due to Handle Cut:"+order.getProfitLossInUSD()+":"+MakeMagic(SymPos,(timeperiodnum*32+i)*10));                         
                    }
                    
                          
                            
                    //每过一个周期订单持有时间标记减一
                    //自动完成
        
                    //订单持有到期，关闭该订单    
                    if(BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i]- (iBars(my_symbol,my_timeperiod)) < 0)
                    {
                        order.close();
                        order.waitForUpdate(2000, CLOSED, CANCELED);
                      //  console.getOut().println(order.getProfitLossInUSD());                        
                        console.getOut().println("shut Long due to Keeptime UP:"+order.getProfitLossInUSD()+":"+MakeMagic(SymPos,(timeperiodnum*32+i)*10));                        
                    } 
            
                    //本周期处于上行阶段持有周期延长
                    if(((BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==1)
                        ||(BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==5))
                        &&( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum])))
                    {
                       //每过一个周期订单持有时间标记加一
                        BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i] = BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i]+1;                         
                        
                    }
                    
                    
                    //本周期突破bool上轨的时候重新评估止损。
                    if((5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
                        &&(5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
                        &&( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum]))
                       )        
                    {
    
                        double equalboollength = 0;
                        for(int j = 0 ; j <28;j++)
                        {
                            equalboollength = equalboollength + BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolLength[j];
        
                        }                
                        equalboollength = equalboollength/28;
                        /*point*/
                                     
                        //持有时间变长             
                        BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i] = iBars(my_symbol,my_timeperiod) + 600;  
                                                                 
                        orderPrice = vask;   
                                         
                        orderStopless = orderPrice - equalboollength*6;
                        
                        //在盈利足够多的情况下，将止损设置为开仓价格止损价格中间
                        if (orderStopless > order.getOpenPrice())
                        {
                           orderStopless = (orderStopless +order.getOpenPrice())/2;                   
                        }  
    
                        //orderStopless =  orderPrice - bool_length*5; 
                        //重新设置止损价格
                        if(orderStopless >order.getStopLossPrice()+0.0001)
                        {        
                            orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);                   
                            //order.setStopLossPrice(orderStopless);
                  
                        }                                                                                                                                                                                                                        
                        
                    }
                    
            
    
                    //大周期突破bool上轨的时候分批止盈。
                    if((4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
                        &&(4==BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
                        &&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
                       )        
                    {
    
                        //分批平仓
                         orderLots = order.getAmount()/2;                
                         /*三次完成出货*/
                         if (orderLots <= BuySellPosRecord[SymPos].orderamount[0]*9/64)
                         {
                             orderLots = order.getAmount();
                         }                                           
                         order.close(orderLots);   
                         //order.close();                        
                         console.getOut().println(my_symbol+"Orderclose MagicNumber"+(timeperiodnum*32+i)*10+"  8 Long successfully:"+orderLots+":"+order.getProfitLossInUSD()); 
                                  
                    }
                       
            
            
            }
                
        }    

    }

    //处理持有的空单
    for(i =  2; i <= 32; i=i+2)
    {
        
        order = engine.getOrder(MakeMagic(SymPos,(timeperiodnum*32+i)*10));        
        if(null != order)
        {    
            if(order.getState() == IOrder.State.FILLED || order.getState() == IOrder.State.OPENED)
            {

                    //标明这是一个前些时候下的订单，且程序被重启过，将持有时间修改为默认的32个周期，如果要关闭以前的单就手工吧    
                    if(BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i]- (iBars(my_symbol,my_timeperiod)) > 100000)
                    {
                        BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i] = iBars(my_symbol,my_timeperiod) + 32;
                    }    
                 
        
                    //止损未触及成本之前采用移动止损
                    orderPrice = vbid; 
                    if(((orderPrice+BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+i])< BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+i] )
                      &&((orderPrice+BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+i])> order.getOpenPrice() ))
                      {
                          BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+i] = orderPrice+BuySellPosRecord[SymPos].StopLossL[timeperiodnum*32+i];
                      }
                    
                    //触发手动止损
                    if(orderPrice>BuySellPosRecord[SymPos].StopLossH[timeperiodnum*32+i])
                    {
                        order.close();
                        order.waitForUpdate(2000, CLOSED, CANCELED);
                      //  console.getOut().println(order.getProfitLossInUSD());                        
                        console.getOut().println("shut Short due to Handle Cut:"+order.getProfitLossInUSD()+":"+MakeMagic(SymPos,(timeperiodnum*32+i)*10));                         
                    }
                    
                          
                            
                    //每过一个周期订单持有时间标记减一
                    //自动完成
        
                    //订单持有到期，关闭该订单    
                    if(BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i]- (iBars(my_symbol,my_timeperiod)) < 0)
                    {
                        order.close();
                        order.waitForUpdate(2000, CLOSED, CANCELED);
                      //  console.getOut().println(order.getProfitLossInUSD());                        
                        console.getOut().println("shut Short due to Keeptime UP:"+order.getProfitLossInUSD()+":"+MakeMagic(SymPos,(timeperiodnum*32+i)*10));                        
                    } 
            
                    //本周期处于下行阶段持有周期延长
                    if(((BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==-1)
                        ||(BoolCrossRecord[SymPos][timeperiodnum].CrossFlag[0]==-5))
                        &&( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum])))
                    {
                       //每过一个周期订单持有时间标记加一
                        BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i] = BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i]+1;                         
                        
                    }
                    
                    
                    //本周期突破bool下轨的时候重新评估止损。
                    if((-5 == BoolCrossRecord[SymPos][timeperiodnum].CrossFlagChange)
                        &&(-5==BoolCrossRecord[SymPos][timeperiodnum].BoolFlag)
                        &&( BoolCrossRecord[SymPos][timeperiodnum].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum]))
                       )        
                    {
    
                        double equalboollength = 0;
                        for(int j = 0 ; j <28;j++)
                        {
                            equalboollength = equalboollength + BoolCrossRecord[SymPos][timeperiodnum-1].CrossBoolLength[j];
        
                        }                
                        equalboollength = equalboollength/28;
                        /*point*/
                                     
                        //持有时间变长             
                        BuySellPosRecord[SymPos].NextModifyPos[timeperiodnum*32+i] = iBars(my_symbol,my_timeperiod) + 600;  
                                                                 
                        orderPrice = vask;   
                                         
                        orderStopless = orderPrice + equalboollength*6;
                        
                        //在盈利足够多的情况下，将止损设置为开仓价格止损价格中间
                        if (orderStopless < order.getOpenPrice())
                        {
                           orderStopless = (orderStopless +order.getOpenPrice())/2;                   
                        }  
    
                        //orderStopless =  orderPrice - bool_length*5; 
                        //重新设置止损价格
                        if(orderStopless < order.getStopLossPrice()-0.0001)
                        {        
                            orderStopless = ((int) (orderStopless*10/my_symbol.getPipValue()))*(my_symbol.getPipValue()/10);                   
                            //order.setStopLossPrice(orderStopless);
                  
                        }                                                                                                                                                                                                                        
                        
                    }
                    
            
    
                    //大周期突破bool下轨的时候分批止盈。
                    if((-4 == BoolCrossRecord[SymPos][timeperiodnum+1].CrossFlagChange)
                        &&(-4==BoolCrossRecord[SymPos][timeperiodnum+1].BoolFlag)
                        &&( BoolCrossRecord[SymPos][timeperiodnum+1].ChartEvent != iBars(my_symbol,timeperiod[timeperiodnum+1]))
                       )        
                    {
    
                        //分批平仓
                         orderLots = order.getAmount()/2;                
                         /*三次完成出货*/
                         if (orderLots <= BuySellPosRecord[SymPos].orderamount[0]*9/64)
                         {
                             orderLots = order.getAmount();
                         }                                           
                         order.close(orderLots);   
                         //order.close();                        
                         console.getOut().println(my_symbol+"Orderclose MagicNumber"+(timeperiodnum*32+i)*10+"  8 Short successfully:"+orderLots+":"+order.getProfitLossInUSD()); 
                                  
                    }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            }


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

        orderbuyselltypeone(SymPos,1,tick);
        orderbuyselltypeone(SymPos,2,tick);
        orderbuyselltypeone(SymPos,3,tick);


        checkbuysellordertypeone(SymPos,1,tick);
        checkbuysellordertypeone(SymPos,2,tick);
        checkbuysellordertypeone(SymPos,3,tick);  
                      
        //checkbuysellordertypeonePlus(SymPos,tick);


        
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
    
        calculateindicatorOnbar(SymPos,timeperiodnum,askBar,bidBar);    
        
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
          
                  
         switch(message.getType()){
            case ORDER_SUBMIT_OK : 
                //console.getOut().println("Order opened: " + message.getOrder());
                break;
            case ORDER_SUBMIT_REJECTED : 
                //console.getOut().println("Order open failed: " + message.getOrder());
                break;
            case ORDER_FILL_OK : 
               // console.getOut().println("Order filled: " + message.getOrder());
                break;
            case ORDER_FILL_REJECTED : 
                //console.getOut().println("Order cancelled: " + message.getOrder());
                break;
            case ORDER_CLOSE_OK : 
                if(message.getReasons().contains(IMessage.Reason.ORDER_CLOSED_BY_SL))
                {
                    //console.getOut().println("Order closed by SL: " + message.getOrder()+":" + message.getOrder().getProfitLossInUSD());
                    console.getOut().println("SL:"+message.getOrder().getProfitLossInUSD());                    
                }
                else if(message.getReasons().contains(IMessage.Reason.ORDER_CLOSED_BY_TP))
                {
                    //console.getOut().println("Order closed by TP: " + message.getOrder()+":" + message.getOrder().getProfitLossInUSD());                    
                    console.getOut().println(message.getOrder().getProfitLossInUSD());                  
                }                 
                break;                
            case ORDER_CHANGED_OK : 
                if(message.getReasons().contains(IMessage.Reason.ORDER_CHANGED_LABEL))
                {
                    console.getOut().println("Order label was changed: " + message.getOrder());                    
                }              

                break;               
        }                   
                
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
    public double StopLossL[];
    public double StopLossH[];
    public int BSChangeFlag[];
    public double orderamount[];
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


//该类反应的是图形指标状态数字化描述，精确到货币对和时间周期
class stBoolCrossRecord {


    //穿越大bool线的值-5，-4，-1，1，4，5
    int CrossFlag[];
    //穿越大bool线时的MA多线交叉情况0.9为多头向上，0.1为多头向下
    int CrossStrongWeak[];
    //穿越大bool线时的多空趋势
    double CrossTrend[];
    //穿越大bool线时的位置  
    int CrossBoolPos[];

    double CrossBoolValue[];
    double CrossBoolLength[];
    int StrongWeak = 0;
    int PreStrongWeak = 0;
    int Trend = 0;
    double BoolIndex = 0;
    double BoolFlag = 0;
    double BoolLength = 0;
    int CrossFlagChange = 0;
    int CrossFlagTemp = 0;
    int CrossFlagTempPre = 0;
    int ChartEvent = 0;
    long startTime = 0;
    int iBarPos = 0;
    public stBoolCrossRecord() throws JFException {};
};



//该类描述的是输入参数，原则上输入参数要进行必要的优化，精确到货币对和时间周期（或者买卖类型的合适参数）
class stInputParamater {

    //大Bool标准方差值倍数，预计1.2-1.5之间；默认按照 1.2 要做参数优化
    double StandardHBoolParam = 0;

    //小Bool标准方差值倍数，预计0.85-1.1之间；默认按照 0.95 要做参数优化
    double StandardLBoolParam = 0;
  
      //设置默认的止损线，N倍的StarndardBool所有的order都必须有止损线，考虑的是出现重大数据事件能有及时止损；
      //默认按照五分钟3倍，三十分钟2倍，4H 1倍，默认为3，要做参数优化
    double StopLessSTBool = 0;

    //下订单后的持有时间 60-120之间，针对不同的货币对，默认为60，时间周期，要做参数优化
    int KeepOrderBarPeriod = 0;

    boolean RelearningFlag =true;

    public stInputParamater() throws JFException {};
};



//对输入参数StandardHBoolParam，StandardLBoolParam，StopLessSTBool，KeepOrderBarPeriod进行自学习，试图寻找到指标最优的输入参数
//该指标指的是总的来说每单平均归一化利润率最高=所有归一化利润之和除以总单数，且总单数大于100（确保样本足够多），且每单平均归一化利润率大于0.2
//归一化处理方法为每单利润除以（StopLessSTBool*Boollength);


//Input1 BigBool  1.2--1.6  step 0.01  count 42
//Input2 LittleBool  0.8--1.2  step 0.01  count 42
//Input3 OrderKeepTime  60--120  step 1  count 62
//Input4 StopLessSTBool  2--4  step 0.1  count 22


class stSelfLearnMidPara{

    //寻找到的订单数量，原则上不超过500，大于100，超过500部分进行覆盖
    int SelfAllLearnOrder = 0;

    //定义最后一个订单的位置，目的是后续再自学习的时候超过500时，更容易自后往前覆盖
    int SelfLastOrderPos = 0;

    //从当前的Bar位置开始往前学习
    int SelfLatestBarPos = 0;

    //最前面的Bar位置
    int SelfLastBarPos = 0;

    //下单价格
    double SelfOrderPrice [];

    //下单位置
    double SelfOrderPos[];
    //做多做空，1为做多，-1为做空
    double SelfLongShort[];
    //平单价格
    double SelfCutOrderPrice[];
    //止损宽度,用来归一化每单利润
    double SelfStopLossLength[];

    //触发宽度止损平仓，设置为1；
    int SelfSltopLossFlag[];

    //触发大bool指数平仓，设置为1
    int SelfBigBoolLossFlag[];

    //触发订单持有时间到期平仓,设置为1
    int SelfCatKeepOrderPeriodFlag[];

    //触发bool止盈平仓，实际做法是平半仓，设置为1；
    int SelfBoolTakeProfitCutFlag[];

    //定义利润率指数，在单数超过100的情况下，这个指数最大的输入参数定义为最优参数
    //计算方式为 求和【（SelfCutOrderPrice-SelfOrderPrice）*SelfLongShort／SelfStopLossLength】/ SelfAllLearnOrder >0.1 寻找最大值
    double SelfProfitIndex;

    int SelfSltopLossFlagCount;
    int SelfBigBoolLossFlagCount;
    int SelfCatKeepOrderPeriodFlagCount;
    int SelfBoolWinCutFlagCount;

    public stSelfLearnMidPara() throws JFException {};

};



//end new added

///////////////////////////////////////////////////
