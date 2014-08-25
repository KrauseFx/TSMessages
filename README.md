TSMessages
==========

This library provides an easy to use class to show little notification views on the top of the screen. (à la Tweetbot).
[![CI Status](http://img.shields.io/travis/Felix Krause/TSMessages.svg?style=flat)](https://travis-ci.org/Felix Krause/TSMessages)
[![Version](https://img.shields.io/cocoapods/v/TSMessages.svg?style=flat)](http://cocoadocs.org/docsets/TSMessages)
[![License](https://img.shields.io/cocoapods/l/TSMessages.svg?style=flat)](http://cocoadocs.org/docsets/TSMessages)
[![Platform](https://img.shields.io/cocoapods/p/TSMessages.svg?style=flat)](http://cocoadocs.org/docsets/TSMessages)

The notification moves from the top of the screen underneath the navigation bar and stays there for a few seconds, depending on the length of the displayed text. To dismiss a notification before the time runs out, the user can swipe it to the top or just tap it.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots)

It is very easy to add new notification types with a different design. Add the new type to the notificationType enum, add the needed design properties to the configuration file and set the name of the theme (used in the config file and images) in TSMessagesView.m inside the switch case.

**Take a look at the Example project to see how to use this library.** You have to open the workspace, not the project file, since the Example project uses cocoapods.

## Author
Follow the developer on Twitter: [KrauseFx](http://twitter.com/KrauseFx) (Felix Krause)

## Installation

### From CocoaPods
TSMessages is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TSMessages"

## License

TSMessages is available under the MIT license. See the LICENSE file for more info.

```objective-c
To show notifications use the following code:
--------
    [TSMessage showNotificationWithTitle:title
                                subtitle:subtitle
                                    type:TSMessageNotificationTypeError];


    // Add a button inside the message
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"New version available", nil)
                                       subtitle:NSLocalizedString(@"Please update our app. We would be very thankful", nil)
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:NSLocalizedString(@"Update", nil)
                                 buttonCallback:^{
                                     [TSMessage showNotificationWithTitle:NSLocalizedString(@"Thanks for updating", nil)
                                                                     type:TSMessageNotificationTypeSuccess];
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:YES];

    // Use a custom design file
    [TSMessage addCustomDesignFromFileWithName:@"AlternativeDesign.json"];
```

The following properties can be set:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The notification type (Message, Warning, Error, Success)
* **duration**: The duration the notification should be displayed
* **callback**: The block that should be executed, when the user dismissed the message by tapping on it or swiping it to the top.

Except the title and the notification type, all of the listed values are optional

You don't need to do anything with TSMessageView, except you want to modify the behavior or the types of the notification itself.

If you don't want a detailed description (the text underneath the title) you don't need to set one. The notification will automatically resize itself properly. There are different initializer available.

![Warning](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationWarning.png)
![Success](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationSuccess.png)
![Error](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationError.png)
![Message](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationMessage.png)

**iOS 7 Support**

![iOS 7 Error](http://www.toursprung.com/wp-content/uploads/2013/09/error_ios7.png)
![iOS 7 Message](http://www.toursprung.com/wp-content/uploads/2013/09/warning_ios7.png)

This project requires ARC.

If you have ideas how to improve this library please let me know or send a pull request.

**Recent changes can be found in the releases section of this repo.**