import("stdfaust.lib");

chain(inp) = del_sigs, harm_sigs, infrev_sigs :> _,_
with {
    del_sigs = inp : *(harmonizer_gain) : component("delay.dsp"); //component("gmem_spat_auto_stereo.dsp");
    harm_sigs = inp : *(delay_gain) : component("harm.dsp");
    infrev_sigs = inp : *(infrev_gain) <: component("verb_inf_fdn.dsp");

    harmonizer_gain = hslider("harmonizer_gain", -70, -70, 12, 0.01) : ba.db2linear;
    delay_gain = hslider("delay_gain", -70, -70, 12, 0.01) : ba.db2linear;
    infrev_gain = hslider("infinite_reverb_gain", -70, -70, 12, 0.01) : ba.db2linear;

};

mainingain = hslider("mainingain", 0, -70, 6, 0.01) : ba.db2linear;
process = _ : *(mainingain) : chain;