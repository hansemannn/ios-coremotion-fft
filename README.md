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
  
  // Start updates
  [fftCalculator startUpdatesWithCalculationHandler:^(CGFloat value) {
    NSLog(@"Fourier value: %f", value);
  }];

  // Stop updates
  [fftCalculator stopUpdates];
}
```

## Copyright
MIT

## Author
Hans Knöchel
