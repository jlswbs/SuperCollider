// Hindustani Dhrupad Meditation (Theta Binaural Beats)

s = Server.default;
s.options.blockSize = 128;

s.waitForBoot({

    s.volume.volume = -12; 

    SynthDef(\dhrupadHypnosis, {
        var tampuraC, tampuraG, tampuraOct, totalTampura;
        var pakhawajBass, pakhawajRim, jingleMod;
        var nightAmbient, finalStereo, reverb;
        var masterTrig, masterTrig2, stepTrig, rimTrig, jingleTrig, tempo, thetaHz;
        var bassSeq, rimSeq;
        var sitarTrig, sitarFreq, sitarPluck, sitarRes, sitarFinal;
        
        tempo = 0.86; 
        masterTrig = Impulse.kr(tempo * 4);
		masterTrig2 = Impulse.kr(tempo * 8);
        
        bassSeq = Dseq([1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0], inf);
        rimSeq  = Dseq([0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1], inf);
        
        stepTrig = Demand.kr(masterTrig, 0, bassSeq) * masterTrig;
        rimTrig  = Demand.kr(masterTrig2, 0, rimSeq) * masterTrig2;
		jingleTrig  = Demand.kr(masterTrig, 0, rimSeq) * masterTrig;

        pakhawajBass = SinOsc.ar(
            EnvGen.ar(Env.perc(0.04, 0.3, 1, \exp), stepTrig).exprange(65.4, 98),
            0, 
            0.8
        ) * EnvGen.ar(Env.perc(0.04, 0.6, 1, -3), stepTrig);
        
        pakhawajBass = pakhawajBass + (BPF.ar(BrownNoise.ar(0.3), 82, 0.4) * EnvGen.ar(Env.perc(0.02, 0.25), stepTrig));

        pakhawajRim = Ringz.ar(
            WhiteNoise.ar(0.1) * EnvGen.ar(Env.perc(0.005, 0.05), rimTrig),
			Demand.kr(rimTrig, 0, Dxrand([196.00, 261.63, 392.00], inf)),
            0.15
        );

        pakhawajRim = pakhawajRim + (Ringz.ar(
            Dust.ar(100) * EnvGen.ar(Env.perc(0.002, 0.02), rimTrig),
			Demand.kr(rimTrig, 0, Dxrand([392.00, 523.25, 784.00], inf)),
            0.08
        ) * 0.4);

        jingleMod = BPF.ar(WhiteNoise.ar(0.02), 8500, 0.1) * EnvGen.ar(Env.perc(0.01, 0.12), jingleTrig);

        thetaHz = 4.5;

        tampuraG = [
            Formant.ar(98, LFNoise1.kr(0.2).range(196, 400), 150, 0.12),
            Formant.ar(98 + thetaHz, LFNoise1.kr(0.2).range(196, 400), 150, 0.12)
        ];
        
        tampuraC = [
            Formant.ar(65.4, LFNoise1.kr(0.15).range(130, 300), 120, 0.15),
            Formant.ar(65.4 + thetaHz, LFNoise1.kr(0.15).range(130, 300), 120, 0.15)
        ];

        tampuraOct = [
            SinOsc.ar(130.8, 0, 0.08) + LFCub.ar(130.8, 0, 0.04),
            SinOsc.ar(130.8 + thetaHz, 0, 0.08) + LFCub.ar(130.8 + thetaHz, 0, 0.04)
        ];

        totalTampura = (tampuraG * LFNoise1.kr(0.4).range(0.5, 1.0)) + 
                       (tampuraC * LFNoise1.kr(0.3).range(0.7, 1.1)) + 
                       (tampuraOct * LFNoise1.kr(0.5).range(0.6, 1.0));
        
        totalTampura = BPF.ar(totalTampura, LFNoise1.kr(0.1).exprange(100, 600), 0.6);

        sitarTrig = Dust.kr(0.2); 
        
        sitarFreq = Demand.kr(sitarTrig, 0, Dxrand([130.81, 146.83, 155.56, 196.00, 233.08, 261.63, 293.66, 311.13, 392.00], inf));
        sitarFreq = Select.kr(sitarFreq > 0, [130.81, sitarFreq]); 
        sitarFreq = sitarFreq * LFNoise2.kr(0.5).range(0.99, 1.01); 

        sitarPluck = PinkNoise.ar(0.3) * EnvGen.ar(Env.perc(0.005, 0.03), sitarTrig);
        sitarRes = CombC.ar(sitarPluck, 0.1, sitarFreq.reciprocal, 2.5);

        sitarFinal = sitarRes + DelayC.ar(BPF.ar(sitarRes, sitarFreq * 3, 0.2), 0.05, 0.01, 0.4);
        sitarFinal = HPF.ar(sitarFinal, 120); 
        sitarFinal = sitarFinal * EnvGen.ar(Env.perc(0.01, 15.0, 1, -2), sitarTrig);
        sitarFinal = Sanitize.ar(sitarFinal);

        sitarFinal = [
            sitarFinal + CombC.ar(sitarFinal, 1.0, (tempo * 0.75).reciprocal, 8),
            sitarFinal + CombC.ar(sitarFinal, 1.0, tempo.reciprocal, 8)
        ];

        nightAmbient = Formlet.ar(
            Dust.ar(LFNoise1.kr(0.2).range(3, 12)), 
            LFNoise1.kr(0.1).range(4000, 6500), 
            0.001, 
            0.04
        ) * 0.03;

        finalStereo = totalTampura * 0.13; 
        finalStereo = finalStereo + Pan2.ar(pakhawajBass * 1.2, LFNoise1.kr(0.05).range(-0.1, 0.1)); 
        finalStereo = finalStereo + Pan2.ar(pakhawajRim * 0.04, SinOsc.kr(tempo * 0.25).range(-0.5, 0.5)); 
        finalStereo = finalStereo + Pan2.ar(jingleMod * 2.2, LFNoise1.kr(0.05).range(-0.6, 0.6)); 
        finalStereo = finalStereo + Pan2.ar(nightAmbient * 1.5, LFNoise1.kr(0.1).range(-0.9, 0.9));
		finalStereo = finalStereo + (sitarFinal * 0.15);

        reverb = FreeVerb2.ar(
            finalStereo[0],       
            finalStereo[1],       
            mix: 0.38,  
            room: 0.95, 
            damp: 0.55  
        );
        
        reverb = Limiter.ar(reverb, 0.95);
        Out.ar(0, reverb);
        
    }).play;

});

ServerQuit.add({ 0.exit });