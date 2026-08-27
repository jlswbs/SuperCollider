// Spectral Tibetan mountain ritual //

s = Server.default;

s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -12;

    SynthDef(\spectral, {
        var windNoise, windBase, windGusts, windThroat, totalWind;
        var chimeTrig, chimeSrc, chimeFreqs, chimeAmps, chimeRings;
        var gongTrig, gongSrc, gongFreqs, gongAmps, gongRings;
        var chainWind, bufWind, finalStereo, mountainReverb;
        var tingshaTrig, tingshaSrc, tingshaFreqs, tingshaAmps, tingshaRings;

        windNoise = PinkNoise.ar(0.9);
        
        windBase = BPF.ar(
            windNoise, 
            LFNoise1.kr(0.04).exprange(60, 180), 
            0.25
        ) * LFNoise1.kr(0.08).range(0.3, 0.7);
        
        windGusts = BPF.ar(
            windNoise, 
            LFNoise1.kr(0.3).exprange(600, 2200), 
            LFNoise2.kr(0.15).range(0.08, 0.25)
        ) * LFNoise1.kr(0.2).exprange(0.05, 0.6);
        
        windThroat = BPF.ar(
            windNoise,
            LFNoise1.kr(0.1).exprange(2500, 4500),
            0.02
        ) * LFNoise1.kr(0.25).range(0.0, 0.15);

        totalWind = windBase + windGusts + windThroat;

        bufWind = LocalBuf(2048, 1);
        chainWind = FFT(bufWind, totalWind);
        chainWind = PV_MagSmear(chainWind, LFNoise1.kr(0.1).range(2, 8));
        totalWind = IFFT(chainWind);

        chimeTrig = Dust.ar(LFNoise1.kr(0.5).range(2, 12) * LFNoise1.kr(0.3).range(0.2, 1.2));
        
        chimeFreqs = [880, 990, 1188, 1320, 1584] * LFNoise1.kr(0.01).range(0.99, 1.01);
        chimeAmps = [0.2, 0.18, 0.15, 0.12, 0.1];
        chimeRings = [4.0, 3.5, 3.0, 2.5, 2.0];

        chimeSrc = Klank.ar(
            `[chimeFreqs, chimeAmps, chimeRings], 
            Decay2.ar(chimeTrig, 0.001, 0.01) * WhiteNoise.ar(0.04),
            decayscale: LFNoise1.kr(0.2).range(0.8, 1.5)
        );

        gongTrig = Dust.kr(0.12); 
        
        gongFreqs = [174.61, 349.23, 523.25, 698.46, 873.07, 1046.50] * 1.02;
        gongAmps = [0.4, 0.3, 0.25, 0.15, 0.1, 0.05];
        gongRings = [12.0, 10.0, 8.0, 6.0, 4.0, 2.0];

        gongSrc = Klank.ar(
            `[gongFreqs, gongAmps, gongRings], 
            Decay2.kr(gongTrig, 0.02, 0.4) * PinkNoise.ar(0.2)
        );

        tingshaTrig = Dust.kr(0.09);
        tingshaFreqs = [2450, 2465, 3680, 4900, 6125] * LFNoise1.kr(0.01).range(0.995, 1.005);
        tingshaAmps = [0.3, 0.25, 0.15, 0.1, 0.05];
        tingshaRings = [7.0, 6.5, 5.0, 3.5, 2.0];

        tingshaSrc = Klank.ar(
            `[tingshaFreqs, tingshaAmps, tingshaRings],
            Decay2.kr(tingshaTrig, 0.002, 0.05) * WhiteNoise.ar(0.25)
        );

        finalStereo = Pan2.ar(totalWind * 1.15, LFNoise1.kr(0.05).range(-0.6, 0.6));
        finalStereo = finalStereo + Pan2.ar(chimeSrc * 0.9, LFNoise1.kr(0.7).range(-0.85, 0.85)); 
        finalStereo = finalStereo + Pan2.ar(gongSrc * 0.15, 0);
        finalStereo = finalStereo + Pan2.ar(tingshaSrc * 0.17, TRand.kr(-0.7, 0.7, tingshaTrig));

        mountainReverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.55,
            room: 0.95,         
            damp: 0.65
        );
        
        mountainReverb = Limiter.ar(mountainReverb, 0.95);
        Out.ar(0, mountainReverb);
        
    }).play;

});