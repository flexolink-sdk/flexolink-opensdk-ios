

#include "Singleton.h"

Singleton* Singleton::instance = NULL;
Singleton::CRelease Singleton::release;
void Singleton::precaculate(double samplingrate, unsigned int indexButter, unsigned int indexNotch, double hp, double lp, double mains)
{
    Singleton::get_instance()->isIniate = true;
    Singleton::get_instance()->bwh;
    Singleton::get_instance()->bwBandstop;
    Singleton::get_instance()->highpass;
    Singleton::get_instance()->lowpass;
    Singleton::get_instance()->iirnotch;

    //Butterworth
    double cutoffl = (lp + hp) / 2;
    double cutoff2 = lp - hp;

    switch (indexButter)
    {
        case 1:             //bandpass
            bwh.setup(samplingrate, cutoffl, cutoff2);
            break;
        case 2:             //highpass
            highpass.setup(samplingrate, hp);
            break;
        case 3:             //lowpass
            lowpass.setup(samplingrate, lp);
            break;
        case 4:             //bandstop
            bwBandstop.setup(samplingrate, cutoffl, cutoff2);
            break;
        case 5: //all
            bwh.setup(samplingrate, cutoffl, cutoff2);
            highpass.setup(samplingrate, hp);
            lowpass.setup(samplingrate, lp);
            bwBandstop.setup(samplingrate, cutoffl, cutoff2);
            break;
        default:
            break;
    }

    //Notch
    if (indexNotch == 1)
    {
        iirnotch.setup(samplingrate, mains);
    }
}

double Singleton::calculate(double a, unsigned int indexButter, unsigned int indexNotch)
{
    double b;
    switch (indexButter)
    {
        case 1:             //bandpass
            b = Singleton::get_instance()->bwh.filter(a);
            break;
        case 2:             //highpass
            b = Singleton::get_instance()->highpass.filter(a);
            break;
        case 3:             //lowpass
            b = Singleton::get_instance()->lowpass.filter(a);
            break;
        case 4:             //bandstop
            b = Singleton::get_instance()->bwBandstop.filter(a);
            break;
        default:
            b = a;
            break;
    }

    if (indexNotch == 1)      //notch
    {
        b = Singleton::get_instance()->iirnotch.filter(b);
        return b;
    }
    else {
        return b;
    }

}

