import("stdfaust.lib");

time = hslider("time", 0.5, 0, 1, 0.001);
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
mix = hslider("mix", 0.3, 0, 1, 0.001);

proc_rev(inp) = inp <: re.vital_rev(prelow, prehigh, low, high, lowgain, highgain, chorus_amt, chorus_freq, predelay, time, size, 1) 
with {
    inf = infrev(inp);
    time = ba.take(1, inf); // tr0 
};

process = _ <: re.vital_rev(prelow, prehigh, low, high, lowgain, highgain, chorus_amt, chorus_freq, predelay, time, size, mix);