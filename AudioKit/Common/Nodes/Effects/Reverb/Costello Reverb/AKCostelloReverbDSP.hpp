//
//  AKCostelloReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKCostelloReverbParameter) {
    AKCostelloReverbParameterFeedback,
    AKCostelloReverbParameterCutoffFrequency,
    AKCostelloReverbParameterRampTime
};

#ifndef __cplusplus

void* createCostelloReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKCostelloReverbDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;

public:
    AKCostelloReverbDSP();
    ~AKCostelloReverbDSP();

    float feedbackLowerBound = 0.0f;
    float feedbackUpperBound = 1.0f;
    float cutoffFrequencyLowerBound = 12.0f;
    float cutoffFrequencyUpperBound = 20000.0f;

    float defaultFeedback = 0.6;
    float defaultCutoffFrequency = 4000.0f;

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void destroy();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
    
};

#endif
