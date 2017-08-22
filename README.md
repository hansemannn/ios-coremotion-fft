# iOS CoreMotion FFT
Calculate FFT values based on iOS CoreMotion accelerometer data.

## Credits
Huge shout-out to [this StackOverflow](https://stackoverflow.com/questions/32840282/how-to-get-correct-mean-values-after-applying-fourier-transform-on-accelerometer/32843293) which provided the core-algorithm used to calculate FFT values.

## Usage
This is an example project containing the `FFTCalculator` library I wrote to wrap the FFT-functionality.
Here is an example usage (Obj-C):
```objc
#import "FFTCalculator.h"

- (void)viewDidLoad {
  [super viewDidLoad];

  // Initialize calculator with frame size
  FFTCalculator *fftCalculator = [[FFTCalculator alloc] initWithFrameSize:256];
  
  // Check if the CoreMotion sensor is available (= FFTCalculator is supported)
  if (![fftCalculator isSupported]) {
    NSLog(@"Error: FFTCalculator not supported due to device restrictions");
    NSLog("@Please run this project on the device to use the CoreMotion sensor.");
    return;
  }
  
  // Start updates
  [fftCalculator startUpdatesWithCalculationHandler:^(NSArray<NSNumber *> * _Nullable values, float mean, NSError * _Nullable error) {
    NSLog(@"\nFourier values: %@", values);
    NSLog(@"Fourier mean-value: %f", mean);
  }];

  // Stop updates
  [fftCalculator stopUpdates];
}
```

## Copyright
MIT

## Author
Hans Knöchel
