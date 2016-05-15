//+------------------------------------------------------------------+
//|                                                    NeuroIBOND.mq4 |
//|                                                 Mariusz Woloszyn |
//|                                           Fann2MQL.wordpress.com |
//+------------------------------------------------------------------+
#property copyright "xuejiayong"
#property link      "Fann2MQL.wordpress.com"

// Include Neural Network package
#include <Fann2MQL.mqh>

// Global defines
#define ANN_PATH	"C:\\ANN\\"
// EA Name
#define NAME		"NeuroIBOND"

//---- input parameters
extern double Lots = 0.1;
extern double StopLoss = 180.0;
extern double TakeProfit = 270.0;
extern double Delta = -0.6;
extern int AnnsNumber = 16;
extern int AnnInputs = 40;
extern bool NeuroFilter = true;
extern bool SaveAnn = true;
extern int DebugLevel = 2;
extern double MinimalBalance = 100;
extern bool Parallel = true;

extern int Move_Av = 3;
extern int iBoll_B = 60;

int BuyedPosition = -1;
int SelledPosition = -1;

// Global variables

// Path to anns folder
string AnnPath;

// Trade magic number
int MagicNumber = 65536;

// AnnsArray[ann#] - Array of anns
int AnnsArray[];

// All anns loded properly status
bool AnnsLoaded = true;

// AnnOutputs[ann#] - Array of ann returned returned
double AnnOutputs[];

// InputVector[] - Array of ann input data
double InputVector[];

// Long position ticket
int LongTicket = -1;

// Short position ticket
int ShortTicket = -1;

// Remembered long and short network inputs
double LongInput[];
double ShortInput[];

void
debug (int level, string text)
{
    if (DebugLevel >= level) {
	if (level == 0)
	    text = "ERROR: " + text;
	Print (text);
    }
}

bool
is_ok_period (int period)
{
    if (Period () != period && period != 0) {
	return (false);
    }
    return (true);
}

int
ann_load (string path)
{
    int ann = -1;
    uchar p[];
    StringToCharArray(path,p,0,-1,CP_ACP);

    /* Load the ANN */
    ann = f2M_create_from_file (p);
    if (ann != -1) {
	debug (1,
	       "ANN: '" + path + "' loaded successfully with handler " + ann);
    }
    if (ann == -1) {

	/* Create ANN */
	ann =
	    f2M_create_standard (4, AnnInputs, AnnInputs, AnnInputs / 2 + 1,
				 1);
	f2M_set_act_function_hidden (ann, FANN_SIGMOID_SYMMETRIC_STEPWISE);
	f2M_set_act_function_output (ann, FANN_SIGMOID_SYMMETRIC_STEPWISE);
	f2M_randomize_weights (ann, -0.4, 0.4);
	debug (1,
	       "ANN: '" + path + "' created successfully with handler " +
	       ann);
    }
    if (ann == -1) {
	debug (0, "ERROR INITIALIZING NETWORK!");
    }
    return (ann);
}

void
ann_save (int ann, string path)
{

    uchar p[];
    int ret = -1;    
    StringToCharArray(path,p,0,-1,CP_ACP);
    ret = f2M_save (ann, p);
    debug (1, "f2M_save(" + ann + ", " + path + ") returned: " + ret);
}

void
ann_destroy (int ann)
{
    int ret = -1;
    ret = f2M_destroy (ann);
    debug (1, "f2M_destroy(" + ann + ") returned: " + ret);
}

double
ann_run (int ann, double &vector[])
{
    int ret;
    double out;
    ret = f2M_run (ann, vector);
    if (ret < 0) {
	debug (0, "Network RUN ERROR! ann=" + ann);
	return (FANN_DOUBLE_ERROR);
    }
    out = f2M_get_output (ann, 0);
    debug (3, "f2M_get_output(" + ann + ") returned: " + out);
    return (out);
}

int
anns_run_parallel (int anns_count, int &anns[], double &input_vector[])
{
    int ret;

    ret = f2M_run_parallel (anns_count, anns, input_vector);

    if (ret < 0) {
	debug (0, "f2M_run_parallel(" + anns_count + ") returned: " + ret);
    }
    return (ret);
}

void
ann_prepare_input ()
{
    int i;
    int j;
    j = 0;
    for (i = 0; i <= AnnInputs - 1; i = i + 4) {
   	InputVector[i] =iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,j);
   	InputVector[i + 1] =iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,j);
   	InputVector[i + 2] = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,j);
      InputVector[i + 3] = (iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,j) - iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,j))/2;
      j = j+1;		
    }
}

void
run_anns ()
{
    int i;

    if (Parallel) {
	anns_run_parallel (AnnsNumber, AnnsArray, InputVector);
    }

    for (i = 0; i < AnnsNumber; i++) {
	if (Parallel) {
	    AnnOutputs[i] = f2M_get_output (AnnsArray[i], 0);
	} else {
	    AnnOutputs[i] = ann_run (AnnsArray[i], InputVector);
	}
    }
}

void
ann_train (int ann, double &input_vector[], double &output_vector[])
{
    if (f2M_train (ann, input_vector, output_vector) == -1) {
	debug (0, "Network TRAIN ERROR! ann=" + ann);
    }
    debug (3, "ann_train(" + ann + ") succeded");
}

double
ann_wise_long ()
{
    int i;
    double ret;

    if (AnnsNumber < 1)
	return (-1);

    for (i = 0; i < AnnsNumber; i += 2) {
	ret += AnnOutputs[i];
    }

    ret = 2 * ret / AnnsNumber;

    debug (3, "Wise long: " + ret);
    return (ret);
}

double
ann_wise_short ()
{
    int i;
    double ret;

    if (AnnsNumber < 1)
	return (-1);

    for (i = 1; i < AnnsNumber; i += 2) {
	ret += AnnOutputs[i];
    }

    ret = 2 * ret / AnnsNumber;

    debug (3, "Wise short: " + ret);
    return (ret);
}
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int
init ()
{
    int i, ann;

    if (!is_ok_period (PERIOD_M5)) {
	debug (0, "Wrong period!");
	return (-1);
    }

    AnnInputs = (AnnInputs / 4) * 4;	// Make it integer divisible by 4

    if (AnnInputs < 4) {
	debug (0, "AnnInputs too low!");
    }
    // Compute MagicNumber and AnnPath
    MagicNumber += (256 * Move_Av + 65536 * iBoll_B);
    AnnPath = StringConcatenate (ANN_PATH, NAME, "-", MagicNumber);


    // Initialize anns
    ArrayResize (AnnsArray, AnnsNumber);
    for (i = 0; i < AnnsNumber; i++) {
	if (i % 2 == 0) {
	    ann = ann_load (AnnPath + "." + i + "-long.net");
	} else {
	    ann = ann_load (AnnPath + "." + i + "-short.net");
	}
	if (ann < 0)
	    AnnsLoaded = false;
	AnnsArray[i] = ann;
    }
    ArrayResize (AnnOutputs, AnnsNumber);
    ArrayResize (InputVector, AnnInputs);
    ArrayResize (LongInput, AnnInputs);
    ArrayResize (ShortInput, AnnInputs);

    // Initialize Intel TBB threads
    f2M_parallel_init ();

    return (0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int
deinit ()
{
    int i;
    if (!is_ok_period (PERIOD_M5)) {
	debug (0, "Wrong period!");
	return (-1);
    }
    // Deinitialize anns
    for (i = AnnsNumber - 1; i >= 0; i--) {
	if (SaveAnn) {
	    if (i % 2 == 0) {
		 ann_save (AnnsArray[i], AnnPath + "." + i + "-long.net");
	    } else {
	    
		ann_save (AnnsArray[i], AnnPath + "." + i + "-short.net");
	    }
	}
	ann_destroy (AnnsArray[i]);
    }

    // Deinitialize Intel TBB threads
    f2M_parallel_deinit ();

    return (0);
}

bool
trade_allowed ()
{
    if (!AnnsLoaded || !is_ok_period (PERIOD_M5))
	return (false);

    /* Trade only on first tick of a bar and there's enough funds */
    if (Volume[0] <= 1 && AccountBalance () > MinimalBalance) {
	return (true);
    }

    return (false);
}



void closeall()
{
   int i;
   if (OrdersTotal( ) > 0 )
   {
         for(i=OrdersTotal()-1;i>=0;i--)
         {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)     break;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)     break;
         if(OrderType()==OP_SELL)
         if(OrderType()==OP_BUY)
         {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
            OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         } 
      }
   
   }

}




//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int
start ()
{
    int i;
    bool BuySignal = false;
    bool SellSignal = false;

   double ma;
   double boll_up_B,boll_low_B,boll_mid_B;

   double boll_up_B_pre,boll_low_B_pre;
   double ma_pre;
   
    double train_output[1];

    /* Is trade allowed? */
    if (!trade_allowed ()) {
	return (-1);
    }
    

    /* Prepare and run neural networks */
    ann_prepare_input ();
    run_anns ();



     ma=iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,0); 
     boll_up_B = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,0);   
     boll_low_B = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,0);
     boll_mid_B = (boll_up_B - boll_low_B )/2;

     ma_pre=iMA(NULL,0,Move_Av,0,MODE_SMA,PRICE_CLOSE,1); 
     boll_up_B_pre = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_UPPER,1);   
     boll_low_B_pre = iBands(NULL,0,iBoll_B,2,0,PRICE_CLOSE,MODE_LOWER,1);


    /* BUY signal */
    if (ma > boll_low_B && ma_pre < boll_low_B_pre) {
	BuySignal = true;
    }
    /* SELL signal */
    if (ma < boll_up_B && ma_pre > boll_up_B_pre) {
	SellSignal = true;
    }

    /* No Long position */
    if (LongTicket == -1) {
	/* BUY signal */
	if (BuySignal) {
	    /* If NeuroFilter is set use ann wise to decide :) */
	    if (!NeuroFilter || ann_wise_long () > Delta) {
		LongTicket =
		    OrderSend (Symbol (), OP_BUY, Lots, Ask, 3,
			       Bid - boll_mid_B,
			       Ask + boll_mid_B,
			       NAME + "-" + "L ", MagicNumber, 0, Blue);
	    }
	     BuyedPosition = iBars(NULL,0);
	    /* Remember network input */
	    for (i = 0; i < AnnInputs; i++) {
		LongInput[i] = InputVector[i];
	    }
	}
    } else {
	/* Maintain long position */
	OrderSelect (LongTicket, SELECT_BY_TICKET);
	if (OrderCloseTime () == 0) {
	    // Order is opened
	    if (SellSignal && OrderProfit () > 0) {
		//OrderClose (LongTicket, Lots, Bid, 3);
	    }
	}
	if (OrderCloseTime () != 0) {
	    // Order is closed
	    LongTicket = -1;
	    BuyedPosition = -1;
	    if (OrderProfit () >= 0) {
		train_output[0] = 1;
	    } else {
		train_output[0] = -1;
	    }
	    for (i = 0; i < AnnsNumber; i += 2) {
		ann_train (AnnsArray[i], LongInput, train_output);
	    }
	}
    }

    /* No short position */
    if (ShortTicket == -1) {
	if (SellSignal) {
	    /* If NeuroFilter is set use ann wise to decide ;) */
	    if (!NeuroFilter || ann_wise_short () > Delta) {
		ShortTicket =
		    OrderSend (Symbol (), OP_SELL, Lots, Bid, 3,
			       Ask + boll_mid_B,
			       Bid - boll_mid_B, NAME + "-" + "S ",
			       MagicNumber, 0, Red);
	    }
	    	     SelledPosition = iBars(NULL,0);

	    /* Remember network input */
	    for (i = 0; i < AnnInputs; i++) {
		ShortInput[i] = InputVector[i];
	    }
	}
    } else {
	/* Maintain short position */
	OrderSelect (ShortTicket, SELECT_BY_TICKET);
	if (OrderCloseTime () == 0) {
	    // Order is opened
	    if (BuySignal && OrderProfit () > 0) {
		//OrderClose (LongTicket, Lots, Bid, 3);
	    }
	}
	if (OrderCloseTime () != 0) {
	    // Order is closed
	    ShortTicket = -1;
	    SelledPosition = -1;
	    if (OrderProfit () >= 0) {
		train_output[0] = 1;
	    } else {
		train_output[0] = -1;
	    }
	    for (i = 1; i < AnnsNumber; i += 2) {
		ann_train (AnnsArray[i], ShortInput, train_output);
	    }
	}
    }

    if ( BuyedPosition >0 )
    {
      if( (iBars(NULL,0)- BuyedPosition)>12)
      {
      
         closeall();     
         OrderSelect (LongTicket, SELECT_BY_TICKET);
	      if (OrderCloseTime () != 0) {
	    // Order is closed
	         if (OrderProfit () >= 0) {
		         train_output[0] = 1;
	         } else {
		         train_output[0] = -1;
	          }
	         for (i = 0; i < AnnsNumber; i += 2) {
		         ann_train (AnnsArray[i], LongInput, train_output);
	         }       
         
      	LongTicket = -1;
         BuyedPosition = -1;
      
      }
    }
    }
    
        if ( SelledPosition >0 )
    {
      if( (iBars(NULL,0)- SelledPosition)>12)
      {
      
         closeall();     
         OrderSelect (ShortTicket, SELECT_BY_TICKET);
	      if (OrderCloseTime () != 0) {
	    // Order is closed
	         if (OrderProfit () >= 0) {
		         train_output[0] = 1;
	         } else {
		         train_output[0] = -1;
	          }
	         for (i = 0; i < AnnsNumber; i += 2) {
		      ann_train (AnnsArray[i], ShortInput, train_output);
	         }       
         
	      ShortTicket = -1;
         SelledPosition = -1;
      
      }
    }
    }
    

    return (0);
}
