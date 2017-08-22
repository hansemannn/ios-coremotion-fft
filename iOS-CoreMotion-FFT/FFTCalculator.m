//
//  FFTCalculator.m
//  iOS-CoreMotion-FFT
//
//  Created by Hans Knöchel on 15.08.17.
//  Copyright © 2017 Hans Knöchel. All rights reserved.
//

#import "FFTCalculator.h"

@implementation FFTCalculator

- (instancetype)initWithFrameSize:(int)frameSize {
  if (self = [super init]) {
    _motionManager = [[CMMotionManager alloc] init];
    [_motionManager setAccelerometerUpdateInterval:0.01];
    _queue = dispatch_queue_create("de.hsosnabrueck.motion-queue", NULL);
    _fftFrameSize = frameSize;
    _debugEnabled = NO;
    _supported = [_motionManager isAccelerometerAvailable];

    [self initializeFFtSetUP];
  }

  return self;
}

- (void)startUpdatesWithCalculationHandler:
    (FFTCalculationHandler)calculationHandler;
{
  if ([_motionManager isAccelerometerAvailable]) {
    [_motionManager
        startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                             withHandler:^(
                                 CMAccelerometerData *accelerometerData,
                                 NSError *error) {
                               [self processAcceleration:accelerometerData
                                                             .acceleration
                                   andCalculationHandler:calculationHandler];
                             }];
  } else {
    calculationHandler(nil, 0, [NSError errorWithDomain:@"SensorAgentAccelerometerErrorDomain"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Accelerometer is not available on this device", nil)}]);
  }
}

- (void)stopUpdates {
  [_motionManager stopAccelerometerUpdates];
}

- (void)processAcceleration:(CMAcceleration)acceleration
      andCalculationHandler:(FFTCalculationHandler)calculationHandler {
  if (_debugEnabled) {
    NSLog(@"\n\nx=%f\ny=%f\nz=%f", acceleration.x, acceleration.y,
          acceleration.z);
  }

  [_accelerometerValues addObject:[NSNumber numberWithDouble:acceleration.x]];

  if (_mAccelFFTLength - _accelerometerValues.count == 0) {
    [self calculateFastFourierTransformWithCompletion:^(NSArray *values, float mean, NSError *error) {
      calculationHandler(values, mean, error);
      
      if (_debugEnabled) {
        NSLog(@"Fourier: %p", [values componentsJoinedByString:@"\n"]);
      }
      
      dispatch_sync(_queue, ^{
        [_accelerometerValues removeAllObjects];
      });
    }];
  }
}

- (void)initializeFFtSetUP {
  _mAccelFFTLength = _fftFrameSize / 2; // 128
  _log2n = log2f(_fftFrameSize / 2) + 1;

  _inputDataSplitComplex.realp =
      (float *)calloc(_mAccelFFTLength, sizeof(Float32));

  _inputDataSplitComplex.imagp =
      (float *)calloc(_mAccelFFTLength, sizeof(Float32));

  _outMagnitudes = (Float32 *)calloc(_mAccelFFTLength, sizeof(Float32));

  _accelerometerValues = [NSMutableArray array];
}

// Huge shout-out to https://stackoverflow.com/questions/32840282/how-to-get-correct-mean-values-after-applying-fourier-transform-on-accelerometer/32843293
// Amazing work!
- (void)calculateFastFourierTransformWithCompletion:(FFTCalculationHandler)completionHandler {
  _fft_weights = vDSP_create_fftsetup(_log2n, kFFTRadix2);
  float meanVal = 0.0;

  for (NSUInteger currentIndex = 0; currentIndex < _mAccelFFTLength;
       currentIndex++) {
    _inputDataSplitComplex.realp[currentIndex] =
        (float)[[_accelerometerValues objectAtIndex:currentIndex] floatValue];
    _inputDataSplitComplex.imagp[currentIndex] = 0.0f;
  }
  vDSP_fft_zrip(_fft_weights, &_inputDataSplitComplex, 1, _log2n,
                kFFTDirection_Forward);

  _inputDataSplitComplex.realp[0] = 0.0;
  _inputDataSplitComplex.imagp[0] = 0.0;

  // Get magnitudes
  vDSP_zvmags(&_inputDataSplitComplex, 1, _outMagnitudes, 1, _mAccelFFTLength);
  
  float *outMagnitudesScalar = (Float32 *)calloc(_mAccelFFTLength, sizeof(Float32));
  float factor = 2.0 / _mAccelFFTLength;
  
  // Scalar-multiplication
  vDSP_vsmul(_outMagnitudes, 1, &factor, outMagnitudesScalar, 1, _mAccelFFTLength);

  // Calculate mean value
  vDSP_meanv(outMagnitudesScalar, 1, &meanVal, _mAccelFFTLength);
  
  NSMutableArray<NSNumber *> *values = [NSMutableArray arrayWithCapacity:_mAccelFFTLength];
  
  for (int i = 0; i < _mAccelFFTLength; i++) {
    [values addObject:[NSNumber numberWithFloat:outMagnitudesScalar[i]]];
  }
  
  vDSP_destroy_fftsetup(_fft_weights);
  _fft_weights = nil;
  
  completionHandler(values, sqrtf(meanVal), nil);
}

@end
