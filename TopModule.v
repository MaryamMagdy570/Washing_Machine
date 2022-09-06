module TopModule 
(
    input wire          SystemClk8MHz,
    input wire          RST,
    input wire [1:0]    clk_freq,
    input wire          Coin_in,
    input wire          Double_Wash,
    input wire          Timer_Pause,
    output wire          Wash_Done
);



wire CLK4MHz;
wire CLK2MHz;
wire CLK1MHz;
wire SelectedCLK;
wire [2:0]  Current_State;

wire [3:0]  Flags;
wire        TimerFlag;
wire [1:0]  TimerMode;

//wire [28:0]  TimerStartPoint FIXME:
wire [4:0]  TimerStartPoint;




ClockDivider ClockDivider1
(
    .RST       (RST),
    .InputCLK  (SystemClk8MHz),
    .OutputClk (CLK4MHz)
);

ClockDivider ClockDivider2
(
    .RST       (RST),
    .InputCLK  (CLK4MHz),
    .OutputClk (CLK2MHz)
);

ClockDivider ClockDivider3
(
    .RST       (RST),
    .InputCLK  (CLK2MHz),
    .OutputClk (CLK1MHz)
);

MUX4X2 u_MUX4X2
(
    .clk_freq (clk_freq),
    .CLK8     (SystemClk8MHz),
    .CLK4     (CLK4MHz),
    .CLK2     (CLK2MHz),
    .CLK1     (CLK1MHz),
    .CLK      (SelectedCLK)
);

FSM  u_FSM
(
    .CLK           (SelectedCLK),
    .RST           (RST),
    .Coin          (Coin_in),
    .DoubleWash    (Double_Wash),
    .DoneFlags     (Flags),
    .current_state (Current_State),
    .Wash_Done     (Wash_Done)
);


TimerController     u_TimerController
(
    .CLK               (SelectedCLK),
    .RST               (RST),
    .clk_freq          (clk_freq),
    .TimerPause        (Timer_Pause),
    .current_state     (Current_State),
    .TimerFlag         (TimerFlag),
    .DoneFlags         (Flags),
    .TimerMode         (TimerMode),
    .TimerStartPoint   (TimerStartPoint)
);

OneMinuteTimer  u_OneMinuteTimer
(
    .CLK               (SelectedCLK),
    .RST               (RST),
    .TimerStartPoint   (TimerStartPoint),
    .TimerMode         (TimerMode),
    .TimerFlag         (TimerFlag)
);



endmodule