#ifndef TMP_H
#define TMP_H


typedef nx_struct TemptoUartMsg {
    nx_uint16_t nodeid;
    nx_uint16_t temp;
    nx_uint16_t hum;
    nx_uint16_t lig;
    

} TemptoUartMsg;

#endif