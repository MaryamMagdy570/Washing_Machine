module MUX4X2 
(
    input wire [1:0]    clk_freq,
    input wire          CLK8,
    input wire          CLK4,
    input wire          CLK2,
    input wire          CLK1,
    output reg          CLK
);



always @ (*)
  begin
    case(clk_freq)
    2'b00:
      begin
        CLK=CLK1;
      end
    2'b01:
      begin
        CLK=CLK2;
      end
     2'b10:
      begin
        CLK=CLK4;
      end
     2'b11:
      begin
        CLK=CLK8;
      end
    endcase
  end


endmodule