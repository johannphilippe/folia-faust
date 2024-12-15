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

intersection(x1, y1, x2, y2, x3, y3, x4, y4) = px, py
with {
    px = ( (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4) ) / ( (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4) ) / ( (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
};

distance(x1, y1, x2, y2) = sqrt(pow(x1 - x2, 2) - pow(y1 - y2, 2));

mstereo_spat(sizex, sizey, x, y, sig) = mixed
with {
 
    panlr = x / sizex;
    panned_lr = sig : sp.panner(panlr);

    center = sizex/2, sizey/2;
    centerx = sizex / 2;
    centery = sizey / 2;
  
    image_lx = 0 - x;
    image_ly = y;
    image_rx = sizex + (sizex-x);
    image_ry = y;
    image_tx = x : hbargraph("top", 0, 1000);
    image_ty = sizey + (sizey-y);
    image_bx = x;
    image_by = 0 - y;

    //proj_l = intersection(center, image_l, 0, 0, 0, sizey);
    proj_l = intersection(centerx, centery, image_lx, image_ly, 0, 0, 0, sizey);
    proj_r = intersection(centerx, centery, image_rx, image_ry, sizex, 0, sizex, sizey);
    proj_t = intersection(centerx, centery, image_tx, image_ty, 0, sizey, sizex, sizey);
    proj_b = intersection(centerx, centery, image_bx, image_by, 0, 0, sizex, 0);
    
    dist_l = distance(centerx, centery, (proj_l : _, !),  (proj_l : !, _) ) + distance(x, y, (proj_l : _, !), (proj_l : !, _));
    dist_r = distance(centerx, centery, (proj_r : _, !), (proj_r : !, _)) + distance(x, y, (proj_r : _, !), (proj_r : !, _));
    dist_t = distance(centerx, centery, (proj_t : _, !), (proj_t : !, _)) + distance(x, y, (proj_t : _, !), (proj_t : !, _));
    dist_b = distance(centerx, centery, (proj_b : _, !), (proj_b : !, _)) + distance(x, y, (proj_b : _, !), (proj_b : !, _));

    SND_SPEED = 344; // m/s in air
    del_l = dist_l / SND_SPEED;
    del_r = dist_r / SND_SPEED;
    del_t = dist_t / SND_SPEED;
    del_b = dist_b / SND_SPEED;

    ref_l = sig : de.delay(48000, int(del_l) ) : sp.panner(proj_l : ba.selectn(2, 0) / sizex);
    ref_r = sig : de.delay(192000, del_r) : sp.panner(proj_r : ba.selectn(2, 0) / sizex);
    ref_t = sig : de.delay(192000, del_t) : sp.panner(proj_t : ba.selectn(2, 0) / sizex);
    ref_b = sig : de.delay(192000, del_b) : sp.panner(proj_b : ba.selectn(2, 0) / sizex);

    mixed = panned_lr, ref_l, ref_r, ref_t, ref_b :> _,_;
};

spat(NSPEAKER, speed_ms) =  sp.spat(NSPEAKER, azim, dist)
with {
    metro = ba.beat(60 / (speed_ms / 1000) );
    rndazim = no.noises(2,0) : abs : ba.sAndH(metro);
    rnddist = no.noises(2,1) : abs : ba.sAndH(metro) : +(0.25) : aa.clip(0, 1) ;
    azim = rndazim : line(speed_ms / 1000 * ma.SR) : hbargraph("azim", 0, 1);
    dist = rnddist : line(speed_ms / 1000 * ma.SR) : hbargraph("dist", 0, 1); 

    roomsize = 4;
};
mspat(speed_ms) = _ : mstereo_spat(sizex, sizey, x, y)
with {
    sizex = 3;
    sizey = 6;
    metro = ba.beat(60 / (speed_ms / 1000) );
    rndx = no.noises(2,0) : abs : ba.sAndH(metro) : *(sizex);
    rndy = no.noises(2,1) : abs : ba.sAndH(metro) : *(sizey);
    x = rndx : line(speed_ms / 1000 * ma.SR) : hbargraph("azim", 0, sizex);
    y = rndy : line(speed_ms / 1000 * ma.SR) : hbargraph("dist", 0, sizey); 
};
process = _ : mspat(3000);
