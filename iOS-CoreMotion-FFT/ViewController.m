//
//  ViewController.m
//  iOS-CoreMotion-FFT
//
//  Created by Hans Knöchel on 15.08.17.
//  Copyright © 2017 Hans Knöchel. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
- (IBAction)startUpdates:(id)sender {
  if ([motionManager isAccelerometerAvailable]) {
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                        withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                          [self processAcceleration:accelerometerData.acceleration];
                                        }];
  } else {
    NSLog(@"Error: Accelerometer not available on this device!");
  }

}

- (IBAction)stopUpdates:(id)sender {
  [motionManager stopAccelerometerUpdates];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  motionManager = [[CMMotionManager alloc] init];
  motionManager.accelerometerUpdateInterval = 0.01;
  queue = dispatch_queue_create("de.hsosnabrueck.motion-queue", NULL);
  
  [self initializeFFtSetUP];
}

- (void)processAcceleration:(CMAcceleration)acceleration
{
  NSLog(@"\n\nx=%f\ny=%f\nz=%f", acceleration.x, acceleration.y, acceleration.z);
  [__accelerometerData addObject:[NSNumber numberWithDouble:acceleration.x]];
  
  if (mAccelFFTLength - __accelerometerData.count == 0) {
    NSLog(@"Fourier: %f", [self calculateFastFourierTransform]);
    dispatch_sync(queue, ^{
      [__accelerometerData removeAllObjects];
    });
  }
}

-(void)initializeFFtSetUP
{
  fftFrameSize = fftsize = 256; //256
  mAccelFFTLength = fftFrameSize / 2; //128
  log2n = log2f(fftFrameSize/2)+1;
  
  inputDataSplitComplex.realp = (Float32 *)calloc(mAccelFFTLength,sizeof(Float32));
  
  inputDataSplitComplex.imagp = (Float32 *)calloc(mAccelFFTLength,sizeof(Float32));
  
  fft_weights = vDSP_create_fftsetup(log2n, kFFTRadix2);
  outMagnitudes = (Float32 *)calloc(mAccelFFTLength,sizeof(Float32));
  
  __accelerometerData = [NSMutableArray array];
}

- (Float32)calculateFastFourierTransform
{
  //accelDataArray is an NSMutableArray of accelerometer data values 'userAcceleration.x'  from CMDeviceMotionManager
  for (NSUInteger currenIndex = 0; currenIndex < mAccelFFTLength; currenIndex++)
  {
    inputDataSplitComplex.realp[currenIndex] = (Float32)[[__accelerometerData objectAtIndex:currenIndex] floatValue];
    inputDataSplitComplex.imagp[currenIndex] = 0.0f;
  }
  vDSP_fft_zrip(fft_weights, &inputDataSplitComplex, 1, log2n, kFFTDirection_Forward);
  
  inputDataSplitComplex.realp[0] = 0.0;
  inputDataSplitComplex.imagp[0] = 0.0;
  
  Float32 meanVal = 0.0;
  
  // Get magnitudes
  vDSP_zvmags(&inputDataSplitComplex, 1, outMagnitudes, 1, mAccelFFTLength);
//  vDSP_vsq(outMagnitudes, 1, outMagnitudes, 1, mAccelFFTLength);//square
  vDSP_meanv(outMagnitudes, 1, &meanVal, mAccelFFTLength);
  
  return sqrtf(meanVal);
}

@end
