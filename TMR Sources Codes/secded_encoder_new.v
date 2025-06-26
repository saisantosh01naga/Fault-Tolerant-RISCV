`timescale 1ns / 1ps

module mdmhc_encoder(clk, in, out);
input clk;
input [31:0] in;
output reg [67:0] out;
reg [19:0] h;
reg [15:0] v;

always @ (posedge clk)
begin 
    v[0] = in[0] ^ in[16];
    v[1] = in[1] ^ in[17];
    v[2] = in[2] ^ in[18];
    v[3] = in[3] ^ in[19];
    v[4] = in[4] ^ in[20];
    v[5] = in[5] ^ in[21];
    v[6] = in[6] ^ in[22];
    v[7] = in[7] ^ in[23];
    v[8] = in[8] ^ in[24];
    v[9] = in[9] ^ in[25];
    v[10]= in[10] ^in[26];
    v[11]= in[11] ^in[27];
    v[12]= in[12] ^in[28];
    v[13]= in[13] ^in[29];
    v[14]= in[14] ^in[30];
    v[15]= in[15] ^in[31];
    
    h[4:0]=in[3:0]+in[11:8];
    h[9:5]=in[7:4]+in[15:12];
    h[19:15]=in[31:28]+in[23:20];
    h[14:10]=in[27:24]+in[19:16];
    out={v,h,in};

end 
endmodule





//module secded_encoder(
//    input  wire [31:0] data_in,
//    output wire [38:0] encoded_data
//);
//    wire [5:0] p;
//    // Hamming parity bits
//    assign p[0] = ^{data_in[0], data_in[1], data_in[3], data_in[4],
//                    data_in[6], data_in[8], data_in[10], data_in[11],
//                    data_in[13],data_in[15],data_in[17],data_in[19],
//                    data_in[21],data_in[23],data_in[25],data_in[26],
//                    data_in[28],data_in[30]};
//    assign p[1] = ^{data_in[0], data_in[2], data_in[3], data_in[5],
//                    data_in[6], data_in[9], data_in[10],data_in[12],
//                    data_in[13],data_in[16],data_in[17],data_in[20],
//                    data_in[21],data_in[24],data_in[25],data_in[27],
//                    data_in[28],data_in[31]};
//    assign p[2] = ^{data_in[1], data_in[2], data_in[3], data_in[7],
//                    data_in[8], data_in[9], data_in[10],data_in[14],
//                    data_in[15],data_in[16],data_in[17],data_in[22],
//                    data_in[23],data_in[24],data_in[25],data_in[29],
//                    data_in[30],data_in[31]};
//    assign p[3] = ^{data_in[4], data_in[5], data_in[6], data_in[7],
//                    data_in[8], data_in[9], data_in[10],
//                    data_in[18],data_in[19],data_in[20],data_in[21],
//                    data_in[22],data_in[23],data_in[24],data_in[25]};
//    assign p[4] = ^{data_in[11],data_in[12],data_in[13],data_in[14],
//                    data_in[15],data_in[16],data_in[17],
//                    data_in[18],data_in[19],data_in[20],data_in[21],
//                    data_in[22],data_in[23],data_in[24],data_in[25]};
//    assign p[5] = ^{data_in[26],data_in[27],data_in[28],
//                    data_in[29],data_in[30],data_in[31]};

//    // Inverted overall parity for SECDED
//    wire overall = ^{p, data_in};
//    assign encoded_data = {~overall, p, data_in};
//endmodule

/*module secded_encoder (
    input wire [31:0] data_in,
    output wire [38:0] encoded_data
);
    wire [5:0] parity_bits;
    wire syndrome_bit;
    
    // Parity bit calculations
    assign parity_bits[0] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^
                            data_in[6] ^ data_in[8] ^ data_in[10] ^ data_in[11] ^
                            data_in[13] ^ data_in[15] ^ data_in[17] ^ data_in[19] ^
                            data_in[21] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^
                            data_in[28] ^ data_in[30];
    
    assign parity_bits[1] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^
                            data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^
                            data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[20] ^
                            data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^
                            data_in[28] ^ data_in[31];
    
    assign parity_bits[2] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7] ^
                            data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[14] ^
                            data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[22] ^
                            data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[29] ^
                            data_in[30] ^ data_in[31];
    
    assign parity_bits[3] = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^
                            data_in[8] ^ data_in[9] ^ data_in[10] ^
                            data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^
                            data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25];
    
    assign parity_bits[4] = data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^
                            data_in[15] ^ data_in[16] ^ data_in[17] ^
                            data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^
                            data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25];
    
    assign parity_bits[5] = data_in[26] ^ data_in[27] ^ data_in[28] ^
                            data_in[29] ^ data_in[30] ^ data_in[31];
    
    // Overall parity for double-error detection
    assign syndrome_bit = ^{parity_bits, data_in};
    
    assign encoded_data = {syndrome_bit, parity_bits, data_in};
endmodule
*/
