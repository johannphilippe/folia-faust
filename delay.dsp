declare name            "Folia Delay";
declare version         "1.0";
declare author          "Johann Philippe";
declare license         "MIT";
declare copyright       "(c) Johann Philippe 2023-2024";

import("stdfaust.lib");

/*
MAXSR is used for delay buffer size calculation
*/
MAXSR = 48000;

sah(trig, condition, sig) = sig : ba.sAndH(cond) 
with {
    cond = (trig' < condition) & (trig >= condition);
};

del_ms(max_ms, time_ms, sig) = sig : de.fdelay(max_smps, time_smps)
with {
    max_smps = (max_ms / 1000) * MAXSR;
    time_smps = (time_ms / 1000) * ma.SR;
};

/*
A recursive (feedback) delay with milliseconds arguments 
*/
recdel_ms(max_ms, time_ms, fb, sig) = sig : +~de.fdelay(max_smps, time_smps) * fb
with {
    max_smps = (max_ms / 1000) * MAXSR;
    time_smps = (time_ms / 1000) * ma.SR;
};


/*
The main delay for this piece 
*/
delay(predel_t, del_t1, del_t2, delfb, lfo_predel_fb, lfo_fb, spat_mix, bass) = del_loop 
with {
    dcblocker = fi.tf21(1, -1, 0, -0.9997, 0.);
    clipped = bass : aa.clip(-1, 1);
    predel = clipped : recdel_ms(1000, predel_t, delfb * lfo_predel_fb);

    del_loop =  ((_,_ :> _ : *(delfb) : *(lfo_fb) : dcblocker : +(predel)) 
        : aa.clip(-1, 1) 
        <: del_ms(1000, del_t1), del_ms(1000, del_t2))
        ~(si.bus(2));    
};

// Constant and variables for the piece are defined here 
predel_v = 419;
delay1_v = 325;
delay2_v = 196;
feedback = 0.44;

lfo_base = os.osc(1 / 0.26)  /*: ba.sAndH( ba.beat( 60 * 10 )) :*/ *(0.2);
lfo_feedback = lfo_base + 0.8; 
lfo_predel_fb =   0.8 - lfo_base;

spat_mix = 0;
fq = hslider("fq", 0.5, 0.01, 10, 0.01);
amp = hslider("amp", 0.1, 0, 1, 0.001);

// Signal to test delay, unused 
testsig = os.osc(440) : *(env)
with {
    env = ba.beat(fq * 60) : en.ar(0, 0.1);
};

ingain = hslider("ingain", 0, -70, 12, 0.001) : si.smoo : ba.db2linear;
outgain = hslider("outgain", 0, -70, 12, 0.001) : si.smoo : ba.db2linear;

process = _ * ingain 
    : delay(predel_v, delay1_v, delay2_v, feedback, lfo_predel_fb, lfo_feedback, spat_mix)
    : *(outgain) , *(outgain);
