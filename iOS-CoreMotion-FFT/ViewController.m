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
  if (![fftCalculator isSupported]) {
    return NSLog(@"Error: FFTCalculator not supported due to device restrictions - Please run this project on the device to use the CoreMotion sensor.");
  }

  [fftCalculator startUpdatesWithCalculationHandler:^(NSArray<NSNumber *> * _Nullable values, float mean, NSError * _Nullable error) {
    NSLog(@"\nFourier values: %@", values);
    NSLog(@"Fourier mean-value: %f", mean);
  }];
}

- (IBAction)stopUpdates:(id)sender {
  [fftCalculator stopUpdates];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  fftCalculator = [[FFTCalculator alloc] initWithFrameSize:256];
}

@end
