module ClockDivider 
(
    input wire RST,
    input wire InputCLK,
    output reg OutputClk
);

always @ (posedge InputCLK or negedge RST)
  begin
    if (!RST)
      begin
        OutputClk = 1'b0;
      end
    else
      begin
        OutputClk <= ~OutputClk;
      end
  end


endmodule