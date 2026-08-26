// Spectral Tibetan cave ritual //

s = Server.default;

s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -16;

    SynthDef(\spectral, {
        var trigger, metalSrc, exciter;
        var bufA, bufB, bufC, chainA, chainB, chainC;
        var liquidDron, glassRain, glassCrystals, finalStereo;
        var wetReverb, freqs, amps, rings;
        var particleTrig1, particleTrig2, glassSrc1, glassSrc2;
        var waterTrig, waterSrc, waterDrops;
        
        trigger = Dust.kr(0.25);
        exciter = Decay2.kr(trigger, 0.05, 0.6) * PinkNoise.ar(0.15);
        
        freqs = [110, 220, 275, 330, 440, 550, 660, 880] * 0.98;
        amps = [0.35, 0.25, 0.2, 0.16, 0.1, 0.6, 0.04, 0.02];
        rings = [8.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.5, 1.0];
        
        metalSrc = Klank.ar(`[freqs, amps, rings], exciter);
        metalSrc = metalSrc + (SinOsc.ar(49, 0) * LFNoise1.kr(0.1).exprange(0.005, 0.03));

        particleTrig1 = Dust.ar(XLine.kr(80, 20, 45));
        glassSrc1 = Formlet.ar(
            Decay2.ar(particleTrig1, 0.0005, 0.008),
            TRand.ar(3500, 8000, particleTrig1),
            0.001, 0.015
        ) * LFNoise1.kr(0.5).range(0.2, 0.5);

        particleTrig2 = Dust2.ar(LFNoise1.kr(0.2).range(5, 40));
        glassSrc2 = Formlet.ar(
            Decay2.ar(particleTrig2, 0.002, 0.04),
            TRand.ar(1500, 4500, particleTrig2),
            0.003, 0.06
        ) * LFNoise1.kr(0.3).range(0.1, 0.4);

        waterTrig = Dust.ar(LFNoise1.kr(0.2).range(0.2, 1.5));
        waterSrc = Formlet.ar(
            Decay2.ar(waterTrig, 0.0005, 0.01),
            TRand.ar(400, 900, waterTrig),
            0.005, 0.12
        ) * TExpRand.ar(0.3, 0.8, waterTrig);

        bufA = LocalBuf(1024, 1);
        bufB = LocalBuf(1024, 1);
        bufC = LocalBuf(1024, 1);
        
        chainA = FFT(bufA, metalSrc);
        chainA = PV_MagFreeze(chainA, LFNoise1.kr(0.1).range(0, 1) > 0.3);
        chainA = PV_MagSmear(chainA, LFNoise1.kr(0.2).range(5, 20));
        chainA = PV_BinShift(chainA, stretch: 0.95, shift: -5);
        
        chainB = FFT(bufB, glassSrc1);
        chainB = PV_Diffuser(chainB, Dust.kr(25)); 
        chainB = PV_BinShift(chainB, stretch: 1.2, shift: 15); 
        
        chainC = FFT(bufC, glassSrc2);
        chainC = PV_MagFreeze(chainC, LFNoise1.kr(0.5).range(0, 1) > 0.5);
        chainC = PV_PhaseShift90(chainC);
        chainC = PV_BinShift(chainC, stretch: 1.05, shift: 8);

        liquidDron = IFFT(chainA);
        glassRain = IFFT(chainB);
        glassCrystals = IFFT(chainC);
        
        finalStereo = Pan2.ar(liquidDron * 0.4, LFNoise1.kr(0.05).range(-0.2, 0.2));
        finalStereo = finalStereo + Pan2.ar(glassRain * 0.4, LFNoise1.kr(0.15).range(-0.8, 0.8));
        finalStereo = finalStereo + Pan2.ar(glassCrystals * 0.35, LFNoise2.kr(1.5).range(-0.9, 0.9));
        finalStereo = finalStereo + Pan2.ar(glassSrc1 * 0.12, LFNoise1.kr(0.8).range(-0.7, 0.7));
        
        waterDrops = Pan2.ar(waterSrc, TRand.ar(-0.85, 0.85, waterTrig));
        finalStereo = finalStereo + (waterDrops * 0.15);

        wetReverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.7,            
            room: 0.995,         
            damp: 0.15            
        );
        
        wetReverb = Limiter.ar(wetReverb, 0.92);
        Out.ar(0, wetReverb);
        
    }).play;

});