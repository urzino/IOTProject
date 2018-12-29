configuration USBAppC { 
}

implementation {
    components USBC, MainC, LedsC;
    components new TimerMilliC() as Timer;
    
    components SerialActiveMessageC;
    components new SerialAMSenderC(0) as Send;

    components new SensirionSht11C() as TempAndHumid;

    components new HamamatsuS1087ParC() as Photo;

    USBC.Boot -> MainC.Boot;
    USBC.Leds -> LedsC;
    USBC.Timer -> Timer;
    
    USBC.AMControl -> SerialActiveMessageC;
    USBC.AMSendT -> Send;

    USBC.TempRead -> TempAndHumid.Temperature;
    USBC.HumidityRead -> TempAndHumid.Humidity;
    USBC.LightRead ->Photo;
}