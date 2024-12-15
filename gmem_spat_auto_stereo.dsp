import("stdfaust.lib");

NSPEAKERS = 4;

az(n) =  azim
with {
    az_dur_smps = 3 * ma.SR;
    az_metro = ba.beat(60 / 3);
    rnd_az = no.noises(4, n) : ba.sAndH(az_metro) : abs : *(2) ;
    azim = rnd_az : ba.line(az_dur_smps) : %(1);
};

dist(n) = distance 
with {
    dist_dur_smps = (60/40) * ma.SR;
    dist_metro = ba.beat(40);
    rnd_dist = no.noises(4, n) : ba.sAndH(dist_metro) : abs : *(0.5) : +(0.5); 
    distance = rnd_dist : ba.line(dist_dur_smps);
};

ingain = hslider("ingain", 0, -70, 12, 0.001) : si.smoo : ba.db2linear;
outgain = hslider("outgain", 0, -70, 12, 0.001) : si.smoo : ba.db2linear;
gspat1 = _ : sp.spat(NSPEAKERS, az(0), dist(2));
gspat2 = _ : sp.spat(NSPEAKERS, az(1), dist(3));

process = _ * ingain, _ * ingain : gspat1, gspat2 :> par(n, NSPEAKERS, _ * outgain);
