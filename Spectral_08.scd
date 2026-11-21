// Shiva - Bhairava ritual v2: Hypnotic Spectral Frenzy (theta binaural beats)

s = Server.default;
s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -12;

    SynthDef(\bhairavaFrenzy, {
        var masterTrig, tempo, thetaHz;
        var kickTrig, kick, subThump;
        var hypnoTrig, hypnoBell, bellBank;
        var breathTrig, breathLayer, boneFlute, breathEnv;
        var chantTrig, chantDrone, choirFormants;
        var chainTrig, metalTrig, metalChain, struckMetal;
        var fireLayer, sparkTrig, fireSpectral;
        var rattleTrig, rattleLayer, boneRattle;
        var finalStereo, reverb, delay;
        var bufA, bufB, fftA, fftB, scramA, scramB;
        var lfo1, lfo2, lfo3, lfo4;
        var polyA, polyB, polyC;

        tempo = 1.15;
        thetaHz = 4.0;

        masterTrig = Impulse.kr(tempo);
        polyA = Impulse.kr(tempo * 1.5);
        polyB = Impulse.kr(tempo * 0.5);
        polyC = Impulse.kr(tempo * 0.75);

        kickTrig = Demand.kr(masterTrig, 0, Dseq([1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,0], inf)) * masterTrig;
        kick = SinOsc.ar(
            EnvGen.ar(Env.perc(0.001, 0.35, 1, \exp), kickTrig).exprange(45, 90),
            0, 0.8
        ) * EnvGen.ar(Env.perc(0.002, 0.5, 1, -3), kickTrig);
        subThump = LPF.ar(BrownNoise.ar(0.5), 90) * EnvGen.ar(Env.perc(0.005, 0.25), kickTrig);

        hypnoTrig = Dust.kr(0.35) + (polyC * Demand.kr(polyC, 0, Dseq([1,0,1], inf)));
        bellBank = Klank.ar(
            `[
                [87, 213, 427, 631, 1043, 1697],
                [0.4, 0.3, 0.2, 0.12, 0.08, 0.04],
                [3.5, 2.8, 2.2, 1.5, 1.0, 0.6]
            ],
            Decay.kr(hypnoTrig, 0.004, WhiteNoise.ar(0.05))
        );
        hypnoBell = bellBank * EnvGen.kr(Env.perc(0.01, 4.0, 1, -4), hypnoTrig);
        hypnoBell = BPF.ar(hypnoBell, LFNoise1.kr(0.15).exprange(200, 1200), 0.2);

        breathTrig = Impulse.kr(0.15) + Dust.kr(0.05);
		breathEnv = EnvGen.ar(Env([0, 1, 0.6, 0], [2.5, 1.5, 3.5], \sin), breathTrig);
		breathLayer = BPF.ar(WhiteNoise.ar(0.6), LFNoise1.kr(0.3).exprange(600, 2500), 0.3, 2.0);
		breathLayer = breathLayer * breathEnv;
		breathLayer = breathLayer * LFNoise1.kr(0.7).range(0.5, 1.0);
	
        boneFlute = SinOsc.ar(
            LFNoise1.kr(0.1).range(174, 186) + (SinOsc.kr(0.05).range(-2, 2)),
            0, 0.18
        );
        boneFlute = boneFlute * EnvGen.kr(Env.perc(1.5, 6.0, 1, -3), breathTrig);
        boneFlute = BPF.ar(boneFlute, LFNoise1.kr(0.2).exprange(500, 1000), 0.15);

        chantTrig = Impulse.kr(0.08) + Dust.kr(0.03);
        choirFormants = [
            Formant.ar(
                LFNoise1.kr(0.1).range(82, 88),
                LFNoise1.kr(0.3).range(600, 750),
                LFNoise1.kr(0.2).range(80, 120),
                0.25
            ),
            Formant.ar(
                LFNoise1.kr(0.1).range(82 + thetaHz, 88 + thetaHz),
                LFNoise1.kr(0.3).range(600, 750),
                LFNoise1.kr(0.2).range(80, 120),
                0.25
            )
        ];

        chantDrone = choirFormants;
        chantDrone = chantDrone + [
            Formant.ar(
                LFNoise1.kr(0.15).range(110, 120),
                LFNoise1.kr(0.25).range(1800, 2400),
                LFNoise1.kr(0.2).range(200, 300),
                0.12
            ),
            Formant.ar(
                LFNoise1.kr(0.15).range(110 + thetaHz, 120 + thetaHz),
                LFNoise1.kr(0.25).range(1800, 2400),
                LFNoise1.kr(0.2).range(200, 300),
                0.12
            )
        ];
        chantDrone = chantDrone * LFNoise1.kr(0.4).range(0.5, 1.1);
        chantDrone = chantDrone + [
            SinOsc.ar(55, 0, 0.1),
            SinOsc.ar(55 + thetaHz, 0, 0.1)
        ];

        metalTrig = Dust.kr(0.5) + (polyA * Demand.kr(polyA, 0, Dseq([1,0,0,1], inf)));
        struckMetal = Klank.ar(
            `[
                [431, 683, 1129, 1777, 2633],
                [0.35, 0.25, 0.15, 0.08, 0.04],
                [2.0, 1.4, 0.9, 0.5, 0.3]
            ],
            Decay.kr(metalTrig, 0.003, WhiteNoise.ar(0.04))
        );
        struckMetal = struckMetal * EnvGen.kr(Env.perc(0.005, 3.0), metalTrig);
        metalChain = HPF.ar(
            BPF.ar(WhiteNoise.ar(0.2), LFNoise1.kr(1.5).range(3000, 8000), 0.4) *
            EnvGen.ar(Env.perc(0.02, 0.4, 1, -2), metalTrig),
            2000
        );

        sparkTrig = Dust.ar(LFNoise1.kr(0.4).range(15, 70));
        fireLayer = Formlet.ar(
            Decay2.ar(sparkTrig, 0.0001, 0.003),
            TRand.ar(2000, 9000, sparkTrig),
            0.0003, 0.002
        ) * TExpRand.ar(0.3, 1.0, sparkTrig);
        fireLayer = fireLayer + BPF.ar(
            BrownNoise.ar(0.5),
            LFNoise1.kr(0.25).exprange(60, 280),
            LFNoise1.kr(0.15).range(0.2, 0.45)
        ) * LFNoise2.kr(3).range(0.4, 1.0);

        bufA = LocalBuf(1024, 1);
        bufB = LocalBuf(1024, 1);
        fftA = FFT(bufA, fireLayer);
        fftB = FFT(bufB, struckMetal + metalChain);

        scramA = PV_BinScramble(fftA, 0.45, 0.25, Dust.kr(7));
        scramA = PV_PhaseShift270(scramA);
        scramA = PV_MagSmear(scramA, 3);
        scramB = PV_BinScramble(fftB, 0.6, 0.4, Dust.kr(11));
        scramB = PV_PhaseShift90(scramB);
        fireSpectral = IFFT(scramA) + IFFT(scramB) * 0.6;

        rattleTrig = Demand.kr(polyB, 0, Dseq([0,1,1,0,1,0,1,1], inf)) * polyB;
        boneRattle = BPF.ar(
            WhiteNoise.ar(0.25) * EnvGen.ar(Env.perc(0.01, 0.15, 1, -3), rattleTrig),
            LFNoise1.kr(2).range(4500, 8500), 0.3);
        boneRattle = boneRattle + CombC.ar(boneRattle, 0.05, LFNoise1.kr(3).range(0.005, 0.02), 0.4);

        finalStereo = Pan2.ar(fireSpectral * 0.35, LFNoise1.kr(0.07).range(-0.55, 0.55));
        finalStereo = finalStereo + Pan2.ar(kick * 0.6, -0.1);
        finalStereo = finalStereo + Pan2.ar(subThump * 0.5, 0.1);
        finalStereo = finalStereo + Pan2.ar(hypnoBell * 0.7, TRand.kr(-0.8, 0.8, hypnoTrig));
        finalStereo = finalStereo + Pan2.ar(breathLayer * 0.1, LFNoise1.kr(0.1).range(-0.6, 0.6));
        finalStereo = finalStereo + Pan2.ar(boneFlute * 1.7, SinOsc.kr(0.03).range(-0.4, 0.4));
        finalStereo = finalStereo + (chantDrone * 0.04);
        finalStereo = finalStereo + Pan2.ar(struckMetal * 0.2, TRand.kr(-0.8, 0.8, metalTrig));
        finalStereo = finalStereo + Pan2.ar(metalChain * 0.15, LFNoise1.kr(0.5).range(-0.65, 0.65));
        finalStereo = finalStereo + Pan2.ar(boneRattle * 0.1, LFNoise1.kr(0.4).range(-0.85, 0.85));

        delay = CombC.ar(finalStereo, 0.6, 0.375, 3.5) * 0.25;
        delay = LPF.ar(delay, 2500);
        finalStereo = finalStereo + delay;

        reverb = FreeVerb2.ar(
            finalStereo[0],
            finalStereo[1],
            mix: 0.35,
            room: 0.96,
            damp: 0.55
        );

        reverb = Limiter.ar(reverb, 0.95);
        Out.ar(0, reverb);

    }).play;

});

ServerQuit.add({ 0.exit });