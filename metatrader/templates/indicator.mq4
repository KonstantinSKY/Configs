//+------------------------------------------------------------------+
//|                    Custom Indicator Template                     |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

double Buffer1[];   // Example buffer

int OnInit()
  {
   // Bind buffer
   SetIndexBuffer(0, Buffer1);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   // Cleanup code
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   // Calculation loop
   for(int i=0; i<rates_total; i++)
     {
      Buffer1[i] = close[i]; // Example: copy Close price
     }
   return(rates_total);
  }
