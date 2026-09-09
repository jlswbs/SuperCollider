// Spectral Tibetan ether ritual //

s = Server.default;

s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -14;

    SynthDef(\spectral, {
        var cosmicWind, singingBowls, totalEther;
        var chainEther, bufEtherA, bufEtherB, finalStereo, etherReverb;
        var bowlFreqs, bowlAmps, bowlMod;
        var pranavaTrig, pranavaEnv, pranavaFreq, pranavaVocal;
        var formantA, formantU, formantM, totalPranava;

        cosmicWind = Resonz.ar(
            WhiteNoise.ar(0.12),
            LFNoise1.kr(0.05).exprange(400, 1500), 
            0.002 
        ) + Resonz.ar(
            PinkNoise.ar(0.1),
            LFNoise1.kr(0.03).exprange(800, 2200),
            0.0015
        );

        bowlFreqs = [164.81, 220.00, 293.66, 329.63, 440.00, 659.25];
        bowlMod = LFNoise1.kr(0.15).range(0.997, 1.003); 
        
        singingBowls = Mix.fill(bowlFreqs.size, { |i|
            var lfo = LFNoise1.kr(0.1 + (i * 0.05)).range(0.1, 0.7);
            SinOsc.ar(
                bowlFreqs[i] * bowlMod, 
                0, 
                lfo * 0.15
            )
        });

        singingBowls = (singingBowls * 1.5).tanh * 0.4;

        pranavaTrig = Dust.kr(0.04);
        pranavaEnv = EnvGen.kr(Env.perc(4.0, 12.0, 1, -2), pranavaTrig);
        pranavaFreq = 136.10 * LFNoise1.kr(0.2).range(0.995, 1.005);
        pranavaVocal = LFTri.ar(pranavaFreq, 0, 0.5) + Saw.ar(pranavaFreq, 0.2);
        
        formantA = BPF.ar(pranavaVocal, XLine.kr(700, 400, 8), 0.08);
        formantU = BPF.ar(pranavaVocal, XLine.kr(400, 250, 12), 0.06);
        formantM = BPF.ar(pranavaVocal, 250, 0.03) * LFNoise1.kr(5).range(0.8, 1.2);
        
        totalPranava = (formantA + formantU + formantM) * pranavaEnv * 0.75;
        totalEther = cosmicWind + singingBowls + totalPranava;

        bufEtherA = LocalBuf(2048, 1);
        chainEther = FFT(bufEtherA, totalEther);
        chainEther = PV_MagFreeze(chainEther, LFNoise1.kr(0.05).range(0, 1) > 0.2);
        chainEther = PV_Diffuser(chainEther, Dust.kr(12)); 
        chainEther = PV_MagSmear(chainEther, LFNoise1.kr(0.1).range(1, 4));
        
        totalEther = IFFT(chainEther);

        finalStereo = Pan2.ar(totalEther * 0.7, LFNoise1.kr(0.04).range(-0.8, 0.8));
		finalStereo = finalStereo + Pan2.ar(totalPranava * 0.5, 0);
        finalStereo = finalStereo + Pan2.ar(singingBowls * 0.2, LFNoise1.kr(0.08).range(-0.5, 0.5));
		finalStereo = finalStereo + Pan2.ar(
            WhiteNoise.ar(0.001) * LFNoise1.kr(0.2).range(0.5, 1.0),
            LFNoise1.kr(0.05).range(-0.3, 0.3)
        );

        etherReverb = FreeVerb2.ar(
            finalStereo,       
            finalStereo,       
            mix: 0.65,
            room: 0.998, 
            damp: 0.05   
        );
        
        etherReverb = Limiter.ar(etherReverb, 0.92);
        Out.ar(0, etherReverb);
        
    }).play;

});

ServerQuit.add({ 0.exit });