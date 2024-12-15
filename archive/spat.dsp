declare name "zitaRevFDN";
declare version "0.0";
declare author "JOS, Revised by RM";
declare description "Reverb demo application based on zita_rev_fdn.";

import("stdfaust.lib");

line(n, x) = state ~ (_,_) : !,_
with {
    state(t, c) = nt,nc
    with {
        nt = ba.if(x != x', n, t-1);
        nc = ba.if(nt > 0, c + (x - c)/nt, x);
    };
};



spat(NSPEAKER, speed_ms) = sp.spat(NSPEAKER, azim, dist)
with {
    metro = ba.beat(60 / (speed_ms / 1000) );
    rndazim = no.noises(2,0) : abs : ba.sAndH(metro);
    rnddist = no.noises(2,1) : abs : ba.sAndH(metro) : +(0.25) : aa.clip(0, 1) ;
    azim = rndazim : line(speed_ms / 1000 * ma.SR) : hbargraph("azim", 0, 1);
    dist = rnddist : line(speed_ms / 1000 * ma.SR) : hbargraph("dist", 0, 1); 

    roomsize = 4;

};

process = os.sawtooth(100) * 0 : spat(2, 3000);
