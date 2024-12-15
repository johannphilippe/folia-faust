declare name            "DBAP";
declare version         "1.0";
declare author          "Johann Philippe";
declare license         "MIT";
declare copyright       "(c) Johann Philippe 2024";

import("stdfaust.lib");

N_SRC = 1; 
N_SPEAKERS = 4;
/*
    DBAP - distance based amplitude panning 
    References : 
        - https://arxiv.org/pdf/2109.08704.pdf
            - where gain[i] = k*w[i]/d[i]^a
            - where k = 1 / w^2/d[i]^2*a for i = 1; i <= N (number of speakers)
            - where a = R / 20*log10^2  

            - where N is number of speakers, d is distance, w is weighting parameter (typically 1) 
                and a is coeffincient calculated from a rollof R in decibels and k is a coef function of the position of the source and the spakers

            - distance = sqrt((xi-xs)^2 + (yi-ys)^2 + (zi-zs)^2 + rs^2)
            - r[s] is spatial blur factor
*/
degtorad = *(ma.PI) : /(180);

poltocar(ad, e, d) = x, y, z 
with {  
    a = ad : degtorad;
    r = d; 
    i = e : degtorad;
    x = r * cos(i) * cos(a);
    y = r * cos(i) * sin(a);
    z = r * sin(i);
};


autom_source(max_dist) = xyz
with {

    a_smps = ma.SR * 4;
    a = no.noise : ba.sAndH(ba.beat(15)) : ba.line(a_smps) : abs : *(360);//os.phasor(360, 0.25);
    e = 0; //os.phasor(90, 0.1) - 45; 

    dist_smps = ma.SR * 3;
    d = no.noise : ba.sAndH(ba.beat(20)) : ba.line(dist_smps) : *(max_dist); //os.phasor(1, 0.1) : *(max_dist) : +(0.1);
    xyz = poltocar(a, e, d);
};


dbap_amps(nsrc, nspeakers, rolloff, rs) = amplitudes
with {
    src = autom_source(hslider("max_source_distance_%nsrc", 0, -10, 10, 0.001));
    //src = srcpos(nsrc);
    x = ba.take(1, src) : hbargraph("X", -10, 10);
    y = ba.take(2, src) : hbargraph("Y", -10, 10);
    z = ba.take(3, src) : hbargraph("Z", -10, 10);

    a(rolloff) = log(pow(10, (rolloff/20)))/log(2);

    distance(x,y,z, xspeaker, yspeaker, zspeaker, rs) = pow(x-xspeaker, 2) 
                                                        : +(pow(y-yspeaker, 2))
                                                        : +(pow(z-zspeaker, 2))
                                                        : +(pow(rs, 2))
                                                        : sqrt;

    dia(x,y,z, xsp, ysp, zsp) = pow(distance(x, y, z, xsp, ysp, zsp, rs), (0.5*a(rolloff))); 

    amplitudes = par(n, nspeakers, op(n) )
    with {
        dias = par(n, nspeakers, proc_dia(n))
        with {
            proc_dia(n) = dia(x, y, z, xsp, ysp, zsp) 
            with {
                speakerlist = speaker(n);
                xsp = ba.take(1, speakerlist);
                ysp = ba.take(2, speakerlist);
                zsp = ba.take(3, speakerlist);
            };
        };
        k = sqrt(1 / sum(n, nspeakers, dias : ba.selectn(nspeakers, n) ));
        op(n) = k / (dias : ba.selectn(nspeakers, n));
    };
};

dbap = si.bus(N_SRC) : par(n, N_SRC, compute(n) ) :> si.bus(N_SPEAKERS)
with {
    compute(n) = _ <: par(n, N_SPEAKERS, _ * amp(n))
    with {
        amps = dbap_amps(n, N_SPEAKERS, rolloff, rs);
        amp(x) = amps : ba.selectn(N_SPEAKERS, x);
    };
};

speaker(n) = (x, y, z)
with {
    x = hslider("speakerpos x %n", 0, -10, 10, 0.001 );
    y = hslider("speakerpos y %n", 0, -10, 10, 0.001 );
    z = hslider("speakerpos z %n", 0, -2, 5, 0.001 );
};

srcpos(n) = (x,y,z) 
with {
    x = hslider("srcpos x %n ", 0, -10, 10, 0.001 );
    y = hslider("srcpos y %n ", 0, -10, 10, 0.001 );
    z = hslider("srcpos z %n ", 0, -2, 5, 0.001 );
};

graphics(n, sig) = sig <: attach(_, (_ : abs : an.rms_envelope_rect(0.05)) : hbargraph("Amp_%n", 0, 1));

rolloff = hslider("rolloff", 3, 1, 12, 0.01);
rs = hslider("sourcewidth", 1, 0.1, 6, 0.01);

gain = hslider("gain", 0.1, 0, 2, 0.001);
outamp = hslider("out_amp", 1, 0, 1, 0.001);

outgain = hslider("outgain", 0, -70, 24, 0.01) : si.smoo : ba.db2linear;

process = dbap : par(n, N_SPEAKERS, graphics(n)) : par(i, N_SPEAKERS, _ * outamp * outgain);