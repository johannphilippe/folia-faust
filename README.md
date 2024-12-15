# Folia in Faust 

# Programme 

This project is a Faust port from the original program of Folia (by Kaija Saariaho) electronic part originally made by Jean-Baptiste Barrière.  
The original (and still well sustained) project is a Max MSP program, and can be found on [Kaiha Saariaho website](http://jb.barriere.free.fr/KS-pieces/Folia-electronics.html). 
This project is a proof of concept : porting Max patches to Faust is not only possible, it is also much more sustainable and it brings electronic works to the free software world. 

The core of the piece is based on three DSP files : 
* delay.dsp
* harm.dsp
* vital_rev_inf.dsp 

These are the three effects used to transform double-bass sound in realtime. 

In order to reproduce the original patch with more fidelity, it has been decided to stick to its sound design philosophy : adding a reverb bus as well as simple circular spatialization tools : 
* Reaverb (or any convolution reverb program) and an IR for a large hall. The IR is here : [IR](https://drive.google.com/file/d/1ScZeuxC5Pkq6eEOTCjd9hYLgIQG0xGCU/view?usp=sharing)
* gmem_spat_auto.dsp and gmem_spat_auto_stereo.dsp enables automatic spatialization

In order to perform the piece, there are a lot of options : 
* Web : Use the provided full-web version
* Reaper : Compile all required DSP's to VST's or JSFX code (reverb must be VST) and use the provided Reaper session
* PureData : Compile all required DSP's to PureData externals and use the patch.svg diagram to reproduce a similar routing
* Other : Probably a lot of other options, since Faust allows to target a lot of platforms 

# TODO

* (+-DONE) Tests Harm & del  
* (+-DONE) Entrées AED pour DBAP +
* (+-DONE) Automatisations du patch de JBB 
* (+-DONE) Reverb et inf reverb
* (DONE) Fix Harm 
* (DONE)Check delay clics
* Route delay to a spat bus (and reverb)
* Spat must go to out (independently from reverb)

* URGENT : Configure MIDI latch to "learn" curves while recording 
* Ecriture du patch final 
* Test avec sons CTB 

* Faire une version avec DBAP, GMEM spat, VBAP  & SPAT IRCAM (?)
* Add gain compensation in DBAP 
* Find why it creates a mess to add trajectories in DBAP 
  * TODO : implement reverberance and envelopment in FDN reverb
  * TODO : implement scale and envelopment parameters in infinite reverb  
  * TODO : externalize dataset (reverb data) and add script to generate new ones 
  * TODO : Try new reverbs (long, short etc)

