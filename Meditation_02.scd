// Shamanic Dream Ritual (Theta Binaural Beats)

s = Server.default;
s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -14; 

    SynthDef(\shamanicRitual, {
        var frameDrum, drumTrig, drumAcc, drumBase;
        var shaker, shakerTrig, shakerPattern;
        var throatDrone, vocalFormant, thetaHz;
        var nightForest, crickets, deepWind;
        var nativeFlute, fluteTrig, flutePitch;
        var finalStereo, reverb;
        var tempo, masterTrig;
        
        tempo = 2.7;
        masterTrig = Impulse.kr(tempo); 
        
        drumTrig = Demand.kr(masterTrig, 0, Dseq([1, 1, 1, 0, 1, 1, 0, 1], inf)) * masterTrig;
        drumAcc = Demand.kr(drumTrig, 0, Dseq([1.0, 0.6, 0.8, 0.5, 0.9, 0.4, 0.8, 0.7], inf));

        drumBase = SinOsc.ar(
            EnvGen.ar(Env.perc(0.005, 0.12, 1, \exp), drumTrig).exprange(65, 95), 
            0, 
            drumAcc
        ) * EnvGen.ar(Env.perc(0.02, 0.5, 1, -4), drumTrig);
        
        frameDrum = drumBase + (BPF.ar(BrownNoise.ar(0.6), 85, 0.4) * EnvGen.ar(Env.perc(0.01, 0.3), drumTrig) * drumAcc);
        frameDrum = frameDrum + (LPF.ar(WhiteNoise.ar(0.3), 1200) * EnvGen.ar(Env.perc(0.002, 0.04), drumTrig) * drumAcc);
        
        shakerTrig = Impulse.kr(tempo * 2); 
        shakerPattern = Demand.kr(shakerTrig, 0, Dseq([0.6, 0.3, 0.8, 0.4, 0.5, 0.3, 0.9, 0.2], inf));

        shaker = WhiteNoise.ar(0.25) * EnvGen.ar(Env.perc(0.01, 0.08, 1, -3), shakerTrig) * shakerPattern;
        shaker = HPF.ar(shaker, 5000);
        shaker = BPF.ar(shaker, LFNoise1.kr(0.2).range(7000, 11000), 0.4);
        shaker = shaker + DelayC.ar(shaker, 0.02, LFNoise1.kr(8).range(0.001, 0.005), 0.4);

        crickets = Formlet.ar(Dust.ar(LFNoise1.kr(0.2).range(5, 20)), LFNoise1.kr(0.1).range(3500, 4500), 0.005, 0.02) * 0.04;
        deepWind = BPF.ar(BrownNoise.ar(0.8), LFNoise1.kr(0.15).exprange(120, 380), LFNoise1.kr(0.1).range(0.25, 0.55)) * 0.25;

        thetaHz = 4.5; 
        
        throatDrone = [
            LFSaw.ar(68, 0, 0.18) + LFSaw.ar(102, 0, 0.08),
            LFSaw.ar(68 + thetaHz, 0, 0.18) + LFSaw.ar(102 + thetaHz, 0, 0.08)
        ];
        vocalFormant = BPF.ar(throatDrone, LFNoise1.kr(0.12).exprange(350, 750), 0.06);
        throatDrone = (throatDrone * 0.4) + (vocalFormant * 1.2);
        throatDrone = throatDrone + [SinOsc.ar(34, 0, 0.15), SinOsc.ar(34 + thetaHz, 0, 0.15)];
        throatDrone = throatDrone * LFNoise1.kr(0.2).range(0.7, 1.3);

        fluteTrig = Dust.kr(0.05) + Impulse.kr(0.02);
        flutePitch = Demand.kr(fluteTrig, 0, Dxrand([66, 69, 71, 73, 76, 78], inf)).midicps;
        
        nativeFlute = SinOsc.ar(Lag.kr(flutePitch, 0.12), 0, 0.3);
        nativeFlute = nativeFlute + (BPF.ar(WhiteNoise.ar(0.18), Lag.kr(flutePitch, 0.1) * 2, 0.1) * LFNoise2.kr(6).range(0.7, 1.0));
        nativeFlute = nativeFlute * EnvGen.kr(Env.perc(0.8, 4.5, 1, -2), fluteTrig);
        nativeFlute = DelayC.ar(nativeFlute, 0.01, SinOsc.kr(5.5, 0, 0.001, 0.003)); 

		finalStereo = Pan2.ar(crickets * 2.1, LFNoise1.kr(0.04).range(-0.8, 0.8));
        finalStereo = finalStereo + Pan2.ar(deepWind * 1.3, LFNoise1.kr(0.02).range(-0.6, 0.6));
        finalStereo = finalStereo + Pan2.ar(frameDrum * 1.1, LFNoise1.kr(0.1).range(-0.1, 0.1)); 
        finalStereo = finalStereo + Pan2.ar(shaker * 0.3, SinOsc.kr(tempo * 0.25).range(-0.7, 0.7)); 
        finalStereo = finalStereo + (throatDrone * 0.15); 
        finalStereo = finalStereo + Pan2.ar(nativeFlute * 0.25, LFNoise1.kr(0.08).range(-0.5, 0.5)); 

        reverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.4,             
            room: 0.95,           
            damp: 0.35            
        );
        
        reverb = Limiter.ar(reverb, 0.95);
        Out.ar(0, reverb);
        
    }).play;

});

ServerQuit.add({ 0.exit });