// Shiva - Bhairava ritual (theta binaural beats)

s = Server.default;
s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -12;

    SynthDef(\bhairavaRitual, {
        var fireSparks, fireRoar, totalFire;
        var damaruTrig, damaruRoll, damaruSrc, deepDrum;
        var voiceDrone, shankhaRes, ghantaChime, shankhaTrig;
        var chainFire, bufFire, finalStereo, reverb;
        var sparkTrig, heatMod, tempo, ghantaTrig;
        var thetaHz;

        tempo = 1.6; 
        damaruTrig = Impulse.kr(tempo); 
        damaruRoll = Dust.ar(LFNoise1.kr(0.5).range(55, 110)) * EnvGen.ar(Env.perc(0.01, 0.25), damaruTrig);
        damaruSrc = BPF.ar(WhiteNoise.ar(0.6), TRand.kr(1200, 2200, damaruTrig), 0.3) * damaruRoll;
        damaruSrc = damaruSrc + (SinOsc.ar(EnvGen.ar(Env.perc(0.005, 0.08, 1, \exp), damaruTrig).exprange(220, 330)) 
            * EnvGen.ar(Env.perc(0.005, 0.08), damaruTrig) * 0.7);
        
        deepDrum = SinOsc.ar(EnvGen.ar(Env.perc(0.02, 0.2, 1, \exp), damaruTrig).exprange(110, 165), 0, 0.9)
            * EnvGen.ar(Env.perc(0.03, 0.45, 1, -4), damaruTrig);
        deepDrum = deepDrum + (BPF.ar(BrownNoise.ar(0.4), 130, 0.5) * EnvGen.ar(Env.perc(0.01, 0.15), damaruTrig));

        sparkTrig = Dust.ar(LFNoise1.kr(0.3).range(8, 40));
        fireSparks = Formlet.ar(Decay2.ar(sparkTrig, 0.0001, 0.004), TRand.ar(1500, 7000, sparkTrig), 0.0005, 0.003) * TExpRand.ar(0.3, 1.0, sparkTrig);
        
        heatMod = LFNoise2.kr(4).range(0.3, 1.0);
        fireRoar = BPF.ar(BrownNoise.ar(0.7), LFNoise1.kr(0.3).exprange(70, 220), LFNoise1.kr(0.2).range(0.25, 0.5)) * heatMod;
        totalFire = fireSparks + fireRoar;

        bufFire = LocalBuf(1024, 1);
        chainFire = FFT(bufFire, totalFire);
        chainFire = PV_PhaseShift270(chainFire);
        chainFire = PV_BinScramble(chainFire, 0.2, 0.1, Dust.kr(4));
        totalFire = IFFT(chainFire);

        thetaHz = 4.5;
        voiceDrone = [
            LFSaw.ar(83, 0, 0.15) + LFSaw.ar(108, 0, 0.1),
            LFSaw.ar(83 + thetaHz, 0, 0.15) + LFSaw.ar(108 + thetaHz, 0, 0.1)
        ];

        voiceDrone = BPF.ar(voiceDrone, LFNoise1.kr(0.2).exprange(120, 400), 0.05); 
        voiceDrone = voiceDrone * LFNoise1.kr(0.5).range(0.6, 1.2);
        voiceDrone = voiceDrone + [
            SinOsc.ar(55, 0, 0.12),
            SinOsc.ar(55 + thetaHz, 0, 0.12)
        ];

        shankhaTrig = Dust.kr(0.08) + Impulse.kr(0.04);
        shankhaRes = Formant.ar(
            LFNoise1.kr(0.2).range(143, 147),
            LFNoise1.kr(5).range(500, 800),
            LFNoise1.kr(0.5).range(250, 450),
            0.3
        );
        shankhaRes = shankhaRes * EnvGen.kr(Env.perc(1.5, 5.0, 1, -2), shankhaTrig);
        shankhaRes = BPF.ar(shankhaRes, LFNoise1.kr(0.4).exprange(300, 900), 0.25);

        ghantaTrig = Dust.kr(0.8);
        ghantaChime = Klank.ar(
            `[[320, 642, 965, 1410], [0.3, 0.2, 0.1, 0.05], [0.8, 1.2, 0.5, 0.2]],
            Decay.kr(ghantaTrig, 0.005, WhiteNoise.ar(0.02))
        ) * EnvGen.kr(Env.perc(0.01, 2.0), ghantaTrig);

        finalStereo = Pan2.ar(totalFire * 0.1, LFNoise1.kr(0.05).range(-0.3, 0.3));
        finalStereo = finalStereo + Pan2.ar(damaruSrc * 0.9, SinOsc.kr(tempo * 0.5).range(-0.2, 0.2)); 
        finalStereo = finalStereo + Pan2.ar(deepDrum * 0.7, 0); 
        finalStereo = finalStereo + (voiceDrone * 0.9);
        finalStereo = finalStereo + Pan2.ar(shankhaRes * 0.2, LFNoise1.kr(0.1).range(-0.4, 0.4));
        finalStereo = finalStereo + Pan2.ar(ghantaChime * 1.5, TRand.kr(-0.7, 0.7, ghantaTrig));

        reverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.45,
            room: 0.92, 
            damp: 0.4
        );
        
        reverb = Limiter.ar(reverb, 0.95);
        Out.ar(0, reverb);
        
    }).play;

});

ServerQuit.add({ 0.exit });