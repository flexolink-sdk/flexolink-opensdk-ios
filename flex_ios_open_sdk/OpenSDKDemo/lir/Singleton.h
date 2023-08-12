//
// Created by hw on 2022/7/20.
//

#ifndef AIRDREAM_SDK_SINGLETON_H
#define AIRDREAM_SDK_SINGLETON_H
#include <iostream>
#include <string>
#include <cstdlib>
#include <vector>
#include <stdio.h>
#include "Iir.h"

class Singleton
{
    public:
        bool isIniate = false;
        static Singleton* get_instance() {
            if(instance == nullptr){
                instance = new Singleton();
            }
            return instance;
        }
        void releaseInstance(){
            delete instance;
            instance = nullptr;
        }
    public:
        void precaculate(double samplingrate, unsigned int indexButter, unsigned int indexNotch, double hp, double lp, double mains);
        double calculate(double a, unsigned int indexNotch, unsigned int indexButter);
        Iir::Butterworth::BandPass<4> bwh;
        Iir::RBJ::IIRNotch iirnotch;
        Iir::Butterworth::BandStop<4> bwBandstop;
        Iir::Butterworth::LowPass<4> lowpass;
        Iir::Butterworth::HighPass<4> highpass;

    private:
        static Singleton* instance;
        Singleton() {
            std::cout << "constructor called!" << std::endl;
        }
        ~Singleton() {
            std:: cout << "destructor called!" << std::endl;
        }
        Singleton(const Singleton&){}

        //注意如果没有下面的释放资源类，在main函数中将手动释放资源
        class CRelease {
        public:
            ~CRelease() { delete instance; }
        };
        static CRelease release;

};

#endif //AIRDREAM_SDK_SINGLETON_H
