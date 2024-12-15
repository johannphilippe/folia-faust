import("stdfaust.lib");


/*
/*
Envelopment by reverberation
Envelopment
The feeling of being enveloped by reverberation. According to Ekhard Kahle's thesis (1995), the perception of envelopment is correlated with the energy of the late reflections and the strength of the low frequencies. Strong late reflections and high low frequency energy facilitate the perception of a reverberant envelopment effect. In Spat 5, these examples were made by changing the "Envelopment", "pan rev" and "Room Size" parameters.
The term "reverberance" refers to the sensation that sounds are prolonged by the room reverberation. Late reverberance differs from running reverberance by the fact that it is essentially perceived during interruptions of the message radiated by the source. Running reverberance, on the contrary, remains perceived during continuous music.
*/


reflectionL( 1 ) =  0.02375 , 0.11557629381583374 ;
reflectionL( 2 ) =  0.0238125 , 0.17010209827595973 ;
reflectionL( 3 ) =  0.0335625 , 0.14706905080802796 ;
reflectionL( 4 ) =  0.0340625 , 0.12367327900430636 ;
reflectionL( 5 ) =  0.034125 , 0.15673481361451821 ;
reflectionL( 6 ) =  0.0413125 , 0.0891286443398325 ;
reflectionL( 7 ) =  0.041375 , 0.13177905570504655 ;
reflectionL( 8 ) =  0.0524375 , 0.05890816143262457 ;
reflectionL( 9 ) =  0.0525 , 0.05279465344890552 ;
reflectionL( 10 ) =  0.0538125 , 0.07869462606960048 ;
reflectionL( 11 ) =  0.057625 , 0.09409817466689661 ;
reflectionL( 12 ) =  0.0576875 , 0.051020003387040276 ;
reflectionL( 13 ) =  0.0585625 , 0.06882167292858093 ;
reflectionL( 14 ) =  0.0620625 , 0.058799883508557006 ;
reflectionL( 15 ) =  0.062125 , 0.07471662643347185 ;
reflectionL( 16 ) =  0.069875 , 0.0601794961850407 ;
reflectionL( 17 ) =  0.070875 , 0.05494709428047797 ;
reflectionL( 18 ) =  0.0738125 , 0.07594753359153955 ;
reflectionL( 19 ) =  0.089875 , 0.06450661216156628 ;
reflectionL( 20 ) =  0.0980625 , 0.0768257142197242 ;
reflectionL( 21 ) =  0.100875 , 0.12471999826179074 ;
reflectionL( 22 ) =  0.11075 , 0.06005898799357838 ;
reflectionL( 23 ) =  0.1605625 , 0.06845860133958348 ;
reflectionL( 24 ) =  0.1715 , 0.05445670994661861 ;
reflectionL( 25 ) =  0.1865 , 0.06963645683490538 ;
nreflectionsL = 25 ;

reflectionR( 1 ) =  0.0314375 , 0.15193326471519605 ;
reflectionR( 2 ) =  0.039625 , 0.06586417439416307 ;
reflectionR( 3 ) =  0.0396875 , 0.16435490861405122 ;
reflectionR( 4 ) =  0.045625 , 0.08910489486782988 ;
reflectionR( 5 ) =  0.0515 , 0.10609348067813229 ;
reflectionR( 6 ) =  0.0515625 , 0.05651789088044618 ;
reflectionR( 7 ) =  0.056125 , 0.0849893168746758 ;
reflectionR( 8 ) =  0.0561875 , 0.12329020995984416 ;
reflectionR( 9 ) =  0.0574375 , 0.06090695990600202 ;
reflectionR( 10 ) =  0.061 , 0.19465860219293551 ;
reflectionR( 11 ) =  0.0610625 , 0.07820713625677377 ;
reflectionR( 12 ) =  0.0649375 , 0.0536389363966531 ;
reflectionR( 13 ) =  0.0691875 , 0.07929873854852743 ;
reflectionR( 14 ) =  0.072625 , 0.07641169325280932 ;
reflectionR( 15 ) =  0.0726875 , 0.07035885879092131 ;
reflectionR( 16 ) =  0.073625 , 0.10310235311555407 ;
reflectionR( 17 ) =  0.0764375 , 0.15846072114137788 ;
reflectionR( 18 ) =  0.08675 , 0.08225205741951004 ;
reflectionR( 19 ) =  0.089125 , 0.050270977509254876 ;
reflectionR( 20 ) =  0.1148125 , 0.056036754044509744 ;
reflectionR( 21 ) =  0.1295625 , 0.05207515164513442 ;
reflectionR( 22 ) =  0.1316875 , 0.07669627908023448 ;
reflectionR( 23 ) =  0.139375 , 0.07245248411369246 ; 
reflectionR( 24 ) =  0.1601875 , 0.055501069059381805 ;
reflectionR( 25 ) =  0.1665 , 0.06963645683490538 ;
nreflectionsR = 25 ;


NDELS = 16;
delL = par(n, NDELS, (reflectionL(n+1) : _,! : *(ma.SR)) );
delR = par(n, NDELS, (reflectionR(n+1) : _,! : *(ma.SR)) );
MAXSR = 48000;
MAXDEL_L = reflectionL(NDELS) : _ , ! : *(MAXSR) : int;
MAXDEL_R = reflectionL(NDELS) : _ , ! : *(MAXSR) : int;

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

    infrev_rt = db : infrev_scaler(20, -30, 0, 90, 5, 100, 0.1);
    infrev_scale = db : infrev_scaler(20, -60, 0, 0, -10, 500, 2);
    infrev_env = db : infrev_scaler(20, -60, 0, 50, 0, 500, 1);
};

rev(delays, sig) = sig <: re.fdnrev0(MAXDELAY, delays, BBSO, freqs, durs, loopgainmax, nonl) :> _ //predel, predel
with {
    infinite_rev_params = infrev(sig);
    inf_duration = ba.take(1, infinite_rev_params); // tr0 
    inf_scale = ba.take(2, infinite_rev_params); // Reverberance 
    inf_scale_lin = ba.db2linear(inf_scale);
    inf_env = ba.take(3, infinite_rev_params); // Envelopment... 
    MAXDELAY = MAXSR;
    BBSO = 5;
    freqs = (500);
    durs =  (inf_duration / 2, inf_duration);
    //durs = (8, 4, 3, 2, 1);
    loopgainmax = 0.99;

    nonl = 0;
    //predel = de.delay( int(0.1 * MAXSR), int(0.05*ma.SR));
};

free = re.stereo_freeverb(0.8, 0.7, 0.7, 1) : predel, predel 
with {
    predel = de.delay( int(0.1 * MAXSR), int(0.05*ma.SR));
};

mix = hslider("mix", 0.3, 0, 1, 0.001);
imix = 1 - mix;
amp = hslider("amp", 0.7, 0, 1, 0.001);
longverb = hslider("longverb", 0.25, 0, 1, 0.001);

ingain = hslider("ingain", 0, -70, 12, 0.001) : si.smoo : ba.db2linear;
outgain = hslider("outgain", 0, -70, 12, 0.001) : si.smoo : ba.db2linear;
process = _ * ingain ,_ * ingain <: 
    rev(delL) * mix, rev(delR) * mix, _ * imix, _ * imix :>
    _ * outgain, _ * outgain ;   
    
    

