// Spectral Tibetan fire ritual //

s = Server.default;

s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -12;

    SynthDef(\spectral, {
        var fireSparks, fireRoar, fireHeat, totalFire;
        var kanglingTrig, kanglingSrc, kanglingEnv, kanglingFreq;
        var ritualDrumTrig, ritualDrumSrc;
        var chainFire, bufFire, finalStereo, fireReverb;
        var sparkTrig, heatMod;

        sparkTrig = Dust.ar(LFNoise1.kr(0.5).range(5, 35));
        fireSparks = Formlet.ar(
            Decay2.ar(sparkTrig, 0.0001, 0.003),
            TRand.ar(2000, 9000, sparkTrig),
            0.0005, 0.004
        ) * TExpRand.ar(0.4, 1.2, sparkTrig);

        heatMod = LFNoise2.kr(3).range(0.2, 1.0);
        fireRoar = BPF.ar(
            BrownNoise.ar(0.8),
            LFNoise1.kr(0.4).exprange(80, 280),
            LFNoise1.kr(0.2).range(0.3, 0.6)
        ) * heatMod;

        fireHeat = SinOsc.ar(
            LFNoise1.kr(0.1).range(36, 45), 
            0, 
            LFNoise1.kr(0.5).exprange(0.01, 0.08)
        );

        totalFire = fireSparks + fireRoar + fireHeat;

        bufFire = LocalBuf(1024, 1);
        chainFire = FFT(bufFire, totalFire);
        chainFire = PV_PhaseShift270(chainFire);
        chainFire = PV_BinScramble(chainFire, 0.15, 0.2, Dust.kr(5));
        totalFire = IFFT(chainFire);

        kanglingTrig = Dust.kr(0.15);
        kanglingEnv = EnvGen.kr(Env.perc(0.4, 5.0, 1, -2), kanglingTrig);

        kanglingFreq = 145 * LFNoise1.kr(6).range(0.96, 1.04); 
        kanglingSrc = Pulse.ar(
            kanglingFreq, 
            LFNoise1.kr(0.5).range(0.3, 0.7), 
            0.25
        ) + Saw.ar(kanglingFreq * 1.5, 0.15);
        
        kanglingSrc = BPF.ar(kanglingSrc, LFNoise1.kr(0.3).exprange(600, 1500), 0.08);
        kanglingSrc = kanglingSrc * kanglingEnv * LFNoise1.kr(8).range(0.5, 1.0);

		ritualDrumTrig = Impulse.kr(LFNoise1.kr(0.3).range(0.2, 0.3));
        ritualDrumSrc = SinOsc.ar(
            EnvGen.ar(Env.perc(0.02, 0.12, 1, \exp), ritualDrumTrig).range(45, 140),
            0,
            0.6
        ) * EnvGen.ar(Env.perc(0.05, 0.4, 1, -4), ritualDrumTrig);
        
        ritualDrumSrc = ritualDrumSrc + (BPF.ar(PinkNoise.ar(0.4), 120, 0.3) * EnvGen.ar(Env.perc(0.02, 0.08), ritualDrumTrig));

        finalStereo = Pan2.ar(totalFire * 0.23, LFNoise1.kr(0.1).range(-0.4, 0.4));
        finalStereo = finalStereo + Pan2.ar(kanglingSrc * 1.4, LFNoise1.kr(0.2).range(-0.5, 0.5));
        finalStereo = finalStereo + Pan2.ar(ritualDrumSrc * 1.2, TRand.kr(-0.3, 0.3, ritualDrumTrig));

        fireReverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.5,
            room: 0.88,
            damp: 0.35
        );
        
        fireReverb = Limiter.ar(fireReverb, 0.95);
        Out.ar(0, fireReverb);
        
    }).play;

});

ServerQuit.add({ 0.exit });