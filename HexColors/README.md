HexColors
=========================
![Badge w/ Version](http://cocoapod-badges.herokuapp.com/v/HexColors/badge.png)

![Badge w/ Version](http://cocoapod-badges.herokuapp.com/p/HexColors/badge.png)

HexColors is easy drop in category for HexColor integration in iOS and Mac OS X. Its build as a category for easy to use and can be used for UIColor and NSColor class.

#Example iOS
``` objective-c
UIColor *colorWithHex = [UIColor colorWithHexString:@"#ff8942" alpha:1];
```

#Example Mac OS X
``` objective-c
NSColor *colorWithHex = [NSColor colorWithHexString:@"#ff8942" alpha:1];
```

#Installation
* `#import HexColors.h` where you want to use easy as pie HexColors
* `pod install HexColors`
* or just drag the source files in your project

##Requirements
HexColors requires [iOS 5.0](http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniPhoneOS/Articles/iPhoneOS4.html) and above, and Mac OS X 10.6

#ToDos
* Implementing Hex Alpha values

##Credits
HexColors was created by [Marius Landwehr](https://github.com/mRs-) because of the pain recalculating Hex values to RGB.

HexColors was ported to Mac OS X by [holgersindbaek](https://github.com/holgersindbaek).

##Creator
[Marius Landwehr](https://github.com/mRs-) [@mariusLAN](https://twitter.com/mariusLAN)

##License
HexColors is available underthe MIT license. See the LICENSE file for more info.
