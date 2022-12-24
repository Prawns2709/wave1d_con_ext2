// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

wave1d_con_ext2 dut(a0,a1,a2,a3,a4,a5,a6,g0,g1,g2,g3,h0,h1,h2,h3,a0s,a1s,a2s,a3s,a4s,a5s,a6s,g0s,g1s,g2s,g3s,h0s,h1s,h2s,h3s,
g10s,g10,g11s,g11,h10s,h10,h11s,h11,clk,reset,dsel);


endmodule

//conventional convolution based folded DWT using 32-bit Wallace tree multiplier

/*`include "dflipflop16.v"
`include "dflipflop.v"
`include "multiplexer5.v"
`include "multiplier32.v"
`include "mux5to1.v"
`include "multiplexer51.v"
`include "recurse45.v"
`include "multiplexer21.v"
`include "recurse46.v"
`include "fulladd1.v"
`include "halfadd1.v"
`include "dflipflop45.v"
`include "tflipflop.v"
`include "mod6.v"
`include "dflipflop8.v"
`include "halfadd.v"
`include "fulladd.v"
`include "recurse27.v"
`include "kgp.v"
`include "kgp_carry.v"
`include "recursive_stage1.v"
`include "wallace24x8.v"
`include "mux5_8.v"
`include "mux5_24.v"
`include "mux5_45.v"
`include "recurse55.v"
`include "mux2_35.v"
`include "dflipflop35.v"
`include "recurse35.v"
`include "recurse36.v"
`include "mux5_35.v"*/

module wave1d_con_ext2(a0,a1,a2,a3,a4,a5,a6,g0,g1,g2,g3,h0,h1,h2,h3,a0s,a1s,a2s,a3s,a4s,a5s,a6s,g0s,g1s,g2s,g3s,h0s,h1s,h2s,h3s,
g10s,g10,g11s,g11,h10s,h10,h11s,h11,clk,reset,dsel);

input [7:0] a0,a1,a2,a3,a4,a5,a6,g0,g1,g2,g3,h0,h1,h2,h3;
input [2:0] dsel;
input a0s,a1s,a2s,a3s,a4s,a5s,a6s,g0s,g1s,g2s,g3s,h0s,h1s,h2s,h3s;
input clk,reset;

wire [2:0] dsel;

output g10s,g11s,h10s,h11s;
output [34:0] g10,g11,h10,h11;

wire [7:0] da0,da1,da2,da3,da4,da5,da6,dg0,dg1,dg2,dg3,dh0,dh1,dh2,dh3;
wire da0s,da1s,da2s,da3s,da4s,da5s,da6s,dg0s,dg1s,dg2s,dg3s,dh0s,dh1s,dh2s,dh3s;

dflipflop8 s01(da0,a0,clk,reset);
dflipflop8 s02(da1,a1,clk,reset);
dflipflop8 s03(da2,a2,clk,reset);
dflipflop8 s04(da3,a3,clk,reset);
dflipflop8 s05(da4,a4,clk,reset);
dflipflop8 s06(da5,a5,clk,reset);
dflipflop8 s07(da6,a6,clk,reset);
dflipflop8 s08(dg0,g0,clk,reset);
dflipflop8 s09(dg1,g1,clk,reset);
dflipflop8 s10(dg2,g2,clk,reset);
dflipflop8 s11(dg3,g3,clk,reset);
dflipflop8 s12(dh0,h0,clk,reset);
dflipflop8 s13(dh1,h1,clk,reset);
dflipflop8 s14(dh2,h2,clk,reset);
dflipflop8 s15(dh3,h3,clk,reset);
dflipflop ss01(da0s,a0s,clk,reset);
dflipflop ss02(da1s,a1s,clk,reset);
dflipflop ss03(da2s,a2s,clk,reset);
dflipflop ss04(da3s,a3s,clk,reset);
dflipflop ss05(da4s,a4s,clk,reset);
dflipflop ss06(da5s,a5s,clk,reset);
dflipflop ss07(da6s,a6s,clk,reset);
dflipflop ss08(dg0s,g0s,clk,reset);
dflipflop ss09(dg1s,g1s,clk,reset);
dflipflop ss10(dg2s,g2s,clk,reset);
dflipflop ss11(dg3s,g3s,clk,reset);
dflipflop ss12(dh0s,h0s,clk,reset);
dflipflop ss13(dh1s,h1s,clk,reset);
dflipflop ss14(dh2s,h2s,clk,reset);
dflipflop ss15(dh3s,h3s,clk,reset);

wire [2:0] sel;

dflipflop drens00(sel[0],dsel[0],clk,reset);
dflipflop drens01(sel[1],dsel[1],clk,reset);
dflipflop drens02(sel[2],dsel[2],clk,reset);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////G/////////

wire [34:0] g10,g11,g20,g21,g30,g31;
wire g10s,g11s,g20s,g21s,g30s,g31s;

wire [23:0] gm1,gm3,gm5,gm7;
wire [7:0] gm2,gm4,gm6,gm8;

mux5_24 mg00({16'b000,dg0},{16'b000,dg0},{16'b000,dg0},g10[23:0],g10[23:0],gm1,sel);
mux5_8 mg01(da6,da4,da0,dg0,dg0,gm2,sel);

mux5_24 mg02({16'b000,dg1},{16'b000,dg1},{16'b000,dg0},g21[23:0],24'b000,gm3,sel);
mux5_8 mg03(da5,da3,da2,dg0,8'b000,gm4,sel);

mux5_24 mg04({16'b000,dg2},{16'b000,dg2},{16'b000,dg1},g11[23:0],24'b000,gm5,sel);
mux5_8 mg05(da4,da2,da1,dg1,8'b000,gm6,sel);

mux5_24 mg06({16'b000,dg3},{16'b000,dg3},{16'b000,dg2},g10[23:0],24'b000,gm7,sel);
mux5_8 mg07(da3,da1,da0,dg2,8'b000,gm8,sel);

wire m1gs1,m1gs2,m1gs3,m1gs4,m1gs5;
wire m2gs1,m2gs2,m2gs3,m2gs4,m2gs5;
wire m3gs1,m3gs2,m3gs3,m3gs4,m3gs5;
wire m4gs1,m4gs2,m4gs3,m4gs4,m4gs5;
wire m5gs1,m5gs2,m5gs3,m5gs4,m5gs5;

assign m1gs1=1'b0; 
assign m1gs2=1'b0;
assign m1gs3=dg0s^da0s;
assign m1gs4=g10s^dg0s;
assign m1gs5=g10s^dg0s;

assign m2gs1=dg0s^da6s;
assign m2gs2=dg0s^da4s;
assign m2gs3=1'b0;
assign m2gs4=1'b0;
assign m2gs5=1'b0;

assign m3gs1=dg1s^da5s;
assign m3gs2=dg1s^da3s;
assign m3gs3=dg0s^da2s;
assign m3gs4=g21s^dg0s;
assign m3gs5=1'b0;

assign m4gs1=dg2s^da4s;
assign m4gs2=dg2s^da2s;
assign m4gs3=dg1s^da1s;
assign m4gs4=g11s^dg1s;
assign m4gs5=1'b0;

assign m5gs1=dg3s^da3s;
assign m5gs2=dg3s^da1s;
assign m5gs3=dg2s^da0s;
assign m5gs4=g10s^dg2s;
assign m5gs5=1'b0;

wire [31:0] go32_1,go32_2,go32_3,go32_4;

wallace24x8 m32g1(go32_1,gm1,gm2);
wallace24x8 m32g2(go32_2,gm3,gm4);
wallace24x8 m32g3(go32_3,gm5,gm6);
wallace24x8 m32g4(go32_4,gm7,gm8);

wire rg1s,rg2s,rg3s,rg4s,rg5s;

mux5to1 m1g0k(m1gs1,m1gs2,m1gs3,m1gs4,m1gs5,rg1s,sel);
mux5to1 m2g0k(m2gs1,m2gs2,m2gs3,m2gs4,m2gs5,rg2s,sel);
mux5to1 m3g0k(m3gs1,m3gs2,m3gs3,m3gs4,m3gs5,rg3s,sel);
mux5to1 m4g0k(m4gs1,m4gs2,m4gs3,m4gs4,m4gs5,rg4s,sel);
mux5to1 m5g0k(m5gs1,m5gs2,m5gs3,m5gs4,m5gs5,rg5s,sel);

wire [34:0] rg1,rg2,rg3,rg4,rg5;

mux5_35 m51g1(35'b000,35'b000,{3'b00,go32_1},{3'b00,go32_1},{3'b00,go32_1},rg1,sel);
mux5_35 m51g2({3'b00,go32_1},{3'b00,go32_1},35'b000,35'b000,35'b000,rg2,sel);
mux5_35 m51g3({3'b00,go32_2},{3'b00,go32_2},{3'b00,go32_2},{3'b00,go32_2},35'b000,rg3,sel);
mux5_35 m51g4({3'b00,go32_3},{3'b00,go32_3},{3'b00,go32_3},{3'b00,go32_3},35'b000,rg4,sel);
mux5_35 m51g5({3'b00,go32_4},{3'b00,go32_4},{3'b00,go32_4},{3'b00,go32_4},35'b000,rg5,sel);

wire [63:0] rg2r,rg3r,rg4r,rg5r;

assign rg2r=~rg2;
assign rg3r=~rg3;
assign rg4r=~rg4;
assign rg5r=~rg5;

wire [34:0] rg2r1,rg3r1,rg4r1,rg5r1;
wire gca2,gca3,gca4,gca5;

recurse35 r45g1(rg2r1,gca2,rg2r[34:0],35'b0000000000000000000000000000000001);
recurse35 r45g2(rg3r1,gca3,rg3r[34:0],35'b0000000000000000000000000000000001);
recurse35 r45g3(rg4r1,gca4,rg4r[34:0],35'b0000000000000000000000000000000001);
recurse35 r45g4(rg5r1,gca5,rg5r[34:0],35'b0000000000000000000000000000000001);

wire [34:0] rg2r11,rg3r11,rg4r11,rg5r11;

mux2_35 mgjj1(rg2r11,rg2[34:0],rg2r1,rg2s);
mux2_35 mgjj2(rg3r11,rg3[34:0],rg3r1,rg3s);
mux2_35 mgjj3(rg4r11,rg4[34:0],rg4r1,rg4s);
mux2_35 mgjj4(rg5r11,rg5[34:0],rg5r1,rg5s);

wire [34:0] sum1g,carry1g;

fulladd1 f1g00(rg2r11[0],rg3r11[0],rg4r11[0],sum1g[0],carry1g[0]);
fulladd1 f1g01(rg2r11[1],rg3r11[1],rg4r11[1],sum1g[1],carry1g[1]);
fulladd1 f1g02(rg2r11[2],rg3r11[2],rg4r11[2],sum1g[2],carry1g[2]);
fulladd1 f1g03(rg2r11[3],rg3r11[3],rg4r11[3],sum1g[3],carry1g[3]);
fulladd1 f1g04(rg2r11[4],rg3r11[4],rg4r11[4],sum1g[4],carry1g[4]);
fulladd1 f1g05(rg2r11[5],rg3r11[5],rg4r11[5],sum1g[5],carry1g[5]);
fulladd1 f1g06(rg2r11[6],rg3r11[6],rg4r11[6],sum1g[6],carry1g[6]);
fulladd1 f1g07(rg2r11[7],rg3r11[7],rg4r11[7],sum1g[7],carry1g[7]);
fulladd1 f1g08(rg2r11[8],rg3r11[8],rg4r11[8],sum1g[8],carry1g[8]);
fulladd1 f1g09(rg2r11[9],rg3r11[9],rg4r11[9],sum1g[9],carry1g[9]);
fulladd1 f1g10(rg2r11[10],rg3r11[10],rg4r11[10],sum1g[10],carry1g[10]);
fulladd1 f1g11(rg2r11[11],rg3r11[11],rg4r11[11],sum1g[11],carry1g[11]);
fulladd1 f1g12(rg2r11[12],rg3r11[12],rg4r11[12],sum1g[12],carry1g[12]);
fulladd1 f1g13(rg2r11[13],rg3r11[13],rg4r11[13],sum1g[13],carry1g[13]);
fulladd1 f1g14(rg2r11[14],rg3r11[14],rg4r11[14],sum1g[14],carry1g[14]);
fulladd1 f1g15(rg2r11[15],rg3r11[15],rg4r11[15],sum1g[15],carry1g[15]);
fulladd1 f1g16(rg2r11[16],rg3r11[16],rg4r11[16],sum1g[16],carry1g[16]);
fulladd1 f1g17(rg2r11[17],rg3r11[17],rg4r11[17],sum1g[17],carry1g[17]);
fulladd1 f1g18(rg2r11[18],rg3r11[18],rg4r11[18],sum1g[18],carry1g[18]);
fulladd1 f1g19(rg2r11[19],rg3r11[19],rg4r11[19],sum1g[19],carry1g[19]);
fulladd1 f1g20(rg2r11[20],rg3r11[20],rg4r11[20],sum1g[20],carry1g[20]);
fulladd1 f1g21(rg2r11[21],rg3r11[21],rg4r11[21],sum1g[21],carry1g[21]);
fulladd1 f1g22(rg2r11[22],rg3r11[22],rg4r11[22],sum1g[22],carry1g[22]);
fulladd1 f1g23(rg2r11[23],rg3r11[23],rg4r11[23],sum1g[23],carry1g[23]);
fulladd1 f1g24(rg2r11[24],rg3r11[24],rg4r11[24],sum1g[24],carry1g[24]);
fulladd1 f1g25(rg2r11[25],rg3r11[25],rg4r11[25],sum1g[25],carry1g[25]);
fulladd1 f1g26(rg2r11[26],rg3r11[26],rg4r11[26],sum1g[26],carry1g[26]);
fulladd1 f1g27(rg2r11[27],rg3r11[27],rg4r11[27],sum1g[27],carry1g[27]);
fulladd1 f1g28(rg2r11[28],rg3r11[28],rg4r11[28],sum1g[28],carry1g[28]);
fulladd1 f1g29(rg2r11[29],rg3r11[29],rg4r11[29],sum1g[29],carry1g[29]);
fulladd1 f1g30(rg2r11[30],rg3r11[30],rg4r11[30],sum1g[30],carry1g[30]);
fulladd1 f1g31(rg2r11[31],rg3r11[31],rg4r11[31],sum1g[31],carry1g[31]);
fulladd1 f1g32(rg2r11[32],rg3r11[32],rg4r11[32],sum1g[32],carry1g[32]);
fulladd1 f1g33(rg2r11[33],rg3r11[33],rg4r11[33],sum1g[33],carry1g[33]);
fulladd1 f1g34(rg2r11[34],rg3r11[34],rg4r11[34],sum1g[34],carry1g[34]);

wire [35:0] sum2g,carry2g;

halfadd1 f2g00(sum1g[0],rg5r11[0],sum2g[0],carry2g[0]);
fulladd1 f2g01(sum1g[1],rg5r11[1],carry1g[0],sum2g[1],carry2g[1]);
fulladd1 f2g02(sum1g[2],rg5r11[2],carry1g[1],sum2g[2],carry2g[2]);
fulladd1 f2g03(sum1g[3],rg5r11[3],carry1g[2],sum2g[3],carry2g[3]);
fulladd1 f2g04(sum1g[4],rg5r11[4],carry1g[3],sum2g[4],carry2g[4]);
fulladd1 f2g05(sum1g[5],rg5r11[5],carry1g[4],sum2g[5],carry2g[5]);
fulladd1 f2g06(sum1g[6],rg5r11[6],carry1g[5],sum2g[6],carry2g[6]);
fulladd1 f2g07(sum1g[7],rg5r11[7],carry1g[6],sum2g[7],carry2g[7]);
fulladd1 f2g08(sum1g[8],rg5r11[8],carry1g[7],sum2g[8],carry2g[8]);
fulladd1 f2g09(sum1g[9],rg5r11[9],carry1g[8],sum2g[9],carry2g[9]);
fulladd1 f2g10(sum1g[10],rg5r11[10],carry1g[9],sum2g[10],carry2g[10]);
fulladd1 f2g11(sum1g[11],rg5r11[11],carry1g[10],sum2g[11],carry2g[11]);
fulladd1 f2g12(sum1g[12],rg5r11[12],carry1g[11],sum2g[12],carry2g[12]);
fulladd1 f2g13(sum1g[13],rg5r11[13],carry1g[12],sum2g[13],carry2g[13]);
fulladd1 f2g14(sum1g[14],rg5r11[14],carry1g[13],sum2g[14],carry2g[14]);
fulladd1 f2g15(sum1g[15],rg5r11[15],carry1g[14],sum2g[15],carry2g[15]);
fulladd1 f2g16(sum1g[16],rg5r11[16],carry1g[15],sum2g[16],carry2g[16]);
fulladd1 f2g17(sum1g[17],rg5r11[17],carry1g[16],sum2g[17],carry2g[17]);
fulladd1 f2g18(sum1g[18],rg5r11[18],carry1g[17],sum2g[18],carry2g[18]);
fulladd1 f2g19(sum1g[19],rg5r11[19],carry1g[18],sum2g[19],carry2g[19]);
fulladd1 f2g20(sum1g[20],rg5r11[20],carry1g[19],sum2g[20],carry2g[20]);
fulladd1 f2g21(sum1g[21],rg5r11[21],carry1g[20],sum2g[21],carry2g[21]);
fulladd1 f2g22(sum1g[22],rg5r11[22],carry1g[21],sum2g[22],carry2g[22]);
fulladd1 f2g23(sum1g[23],rg5r11[23],carry1g[22],sum2g[23],carry2g[23]);
fulladd1 f2g24(sum1g[24],rg5r11[24],carry1g[23],sum2g[24],carry2g[24]);
fulladd1 f2g25(sum1g[25],rg5r11[25],carry1g[24],sum2g[25],carry2g[25]);
fulladd1 f2g26(sum1g[26],rg5r11[26],carry1g[25],sum2g[26],carry2g[26]);
fulladd1 f2g27(sum1g[27],rg5r11[27],carry1g[26],sum2g[27],carry2g[27]);
fulladd1 f2g28(sum1g[28],rg5r11[28],carry1g[27],sum2g[28],carry2g[28]);
fulladd1 f2g29(sum1g[29],rg5r11[29],carry1g[28],sum2g[29],carry2g[29]);
fulladd1 f2g30(sum1g[30],rg5r11[30],carry1g[29],sum2g[30],carry2g[30]);
fulladd1 f2g31(sum1g[31],rg5r11[31],carry1g[30],sum2g[31],carry2g[31]);
fulladd1 f2g32(sum1g[32],rg5r11[32],carry1g[31],sum2g[32],carry2g[32]);
fulladd1 f2g33(sum1g[33],rg5r11[33],carry1g[32],sum2g[33],carry2g[33]);
fulladd1 f2g34(sum1g[34],rg5r11[34],carry1g[33],sum2g[34],carry2g[34]);
fulladd1 f2g35(sum1g[34],rg5r11[34],carry1g[34],sum2g[35],carry2g[35]);

wire [36:0] sum3g,sum3gr,sum3gr1,sum4g;
wire ca3g,ca4g;

assign sum3g[0]=sum2g[0];
recurse36 rg460(sum3g[36:1],ca3g,{sum2g[35],sum2g[35:1]},carry2g[35:0]);//sign bit=sum3g[36]

assign sum3gr=~sum3g;
recurse36 rg461(sum3gr1[35:0],ca4g,sum3gr[35:0],36'b000000000000000000000000000000000001);

mux2_35 m21lg(sum4g[34:0],sum3g[34:0],sum3gr1[34:0],sum3g[36]);

dflipflop35 ffg451(g10,rg1[34:0],clk,reset);
dflipflop35 ffg452(g11,sum4g[34:0],clk,reset);

dflipflop ffgl1(g10s,rg1s,clk,reset);
dflipflop ffgl2(g11s,sum3g[36],clk,reset);

dflipflop35 ffg453(g20,g10,clk,reset);
dflipflop35 ffg454(g21,g11,clk,reset);

dflipflop ffgl3(g20s,g10s,clk,reset);
dflipflop ffgl4(g21s,g11s,clk,reset);

dflipflop35 ffg455(g30,g20,clk,reset);
dflipflop35 ffg456(g31,g21,clk,reset);

dflipflop ffgl5(g30s,g20s,clk,reset);
dflipflop ffgl6(g31s,g21s,clk,reset);

//////////////////////////////////////////////////////////////////////////////////////////////////////////H////////

wire [34:0] h10,h11,h20,h21,h30,h31;
wire h10s,h11s,h20s,h21s,h30s,h31s;

wire [23:0] hm1,hm3,hm5,hm7;
wire [7:0] hm2,hm4,hm6,hm8;

mux5_24 mh00({16'b000,dh0},{16'b000,dh0},{16'b000,dh0},h10[23:0],h10[23:0],hm1,sel);
mux5_8 mh01(da6,da4,da0,dh0,dh0,hm2,sel);

mux5_24 mh02({16'b000,dh1},{16'b000,dh1},{16'b000,dh0},h21[23:0],24'b000,hm3,sel);
mux5_8 mh03(da5,da3,da2,dh0,8'b000,hm4,sel);

mux5_24 mh04({16'b000,dh2},{16'b000,dh2},{16'b000,dh1},h11[23:0],24'b000,hm5,sel);
mux5_8 mh05(da4,da2,da1,dh1,8'b000,hm6,sel);

mux5_24 mh06({16'b000,dh3},{16'b000,dh3},{16'b000,dh2},h10[23:0],24'b000,hm7,sel);
mux5_8 mh07(da3,da1,da0,dh2,8'b000,hm8,sel);

wire m1hs1,m1hs2,m1hs3,m1hs4,m1hs5;
wire m2hs1,m2hs2,m2hs3,m2hs4,m2hs5;
wire m3hs1,m3hs2,m3hs3,m3hs4,m3hs5;
wire m4hs1,m4hs2,m4hs3,m4hs4,m4hs5;
wire m5hs1,m5hs2,m5hs3,m5hs4,m5hs5;

assign m1hs1=1'b0; 
assign m1hs2=1'b0;
assign m1hs3=dh0s^da0s;
assign m1hs4=h10s^dh0s;
assign m1hs5=h10s^dh0s;

assign m2hs1=dh0s^da6s;
assign m2hs2=dh0s^da4s;
assign m2hs3=1'b0;
assign m2hs4=1'b0;
assign m2hs5=1'b0;

assign m3hs1=dh1s^da5s;
assign m3hs2=dh1s^da3s;
assign m3hs3=dh0s^da2s;
assign m3hs4=h21s^dh0s;
assign m3hs5=1'b0;

assign m4hs1=dh2s^da4s;
assign m4hs2=dh2s^da2s;
assign m4hs3=dh1s^da1s;
assign m4hs4=h11s^dh1s;
assign m4hs5=1'b0;

assign m5hs1=dh3s^da3s;
assign m5hs2=dh3s^da1s;
assign m5hs3=dh2s^da0s;
assign m5hs4=h10s^dh2s;
assign m5hs5=1'b0;

wire [31:0] ho32_1,ho32_2,ho32_3,ho32_4;

wallace24x8 m32h1(ho32_1,hm1,hm2);
wallace24x8 m32h2(ho32_2,hm3,hm4);
wallace24x8 m32h3(ho32_3,hm5,hm6);
wallace24x8 m32h4(ho32_4,hm7,hm8);

wire rh1s,rh2s,rh3s,rh4s,rh5s;

mux5to1 m1h0k(m1hs1,m1hs2,m1hs3,m1hs4,m1hs5,rh1s,sel);
mux5to1 m2h0k(m2hs1,m2hs2,m2hs3,m2hs4,m2hs5,rh2s,sel);
mux5to1 m3h0k(m3hs1,m3hs2,m3hs3,m3hs4,m3hs5,rh3s,sel);
mux5to1 m4h0k(m4hs1,m4hs2,m4hs3,m4hs4,m4hs5,rh4s,sel);
mux5to1 m5h0k(m5hs1,m5hs2,m5hs3,m5hs4,m5hs5,rh5s,sel);

wire [34:0] rh1,rh2,rh3,rh4,rh5;

mux5_35 m51h1(35'b000,35'b000,{3'b00,ho32_1},{3'b00,ho32_1},{3'b00,ho32_1},rh1,sel);
mux5_35 m51h2({3'b00,ho32_1},{3'b00,ho32_1},35'b000,35'b000,35'b000,rh2,sel);
mux5_35 m51h3({3'b00,ho32_2},{3'b00,ho32_2},{3'b00,ho32_2},{3'b00,ho32_2},35'b000,rh3,sel);
mux5_35 m51h4({3'b00,ho32_3},{3'b00,ho32_3},{3'b00,ho32_3},{3'b00,ho32_3},35'b000,rh4,sel);
mux5_35 m51h5({3'b00,ho32_4},{3'b00,ho32_4},{3'b00,ho32_4},{3'b00,ho32_4},35'b000,rh5,sel);

wire [63:0] rh2r,rh3r,rh4r,rh5r;

assign rh2r=~rh2;
assign rh3r=~rh3;
assign rh4r=~rh4;
assign rh5r=~rh5;

wire [34:0] rh2r1,rh3r1,rh4r1,rh5r1;
wire hca2,hca3,hca4,hca5;

recurse35 r45h1(rh2r1,hca2,rh2r[34:0],35'b0000000000000000000000000000000001);
recurse35 r45h2(rh3r1,hca3,rh3r[34:0],35'b0000000000000000000000000000000001);
recurse35 r45h3(rh4r1,hca4,rh4r[34:0],35'b0000000000000000000000000000000001);
recurse35 r45h4(rh5r1,hca5,rh5r[34:0],35'b0000000000000000000000000000000001);

wire [34:0] rh2r11,rh3r11,rh4r11,rh5r11;

mux2_35 mhjj1(rh2r11,rh2[34:0],rh2r1,rh2s);
mux2_35 mhjj2(rh3r11,rh3[34:0],rh3r1,rh3s);
mux2_35 mhjj3(rh4r11,rh4[34:0],rh4r1,rh4s);
mux2_35 mhjj4(rh5r11,rh5[34:0],rh5r1,rh5s);

wire [34:0] sum1h,carry1h;

fulladd1 f1h00(rh2r11[0],rh3r11[0],rh4r11[0],sum1h[0],carry1h[0]);
fulladd1 f1h01(rh2r11[1],rh3r11[1],rh4r11[1],sum1h[1],carry1h[1]);
fulladd1 f1h02(rh2r11[2],rh3r11[2],rh4r11[2],sum1h[2],carry1h[2]);
fulladd1 f1h03(rh2r11[3],rh3r11[3],rh4r11[3],sum1h[3],carry1h[3]);
fulladd1 f1h04(rh2r11[4],rh3r11[4],rh4r11[4],sum1h[4],carry1h[4]);
fulladd1 f1h05(rh2r11[5],rh3r11[5],rh4r11[5],sum1h[5],carry1h[5]);
fulladd1 f1h06(rh2r11[6],rh3r11[6],rh4r11[6],sum1h[6],carry1h[6]);
fulladd1 f1h07(rh2r11[7],rh3r11[7],rh4r11[7],sum1h[7],carry1h[7]);
fulladd1 f1h08(rh2r11[8],rh3r11[8],rh4r11[8],sum1h[8],carry1h[8]);
fulladd1 f1h09(rh2r11[9],rh3r11[9],rh4r11[9],sum1h[9],carry1h[9]);
fulladd1 f1h10(rh2r11[10],rh3r11[10],rh4r11[10],sum1h[10],carry1h[10]);
fulladd1 f1h11(rh2r11[11],rh3r11[11],rh4r11[11],sum1h[11],carry1h[11]);
fulladd1 f1h12(rh2r11[12],rh3r11[12],rh4r11[12],sum1h[12],carry1h[12]);
fulladd1 f1h13(rh2r11[13],rh3r11[13],rh4r11[13],sum1h[13],carry1h[13]);
fulladd1 f1h14(rh2r11[14],rh3r11[14],rh4r11[14],sum1h[14],carry1h[14]);
fulladd1 f1h15(rh2r11[15],rh3r11[15],rh4r11[15],sum1h[15],carry1h[15]);
fulladd1 f1h16(rh2r11[16],rh3r11[16],rh4r11[16],sum1h[16],carry1h[16]);
fulladd1 f1h17(rh2r11[17],rh3r11[17],rh4r11[17],sum1h[17],carry1h[17]);
fulladd1 f1h18(rh2r11[18],rh3r11[18],rh4r11[18],sum1h[18],carry1h[18]);
fulladd1 f1h19(rh2r11[19],rh3r11[19],rh4r11[19],sum1h[19],carry1h[19]);
fulladd1 f1h20(rh2r11[20],rh3r11[20],rh4r11[20],sum1h[20],carry1h[20]);
fulladd1 f1h21(rh2r11[21],rh3r11[21],rh4r11[21],sum1h[21],carry1h[21]);
fulladd1 f1h22(rh2r11[22],rh3r11[22],rh4r11[22],sum1h[22],carry1h[22]);
fulladd1 f1h23(rh2r11[23],rh3r11[23],rh4r11[23],sum1h[23],carry1h[23]);
fulladd1 f1h24(rh2r11[24],rh3r11[24],rh4r11[24],sum1h[24],carry1h[24]);
fulladd1 f1h25(rh2r11[25],rh3r11[25],rh4r11[25],sum1h[25],carry1h[25]);
fulladd1 f1h26(rh2r11[26],rh3r11[26],rh4r11[26],sum1h[26],carry1h[26]);
fulladd1 f1h27(rh2r11[27],rh3r11[27],rh4r11[27],sum1h[27],carry1h[27]);
fulladd1 f1h28(rh2r11[28],rh3r11[28],rh4r11[28],sum1h[28],carry1h[28]);
fulladd1 f1h29(rh2r11[29],rh3r11[29],rh4r11[29],sum1h[29],carry1h[29]);
fulladd1 f1h30(rh2r11[30],rh3r11[30],rh4r11[30],sum1h[30],carry1h[30]);
fulladd1 f1h31(rh2r11[31],rh3r11[31],rh4r11[31],sum1h[31],carry1h[31]);
fulladd1 f1h32(rh2r11[32],rh3r11[32],rh4r11[32],sum1h[32],carry1h[32]);
fulladd1 f1h33(rh2r11[33],rh3r11[33],rh4r11[33],sum1h[33],carry1h[33]);
fulladd1 f1h34(rh2r11[34],rh3r11[34],rh4r11[34],sum1h[34],carry1h[34]);

wire [35:0] sum2h,carry2h;

halfadd1 f2h00(sum1h[0],rh5r11[0],sum2h[0],carry2h[0]);
fulladd1 f2h01(sum1h[1],rh5r11[1],carry1h[0],sum2h[1],carry2h[1]);
fulladd1 f2h02(sum1h[2],rh5r11[2],carry1h[1],sum2h[2],carry2h[2]);
fulladd1 f2h03(sum1h[3],rh5r11[3],carry1h[2],sum2h[3],carry2h[3]);
fulladd1 f2h04(sum1h[4],rh5r11[4],carry1h[3],sum2h[4],carry2h[4]);
fulladd1 f2h05(sum1h[5],rh5r11[5],carry1h[4],sum2h[5],carry2h[5]);
fulladd1 f2h06(sum1h[6],rh5r11[6],carry1h[5],sum2h[6],carry2h[6]);
fulladd1 f2h07(sum1h[7],rh5r11[7],carry1h[6],sum2h[7],carry2h[7]);
fulladd1 f2h08(sum1h[8],rh5r11[8],carry1h[7],sum2h[8],carry2h[8]);
fulladd1 f2h09(sum1h[9],rh5r11[9],carry1h[8],sum2h[9],carry2h[9]);
fulladd1 f2h10(sum1h[10],rh5r11[10],carry1h[9],sum2h[10],carry2h[10]);
fulladd1 f2h11(sum1h[11],rh5r11[11],carry1h[10],sum2h[11],carry2h[11]);
fulladd1 f2h12(sum1h[12],rh5r11[12],carry1h[11],sum2h[12],carry2h[12]);
fulladd1 f2h13(sum1h[13],rh5r11[13],carry1h[12],sum2h[13],carry2h[13]);
fulladd1 f2h14(sum1h[14],rh5r11[14],carry1h[13],sum2h[14],carry2h[14]);
fulladd1 f2h15(sum1h[15],rh5r11[15],carry1h[14],sum2h[15],carry2h[15]);
fulladd1 f2h16(sum1h[16],rh5r11[16],carry1h[15],sum2h[16],carry2h[16]);
fulladd1 f2h17(sum1h[17],rh5r11[17],carry1h[16],sum2h[17],carry2h[17]);
fulladd1 f2h18(sum1h[18],rh5r11[18],carry1h[17],sum2h[18],carry2h[18]);
fulladd1 f2h19(sum1h[19],rh5r11[19],carry1h[18],sum2h[19],carry2h[19]);
fulladd1 f2h20(sum1h[20],rh5r11[20],carry1h[19],sum2h[20],carry2h[20]);
fulladd1 f2h21(sum1h[21],rh5r11[21],carry1h[20],sum2h[21],carry2h[21]);
fulladd1 f2h22(sum1h[22],rh5r11[22],carry1h[21],sum2h[22],carry2h[22]);
fulladd1 f2h23(sum1h[23],rh5r11[23],carry1h[22],sum2h[23],carry2h[23]);
fulladd1 f2h24(sum1h[24],rh5r11[24],carry1h[23],sum2h[24],carry2h[24]);
fulladd1 f2h25(sum1h[25],rh5r11[25],carry1h[24],sum2h[25],carry2h[25]);
fulladd1 f2h26(sum1h[26],rh5r11[26],carry1h[25],sum2h[26],carry2h[26]);
fulladd1 f2h27(sum1h[27],rh5r11[27],carry1h[26],sum2h[27],carry2h[27]);
fulladd1 f2h28(sum1h[28],rh5r11[28],carry1h[27],sum2h[28],carry2h[28]);
fulladd1 f2h29(sum1h[29],rh5r11[29],carry1h[28],sum2h[29],carry2h[29]);
fulladd1 f2h30(sum1h[30],rh5r11[30],carry1h[29],sum2h[30],carry2h[30]);
fulladd1 f2h31(sum1h[31],rh5r11[31],carry1h[30],sum2h[31],carry2h[31]);
fulladd1 f2h32(sum1h[32],rh5r11[32],carry1h[31],sum2h[32],carry2h[32]);
fulladd1 f2h33(sum1h[33],rh5r11[33],carry1h[32],sum2h[33],carry2h[33]);
fulladd1 f2h34(sum1h[34],rh5r11[34],carry1h[33],sum2h[34],carry2h[34]);
fulladd1 f2h35(sum1h[34],rh5r11[34],carry1h[34],sum2h[35],carry2h[35]);

wire [36:0] sum3h,sum3hr,sum3hr1,sum4h;
wire ca3h,ca4h;

assign sum3h[0]=sum2h[0];
recurse36 rh460(sum3h[36:1],ca3h,{sum2h[35],sum2h[35:1]},carry2h[35:0]);//sihn bit=sum3h[36]

assign sum3hr=~sum3h;
recurse36 rh461(sum3hr1[35:0],ca4h,sum3hr[35:0],36'b000000000000000000000000000000000001);

mux2_35 m21lh(sum4h[34:0],sum3h[34:0],sum3hr1[34:0],sum3h[36]);

dflipflop35 ffh451(h10,rh1[34:0],clk,reset);
dflipflop35 ffh452(h11,sum4h[34:0],clk,reset);

dflipflop ffhl1(h10s,rh1s,clk,reset);
dflipflop ffhl2(h11s,sum3h[36],clk,reset);

dflipflop35 ffh453(h20,h10,clk,reset);
dflipflop35 ffh454(h21,h11,clk,reset);

dflipflop ffhl3(h20s,h10s,clk,reset);
dflipflop ffhl4(h21s,h11s,clk,reset);

dflipflop35 ffh455(h30,h20,clk,reset);
dflipflop35 ffh456(h31,h21,clk,reset);

dflipflop ffhl5(h30s,h20s,clk,reset);
dflipflop ffhl6(h31s,h21s,clk,reset);

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// D flip flop

module dflipflop8(q,d,clk,reset);
output [7:0] q;
input [7:0] d;
input clk,reset;
reg [7:0] q;
always@(posedge reset or negedge clk)
if(reset)
q<=8'b00000000;
else
q<=d;
endmodule

// D flip flop

module dflipflop(q,d,clk,reset);
output q;
input d,clk,reset;
reg q;
always@(posedge reset or negedge clk)
if(reset)
q<=1'b0;
else
q<=d;
endmodule

//mux 5to1

module mux5_24(a,b,c,d,e,out,sel);

input [23:0] a,b,c,d,e;
input [2:0] sel;
output [23:0] out;

reg [23:0] out;

always@(a or b or c or d or e or sel)
begin
case(sel)
3'b000:out=a;  
3'b001:out=b;
3'b010:out=c;	
3'b011:out=d;  
3'b100:out=e;
endcase   
end

endmodule

//mux 5to1

module mux5_8(a,b,c,d,e,out,sel);

input [7:0] a,b,c,d,e;
input [2:0] sel;
output [7:0] out;

reg [7:0] out;

always@(a or b or c or d or e or sel)
begin
case(sel)
3'b000:out=a;  
3'b001:out=b;
3'b010:out=c;	
3'b011:out=d;  
3'b100:out=e;
endcase   
end

endmodule

//24x8-bit wallace tree multiplier

module wallace24x8(r,a,b);

output [31:0] r;
input [23:0] a;
input [7:0] b;

wire [23:0] p0;
wire [23:0] p1;
wire [23:0] p2;
wire [23:0] p3;
wire [23:0] p4;
wire [23:0] p5;
wire [23:0] p6;
wire [23:0] p7;

wire [25:0] sum1;
wire [25:0] sum2;
wire [28:0] sum3;
wire [25:0] sum4;
wire [30:0] sum5;
wire [30:0] sum6;

wire [23:0] carry1;
wire [23:0] carry2;
wire [23:0] carry3;
wire [23:0] carry4;
wire [25:0] carry5;
wire [26:0] carry6;

assign p0 = b[0] ? a[23:0] : 24'b00000000;
assign p1 = b[1] ? a[23:0] : 24'b00000000;
assign p2 = b[2] ? a[23:0] : 24'b00000000;
assign p3 = b[3] ? a[23:0] : 24'b00000000;    
assign p4 = b[4] ? a[23:0] : 24'b00000000;
assign p5 = b[5] ? a[23:0] : 24'b00000000;
assign p6 = b[6] ? a[23:0] : 24'b00000000;
assign p7 = b[7] ? a[23:0] : 24'b00000000;

//csa1

assign sum1[0]=p0[0];
halfadd h101(sum1[1],carry1[0],p0[1],p1[0]);
fulladd f101(sum1[2],carry1[1],p0[2],p1[1],p2[0]);
fulladd f102(sum1[3],carry1[2],p0[3],p1[2],p2[1]);
fulladd f103(sum1[4],carry1[3],p0[4],p1[3],p2[2]);
fulladd f104(sum1[5],carry1[4],p0[5],p1[4],p2[3]);
fulladd f105(sum1[6],carry1[5],p0[6],p1[5],p2[4]);
fulladd f106(sum1[7],carry1[6],p0[7],p1[6],p2[5]);
fulladd f107(sum1[8],carry1[7],p0[8],p1[7],p2[6]);
fulladd f108(sum1[9],carry1[8],p0[9],p1[8],p2[7]);
fulladd f109(sum1[10],carry1[9],p0[10],p1[9],p2[8]);
fulladd f110(sum1[11],carry1[10],p0[11],p1[10],p2[9]);
fulladd f111(sum1[12],carry1[11],p0[12],p1[11],p2[10]);
fulladd f112(sum1[13],carry1[12],p0[13],p1[12],p2[11]);
fulladd f113(sum1[14],carry1[13],p0[14],p1[13],p2[12]);
fulladd f114(sum1[15],carry1[14],p0[15],p1[14],p2[13]);
fulladd f115(sum1[16],carry1[15],p0[16],p1[15],p2[14]);
fulladd f116(sum1[17],carry1[16],p0[17],p1[16],p2[15]);
fulladd f117(sum1[18],carry1[17],p0[18],p1[17],p2[16]);
fulladd f118(sum1[19],carry1[18],p0[19],p1[18],p2[17]);
fulladd f119(sum1[20],carry1[19],p0[20],p1[19],p2[18]);
fulladd f120(sum1[21],carry1[20],p0[21],p1[20],p2[19]);
fulladd f121(sum1[22],carry1[21],p0[22],p1[21],p2[20]);
fulladd f122(sum1[23],carry1[22],p0[23],p1[22],p2[21]);
halfadd h102(sum1[24],carry1[23],p1[23],p2[22]);
assign sum1[25]=p2[23];

//csa2

assign sum2[0]=p3[0];
halfadd h201(sum2[1],carry2[0],p3[1],p4[0]);
fulladd f201(sum2[2],carry2[1],p3[2],p4[1],p5[0]);
fulladd f202(sum2[3],carry2[2],p3[3],p4[2],p5[1]);
fulladd f203(sum2[4],carry2[3],p3[4],p4[3],p5[2]);
fulladd f204(sum2[5],carry2[4],p3[5],p4[4],p5[3]);
fulladd f205(sum2[6],carry2[5],p3[6],p4[5],p5[4]);
fulladd f206(sum2[7],carry2[6],p3[7],p4[6],p5[5]);
fulladd f207(sum2[8],carry2[7],p3[8],p4[7],p5[6]);
fulladd f208(sum2[9],carry2[8],p3[9],p4[8],p5[7]);
fulladd f209(sum2[10],carry2[9],p3[10],p4[9],p5[8]);
fulladd f210(sum2[11],carry2[10],p3[11],p4[10],p5[9]);
fulladd f211(sum2[12],carry2[11],p3[12],p4[11],p5[10]);
fulladd f212(sum2[13],carry2[12],p3[13],p4[12],p5[11]);
fulladd f213(sum2[14],carry2[13],p3[14],p4[13],p5[12]);
fulladd f214(sum2[15],carry2[14],p3[15],p4[14],p5[13]);
fulladd f215(sum2[16],carry2[15],p3[16],p4[15],p5[14]);
fulladd f216(sum2[17],carry2[16],p3[17],p4[16],p5[15]);
fulladd f217(sum2[18],carry2[17],p3[18],p4[17],p5[16]);
fulladd f218(sum2[19],carry2[18],p3[19],p4[18],p5[17]);
fulladd f219(sum2[20],carry2[19],p3[20],p4[19],p5[18]);
fulladd f220(sum2[21],carry2[20],p3[21],p4[20],p5[19]);
fulladd f221(sum2[22],carry2[21],p3[22],p4[21],p5[20]);
fulladd f222(sum2[23],carry2[22],p3[23],p4[22],p5[21]);
halfadd h202(sum2[24],carry2[23],p4[23],p5[22]);
assign sum2[25]=p5[23];

//csa3

assign sum3[1:0]=sum1[1:0];
halfadd h301(sum3[2],carry3[0],sum1[2],carry1[0]);
fulladd f301(sum3[3],carry3[1],sum1[3],carry1[1],sum2[0]);
fulladd f302(sum3[4],carry3[2],sum1[4],carry1[2],sum2[1]);
fulladd f303(sum3[5],carry3[3],sum1[5],carry1[3],sum2[2]);
fulladd f304(sum3[6],carry3[4],sum1[6],carry1[4],sum2[3]);
fulladd f305(sum3[7],carry3[5],sum1[7],carry1[5],sum2[4]);
fulladd f306(sum3[8],carry3[6],sum1[8],carry1[6],sum2[5]);
fulladd f307(sum3[9],carry3[7],sum1[9],carry1[7],sum2[6]);
fulladd f308(sum3[10],carry3[8],sum1[10],carry1[8],sum2[7]);
fulladd f309(sum3[11],carry3[9],sum1[11],carry1[9],sum2[8]);
fulladd f310(sum3[12],carry3[10],sum1[12],carry1[10],sum2[9]);
fulladd f311(sum3[13],carry3[11],sum1[13],carry1[11],sum2[10]);
fulladd f312(sum3[14],carry3[12],sum1[14],carry1[12],sum2[11]);
fulladd f313(sum3[15],carry3[13],sum1[15],carry1[13],sum2[12]);
fulladd f314(sum3[16],carry3[14],sum1[16],carry1[14],sum2[13]);
fulladd f315(sum3[17],carry3[15],sum1[17],carry1[15],sum2[14]);
fulladd f316(sum3[18],carry3[16],sum1[18],carry1[16],sum2[15]);
fulladd f317(sum3[19],carry3[17],sum1[19],carry1[17],sum2[16]);
fulladd f318(sum3[20],carry3[18],sum1[20],carry1[18],sum2[17]);
fulladd f319(sum3[21],carry3[19],sum1[21],carry1[19],sum2[18]);
fulladd f320(sum3[22],carry3[20],sum1[22],carry1[20],sum2[19]);
fulladd f321(sum3[23],carry3[21],sum1[23],carry1[21],sum2[20]);
fulladd f322(sum3[24],carry3[22],sum1[24],carry1[22],sum2[21]);
fulladd f323(sum3[25],carry3[23],sum1[25],carry1[23],sum2[22]);
assign sum3[28:26]=sum2[25:23];

//csa4

assign sum4[0]=carry2[0];
halfadd h401(sum4[1],carry4[0],carry2[1],p6[0]);
fulladd f401(sum4[2],carry4[1],carry2[2],p6[1],p7[0]);
fulladd f402(sum4[3],carry4[2],carry2[3],p6[2],p7[1]);
fulladd f403(sum4[4],carry4[3],carry2[4],p6[3],p7[2]);
fulladd f404(sum4[5],carry4[4],carry2[5],p6[4],p7[3]);
fulladd f405(sum4[6],carry4[5],carry2[6],p6[5],p7[4]);
fulladd f406(sum4[7],carry4[6],carry2[7],p6[6],p7[5]);
fulladd f407(sum4[8],carry4[7],carry2[8],p6[7],p7[6]);
fulladd f408(sum4[9],carry4[8],carry2[9],p6[8],p7[7]);
fulladd f409(sum4[10],carry4[9],carry2[10],p6[9],p7[8]);
fulladd f410(sum4[11],carry4[10],carry2[11],p6[10],p7[9]);
fulladd f411(sum4[12],carry4[11],carry2[12],p6[11],p7[10]);
fulladd f412(sum4[13],carry4[12],carry2[13],p6[12],p7[11]);
fulladd f413(sum4[14],carry4[13],carry2[14],p6[13],p7[12]);
fulladd f414(sum4[15],carry4[14],carry2[15],p6[14],p7[13]);
fulladd f415(sum4[16],carry4[15],carry2[16],p6[15],p7[14]);
fulladd f416(sum4[17],carry4[16],carry2[17],p6[16],p7[15]);
fulladd f417(sum4[18],carry4[17],carry2[18],p6[17],p7[16]);
fulladd f418(sum4[19],carry4[18],carry2[19],p6[18],p7[17]);
fulladd f419(sum4[20],carry4[19],carry2[20],p6[19],p7[18]);
fulladd f420(sum4[21],carry4[20],carry2[21],p6[20],p7[19]);
fulladd f421(sum4[22],carry4[21],carry2[22],p6[21],p7[20]);
fulladd f422(sum4[23],carry4[22],carry2[23],p6[22],p7[21]);
halfadd h415(sum4[24],carry4[23],p6[23],p7[22]);
assign sum4[25]=p7[23];

//csa5

assign sum5[2:0]=sum3[2:0];
halfadd h500(sum5[3],carry5[0],sum3[3],carry3[0]);
halfadd h501(sum5[4],carry5[1],sum3[4],carry3[1]);
fulladd f502(sum5[5],carry5[2],sum3[5],carry3[2],sum4[0]);
fulladd f503(sum5[6],carry5[3],sum3[6],carry3[3],sum4[1]);
fulladd f504(sum5[7],carry5[4],sum3[7],carry3[4],sum4[2]);
fulladd f505(sum5[8],carry5[5],sum3[8],carry3[5],sum4[3]);
fulladd f506(sum5[9],carry5[6],sum3[9],carry3[6],sum4[4]);
fulladd f507(sum5[10],carry5[7],sum3[10],carry3[7],sum4[5]);
fulladd f508(sum5[11],carry5[8],sum3[11],carry3[8],sum4[6]);
fulladd f509(sum5[12],carry5[9],sum3[12],carry3[9],sum4[7]);
fulladd f510(sum5[13],carry5[10],sum3[13],carry3[10],sum4[8]);
fulladd f511(sum5[14],carry5[11],sum3[14],carry3[11],sum4[9]);
fulladd f512(sum5[15],carry5[12],sum3[15],carry3[12],sum4[10]);
fulladd f513(sum5[16],carry5[13],sum3[16],carry3[13],sum4[11]);
fulladd f514(sum5[17],carry5[14],sum3[17],carry3[14],sum4[12]);
fulladd f515(sum5[18],carry5[15],sum3[18],carry3[15],sum4[13]);
fulladd f516(sum5[19],carry5[16],sum3[19],carry3[16],sum4[14]);
fulladd f517(sum5[20],carry5[17],sum3[20],carry3[17],sum4[15]);
fulladd f518(sum5[21],carry5[18],sum3[21],carry3[18],sum4[16]);
fulladd f519(sum5[22],carry5[19],sum3[22],carry3[19],sum4[17]);
fulladd f520(sum5[23],carry5[20],sum3[23],carry3[20],sum4[18]);
fulladd f521(sum5[24],carry5[21],sum3[24],carry3[21],sum4[19]);
fulladd f522(sum5[25],carry5[22],sum3[25],carry3[22],sum4[20]);
fulladd f523(sum5[26],carry5[23],sum3[26],carry3[23],sum4[21]);
halfadd h516(sum5[27],carry5[24],sum3[27],sum4[22]);
halfadd h517(sum5[28],carry5[25],sum3[28],sum4[23]);
assign sum5[30:29]=sum4[25:24];

//csa6

assign sum6[3:0]=sum5[3:0];
halfadd h600(sum6[4],carry6[0],sum5[4],carry5[0]);
halfadd h601(sum6[5],carry6[1],sum5[5],carry5[1]);
halfadd h602(sum6[6],carry6[2],sum5[6],carry5[2]);
fulladd f600(sum6[7],carry6[3],sum5[7],carry5[3],carry4[0]);
fulladd f601(sum6[8],carry6[4],sum5[8],carry5[4],carry4[1]);
fulladd f602(sum6[9],carry6[5],sum5[9],carry5[5],carry4[2]);
fulladd f603(sum6[10],carry6[6],sum5[10],carry5[6],carry4[3]);
fulladd f604(sum6[11],carry6[7],sum5[11],carry5[7],carry4[4]);
fulladd f605(sum6[12],carry6[8],sum5[12],carry5[8],carry4[5]);
fulladd f606(sum6[13],carry6[9],sum5[13],carry5[9],carry4[6]);
fulladd f607(sum6[14],carry6[10],sum5[14],carry5[10],carry4[7]);
fulladd f608(sum6[15],carry6[11],sum5[15],carry5[11],carry4[8]);
fulladd f609(sum6[16],carry6[12],sum5[16],carry5[12],carry4[9]);
fulladd f610(sum6[17],carry6[13],sum5[17],carry5[13],carry4[10]);
fulladd f611(sum6[18],carry6[14],sum5[18],carry5[14],carry4[11]);
fulladd f612(sum6[19],carry6[15],sum5[19],carry5[15],carry4[12]);
fulladd f613(sum6[20],carry6[16],sum5[20],carry5[16],carry4[13]);
fulladd f614(sum6[21],carry6[17],sum5[21],carry5[17],carry4[14]);
fulladd f615(sum6[22],carry6[18],sum5[22],carry5[18],carry4[15]);
fulladd f616(sum6[23],carry6[19],sum5[23],carry5[19],carry4[16]);
fulladd f617(sum6[24],carry6[20],sum5[24],carry5[20],carry4[17]);
fulladd f618(sum6[25],carry6[21],sum5[25],carry5[21],carry4[18]);
fulladd f619(sum6[26],carry6[22],sum5[26],carry5[22],carry4[19]);
fulladd f620(sum6[27],carry6[23],sum5[27],carry5[23],carry4[20]);
fulladd f621(sum6[28],carry6[24],sum5[28],carry5[24],carry4[21]);
fulladd f622(sum6[29],carry6[25],sum5[29],carry5[25],carry4[22]);
halfadd h603(sum6[30],carry6[26],sum5[30],carry4[23]);
assign r[4:0]=sum6[4:0];

wire co;

recurse27 r27(r[31:5],co,{1'b0,sum6[30:5]},carry6); 

endmodule

// half Adder Module
module halfadd(sum, carry, x,y);

output sum,carry;
input x,y;

	assign	 sum = x ^ y;
	assign 	 carry = x & y;
	
endmodule

// Full Adder Module
module fulladd(sum, carry, x,y,z);

output sum,carry;
input x,y,z;

wire w;	
	assign 	 w = x ^ y;
        assign	 sum = w ^ z;
	assign 	 carry = (x & y)|(w & z);
endmodule

//27 bit recursive doubling technique

module recurse27(sum,carry,a,b); 

output [26:0] sum;
output  carry;
input [26:0] a,b;

wire [55:0] x;

assign x[1:0]=2'b00;  // kgp generation

kgp a00(a[0],b[0],x[3:2]);
kgp a01(a[1],b[1],x[5:4]);
kgp a02(a[2],b[2],x[7:6]);
kgp a03(a[3],b[3],x[9:8]);
kgp a04(a[4],b[4],x[11:10]);
kgp a05(a[5],b[5],x[13:12]);
kgp a06(a[6],b[6],x[15:14]);
kgp a07(a[7],b[7],x[17:16]);
kgp a08(a[8],b[8],x[19:18]);
kgp a09(a[9],b[9],x[21:20]);
kgp a10(a[10],b[10],x[23:22]);
kgp a11(a[11],b[11],x[25:24]);
kgp a12(a[12],b[12],x[27:26]);
kgp a13(a[13],b[13],x[29:28]);
kgp a14(a[14],b[14],x[31:30]);
kgp a15(a[15],b[15],x[33:32]);
kgp a16(a[16],b[16],x[35:34]);
kgp a17(a[17],b[17],x[37:36]);
kgp a18(a[18],b[18],x[39:38]);
kgp a19(a[19],b[19],x[41:40]);
kgp a20(a[20],b[20],x[43:42]);
kgp a21(a[21],b[21],x[45:44]);
kgp a22(a[22],b[22],x[47:46]);
kgp a23(a[23],b[23],x[49:48]);
kgp a24(a[24],b[24],x[51:50]);
kgp a25(a[25],b[25],x[53:52]);
kgp a26(a[26],b[26],x[55:54]);

wire [53:0] x1;  //recursive doubling stage 1
assign x1[1:0]=x[1:0];

recursive_stage1 s00(x[1:0],x[3:2],x1[3:2]);
recursive_stage1 s01(x[3:2],x[5:4],x1[5:4]);
recursive_stage1 s02(x[5:4],x[7:6],x1[7:6]);
recursive_stage1 s03(x[7:6],x[9:8],x1[9:8]);
recursive_stage1 s04(x[9:8],x[11:10],x1[11:10]);
recursive_stage1 s05(x[11:10],x[13:12],x1[13:12]);
recursive_stage1 s06(x[13:12],x[15:14],x1[15:14]);
recursive_stage1 s07(x[15:14],x[17:16],x1[17:16]);
recursive_stage1 s08(x[17:16],x[19:18],x1[19:18]);
recursive_stage1 s09(x[19:18],x[21:20],x1[21:20]);
recursive_stage1 s10(x[21:20],x[23:22],x1[23:22]);
recursive_stage1 s11(x[23:22],x[25:24],x1[25:24]);
recursive_stage1 s12(x[25:24],x[27:26],x1[27:26]);
recursive_stage1 s13(x[27:26],x[29:28],x1[29:28]);
recursive_stage1 s14(x[29:28],x[31:30],x1[31:30]);
recursive_stage1 s15(x[31:30],x[33:32],x1[33:32]);
recursive_stage1 s16(x[33:32],x[35:34],x1[35:34]);
recursive_stage1 s17(x[35:34],x[37:36],x1[37:36]);
recursive_stage1 s18(x[37:36],x[39:38],x1[39:38]);
recursive_stage1 s19(x[39:38],x[41:40],x1[41:40]);
recursive_stage1 s20(x[41:40],x[43:42],x1[43:42]);
recursive_stage1 s21(x[43:42],x[45:44],x1[45:44]);
recursive_stage1 s22(x[45:44],x[47:46],x1[47:46]);
recursive_stage1 s23(x[47:46],x[49:48],x1[49:48]);
recursive_stage1 s24(x[49:48],x[51:50],x1[51:50]);
recursive_stage1 s25(x[51:50],x[53:52],x1[53:52]);

wire [53:0] x2;  //recursive doubling stage2
assign x2[3:0]=x1[3:0];

recursive_stage1 s101(x1[1:0],x1[5:4],x2[5:4]);
recursive_stage1 s102(x1[3:2],x1[7:6],x2[7:6]);
recursive_stage1 s103(x1[5:4],x1[9:8],x2[9:8]);
recursive_stage1 s104(x1[7:6],x1[11:10],x2[11:10]);
recursive_stage1 s105(x1[9:8],x1[13:12],x2[13:12]);
recursive_stage1 s106(x1[11:10],x1[15:14],x2[15:14]);
recursive_stage1 s107(x1[13:12],x1[17:16],x2[17:16]);
recursive_stage1 s108(x1[15:14],x1[19:18],x2[19:18]);
recursive_stage1 s109(x1[17:16],x1[21:20],x2[21:20]);
recursive_stage1 s110(x1[19:18],x1[23:22],x2[23:22]);
recursive_stage1 s111(x1[21:20],x1[25:24],x2[25:24]);
recursive_stage1 s112(x1[23:22],x1[27:26],x2[27:26]);
recursive_stage1 s113(x1[25:24],x1[29:28],x2[29:28]);
recursive_stage1 s114(x1[27:26],x1[31:30],x2[31:30]);
recursive_stage1 s115(x1[29:28],x1[33:32],x2[33:32]);
recursive_stage1 s116(x1[31:30],x1[35:34],x2[35:34]);
recursive_stage1 s117(x1[33:32],x1[37:36],x2[37:36]);
recursive_stage1 s118(x1[35:34],x1[39:38],x2[39:38]);
recursive_stage1 s119(x1[37:36],x1[41:40],x2[41:40]);
recursive_stage1 s120(x1[39:38],x1[43:42],x2[43:42]);
recursive_stage1 s121(x1[41:40],x1[45:44],x2[45:44]);
recursive_stage1 s122(x1[43:42],x1[47:46],x2[47:46]);
recursive_stage1 s123(x1[45:44],x1[49:48],x2[49:48]);
recursive_stage1 s124(x1[47:46],x1[51:50],x2[51:50]);
recursive_stage1 s125(x1[49:48],x1[53:52],x2[53:52]);

wire [53:0] x3;  //recursive doubling stage3
assign x3[7:0]=x2[7:0];

recursive_stage1 s203(x2[1:0],x2[9:8],x3[9:8]);
recursive_stage1 s204(x2[3:2],x2[11:10],x3[11:10]);
recursive_stage1 s205(x2[5:4],x2[13:12],x3[13:12]);
recursive_stage1 s206(x2[7:6],x2[15:14],x3[15:14]);
recursive_stage1 s207(x2[9:8],x2[17:16],x3[17:16]);
recursive_stage1 s208(x2[11:10],x2[19:18],x3[19:18]);
recursive_stage1 s209(x2[13:12],x2[21:20],x3[21:20]);
recursive_stage1 s210(x2[15:14],x2[23:22],x3[23:22]);
recursive_stage1 s211(x2[17:16],x2[25:24],x3[25:24]);
recursive_stage1 s212(x2[19:18],x2[27:26],x3[27:26]);
recursive_stage1 s213(x2[21:20],x2[29:28],x3[29:28]);
recursive_stage1 s214(x2[23:22],x2[31:30],x3[31:30]);
recursive_stage1 s215(x2[25:24],x2[33:32],x3[33:32]);
recursive_stage1 s216(x2[27:26],x2[35:34],x3[35:34]);
recursive_stage1 s217(x2[29:28],x2[37:36],x3[37:36]);
recursive_stage1 s218(x2[31:30],x2[39:38],x3[39:38]);
recursive_stage1 s219(x2[33:32],x2[41:40],x3[41:40]);
recursive_stage1 s220(x2[35:34],x2[43:42],x3[43:42]);
recursive_stage1 s221(x2[37:36],x2[45:44],x3[45:44]);
recursive_stage1 s222(x2[39:38],x2[47:46],x3[47:46]);
recursive_stage1 s223(x2[41:40],x2[49:48],x3[49:48]);
recursive_stage1 s224(x2[43:42],x2[51:50],x3[51:50]);
recursive_stage1 s225(x2[45:44],x2[53:52],x3[53:52]);

wire [53:0] x4;  //recursive doubling stage 4
assign x4[15:0]=x3[15:0];

recursive_stage1 s307(x3[1:0],x3[17:16],x4[17:16]);
recursive_stage1 s308(x3[3:2],x3[19:18],x4[19:18]);
recursive_stage1 s309(x3[5:4],x3[21:20],x4[21:20]);
recursive_stage1 s310(x3[7:6],x3[23:22],x4[23:22]);
recursive_stage1 s311(x3[9:8],x3[25:24],x4[25:24]);
recursive_stage1 s312(x3[11:10],x3[27:26],x4[27:26]);
recursive_stage1 s313(x3[13:12],x3[29:28],x4[29:28]);
recursive_stage1 s314(x3[15:14],x3[31:30],x4[31:30]);
recursive_stage1 s315(x3[17:16],x3[33:32],x4[33:32]);
recursive_stage1 s316(x3[19:18],x3[35:34],x4[35:34]);
recursive_stage1 s317(x3[21:20],x3[37:36],x4[37:36]);
recursive_stage1 s318(x3[23:22],x3[39:38],x4[39:38]);
recursive_stage1 s319(x3[25:24],x3[41:40],x4[41:40]);
recursive_stage1 s320(x3[27:26],x3[43:42],x4[43:42]);
recursive_stage1 s321(x3[29:28],x3[45:44],x4[45:44]);
recursive_stage1 s322(x3[31:30],x3[47:46],x4[47:46]);
recursive_stage1 s323(x3[33:32],x3[49:48],x4[49:48]);
recursive_stage1 s324(x3[35:34],x3[51:50],x4[51:50]);
recursive_stage1 s325(x3[37:36],x3[53:52],x4[53:52]);

wire [53:0] x5;  //recursive doubling stage 5
assign x5[31:0]=x4[31:0];

recursive_stage1 s415(x4[1:0],x4[33:32],x5[33:32]);
recursive_stage1 s416(x4[3:2],x4[35:34],x5[35:34]);
recursive_stage1 s417(x4[5:4],x4[37:36],x5[37:36]);
recursive_stage1 s418(x4[7:6],x4[39:38],x5[39:38]);
recursive_stage1 s419(x4[9:8],x4[41:40],x5[41:40]);
recursive_stage1 s420(x4[11:10],x4[43:42],x5[43:42]);
recursive_stage1 s421(x4[13:12],x4[45:44],x5[45:44]);
recursive_stage1 s422(x4[15:14],x4[47:46],x5[47:46]);
recursive_stage1 s423(x4[17:16],x4[49:48],x5[49:48]);
recursive_stage1 s424(x4[19:18],x4[51:50],x5[51:50]);
recursive_stage1 s425(x4[21:20],x4[53:52],x5[53:52]);

 // final sum and carry

assign sum[0]=a[0]^b[0]^x5[0];
assign sum[1]=a[1]^b[1]^x5[2];
assign sum[2]=a[2]^b[2]^x5[4];
assign sum[3]=a[3]^b[3]^x5[6];
assign sum[4]=a[4]^b[4]^x5[8];
assign sum[5]=a[5]^b[5]^x5[10];
assign sum[6]=a[6]^b[6]^x5[12];
assign sum[7]=a[7]^b[7]^x5[14];
assign sum[8]=a[8]^b[8]^x5[16];
assign sum[9]=a[9]^b[9]^x5[18];
assign sum[10]=a[10]^b[10]^x5[20];
assign sum[11]=a[11]^b[11]^x5[22];
assign sum[12]=a[12]^b[12]^x5[24];
assign sum[13]=a[13]^b[13]^x5[26];
assign sum[14]=a[14]^b[14]^x5[28];
assign sum[15]=a[15]^b[15]^x5[30];
assign sum[16]=a[16]^b[16]^x5[32];
assign sum[17]=a[17]^b[17]^x5[34];
assign sum[18]=a[18]^b[18]^x5[36];
assign sum[19]=a[19]^b[19]^x5[38];
assign sum[20]=a[20]^b[20]^x5[40];
assign sum[21]=a[21]^b[21]^x5[42];
assign sum[22]=a[22]^b[22]^x5[44];
assign sum[23]=a[23]^b[23]^x5[46];
assign sum[24]=a[24]^b[24]^x5[48];
assign sum[25]=a[25]^b[25]^x5[50];
assign sum[26]=a[26]^b[26]^x5[52];
kgp_carry kkc(x[55:54],x5[53:52],carry);

endmodule


module kgp(a,b,y);

input a,b;
output [1:0] y;
//reg [1:0] y;

//always@(a or b)
//begin
//case({a,b})
//2'b00:y=2'b00;  //kill
//2'b11:y=2'b11;	  //generate
//2'b01:y=2'b01;	//propagate
//2'b10:y=2'b01;  //propagate
//endcase   //y[1]=ab  y[0]=a+b  
//end

assign y[0]=a | b;
assign y[1]=a & b;

endmodule


module recursive_stage1(a,b,y);

input [1:0] a,b;
output [1:0] y;

wire [1:0] y;
wire b0;
not n1(b0,b[1]);
wire f,g0,g1;
and a1(f,b[0],b[1]);
and a2(g0,b0,b[0],a[0]);
and a3(g1,b0,b[0],a[1]);

or o1(y[0],f,g0);
or o2(y[1],f,g1);

//reg [1:0] y;
//always@(a or b)
//begin
//case(b)
//2'b00:y=2'b00;  
//2'b11:y=2'b11;
//2'b01:y=a;
//default:y=2'bx;
//endcase
//end

//always@(a or b)
//begin
//if(b==2'b00)
//	y=2'b00;  
//else if (b==2'b11)
//	y=2'b11;
//else if (b==2'b01)
//	y=a;
//end

//wire x;
//assign x=a[0] ^ b[0];
//always@(a or b or x)
//begin
//case(x)
//1'b0:y[0]=b[0];  
//1'b1:y[0]=a[0]; 
//endcase
//end
//
//always@(a or b or x)
//begin
//case(x)
//1'b0:y[1]=b[1];  
//1'b1:y[1]=a[1];
//endcase
//end


//always@(a or b)
//begin
//if (b==2'b00)
//	y=2'b00; 
//else if (b==2'b11)	
//	y=2'b11;
//else if (b==2'b01 && a==2'b00)
//	y=2'b00;
//else if (b==2'b01 && a==2'b11)
//	y=2'b11;
//else if (b==2'b01 && a==2'b01)
//	y=2'b01;
//end

endmodule


module kgp_carry(a,b,carry);

input [1:0] a,b;
output carry;
reg carry;

always@(a or b)
begin
case(a)
2'b00:carry=1'b0;  
2'b11:carry=1'b1;
2'b01:carry=b[0];
2'b10:carry=b[0];
default:carry=1'bx;
endcase
end

/*wire carry;

wire f,g;
assign g=a[0] & a[1];
assign f=a[0] ^ a[1];

assign carry=g|(b[0] & f);*/

endmodule

//mux 5to1

module mux5to1(a,b,c,d,e,out,sel);

input a,b,c,d,e;
input [2:0] sel;
output out;

reg out;

always@(a or b or c or d or e or sel)
begin
case(sel)
3'b000:out=a;  
3'b001:out=b;
3'b010:out=c;	
3'b011:out=d;  
3'b100:out=e;
endcase   
end

endmodule

//mux 5to1

module mux5_35(a,b,c,d,e,out,sel);

input [34:0] a,b,c,d,e;
input [2:0] sel;
output [34:0] out;

reg [34:0] out;

always@(a or b or c or d or e or sel)
begin
case(sel)
3'b000:out=a;  
3'b001:out=b;
3'b010:out=c;	
3'b011:out=d;  
3'b100:out=e;
endcase   
end

endmodule

//35 bit recursive doubling technique

module recurse35(sum,carry,a,b); 

output [34:0] sum;
output  carry;
input [34:0] a,b;

wire [71:0] x;

assign x[1:0]=2'b00;  // kgp generation

kgp a00(a[0],b[0],x[3:2]);
kgp a01(a[1],b[1],x[5:4]);
kgp a02(a[2],b[2],x[7:6]);
kgp a03(a[3],b[3],x[9:8]);
kgp a04(a[4],b[4],x[11:10]);
kgp a05(a[5],b[5],x[13:12]);
kgp a06(a[6],b[6],x[15:14]);
kgp a07(a[7],b[7],x[17:16]);
kgp a08(a[8],b[8],x[19:18]);
kgp a09(a[9],b[9],x[21:20]);
kgp a10(a[10],b[10],x[23:22]);
kgp a11(a[11],b[11],x[25:24]);
kgp a12(a[12],b[12],x[27:26]);
kgp a13(a[13],b[13],x[29:28]);
kgp a14(a[14],b[14],x[31:30]);
kgp a15(a[15],b[15],x[33:32]);
kgp a16(a[16],b[16],x[35:34]);
kgp a17(a[17],b[17],x[37:36]);
kgp a18(a[18],b[18],x[39:38]);
kgp a19(a[19],b[19],x[41:40]);
kgp a20(a[20],b[20],x[43:42]);
kgp a21(a[21],b[21],x[45:44]);
kgp a22(a[22],b[22],x[47:46]);
kgp a23(a[23],b[23],x[49:48]);
kgp a24(a[24],b[24],x[51:50]);
kgp a25(a[25],b[25],x[53:52]);
kgp a26(a[26],b[26],x[55:54]);
kgp a27(a[27],b[27],x[57:56]);
kgp a28(a[28],b[28],x[59:58]);
kgp a29(a[29],b[29],x[61:60]);
kgp a30(a[30],b[30],x[63:62]);
kgp a31(a[31],b[31],x[65:64]);
kgp a32(a[32],b[32],x[67:66]);
kgp a33(a[33],b[33],x[69:68]);
kgp a34(a[34],b[34],x[71:70]);

wire [69:0] x1;  //recursive doubling stage 1
assign x1[1:0]=x[1:0];

recursive_stage1 s00(x[1:0],x[3:2],x1[3:2]);
recursive_stage1 s01(x[3:2],x[5:4],x1[5:4]);
recursive_stage1 s02(x[5:4],x[7:6],x1[7:6]);
recursive_stage1 s03(x[7:6],x[9:8],x1[9:8]);
recursive_stage1 s04(x[9:8],x[11:10],x1[11:10]);
recursive_stage1 s05(x[11:10],x[13:12],x1[13:12]);
recursive_stage1 s06(x[13:12],x[15:14],x1[15:14]);
recursive_stage1 s07(x[15:14],x[17:16],x1[17:16]);
recursive_stage1 s08(x[17:16],x[19:18],x1[19:18]);
recursive_stage1 s09(x[19:18],x[21:20],x1[21:20]);
recursive_stage1 s10(x[21:20],x[23:22],x1[23:22]);
recursive_stage1 s11(x[23:22],x[25:24],x1[25:24]);
recursive_stage1 s12(x[25:24],x[27:26],x1[27:26]);
recursive_stage1 s13(x[27:26],x[29:28],x1[29:28]);
recursive_stage1 s14(x[29:28],x[31:30],x1[31:30]);
recursive_stage1 s15(x[31:30],x[33:32],x1[33:32]);
recursive_stage1 s16(x[33:32],x[35:34],x1[35:34]);
recursive_stage1 s17(x[35:34],x[37:36],x1[37:36]);
recursive_stage1 s18(x[37:36],x[39:38],x1[39:38]);
recursive_stage1 s19(x[39:38],x[41:40],x1[41:40]);
recursive_stage1 s20(x[41:40],x[43:42],x1[43:42]);
recursive_stage1 s21(x[43:42],x[45:44],x1[45:44]);
recursive_stage1 s22(x[45:44],x[47:46],x1[47:46]);
recursive_stage1 s23(x[47:46],x[49:48],x1[49:48]);
recursive_stage1 s24(x[49:48],x[51:50],x1[51:50]);
recursive_stage1 s25(x[51:50],x[53:52],x1[53:52]);
recursive_stage1 s26(x[53:52],x[55:54],x1[55:54]);
recursive_stage1 s27(x[55:54],x[57:56],x1[57:56]);
recursive_stage1 s28(x[57:56],x[59:58],x1[59:58]);
recursive_stage1 s29(x[59:58],x[61:60],x1[61:60]);
recursive_stage1 s30(x[61:60],x[63:62],x1[63:62]);
recursive_stage1 s31(x[63:62],x[65:64],x1[65:64]);
recursive_stage1 s32(x[65:64],x[67:66],x1[67:66]);
recursive_stage1 s33(x[67:66],x[69:68],x1[69:68]);

wire [69:0] x2;  //recursive doubling stage2
assign x2[3:0]=x1[3:0];

recursive_stage1 s101(x1[1:0],x1[5:4],x2[5:4]);
recursive_stage1 s102(x1[3:2],x1[7:6],x2[7:6]);
recursive_stage1 s103(x1[5:4],x1[9:8],x2[9:8]);
recursive_stage1 s104(x1[7:6],x1[11:10],x2[11:10]);
recursive_stage1 s105(x1[9:8],x1[13:12],x2[13:12]);
recursive_stage1 s106(x1[11:10],x1[15:14],x2[15:14]);
recursive_stage1 s107(x1[13:12],x1[17:16],x2[17:16]);
recursive_stage1 s108(x1[15:14],x1[19:18],x2[19:18]);
recursive_stage1 s109(x1[17:16],x1[21:20],x2[21:20]);
recursive_stage1 s110(x1[19:18],x1[23:22],x2[23:22]);
recursive_stage1 s111(x1[21:20],x1[25:24],x2[25:24]);
recursive_stage1 s112(x1[23:22],x1[27:26],x2[27:26]);
recursive_stage1 s113(x1[25:24],x1[29:28],x2[29:28]);
recursive_stage1 s114(x1[27:26],x1[31:30],x2[31:30]);
recursive_stage1 s115(x1[29:28],x1[33:32],x2[33:32]);
recursive_stage1 s116(x1[31:30],x1[35:34],x2[35:34]);
recursive_stage1 s117(x1[33:32],x1[37:36],x2[37:36]);
recursive_stage1 s118(x1[35:34],x1[39:38],x2[39:38]);
recursive_stage1 s119(x1[37:36],x1[41:40],x2[41:40]);
recursive_stage1 s120(x1[39:38],x1[43:42],x2[43:42]);
recursive_stage1 s121(x1[41:40],x1[45:44],x2[45:44]);
recursive_stage1 s122(x1[43:42],x1[47:46],x2[47:46]);
recursive_stage1 s123(x1[45:44],x1[49:48],x2[49:48]);
recursive_stage1 s124(x1[47:46],x1[51:50],x2[51:50]);
recursive_stage1 s125(x1[49:48],x1[53:52],x2[53:52]);
recursive_stage1 s126(x1[51:50],x1[55:54],x2[55:54]);
recursive_stage1 s127(x1[53:52],x1[57:56],x2[57:56]);
recursive_stage1 s128(x1[55:54],x1[59:58],x2[59:58]);
recursive_stage1 s129(x1[57:56],x1[61:60],x2[61:60]);
recursive_stage1 s130(x1[59:58],x1[63:62],x2[63:62]);
recursive_stage1 s131(x1[61:60],x1[65:64],x2[65:64]);
recursive_stage1 s132(x1[63:62],x1[67:66],x2[67:66]);
recursive_stage1 s133(x1[65:64],x1[69:68],x2[69:68]);

wire [69:0] x3;  //recursive doubling stage3
assign x3[7:0]=x2[7:0];

recursive_stage1 s203(x2[1:0],x2[9:8],x3[9:8]);
recursive_stage1 s204(x2[3:2],x2[11:10],x3[11:10]);
recursive_stage1 s205(x2[5:4],x2[13:12],x3[13:12]);
recursive_stage1 s206(x2[7:6],x2[15:14],x3[15:14]);
recursive_stage1 s207(x2[9:8],x2[17:16],x3[17:16]);
recursive_stage1 s208(x2[11:10],x2[19:18],x3[19:18]);
recursive_stage1 s209(x2[13:12],x2[21:20],x3[21:20]);
recursive_stage1 s210(x2[15:14],x2[23:22],x3[23:22]);
recursive_stage1 s211(x2[17:16],x2[25:24],x3[25:24]);
recursive_stage1 s212(x2[19:18],x2[27:26],x3[27:26]);
recursive_stage1 s213(x2[21:20],x2[29:28],x3[29:28]);
recursive_stage1 s214(x2[23:22],x2[31:30],x3[31:30]);
recursive_stage1 s215(x2[25:24],x2[33:32],x3[33:32]);
recursive_stage1 s216(x2[27:26],x2[35:34],x3[35:34]);
recursive_stage1 s217(x2[29:28],x2[37:36],x3[37:36]);
recursive_stage1 s218(x2[31:30],x2[39:38],x3[39:38]);
recursive_stage1 s219(x2[33:32],x2[41:40],x3[41:40]);
recursive_stage1 s220(x2[35:34],x2[43:42],x3[43:42]);
recursive_stage1 s221(x2[37:36],x2[45:44],x3[45:44]);
recursive_stage1 s222(x2[39:38],x2[47:46],x3[47:46]);
recursive_stage1 s223(x2[41:40],x2[49:48],x3[49:48]);
recursive_stage1 s224(x2[43:42],x2[51:50],x3[51:50]);
recursive_stage1 s225(x2[45:44],x2[53:52],x3[53:52]);
recursive_stage1 s226(x2[47:46],x2[55:54],x3[55:54]);
recursive_stage1 s227(x2[49:48],x2[57:56],x3[57:56]);
recursive_stage1 s228(x2[51:50],x2[59:58],x3[59:58]);
recursive_stage1 s229(x2[53:52],x2[61:60],x3[61:60]);
recursive_stage1 s230(x2[55:54],x2[63:62],x3[63:62]);
recursive_stage1 s231(x2[57:56],x2[65:64],x3[65:64]);
recursive_stage1 s232(x2[59:58],x2[67:66],x3[67:66]);
recursive_stage1 s233(x2[61:60],x2[69:68],x3[69:68]);

wire [69:0] x4;  //recursive doubling stage 4
assign x4[15:0]=x3[15:0];

recursive_stage1 s307(x3[1:0],x3[17:16],x4[17:16]);
recursive_stage1 s308(x3[3:2],x3[19:18],x4[19:18]);
recursive_stage1 s309(x3[5:4],x3[21:20],x4[21:20]);
recursive_stage1 s310(x3[7:6],x3[23:22],x4[23:22]);
recursive_stage1 s311(x3[9:8],x3[25:24],x4[25:24]);
recursive_stage1 s312(x3[11:10],x3[27:26],x4[27:26]);
recursive_stage1 s313(x3[13:12],x3[29:28],x4[29:28]);
recursive_stage1 s314(x3[15:14],x3[31:30],x4[31:30]);
recursive_stage1 s315(x3[17:16],x3[33:32],x4[33:32]);
recursive_stage1 s316(x3[19:18],x3[35:34],x4[35:34]);
recursive_stage1 s317(x3[21:20],x3[37:36],x4[37:36]);
recursive_stage1 s318(x3[23:22],x3[39:38],x4[39:38]);
recursive_stage1 s319(x3[25:24],x3[41:40],x4[41:40]);
recursive_stage1 s320(x3[27:26],x3[43:42],x4[43:42]);
recursive_stage1 s321(x3[29:28],x3[45:44],x4[45:44]);
recursive_stage1 s322(x3[31:30],x3[47:46],x4[47:46]);
recursive_stage1 s323(x3[33:32],x3[49:48],x4[49:48]);
recursive_stage1 s324(x3[35:34],x3[51:50],x4[51:50]);
recursive_stage1 s325(x3[37:36],x3[53:52],x4[53:52]);
recursive_stage1 s326(x3[39:38],x3[55:54],x4[55:54]);
recursive_stage1 s327(x3[41:40],x3[57:56],x4[57:56]);
recursive_stage1 s328(x3[43:42],x3[59:58],x4[59:58]);
recursive_stage1 s329(x3[45:44],x3[61:60],x4[61:60]);
recursive_stage1 s330(x3[47:46],x3[63:62],x4[63:62]);
recursive_stage1 s331(x3[49:48],x3[65:64],x4[65:64]);
recursive_stage1 s332(x3[51:50],x3[67:66],x4[67:66]);
recursive_stage1 s333(x3[53:52],x3[69:68],x4[69:68]);

wire [69:0] x5;  //recursive doubling stage 5
assign x5[31:0]=x4[31:0];

recursive_stage1 s415(x4[1:0],x4[33:32],x5[33:32]);
recursive_stage1 s416(x4[3:2],x4[35:34],x5[35:34]);
recursive_stage1 s417(x4[5:4],x4[37:36],x5[37:36]);
recursive_stage1 s418(x4[7:6],x4[39:38],x5[39:38]);
recursive_stage1 s419(x4[9:8],x4[41:40],x5[41:40]);
recursive_stage1 s420(x4[11:10],x4[43:42],x5[43:42]);
recursive_stage1 s421(x4[13:12],x4[45:44],x5[45:44]);
recursive_stage1 s422(x4[15:14],x4[47:46],x5[47:46]);
recursive_stage1 s423(x4[17:16],x4[49:48],x5[49:48]);
recursive_stage1 s424(x4[19:18],x4[51:50],x5[51:50]);
recursive_stage1 s425(x4[21:20],x4[53:52],x5[53:52]);
recursive_stage1 s426(x4[23:22],x4[55:54],x5[55:54]);
recursive_stage1 s427(x4[25:24],x4[57:56],x5[57:56]);
recursive_stage1 s428(x4[27:26],x4[59:58],x5[59:58]);
recursive_stage1 s429(x4[29:28],x4[61:60],x5[61:60]);
recursive_stage1 s430(x4[31:30],x4[63:62],x5[63:62]);
recursive_stage1 s431(x4[33:32],x4[65:64],x5[65:64]);
recursive_stage1 s432(x4[35:34],x4[67:66],x5[67:66]);
recursive_stage1 s433(x4[37:36],x4[69:68],x5[69:68]);

wire [69:0] x6;  // recursive doubling stage 6
assign x6[63:0]=x5[63:0];

recursive_stage1 s531(x5[1:0],x5[65:64],x6[65:64]);
recursive_stage1 s532(x5[3:2],x5[67:66],x6[67:66]);
recursive_stage1 s533(x5[5:4],x5[69:68],x6[69:68]);

// final sum and carry

assign sum[0]=a[0]^b[0]^x6[0];
assign sum[1]=a[1]^b[1]^x6[2];
assign sum[2]=a[2]^b[2]^x6[4];
assign sum[3]=a[3]^b[3]^x6[6];
assign sum[4]=a[4]^b[4]^x6[8];
assign sum[5]=a[5]^b[5]^x6[10];
assign sum[6]=a[6]^b[6]^x6[12];
assign sum[7]=a[7]^b[7]^x6[14];
assign sum[8]=a[8]^b[8]^x6[16];
assign sum[9]=a[9]^b[9]^x6[18];
assign sum[10]=a[10]^b[10]^x6[20];
assign sum[11]=a[11]^b[11]^x6[22];
assign sum[12]=a[12]^b[12]^x6[24];
assign sum[13]=a[13]^b[13]^x6[26];
assign sum[14]=a[14]^b[14]^x6[28];
assign sum[15]=a[15]^b[15]^x6[30];
assign sum[16]=a[16]^b[16]^x6[32];
assign sum[17]=a[17]^b[17]^x6[34];
assign sum[18]=a[18]^b[18]^x6[36];
assign sum[19]=a[19]^b[19]^x6[38];
assign sum[20]=a[20]^b[20]^x6[40];
assign sum[21]=a[21]^b[21]^x6[42];
assign sum[22]=a[22]^b[22]^x6[44];
assign sum[23]=a[23]^b[23]^x6[46];
assign sum[24]=a[24]^b[24]^x6[48];
assign sum[25]=a[25]^b[25]^x6[50];
assign sum[26]=a[26]^b[26]^x6[52];
assign sum[27]=a[27]^b[27]^x6[54];
assign sum[28]=a[28]^b[28]^x6[56];
assign sum[29]=a[29]^b[29]^x6[58];
assign sum[30]=a[30]^b[30]^x6[60];
assign sum[31]=a[31]^b[31]^x6[62];
assign sum[32]=a[32]^b[32]^x6[64];
assign sum[33]=a[33]^b[33]^x6[66];
assign sum[34]=a[34]^b[34]^x6[68];

kgp_carry kkc(x[71:70],x6[69:68],carry);

endmodule

//MUX 2to1
module mux2_35(o,i0,i1,s);

input [34:0] i0,i1;
input s;
output [34:0] o;
reg [34:0] o;

always@(i0 or i1 or s)
	begin
		case(s)
		 1'b0:o=i0;
		 1'b1:o=i1;
	endcase
	end


endmodule

// Full Adder Module
module fulladd1(x,y,z,sum, carry);

output sum,carry;
input x,y,z;

wire w;	
	assign 	 w = x ^ y;
        assign	 sum = w ^ z;
	assign 	 carry = (x & y)|(w & z);
endmodule

// half Adder Module
module halfadd1(x,y,sum, carry);

output sum,carry;
input x,y;

	assign	 sum = x ^ y;
	assign 	 carry = x & y;
	
endmodule

//36 bit recursive doubling technique

module recurse36(sum,carry,a,b); 

output [35:0] sum;
output  carry;
input [35:0] a,b;

wire [73:0] x;

assign x[1:0]=2'b00;  // kgp generation

kgp a00(a[0],b[0],x[3:2]);
kgp a01(a[1],b[1],x[5:4]);
kgp a02(a[2],b[2],x[7:6]);
kgp a03(a[3],b[3],x[9:8]);
kgp a04(a[4],b[4],x[11:10]);
kgp a05(a[5],b[5],x[13:12]);
kgp a06(a[6],b[6],x[15:14]);
kgp a07(a[7],b[7],x[17:16]);
kgp a08(a[8],b[8],x[19:18]);
kgp a09(a[9],b[9],x[21:20]);
kgp a10(a[10],b[10],x[23:22]);
kgp a11(a[11],b[11],x[25:24]);
kgp a12(a[12],b[12],x[27:26]);
kgp a13(a[13],b[13],x[29:28]);
kgp a14(a[14],b[14],x[31:30]);
kgp a15(a[15],b[15],x[33:32]);
kgp a16(a[16],b[16],x[35:34]);
kgp a17(a[17],b[17],x[37:36]);
kgp a18(a[18],b[18],x[39:38]);
kgp a19(a[19],b[19],x[41:40]);
kgp a20(a[20],b[20],x[43:42]);
kgp a21(a[21],b[21],x[45:44]);
kgp a22(a[22],b[22],x[47:46]);
kgp a23(a[23],b[23],x[49:48]);
kgp a24(a[24],b[24],x[51:50]);
kgp a25(a[25],b[25],x[53:52]);
kgp a26(a[26],b[26],x[55:54]);
kgp a27(a[27],b[27],x[57:56]);
kgp a28(a[28],b[28],x[59:58]);
kgp a29(a[29],b[29],x[61:60]);
kgp a30(a[30],b[30],x[63:62]);
kgp a31(a[31],b[31],x[65:64]);
kgp a32(a[32],b[32],x[67:66]);
kgp a33(a[33],b[33],x[69:68]);
kgp a34(a[34],b[34],x[71:70]);
kgp a35(a[35],b[35],x[73:72]);

wire [71:0] x1;  //recursive doubling stage 1
assign x1[1:0]=x[1:0];

recursive_stage1 s00(x[1:0],x[3:2],x1[3:2]);
recursive_stage1 s01(x[3:2],x[5:4],x1[5:4]);
recursive_stage1 s02(x[5:4],x[7:6],x1[7:6]);
recursive_stage1 s03(x[7:6],x[9:8],x1[9:8]);
recursive_stage1 s04(x[9:8],x[11:10],x1[11:10]);
recursive_stage1 s05(x[11:10],x[13:12],x1[13:12]);
recursive_stage1 s06(x[13:12],x[15:14],x1[15:14]);
recursive_stage1 s07(x[15:14],x[17:16],x1[17:16]);
recursive_stage1 s08(x[17:16],x[19:18],x1[19:18]);
recursive_stage1 s09(x[19:18],x[21:20],x1[21:20]);
recursive_stage1 s10(x[21:20],x[23:22],x1[23:22]);
recursive_stage1 s11(x[23:22],x[25:24],x1[25:24]);
recursive_stage1 s12(x[25:24],x[27:26],x1[27:26]);
recursive_stage1 s13(x[27:26],x[29:28],x1[29:28]);
recursive_stage1 s14(x[29:28],x[31:30],x1[31:30]);
recursive_stage1 s15(x[31:30],x[33:32],x1[33:32]);
recursive_stage1 s16(x[33:32],x[35:34],x1[35:34]);
recursive_stage1 s17(x[35:34],x[37:36],x1[37:36]);
recursive_stage1 s18(x[37:36],x[39:38],x1[39:38]);
recursive_stage1 s19(x[39:38],x[41:40],x1[41:40]);
recursive_stage1 s20(x[41:40],x[43:42],x1[43:42]);
recursive_stage1 s21(x[43:42],x[45:44],x1[45:44]);
recursive_stage1 s22(x[45:44],x[47:46],x1[47:46]);
recursive_stage1 s23(x[47:46],x[49:48],x1[49:48]);
recursive_stage1 s24(x[49:48],x[51:50],x1[51:50]);
recursive_stage1 s25(x[51:50],x[53:52],x1[53:52]);
recursive_stage1 s26(x[53:52],x[55:54],x1[55:54]);
recursive_stage1 s27(x[55:54],x[57:56],x1[57:56]);
recursive_stage1 s28(x[57:56],x[59:58],x1[59:58]);
recursive_stage1 s29(x[59:58],x[61:60],x1[61:60]);
recursive_stage1 s30(x[61:60],x[63:62],x1[63:62]);
recursive_stage1 s31(x[63:62],x[65:64],x1[65:64]);
recursive_stage1 s32(x[65:64],x[67:66],x1[67:66]);
recursive_stage1 s33(x[67:66],x[69:68],x1[69:68]);
recursive_stage1 s34(x[69:68],x[71:70],x1[71:70]);

wire [71:0] x2;  //recursive doubling stage2
assign x2[3:0]=x1[3:0];

recursive_stage1 s101(x1[1:0],x1[5:4],x2[5:4]);
recursive_stage1 s102(x1[3:2],x1[7:6],x2[7:6]);
recursive_stage1 s103(x1[5:4],x1[9:8],x2[9:8]);
recursive_stage1 s104(x1[7:6],x1[11:10],x2[11:10]);
recursive_stage1 s105(x1[9:8],x1[13:12],x2[13:12]);
recursive_stage1 s106(x1[11:10],x1[15:14],x2[15:14]);
recursive_stage1 s107(x1[13:12],x1[17:16],x2[17:16]);
recursive_stage1 s108(x1[15:14],x1[19:18],x2[19:18]);
recursive_stage1 s109(x1[17:16],x1[21:20],x2[21:20]);
recursive_stage1 s110(x1[19:18],x1[23:22],x2[23:22]);
recursive_stage1 s111(x1[21:20],x1[25:24],x2[25:24]);
recursive_stage1 s112(x1[23:22],x1[27:26],x2[27:26]);
recursive_stage1 s113(x1[25:24],x1[29:28],x2[29:28]);
recursive_stage1 s114(x1[27:26],x1[31:30],x2[31:30]);
recursive_stage1 s115(x1[29:28],x1[33:32],x2[33:32]);
recursive_stage1 s116(x1[31:30],x1[35:34],x2[35:34]);
recursive_stage1 s117(x1[33:32],x1[37:36],x2[37:36]);
recursive_stage1 s118(x1[35:34],x1[39:38],x2[39:38]);
recursive_stage1 s119(x1[37:36],x1[41:40],x2[41:40]);
recursive_stage1 s120(x1[39:38],x1[43:42],x2[43:42]);
recursive_stage1 s121(x1[41:40],x1[45:44],x2[45:44]);
recursive_stage1 s122(x1[43:42],x1[47:46],x2[47:46]);
recursive_stage1 s123(x1[45:44],x1[49:48],x2[49:48]);
recursive_stage1 s124(x1[47:46],x1[51:50],x2[51:50]);
recursive_stage1 s125(x1[49:48],x1[53:52],x2[53:52]);
recursive_stage1 s126(x1[51:50],x1[55:54],x2[55:54]);
recursive_stage1 s127(x1[53:52],x1[57:56],x2[57:56]);
recursive_stage1 s128(x1[55:54],x1[59:58],x2[59:58]);
recursive_stage1 s129(x1[57:56],x1[61:60],x2[61:60]);
recursive_stage1 s130(x1[59:58],x1[63:62],x2[63:62]);
recursive_stage1 s131(x1[61:60],x1[65:64],x2[65:64]);
recursive_stage1 s132(x1[63:62],x1[67:66],x2[67:66]);
recursive_stage1 s133(x1[65:64],x1[69:68],x2[69:68]);
recursive_stage1 s134(x1[67:66],x1[71:70],x2[71:70]);

wire [71:0] x3;  //recursive doubling stage3
assign x3[7:0]=x2[7:0];

recursive_stage1 s203(x2[1:0],x2[9:8],x3[9:8]);
recursive_stage1 s204(x2[3:2],x2[11:10],x3[11:10]);
recursive_stage1 s205(x2[5:4],x2[13:12],x3[13:12]);
recursive_stage1 s206(x2[7:6],x2[15:14],x3[15:14]);
recursive_stage1 s207(x2[9:8],x2[17:16],x3[17:16]);
recursive_stage1 s208(x2[11:10],x2[19:18],x3[19:18]);
recursive_stage1 s209(x2[13:12],x2[21:20],x3[21:20]);
recursive_stage1 s210(x2[15:14],x2[23:22],x3[23:22]);
recursive_stage1 s211(x2[17:16],x2[25:24],x3[25:24]);
recursive_stage1 s212(x2[19:18],x2[27:26],x3[27:26]);
recursive_stage1 s213(x2[21:20],x2[29:28],x3[29:28]);
recursive_stage1 s214(x2[23:22],x2[31:30],x3[31:30]);
recursive_stage1 s215(x2[25:24],x2[33:32],x3[33:32]);
recursive_stage1 s216(x2[27:26],x2[35:34],x3[35:34]);
recursive_stage1 s217(x2[29:28],x2[37:36],x3[37:36]);
recursive_stage1 s218(x2[31:30],x2[39:38],x3[39:38]);
recursive_stage1 s219(x2[33:32],x2[41:40],x3[41:40]);
recursive_stage1 s220(x2[35:34],x2[43:42],x3[43:42]);
recursive_stage1 s221(x2[37:36],x2[45:44],x3[45:44]);
recursive_stage1 s222(x2[39:38],x2[47:46],x3[47:46]);
recursive_stage1 s223(x2[41:40],x2[49:48],x3[49:48]);
recursive_stage1 s224(x2[43:42],x2[51:50],x3[51:50]);
recursive_stage1 s225(x2[45:44],x2[53:52],x3[53:52]);
recursive_stage1 s226(x2[47:46],x2[55:54],x3[55:54]);
recursive_stage1 s227(x2[49:48],x2[57:56],x3[57:56]);
recursive_stage1 s228(x2[51:50],x2[59:58],x3[59:58]);
recursive_stage1 s229(x2[53:52],x2[61:60],x3[61:60]);
recursive_stage1 s230(x2[55:54],x2[63:62],x3[63:62]);
recursive_stage1 s231(x2[57:56],x2[65:64],x3[65:64]);
recursive_stage1 s232(x2[59:58],x2[67:66],x3[67:66]);
recursive_stage1 s233(x2[61:60],x2[69:68],x3[69:68]);
recursive_stage1 s234(x2[63:62],x2[71:70],x3[71:70]);

wire [71:0] x4;  //recursive doubling stage 4
assign x4[15:0]=x3[15:0];

recursive_stage1 s307(x3[1:0],x3[17:16],x4[17:16]);
recursive_stage1 s308(x3[3:2],x3[19:18],x4[19:18]);
recursive_stage1 s309(x3[5:4],x3[21:20],x4[21:20]);
recursive_stage1 s310(x3[7:6],x3[23:22],x4[23:22]);
recursive_stage1 s311(x3[9:8],x3[25:24],x4[25:24]);
recursive_stage1 s312(x3[11:10],x3[27:26],x4[27:26]);
recursive_stage1 s313(x3[13:12],x3[29:28],x4[29:28]);
recursive_stage1 s314(x3[15:14],x3[31:30],x4[31:30]);
recursive_stage1 s315(x3[17:16],x3[33:32],x4[33:32]);
recursive_stage1 s316(x3[19:18],x3[35:34],x4[35:34]);
recursive_stage1 s317(x3[21:20],x3[37:36],x4[37:36]);
recursive_stage1 s318(x3[23:22],x3[39:38],x4[39:38]);
recursive_stage1 s319(x3[25:24],x3[41:40],x4[41:40]);
recursive_stage1 s320(x3[27:26],x3[43:42],x4[43:42]);
recursive_stage1 s321(x3[29:28],x3[45:44],x4[45:44]);
recursive_stage1 s322(x3[31:30],x3[47:46],x4[47:46]);
recursive_stage1 s323(x3[33:32],x3[49:48],x4[49:48]);
recursive_stage1 s324(x3[35:34],x3[51:50],x4[51:50]);
recursive_stage1 s325(x3[37:36],x3[53:52],x4[53:52]);
recursive_stage1 s326(x3[39:38],x3[55:54],x4[55:54]);
recursive_stage1 s327(x3[41:40],x3[57:56],x4[57:56]);
recursive_stage1 s328(x3[43:42],x3[59:58],x4[59:58]);
recursive_stage1 s329(x3[45:44],x3[61:60],x4[61:60]);
recursive_stage1 s330(x3[47:46],x3[63:62],x4[63:62]);
recursive_stage1 s331(x3[49:48],x3[65:64],x4[65:64]);
recursive_stage1 s332(x3[51:50],x3[67:66],x4[67:66]);
recursive_stage1 s333(x3[53:52],x3[69:68],x4[69:68]);
recursive_stage1 s334(x3[55:54],x3[71:70],x4[71:70]);

wire [71:0] x5;  //recursive doubling stage 5
assign x5[31:0]=x4[31:0];

recursive_stage1 s415(x4[1:0],x4[33:32],x5[33:32]);
recursive_stage1 s416(x4[3:2],x4[35:34],x5[35:34]);
recursive_stage1 s417(x4[5:4],x4[37:36],x5[37:36]);
recursive_stage1 s418(x4[7:6],x4[39:38],x5[39:38]);
recursive_stage1 s419(x4[9:8],x4[41:40],x5[41:40]);
recursive_stage1 s420(x4[11:10],x4[43:42],x5[43:42]);
recursive_stage1 s421(x4[13:12],x4[45:44],x5[45:44]);
recursive_stage1 s422(x4[15:14],x4[47:46],x5[47:46]);
recursive_stage1 s423(x4[17:16],x4[49:48],x5[49:48]);
recursive_stage1 s424(x4[19:18],x4[51:50],x5[51:50]);
recursive_stage1 s425(x4[21:20],x4[53:52],x5[53:52]);
recursive_stage1 s426(x4[23:22],x4[55:54],x5[55:54]);
recursive_stage1 s427(x4[25:24],x4[57:56],x5[57:56]);
recursive_stage1 s428(x4[27:26],x4[59:58],x5[59:58]);
recursive_stage1 s429(x4[29:28],x4[61:60],x5[61:60]);
recursive_stage1 s430(x4[31:30],x4[63:62],x5[63:62]);
recursive_stage1 s431(x4[33:32],x4[65:64],x5[65:64]);
recursive_stage1 s432(x4[35:34],x4[67:66],x5[67:66]);
recursive_stage1 s433(x4[37:36],x4[69:68],x5[69:68]);
recursive_stage1 s434(x4[39:38],x4[71:70],x5[71:70]);

wire [71:0] x6;  // recursive doubling stage 6
assign x6[63:0]=x5[63:0];

recursive_stage1 s531(x5[1:0],x5[65:64],x6[65:64]);
recursive_stage1 s532(x5[3:2],x5[67:66],x6[67:66]);
recursive_stage1 s533(x5[5:4],x5[69:68],x6[69:68]);
recursive_stage1 s534(x5[7:6],x5[71:70],x6[71:70]);

// final sum and carry

assign sum[0]=a[0]^b[0]^x6[0];
assign sum[1]=a[1]^b[1]^x6[2];
assign sum[2]=a[2]^b[2]^x6[4];
assign sum[3]=a[3]^b[3]^x6[6];
assign sum[4]=a[4]^b[4]^x6[8];
assign sum[5]=a[5]^b[5]^x6[10];
assign sum[6]=a[6]^b[6]^x6[12];
assign sum[7]=a[7]^b[7]^x6[14];
assign sum[8]=a[8]^b[8]^x6[16];
assign sum[9]=a[9]^b[9]^x6[18];
assign sum[10]=a[10]^b[10]^x6[20];
assign sum[11]=a[11]^b[11]^x6[22];
assign sum[12]=a[12]^b[12]^x6[24];
assign sum[13]=a[13]^b[13]^x6[26];
assign sum[14]=a[14]^b[14]^x6[28];
assign sum[15]=a[15]^b[15]^x6[30];
assign sum[16]=a[16]^b[16]^x6[32];
assign sum[17]=a[17]^b[17]^x6[34];
assign sum[18]=a[18]^b[18]^x6[36];
assign sum[19]=a[19]^b[19]^x6[38];
assign sum[20]=a[20]^b[20]^x6[40];
assign sum[21]=a[21]^b[21]^x6[42];
assign sum[22]=a[22]^b[22]^x6[44];
assign sum[23]=a[23]^b[23]^x6[46];
assign sum[24]=a[24]^b[24]^x6[48];
assign sum[25]=a[25]^b[25]^x6[50];
assign sum[26]=a[26]^b[26]^x6[52];
assign sum[27]=a[27]^b[27]^x6[54];
assign sum[28]=a[28]^b[28]^x6[56];
assign sum[29]=a[29]^b[29]^x6[58];
assign sum[30]=a[30]^b[30]^x6[60];
assign sum[31]=a[31]^b[31]^x6[62];
assign sum[32]=a[32]^b[32]^x6[64];
assign sum[33]=a[33]^b[33]^x6[66];
assign sum[34]=a[34]^b[34]^x6[68];
assign sum[35]=a[35]^b[35]^x6[70];

kgp_carry kkc(x[73:72],x6[71:70],carry);

endmodule

// D flip flop

module dflipflop35(q,d,clk,reset);
output [34:0] q;
input [34:0] d;
input clk,reset;
reg [34:0] q;
always@(posedge reset or negedge clk)
if(reset)
q<=35'b00000000;
else
q<=d;
endmodule








`default_nettype wire
