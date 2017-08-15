//
//  ViewController.h
//  iOS-CoreMotion-FFT
//
//  Created by Hans Knöchel on 15.08.17.
//  Copyright © 2017 Hans Knöchel. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Accelerate;
@import CoreMotion;

@interface ViewController : UIViewController {
  FFTSetup fft_weights;
  DSPSplitComplex inputDataSplitComplex;
  Float32 *outMagnitudes;
  UInt32  mAccelFFTLength;
  UInt32 log2n;
  UInt32 fftFrameSize;
  int fftsize;
  
  CMMotionManager *motionManager;
  dispatch_queue_t queue;
  NSMutableArray<NSNumber *> *__accelerometerData;
}


@end

