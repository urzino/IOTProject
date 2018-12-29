#include "Timer.h"

#include "senseappmsg.h"





module USBC {
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli>;
        
        interface AMSend as AMSendT;
        interface SplitControl as AMControl;

        interface Read<uint16_t> as TempRead;
        interface Read<uint16_t> as HumidityRead;
        interface Read<uint16_t> as LightRead;
    }
}

implementation {
    #define SAMPLING_FREQUENCY 15000

    bool LEDon = FALSE;
    
    bool busy = FALSE;
    message_t package;     
    uint16_t counter = 0;
    
    uint16_t temperature;
    uint16_t humidity;
    uint16_t light;

    bool temp_ok = FALSE;
    bool hum_ok = FALSE;
    bool lig_ok = FALSE;




    event void Boot.booted() {
        call AMControl.start();
        call Timer.startPeriodic(SAMPLING_FREQUENCY);
    }


    task void SendTemptoUart(){
        if (!busy & temp_ok & hum_ok & lig_ok){
            TemptoUartMsg* btrpkt = (TemptoUartMsg*)(call AMSendT.getPayload(&package, NULL));

            btrpkt->nodeid = TOS_NODE_ID;

            btrpkt->temp = temperature;    

            btrpkt->hum = humidity;    

            btrpkt->lig = light;


            if (call AMSendT.send(AM_BROADCAST_ADDR, &package, sizeof(TemptoUartMsg)) == SUCCESS) {
                busy=TRUE;
            } else {

            }
        }
    }

    event void AMSendT.sendDone(message_t* msg, error_t error) {
        if (&package == msg) {
            busy = FALSE;
            temp_ok=FALSE;
            hum_ok=FALSE;
            lig_ok=FALSE;
        }
    }

    event void Timer.fired() {
        if (LEDon && !busy) {
            call Leds.led1On();
            counter++;
            call TempRead.read();
            call HumidityRead.read();
            call LightRead.read();
            LEDon = FALSE;
        } else {
            call Leds.led1Off();
            LEDon = TRUE;
        }
    }

    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) {

        } else {

        }
    }

    event void AMControl.stopDone(error_t err) {

    }

    event void TempRead.readDone(error_t result, uint16_t data) {

        if (result == SUCCESS){

            temperature=data;
            temp_ok=TRUE;
            post SendTemptoUart();

        } else {
        }
    }

    event void HumidityRead.readDone(error_t result, uint16_t data) {

        if (result == SUCCESS){

            humidity=data;
            hum_ok=TRUE;
            post SendTemptoUart();

        } else {
        }
    }

    event void LightRead.readDone(error_t result, uint16_t data) {

        if (result == SUCCESS){

            light=data;
            lig_ok=TRUE;
            post SendTemptoUart();

        } else {
        }
    }



}
