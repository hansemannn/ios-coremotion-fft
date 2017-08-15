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
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 0.01;
    queue = dispatch_queue_create("de.hsosnabrueck.motion-queue", NULL);
    fftFrameSize = frameSize;
    _debugEnabled = NO;

    [self initializeFFtSetUP];
  }

  return self;
}

- (void)startUpdatesWithCalculationHandler:
    (FFTCalculationHandler)calculationHandler;
{
  if ([motionManager isAccelerometerAvailable]) {
    [motionManager
        startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                             withHandler:^(
                                 CMAccelerometerData *accelerometerData,
                                 NSError *error) {
                               [self processAcceleration:accelerometerData
                                                             .acceleration
                                   andCalculationHandler:calculationHandler];
                             }];
  } else {
    NSLog(@"Error: Accelerometer not available on this device!");
  }
}

- (void)stopUpdates {
  [motionManager stopAccelerometerUpdates];
}

- (void)processAcceleration:(CMAcceleration)acceleration
      andCalculationHandler:(FFTCalculationHandler)calculationHandler {
  if (_debugEnabled) {
    NSLog(@"\n\nx=%f\ny=%f\nz=%f", acceleration.x, acceleration.y,
          acceleration.z);
  }

  [__accelerometerData addObject:[NSNumber numberWithDouble:acceleration.x]];

  if (mAccelFFTLength - __accelerometerData.count == 0) {
    float fftValue = [self calculateFastFourierTransform];
    calculationHandler(fftValue);

    if (_debugEnabled) {
      NSLog(@"Fourier: %f", fftValue);
    }

    dispatch_sync(queue, ^{
      [__accelerometerData removeAllObjects];
    });
  }
}

- (void)initializeFFtSetUP {
  mAccelFFTLength = fftFrameSize / 2; // 128
  log2n = log2f(fftFrameSize / 2) + 1;

  inputDataSplitComplex.realp =
      (float *)calloc(mAccelFFTLength, sizeof(Float32));

  inputDataSplitComplex.imagp =
      (float *)calloc(mAccelFFTLength, sizeof(Float32));

  fft_weights = vDSP_create_fftsetup(log2n, kFFTRadix2);
  outMagnitudes = (Float32 *)calloc(mAccelFFTLength, sizeof(Float32));

  __accelerometerData = [NSMutableArray array];
}

// Huge shout-out to https://stackoverflow.com/questions/32840282/how-to-get-correct-mean-values-after-applying-fourier-transform-on-accelerometer/32843293
// Amazing work!
- (Float32)calculateFastFourierTransform {
  float meanVal = 0.0;

  for (NSUInteger currenIndex = 0; currenIndex < mAccelFFTLength;
       currenIndex++) {
    inputDataSplitComplex.realp[currenIndex] =
        (float)[[__accelerometerData objectAtIndex:currenIndex] floatValue];
    inputDataSplitComplex.imagp[currenIndex] = 0.0f;
  }
  vDSP_fft_zrip(fft_weights, &inputDataSplitComplex, 1, log2n,
                kFFTDirection_Forward);

  inputDataSplitComplex.realp[0] = 0.0;
  inputDataSplitComplex.imagp[0] = 0.0;

  // Get magnitudes
  vDSP_zvmags(&inputDataSplitComplex, 1, outMagnitudes, 1, mAccelFFTLength);
  //  vDSP_vsq(outMagnitudes, 1, outMagnitudes, 1, mAccelFFTLength);//square
  vDSP_meanv(outMagnitudes, 1, &meanVal, mAccelFFTLength);

  return sqrtf(meanVal);
}

@end
