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
  [fftCalculator startUpdatesWithCalculationHandler:^(CGFloat value) {
    NSLog(@"Fourier: %f", value);
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
