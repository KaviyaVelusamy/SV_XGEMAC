//Xgemac TX RX defines
`define XGEMAC_TX_RX_DATA_WIDTH 64
`define XGEMAC_TX_RX_MOD        3

//xgemac wishbone defines
`define XGEMAC_WB_ADDR_WIDTH 8
`define XGEMAC_WB_DATA_WIDTH 32

//xgmii tx rx defines
`define XGMII_TX_RX_CONTROL_WIDTH 8
`define XGMII_TX_RX_DATA_WIDTH    64

//xgemac TX RX CLOCK PERIOD & RESET PERIOD
`define XGEMAC_TX_RX_CLOCK_PERIOD 10000
`define XGEMAC_TX_RX_RESET_PERIOD 2

//xgemac WISHBONE CLOCK & RESET PERIOD
`define XGEMAC_WB_CLOCK_PERIOD 6400
`define XGEMAC_WB_RESET_PERIOD 2

//Random Test minimum reserve and allow maximum
`define MIN_RESERVED_ODD   3
`define MIN_RESERVED_EVEN  2

//timeout
`define TIMEOUT 10000
//`define TIMEOUT 64'd900000000000

//Minimum paddding bytes
`define MIN_PADDING_BYTE 60

`define BYTE 8


