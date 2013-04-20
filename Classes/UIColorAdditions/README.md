mRs- / MLUIColorAdditions
=========================

Licence informations: [MIT](https://github.com/mRs-/MLUIColorAdditions/blob/master/LICENCE)

With this category it is easy to handle HEX and RGB Colors within the UIColors class.

Example
-------
``` objective-c
UIColor *colorWithHex = [UIColor colorWithHexString:@"#ff8942" alpha:1];
UIColor *colorWith8Bit = [UIColor colorWith8BitRed:222 green:231 blue:231 alpha:1];
```

It's really easy. Instead of recalculating HEX colors to RGB use this little category like a boss!

Installation
-------
* `#import UIColor+MLColorAdditions.h` where you want to use the HEX / RGB Categories
* `pod install MLUIColorAdditions`
* or just drag the source files in your project
