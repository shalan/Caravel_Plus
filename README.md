# Caravel Plus
Caravel management SoC attached to the largest possible DFFRAM that can fit the user's area. For the RAM related development, refer to [DFFRAM](https://github.com/shalan/DFFRAM)

# Caravel Integration

## Verilog View

The DFFRAM macro is placed on the management area wishbone bus at address (0x30000000). For the memory interface and wishbone bus conversion, refer to [Caravel_RAM_24KB_wb](https://github.com/shalan/Caravel_Plus/blob/master/verilog/rtl/Caravel_RAM_24KB_wb.v)

 MGMT-WB               | DFFRAM        |  Description
| -----------------    | ------------- | -------------
|  wb_adr_i[14:2]      | A             | Address
|  wb_dat_i            | Di            | Input Data
|  wb_sel_i & wb_we_i  | WE            | Write-Enable
|  wb_cyc_i & wb_stb_i | EN            | Enable
|  wb_dat_o            | Do            | Output Data


## GDS View

<p align=”center”>
<img src="doc/caravel.png" width="40%" height="40%">
</p>
