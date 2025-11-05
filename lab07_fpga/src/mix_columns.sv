/////////////////////////////////////////////
// mix_columns
//   Even funkier action on columns
//   Section 5.1.3, Figure 9
//   Same operation performed on each of four columns
/////////////////////////////////////////////

module mix_columns(
    //input  logic         enable,
    input  logic [127:0] a,
    output logic [127:0] y
  );

  //logic [127:0] y_interm;

  mix_column mc0(a[127:96], y[127:96]);
  mix_column mc1(a[95:64],  y[95:64]);
  mix_column mc2(a[63:32],  y[63:32]);
  mix_column mc3(a[31:0],   y[31:0]);

  //assign y = enable ? (y_interm) : (a);
endmodule
