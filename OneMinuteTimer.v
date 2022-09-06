module OneMinuteTimer
(
  input wire          CLK,
  input wire          RST,
  //input wire  [28:0]        TimerStartPoint,
  input wire [4:0]    TimerStartPoint,
  input wire [1:0]    TimerMode,
  output wire         TimerFlag
);


//---------------------------- interal signals ----------------------------//

//reg [28:0] Counter; //FIXME:
reg [4:0] Counter;
//reg [28:0] Counter_comb;  //FIXME:
reg [4:0] Counter_comb;


//---------------------------- local parameters ---------------------------//

//Counter Modes
localparam  RUN = 2'b00,
            PAUSE = 2'b01,
            STOP = 2'b10;


//---------------------- sequential always blocks -------------------------//

always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Counter <= 28'd0;
      end
    else 
      begin
        Counter <= Counter_comb;
      end
  end


//-------------------------- combinational blocks -------------------------//

//asserting flag when the  minute is completed
assign TimerFlag = (Counter == 28'd1);


//counter behavoir according to timer mode
always @ (*)
  begin
    case(TimerMode)
      RUN:
        begin
          if(Counter)
            begin
              Counter_comb = Counter_comb - 1;
            end
          else
            begin
              Counter_comb = TimerStartPoint;
            end
        end
      PAUSE:
        begin
          Counter_comb = Counter;
        end
      STOP:
        begin
          Counter_comb = 0;
        end
      default:
        begin
          Counter_comb = 0;
        end
    endcase
  end 
   



endmodule