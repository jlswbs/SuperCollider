// Spectral Tibetan earth ritual //

s = Server.default;

s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -12;

    SynthDef(\spectral, {
        var earthRumble, stoneCrush, totalEarth;
        var throatChantSrc, throatChantEnv, throatFreq;
        var formant1, formant2, formant3, totalVocal;
        var chainEarth, bufEarth, finalStereo, earthReverb;
        var stoneTrig, rumbleMod;
        var bellTrig, bellSrc, bellFreqs, bellAmps, bellRings;

        rumbleMod = LFNoise1.kr(0.2).range(0.2, 0.8);
        earthRumble = LPF.ar(
            BrownNoise.ar(0.9),
            LFNoise1.kr(0.1).range(45, 75)
        ) * rumbleMod;
        
        earthRumble = earthRumble + SinOsc.ar(
            LFNoise1.kr(0.05).range(35, 42), 
            0, 
            0.35 * rumbleMod
        );

        stoneTrig = Dust.ar(LFNoise1.kr(0.15).range(2, 15));
        stoneCrush = BPF.ar(
            Decay2.ar(stoneTrig, 0.01, 0.08) * BrownNoise.ar(0.4),
            TRand.ar(120, 450, stoneTrig), 
            0.15
        ) * LFNoise1.kr(0.3).range(0.3, 0.9);

        totalEarth = earthRumble + stoneCrush;

        throatChantEnv = EnvGen.kr(
            Env.circle([0, 1, 0.8, 0], [1.5, 7.0, 2.0, 2.0]), 
            1
        );
        
        throatFreq = LFNoise1.kr(0.15).range(49, 53) * LFNoise1.kr(4).range(0.99, 1.01); 
        throatChantSrc = Pulse.ar(throatFreq, 0.65, 0.4) + Saw.ar(throatFreq, 0.3);
        
        formant1 = BPF.ar(throatChantSrc, LFNoise1.kr(0.1).range(350, 450), 0.05) * 1.5;  
        formant2 = BPF.ar(throatChantSrc, LFNoise1.kr(0.12).range(650, 800), 0.06) * 1.2; 
        formant3 = BPF.ar(throatChantSrc, 2400, 0.1) * 0.4; 
        
        totalVocal = (formant1 + formant2 + formant3) * throatChantEnv;

        bufEarth = LocalBuf(2048, 1);
        chainEarth = FFT(bufEarth, totalVocal + (stoneCrush * 0.3));
        chainEarth = PV_MagFreeze(chainEarth, LFNoise1.kr(0.08).range(0, 1) > 0.4);
        chainEarth = PV_BinShift(chainEarth, stretch: 1.02, shift: 2);
        totalVocal = IFFT(chainEarth);

        bellTrig = Dust.kr(LFNoise1.kr(0.15).range(0.04, 0.08));
        bellFreqs = [311.13, 622.25, 933.38, 1244.51, 1555.63, 2100] * LFNoise1.kr(0.01).range(0.995, 1.005);
        bellAmps = [0.35, 0.25, 0.2, 0.15, 0.1, 0.05];
        bellRings = [10.0, 8.5, 7.0, 5.0, 3.5, 2.0];

        bellSrc = Klank.ar(
            `[bellFreqs, bellAmps, bellRings], 
            Decay2.kr(bellTrig, 0.001, 0.03) * WhiteNoise.ar(0.15)
        );

        finalStereo = Pan2.ar(earthRumble * 0.27, 0); 
        finalStereo = finalStereo + Pan2.ar(stoneCrush * 2.0, LFNoise1.kr(0.3).range(-0.7, 0.7));
        finalStereo = finalStereo + Pan2.ar(totalVocal * 0.4, LFNoise1.kr(0.05).range(-0.3, 0.3));
        finalStereo = finalStereo + Pan2.ar(bellSrc * 0.27, TRand.kr(-0.6, 0.6, bellTrig));

        earthReverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.45,
            room: 0.98, 
            damp: 0.75  
        );
        
        earthReverb = Limiter.ar(earthReverb, 0.95);
        Out.ar(0, earthReverb);
        
    }).play;

});

ServerQuit.add({ 0.exit });