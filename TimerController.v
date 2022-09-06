module TimerController 
(
    input wire          CLK,
    input wire          RST,
    input wire [1:0]    clk_freq,
    input wire          TimerPause,
    input wire [2:0]    current_state,
    input wire          TimerFlag,
    output reg [3:0]    DoneFlags, 
    output reg [1:0]    TimerMode,
    //output reg [28:0]   TimerStartPoint   //FIXME:
    output reg [4:0]    TimerStartPoint  
);


//---------------------------- interal signals ----------------------------//

// to count number of minutes needed for each state
reg [2:0]  MinutesCounter;  




//---------------------------- local parameters ---------------------------//

//states 
localparam  IDLE            = 3'b000,
            FillingWater    = 3'b001,
            Washing         = 3'b010,
            Rinsing         = 3'b011,
            Spinning        = 3'b100;

//flags   
localparam  Done_FillingWater  = 4'b1000,
            Done_Washing       = 4'b0100,
            Done_Rinsing       = 4'b0010,
            Done_Spinning      = 4'b0001;

//Counter Modes
localparam  RUN   = 2'b00,
            PAUSE = 2'b01,
            STOP  = 2'b10;

//Clock Options
localparam  CLK1 = 2'b00,
            CLK2 = 2'b01,
            CLK4 = 2'b10,
            CLK8 = 2'b11;


//---------------------- sequential always blocks -------------------------//

//calculating number of minutes for each state
always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        MinutesCounter <= 3'b000;
      end
    else if (TimerFlag && !DoneFlags)
      begin
        MinutesCounter <= MinutesCounter + 1;
      end
    else if (DoneFlags || (current_state == IDLE))  
      begin
        MinutesCounter <= 3'b000;
      end
  end

//obtaining timer start point for each operating frequency
always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        TimerStartPoint <= 28'd0;
      end
    else 
      begin
        case(clk_freq)
          CLK8:
            begin
              //TimerStartPoint = 28'd480000000  FIXME:
              TimerStartPoint <= 28'd6 ;
            end
          CLK4:
            begin
              //TimerStartPoint = 28'd240000000   FIXME:
              TimerStartPoint <= 28'd8;
            end
          CLK2:
            begin
              //TimerStartPoint = 28'd120000000  FIXME:
              TimerStartPoint <= 28'd4;
            end
          CLK1:
            begin
              //TimerStartPoint = 28'd60000000 -  FIXME:
              TimerStartPoint <= 28'd2 ;
            end
        endcase
      end
  end


//--------------------- combinational always blocks -----------------------//

// to obtain timer mode
always @ (*)
  begin
    if(TimerPause && (current_state == Spinning))
      begin
        TimerMode = PAUSE;
      end
    else if (DoneFlags || (current_state == IDLE))
      begin
        TimerMode = STOP;
      end
    else
      begin
        TimerMode = RUN;
      end
    end 

//to assert a flag at the end of each state
always @ (*)
  begin
    case (current_state)
      FillingWater:
        begin
          if (MinutesCounter == 2)
            begin
              DoneFlags = Done_FillingWater;
            end
          else
            begin
              DoneFlags = 4'b0000;
            end
        end  
      Washing:
        begin
          if (MinutesCounter == 5)
            begin
              DoneFlags = Done_Washing;
            end
          else
            begin
              DoneFlags = 4'b0000;
            end
        end
      Rinsing:
        begin
          if (MinutesCounter == 2)
            begin
              DoneFlags = Done_Rinsing;
            end
          else
            begin
              DoneFlags = 4'b0000;
            end
        end
      Spinning:
        begin
          if (MinutesCounter == 1)
            begin
              DoneFlags = Done_Spinning;
            end
          else
            begin
              DoneFlags = 4'b0000;
            end
        end
      default:
        begin
          DoneFlags = 4'b0000;
        end
    endcase
  end



endmodule