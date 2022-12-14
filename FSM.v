module FSM 
(
    input wire          CLK,
    input wire          RST,
    input wire          Coin,
    input wire          DoubleWash,
    input wire  [3:0]   DoneFlags,
    output reg  [2:0]   current_state,
    output reg          Wash_Done
   
);

//---------------------------- interal signals ----------------------------//

//internals
reg [2:0]   current_state_comb; 
reg [1:0]   Double_Wash_Count;      


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



//---------------------- sequential always blocks -------------------------//

always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
        begin
            current_state <= IDLE;
        end
    else
        begin
            current_state <= current_state_comb;
        end
  end

//asserting flag that indicates that the washing job is done
always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Wash_Done <= 1'b0;
      end  
    else if (DoneFlags[0])
      begin
        Wash_Done <= 1'b1;
      end 
    else if (Coin && !DoneFlags[0])
      begin
        Wash_Done <= 1'b0;
      end
  end

//a counter to handle switching between states in double wash option
always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Double_Wash_Count <= 2'b00;
      end
    else if ((DoneFlags == Done_Rinsing || DoneFlags == Done_Washing) && DoubleWash)

      begin
        Double_Wash_Count <= Double_Wash_Count + 1;
        //AFTER 4 COUNTS IT WILL BE ZERO AGAIN >> و هو المطلوب
      end
  end




//-------------------------- combinational blocks -------------------------//

//switching between states
always @ (*)
  begin
    case(current_state)
        IDLE:
          begin
            if(Coin)
                current_state_comb = FillingWater;
            else
                current_state_comb = IDLE;
          end
        FillingWater:
          begin
            if(DoneFlags == Done_FillingWater)
                current_state_comb = Washing;
            else
                current_state_comb = FillingWater;
          end
        Washing:
          begin
            if(DoneFlags == Done_Washing)
                current_state_comb = Rinsing;
            else
                current_state_comb = Washing;
          end
        Rinsing:
          begin
            if ((DoneFlags == Done_Rinsing) && (Double_Wash_Count == 2'd1))    
                current_state_comb = Washing;
            else if (DoneFlags == Done_Rinsing)
                current_state_comb = Spinning;
            else
                current_state_comb = Rinsing;
          end
        Spinning:
          begin
            if(DoneFlags == Done_Spinning)
                current_state_comb = IDLE;
            else
                current_state_comb = Spinning;
          end
        default:
          begin
                current_state_comb = IDLE;
          end
   endcase
  end
    

endmodule