/////////////////////////////////////////////
// mix_columns
//   Even funkier action on columns
//   Section 5.1.3, Figure 9
//   Same operation performed on each of four columns
/////////////////////////////////////////////

module mix_columns(
    input  logic         enable,
    input  logic [127:0] a,
    output logic [127:0] y
  );

  logic [127:0] y_interm;

  mixcolumn mc0(a[127:96], y_interm[127:96]);
  mixcolumn mc1(a[95:64],  y_interm[95:64]);
  mixcolumn mc2(a[63:32],  y_interm[63:32]);
  mixcolumn mc3(a[31:0],   y_interm[31:0]);

  assign y = enable ? (y_interm) : (a);
endmodule
