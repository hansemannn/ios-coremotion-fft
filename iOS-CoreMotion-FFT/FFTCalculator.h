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

typedef void (^FFTCalculationHandler)(NSArray<NSNumber *>  * _Nullable values, float mean, NSError * _Nullable error);

@interface FFTCalculator : NSObject {
@private
  FFTSetup _fft_weights;
  DSPSplitComplex _inputDataSplitComplex;
  float *_outMagnitudes;
  int _mAccelFFTLength;
  int _log2n;
  int _fftFrameSize;

  CMMotionManager *_motionManager;
  dispatch_queue_t _queue;
  NSMutableArray<NSNumber *> *_accelerometerValues;
}

/**
 @abstract Determines whether the acceleratometer-updates are supported.
 */
@property (nonatomic, assign, getter=isSupported) BOOL supported;

/**
 @abstract Determines whether debug-logs are enabled.
 */
@property (nonatomic, assign, getter=isDebugEnabled) BOOL debugEnabled;

/**
 @abstract Creates a new FFT-calculator based on the frame-size.
 
 @param frameSize The frame-size to use
 @return The new instance.
 */
- (instancetype)initWithFrameSize:(int)frameSize;

/**
 @abstract Starts new calculation-updates.
 
 @param calculationHandler The calculation-handler called when new updates are
 available or an error occured.
 */
- (void)startUpdatesWithCalculationHandler:
    (FFTCalculationHandler)calculationHandler;

/**
 @abstract Stops calculation-updates.
 */
- (void)stopUpdates;

@end

NS_ASSUME_NONNULL_END
