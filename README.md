TSMessages
==========

This library provides an easy to use class to show little notification views on the top of the screen. (à la Tweetbot).

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![Version](https://img.shields.io/cocoapods/v/TSMessages.svg?style=flat)](http://cocoadocs.org/docsets/TSMessages)
[![License](https://img.shields.io/cocoapods/l/TSMessages.svg?style=flat)](http://cocoadocs.org/docsets/TSMessages)
[![Platform](https://img.shields.io/cocoapods/p/TSMessages.svg?style=flat)](http://cocoadocs.org/docsets/TSMessages)

The notification moves from the top of the screen underneath the navigation bar and stays there for a few seconds, depending on the length of the displayed text. To dismiss a notification before the time runs out, the user can swipe it to the top or just tap it.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots)

It is very easy to add new notification types with a different design. Add the new type to the notificationType enum, add the needed design properties to the configuration file and set the name of the theme (used in the config file and images) in TSMessagesView.m inside the switch case.

**Take a look at the Example project to see how to use this library.** You have to open the workspace, not the project file, since the Example project uses cocoapods.

Follow the developer on Twitter: [KrauseFx](http://twitter.com/KrauseFx) (Felix Krause)

# Installation

## From CocoaPods
TSMessages is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TSMessages"
    
## Manually
Copy the source files TSMessageView and TSMessage into your project. Also copy the TSMessagesDesignDefault.json.

# Usage

To show notifications use the following code:

```objective-c
    [TSMessage showNotificationWithTitle:@"Your Title"
                                subtitle:@"A description"
                                    type:TSMessageNotificationTypeError];


    // Add a button inside the message
    [TSMessage showNotificationInViewController:self
                                          title:@"Update available"
                                       subtitle:@"Please update the app"
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:@"Update"
                                 buttonCallback:^{
                                     NSlog(@"User tapped the button");
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];


    // Use a custom design file
    [TSMessage addCustomDesignFromFileWithName:@"AlternativeDesign.json"];
```

You can define a default view controller in which the notifications should be displayed:
```objective-c
   [TSMessage setDefaultViewController:myNavController];
```

You can define a default view controller in which the notifications should be displayed:
```objective-c
   [TSMessage setDelegate:self];
   
   ...
   
   - (CGFloat)messageLocationOfMessageView:(TSMessageView *)messageView
   {
    return messageView.viewController...; // any calculation here
   }
```

You can customize a message view, right before it's displayed, like setting an alpha value, or adding a custom subview
```objective-c
   [TSMessage setDelegate:self];
   
   ...
   
   - (void)customizeMessageView:(TSMessageView *)messageView
   {
      messageView.alpha = 0.4;
      [messageView addSubview:...];
   }
```

The following properties can be set when creating a new notification:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The notification type (Message, Warning, Error, Success)
* **duration**: The duration the notification should be displayed
* **callback**: The block that should be executed, when the user dismissed the message by tapping on it or swiping it to the top.

Except the title and the notification type, all of the listed values are optional

If you don't want a detailed description (the text underneath the title) you don't need to set one. The notification will automatically resize itself properly. 

## Screenshots

**iOS 7 Design**

![iOS 7 Error](http://www.toursprung.com/wp-content/uploads/2013/09/error_ios7.png)

![iOS 7 Message](http://www.toursprung.com/wp-content/uploads/2013/09/warning_ios7.png)

**iOS 6 Design**

![Warning](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationWarning.png)

![Success](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationSuccess.png)

![Error](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationError.png)

![Message](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationMessage.png)


# License
TSMessages is available under the MIT license. See the LICENSE file for more information.

# Recent Changes
Can be found in the [releases section](https://github.com/toursprung/TSMessages/releases) of this repo.