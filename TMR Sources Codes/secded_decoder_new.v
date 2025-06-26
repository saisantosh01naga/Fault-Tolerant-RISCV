`timescale 1ns / 1ps


module mdmhc_decoder(clk,in,outer);
input clk;
//input [67:0] in;
input [67:0] in;
output [31:0] outer;

reg [31:0] out;
wire [6:0] enc_19_16,enc_3_0,enc_7_4,enc_11_8,enc_15_12,enc_23_20,enc_27_24,enc_31_28, ri_enc_19_16,ri_enc_3_0,ri_enc_7_4,ri_enc_11_8,ri_enc_15_12,ri_enc_23_20,ri_enc_27_24,ri_enc_31_28;
reg [67:0] dat;
reg [19:0] h_;
reg [15:0] v_;
reg [31:0] s;
reg [15:0] v;
reg [19:0] h,sh;
integer i;
wire [4:0] err1,err2,err3,err4,err5,err6;

lfsr11 dt1(clk,err1);
lfsr12 dt2(clk,err2);
lfsr13 dt3(clk,err3);
lfsr14 dt4(clk,err4);
lfsr15 dt5(clk,err5);
lfsr16 dt6(clk,err6);


//lfsr dt7(clk,err);

ham_enco u1(clk, out[3:0], enc_3_0);
ham_enco u2(clk, out[7:4], enc_7_4);
ham_enco u3(clk, out[11:8], enc_11_8);
ham_enco u4(clk, out[15:12], enc_15_12);
ham_enco u5(clk, out[19:16], enc_19_16);
ham_enco u6(clk, out[23:20], enc_23_20);
ham_enco u7(clk, out[27:24], enc_27_24);
ham_enco u8(clk, out[31:28], enc_31_28);

ham_enco v1(clk, in[3:0], ri_enc_3_0);
ham_enco v2(clk, in[7:4], ri_enc_7_4);
ham_enco v3(clk, in[11:8], ri_enc_11_8);
ham_enco v4(clk, in[15:12], ri_enc_15_12);
ham_enco v5(clk, in[19:16], ri_enc_19_16);
ham_enco v6(clk, in[23:20], ri_enc_23_20);
ham_enco v7(clk, in[27:24], ri_enc_27_24);
ham_enco v8(clk, in[31:28], ri_enc_31_28);

ham_deco k1(clk, ri_enc_3_0, enc_3_0,outer[3:0]);
ham_deco k2(clk, ri_enc_7_4, enc_7_4,outer[7:4]);
ham_deco k3(clk, ri_enc_11_8, enc_11_8,outer[11:8]);
ham_deco k4(clk, ri_enc_15_12, enc_15_12,outer[15:12]);
ham_deco k5(clk, ri_enc_19_16, enc_19_16,outer[19:16]);
ham_deco k6(clk, ri_enc_23_20, enc_23_20,outer[23:20]);
ham_deco k7(clk, ri_enc_27_24, enc_27_24,outer[27:24]);
ham_deco k8(clk, ri_enc_31_28, enc_31_28,outer[31:28]);


always @ (posedge clk)
begin 
    dat=in;
    
    v=in[67:52];
    h=in[51:32];
        dat[err1-1]=~dat[err1-1];
    dat[err2-1]=~dat[err2-1];
    dat[err3-1]=~dat[err3-1];
    dat[err4-1]=~dat[err4-1];
    dat[err5-1]=~dat[err5-1];
        dat[err6-1]=~dat[err6-1];


    /*
    if( (err1!=err2) && (err1!=0) && (err2!=0))
    begin 
    dat[err1-1]=~dat[err1-1];
    dat[err2-1]=~dat[err2-1];
    end 
    else if ( (err1==0) && (err2!=0))
    begin
    dat[0]=~dat[0];
    dat[err2-1]=~dat[err2-1];
    end
    else if ( (err2==0) && (err1!=0))
    begin 
    dat[0]=~dat[0];
    dat[err1-1]=~dat[err1-1];
    end 
    */
    /*
    if (err!=0) begin 
    dat[err-1]=~dat[err-1];
    end 
    else dat[0]=~dat[0];
    */
    
        v_[0] = dat[0] ^ dat[16];
        v_[1] = dat[1] ^ dat[17];
        v_[2] = dat[2] ^ dat[18];
        v_[3] = dat[3] ^ dat[19];
        v_[4] = dat[4] ^ dat[20];
        v_[5] = dat[5] ^ dat[21];
        v_[6] = dat[6] ^ dat[22];
        v_[7] = dat[7] ^ dat[23];
        v_[8] = dat[8] ^ dat[24];
        v_[9] = dat[9] ^ dat[25];
        v_[10] = dat[10] ^ dat[26];
        v_[11] = dat[11] ^ dat[27];
        v_[12] = dat[12] ^ dat[28];
        v_[13] = dat[13] ^ dat[29];
        v_[14] = dat[14] ^ dat[30];
        v_[15] = dat[15] ^ dat[31];
        
        h_[4:0]=dat[3:0]+dat[11:8];
        h_[9:5]=dat[7:4]+dat[15:12];
        h_[19:15]=dat[31:28]+dat[23:20];
        h_[14:10]=dat[27:24]+dat[19:16];
    //v_=dat[67:52];
    //h_=dat[51:32];
    s[0] = v_[0] ^ v[0];
    s[1] = v_[1] ^ v[1];
    s[2] = v_[2] ^ v[2];
    s[3] = v_[3] ^ v[3];
    s[4] = v_[4] ^ v[4];
    s[5] = v_[5] ^ v[5];
    s[6] = v_[6] ^ v[6];
    s[7] = v_[7] ^ v[7];
    s[8] = v_[8] ^ v[8];
    s[9] = v_[9] ^ v[9];
    s[10] = v_[10] ^ v[10];
    s[11] = v_[11] ^ v[11];
    s[12] = v_[12] ^ v[12];
    s[13] = v_[13] ^ v[13];
    s[14] = v_[14] ^ v[14];
    s[15] = v_[15] ^ v[15];
    
    
    sh[0] = h_[0] ^ h[0];
    sh[1] = h_[1] ^ h[1];
    sh[2] = h_[2] ^ h[2];
    sh[3] = h_[3] ^ h[3];
    sh[4] = h_[4] ^ h[4];
    sh[5] = h_[5] ^ h[5];
    sh[6] = h_[6] ^ h[6];
    sh[7] = h_[7] ^ h[7];
    sh[8] = h_[8] ^ h[8];
    sh[9] = h_[9] ^ h[9];
    sh[10] = h_[10] ^ h[10];
    sh[11] = h_[11] ^ h[11];
    sh[12] = h_[12] ^ h[12];
    sh[13] = h_[13] ^ h[13];
    sh[14] = h_[14] ^ h[14];
    sh[15] = h_[15] ^ h[15];
    sh[16] = h_[16] ^ h[16];
    sh[17] = h_[17] ^ h[17];
    sh[18] = h_[18] ^ h[18];
    sh[19] = h_[19] ^ h[19];
    
       
    if ((sh[4:0]!=0) || (s[3:0]!=0) && (s[11:8]===0) ) begin 
    out[0]=dat[0]^s[0];
    out[1]=dat[1]^s[1];
    out[2]=dat[2]^s[2];
    out[3]=dat[3]^s[3]; end 
    else 
    begin 
    out[4:0] = dat[4:0]; 
    end
    if ((sh[4:0]!=0) || (s[11:8]!=0) && (s[3:0]==0)) begin 
        out[10] = dat[10] ^ s[10];
        out[11] = dat[11] ^ s[11];
        out[8] = dat[8] ^ s[8];
        out[9] = dat[9] ^ s[9];    
        end
    else 
    begin 
    out[11:8] = dat[11:8]; 
    end
    
    
    // New conditions
    if ((sh[9:5] != 0) || (s[7:4] != 0) && (s[15:12] == 0)) begin 
        out[4] = dat[4] ^ s[4];
        out[5] = dat[5] ^ s[5];
        out[6] = dat[6] ^ s[6];
        out[7] = dat[7] ^ s[7]; 
    end else begin 
        out[7:4] = dat[7:4]; 
    end
    
    if ((sh[9:5] != 0) || (s[15:12] != 0) && (s[7:4] == 0)  ) begin 
        out[12] = dat[12] ^ s[12];
        out[13] = dat[13] ^ s[13];
        out[14] = dat[14] ^ s[14];
        out[15] = dat[15] ^ s[15]; 
    end else begin 
        out[15:12] = dat[15:12]; 
    end
    
    if ((sh[19:15] != 0) || (s[31:28] != 0) && (s[23:20] == 0)) begin 
        out[28] = dat[28] ^ s[12];
        out[29] = dat[29] ^ s[13];
        out[30] = dat[30] ^ s[14];
        out[31] = dat[31] ^ s[15]; 
    end else begin 
        out[31:28] = dat[31:28]; 
    end
    
    if ((sh[19:15] != 0) || (s[23:20] != 0) && (s[31:28] == 0) ) begin 
        out[20] = dat[20] ^ s[4];
        out[21] = dat[21] ^ s[5];
        out[22] = dat[22] ^ s[6];
        out[23] = dat[23] ^ s[7]; 
    end else begin 
        out[23:20] = dat[23:20]; 
    end
    
    if ((sh[14:10] != 0) || (s[27:24] != 0) && (s[19:16] == 0) ) begin 
        out[24] = dat[24] ^ s[8];
        out[25] = dat[25] ^ s[9];
        out[26] = dat[26] ^ s[10];
        out[27] = dat[27] ^ s[11]; 
    end else begin 
        out[27:24] = dat[27:24]; 
    end
    
    if ((sh[14:10] != 0) || (s[19:16] != 0) && (s[27:24] == 0)) begin 
        out[16] = dat[16] ^ s[0];
        out[17] = dat[17] ^ s[1];
        out[18] = dat[18] ^ s[2];
        out[19] = dat[19] ^ s[3]; 
    end else begin 
        out[19:16] = dat[19:16]; 
    end 

end

endmodule









//module secded_decoder (
//    input  wire [38:0] encoded_data,        // {syndrome_bit, parity[5:0], data[31:0]}
//    output wire [31:0] corrected_data,
//    output wire        single_error_detected,
//    output wire        double_error_detected,
//    output wire        no_error
//);

//  // Split received fields
//  wire [31:0] d = encoded_data[31:0];
//  wire [5:0]  rp = encoded_data[37:32];
//  wire        rs = encoded_data[38];
  
//  // Recalculate 6 Hamming parity bits (identical to encoder)
//  wire [5:0] p_calc;
//  assign p_calc[0] = ^{ d[0], d[1], d[3], d[4], d[6], d[8], d[10], d[11],
//                        d[13], d[15], d[17], d[19], d[21], d[23], d[25],
//                        d[26], d[28], d[30] };
//  assign p_calc[1] = ^{ d[0], d[2], d[3], d[5], d[6], d[9], d[10], d[12],
//                        d[13], d[16], d[17], d[20], d[21], d[24], d[25],
//                        d[27], d[28], d[31] };
//  assign p_calc[2] = ^{ d[1], d[2], d[3], d[7], d[8], d[9], d[10], d[14],
//                        d[15], d[16], d[17], d[22], d[23], d[24], d[25],
//                        d[29], d[30], d[31] };
//  assign p_calc[3] = ^{ d[4], d[5], d[6], d[7], d[8], d[9], d[10],
//                        d[18], d[19], d[20], d[21], d[22], d[23],
//                        d[24], d[25] };
//  assign p_calc[4] = ^{ d[11], d[12], d[13], d[14], d[15], d[16],
//                        d[17], d[18], d[19], d[20], d[21], d[22],
//                        d[23], d[24], d[25] };
//  assign p_calc[5] = ^{ d[26], d[27], d[28], d[29], d[30], d[31] };

//  // Recalculate overall parity and construct 7-bit syndrome
//  wire s_calc = ^{ p_calc, d };
//  wire [6:0] syndrome = { s_calc ^ ~rs, p_calc ^ rp };

//  // Error flags
//  assign no_error              = (syndrome == 7'b0000000);
//  assign single_error_detected = (syndrome[6]==1'b0) && (syndrome[5:0]!=6'b000000);
//  assign double_error_detected = (syndrome[6]==1'b1) && (syndrome[5:0]!=6'b000000);

//  // Correct single-bit error (combinational)
// integer pos;

//reg [31:0] d_corr;

//always @(*) begin
//  d_corr = d;                              // Copy received data[1]
//  pos    = syndrome[5:0] - 6'd1;           // Compute 0-based bit position[1]
//  if (single_error_detected 
//      && (pos >= 0) 
//      && (pos < 32)) begin
//    d_corr[pos] = ~d_corr[pos];            // Flip the erroneous bit
//  end
//end

//  assign corrected_data = d_corr;
//endmodule


/*module secded_decoder (
    input wire [38:0] encoded_data,
    output wire [31:0] corrected_data,
    output wire single_error_detected,
    output wire double_error_detected,
    output wire no_error
);
    
    wire [31:0] received_data = encoded_data[31:0];
    wire [5:0] received_parity = encoded_data[37:32];
    wire received_syndrome_bit = encoded_data[38];
    
    wire [5:0] recalculated_parity;
    wire recalculated_syndrome_bit;
    wire [6:0] syndrome;
    
    // Recalculate parity bits from received data
    assign recalculated_parity[0] = received_data[0] ^ received_data[1] ^ received_data[3] ^ received_data[4] ^
                                    received_data[6] ^ received_data[8] ^ received_data[10] ^ received_data[11] ^
                                    received_data[13] ^ received_data[15] ^ received_data[17] ^ received_data[19] ^
                                    received_data[21] ^ received_data[23] ^ received_data[25] ^ received_data[26] ^
                                    received_data[28] ^ received_data[30];
    
    // Similar calculations for parity_bits[1] through [5]...
    
    // Recalculate overall syndrome bit
    assign recalculated_syndrome_bit = ^{recalculated_parity, received_data};
    
    // Calculate syndrome
    assign syndrome = {recalculated_syndrome_bit ^ received_syndrome_bit, 
                      recalculated_parity ^ received_parity};
    
    // Correct error detection logic
    assign no_error = (syndrome == 7'b0000000);
    assign single_error_detected = (syndrome != 7'b0000000) && (syndrome[6] == 1'b1);
    assign double_error_detected = (syndrome != 7'b0000000) && (syndrome[6] == 1'b0);
    
    // Error correction logic
    reg [31:0] data_corrected;
    integer error_position;
    
    always @(*) begin
        data_corrected = received_data;
        if (single_error_detected && syndrome[5:0] != 6'b000000) begin
            error_position = syndrome[5:0];
            if (error_position > 0 && error_position <= 32) begin
                data_corrected[error_position-1] = ~data_corrected[error_position-1];
            end
        end
    end
    
    assign corrected_data = data_corrected;
endmodule*/


