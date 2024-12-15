import("stdfaust.lib");

/*
/*
Envelopment by reverberation
Envelopment
The feeling of being enveloped by reverberation. According to Ekhard Kahle's thesis (1995), the perception of envelopment is correlated with the energy of the late reflections and the strength of the low frequencies. Strong late reflections and high low frequency energy facilitate the perception of a reverberant envelopment effect. In Spat 5, these examples were made by changing the "Envelopment", "pan rev" and "Room Size" parameters.
The term "reverberance" refers to the sensation that sounds are prolonged by the room reverberation. Late reverberance differs from running reverberance by the fact that it is essentially perceived during interruptions of the message radiated by the source. Running reverberance, on the contrary, remains perceived during continuous music.
*/

scale(smin, smax, tmin, tmax, src ) = target
with {
    sdiff = smax - smin; 
    tdiff = tmax  - tmin; 
    norm = (src - smin) / sdiff;
    target = norm * tdiff + tmin;
};

ms_cnt(ms) = cnt
with {
    smps = ba.sec2samp(ms/1000);
    cnt = _~+(1) : %(smps);
};

infrev(sig) = infrev_rt, infrev_scale, infrev_env
with {
    smoothed = sig * ba.db2linear(20) : _, 2 : pow : ba.line(ba.sec2samp(0.03));
    snap = smoothed : ba.sAndH( ms_cnt(5) == 0 );
    db = ba.linear2db(snap);

    // Rev time 
    infrev_scaler(speedlim, preclip_min, preclip_max, postscale_min, postscale_max, itp_time, power) = ba.sAndH( ms_cnt(speedlim) == 0 )
        : aa.clip(preclip_min, preclip_max)
        : scale(preclip_min, preclip_max, 0, 1) 
        : ba.line( ba.sec2samp(0.5) )
        : _, power : pow
        : scale(0, 1, postscale_min, postscale_max)
        : aa.clip(postscale_max, postscale_min);

    // 0.72 is the sensitive part here, it could be increased for more time, or decreased 
    infrev_rt = db : infrev_scaler(20, -30, 0, 1, 0.69, 100, 0.1);
    infrev_scale = db : infrev_scaler(20, -60, 0, 0, -10, 500, 2);
    infrev_env = db : infrev_scaler(20, -60, 0, 50, 0, 500, 1);
};

//time = hslider("time", 0.5, 0, 1, 0.001);
size = hslider("size", 0.5, 0, 1, 0.001);
prelow = hslider("prelow", 0, 0, 1, 0.001);
low = hslider("low", 0, 0, 1, 0.001);
prehigh = hslider("prehigh", 1, 0, 1, 0.001);
high = hslider("high", 1, 0, 1, 0.001);
lowgain = hslider("lowgain", 1, 0, 1, 0.001);
highgain = hslider("highgain", 1, 0, 1, 0.001);
chorus_amt = hslider("chorus_amt", 0, 0, 1, 0.001);
chorus_freq = hslider("chorus_freq", 0, 0, 1, 0.001);
predelay = hslider("predelay", 0, 0, 1, 0.001);

proc_rev(inp) = inp <: re.vital_rev(prelow, prehigh, low, high, lowgain, highgain, chorus_amt, chorus_freq, predelay, time, size, 1) 
with {
    inf = infrev(inp);
    time = ba.take(1, inf); // tr0 
};

process = _ : proc_rev;