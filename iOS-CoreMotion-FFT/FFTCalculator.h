//
//  FFTCalculator.h
//  iOS-CoreMotion-FFT
//
//  Created by Hans Knöchel on 15.08.17.
//  Copyright © 2017 Hans Knöchel. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FFTCalculationHandler)(CGFloat value);

@interface FFTCalculator : NSObject {
@private
  FFTSetup fft_weights;
  DSPSplitComplex inputDataSplitComplex;
  float *outMagnitudes;
  int mAccelFFTLength;
  int log2n;
  int fftFrameSize;

  CMMotionManager *motionManager;
  dispatch_queue_t queue;
  NSMutableArray<NSNumber *> *__accelerometerData;
}

@property(nonatomic, assign, getter=isDebugEnabled) BOOL debugEnabled;

- (instancetype)initWithFrameSize:(int)frameSize;

- (void)startUpdatesWithCalculationHandler:
    (FFTCalculationHandler)calculationHandler;

- (void)stopUpdates;

@end

NS_ASSUME_NONNULL_END
