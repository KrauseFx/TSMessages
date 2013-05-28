TSMessages
==========

This framework provides an easy to use class to show little notification views on the top of the screen. (à la Tweetbot). 

The notification moves from the top of the screen underneath the navigation bar and stays there for a few seconds, depending on the length of the displayed text. To dismiss a notification before the time runs out, the user can swipe it to the top or just tap it.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots)

It is very easy to add new notification types with a different design. Add the new type to the notificationType enum, add the needed design properties to the configuration file and set the name of the theme (used in the config file and images) in TSMessagesView.m inside the switch case. 

**Take a look at the Example project to see how to use this library.** You have to open the workspace, not the project file, since the Example project uses cocoapods.

Follow the developer on Twitter: [KrauseFx](http://twitter.com/krausefx) (Felix Krause)

## Installation

### From CocoaPods

Add `pod 'TSMessages'` to your Podfile.

### Manually

Drag the whole folder into your project and remove the example project. This library requires ARC.

To show notifications use the following code:
--------

```objective-c
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeError];


    [TSMessage showNotificationInViewController:self
                                      withTitle:title
                                    withMessage:message
                                       withType:TSMessageNotificationTypeSuccess
                                   withDuration:15.0
                                   withCallback:^{
                                       // user dismissed callback
                                   }];
```

The following properties can be set:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **message**: The message that is displayed underneath the title.
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

This project requires ARC.

If you have ideas how to improve this library please let me know or send a pull request.

Changes
-----
**0.9.3**

* Added new customization options for buttons (font size, custom background image, separate font and shadow color)
* Added method to dismiss the currently active message
* Added option to show a message until it is dismissed by the user
* Added option to disable dismissing notification by the user
* Added method to check whether a notification is currently being displayed
* Fixed auto rotation when notification is displayed on the bottom

**0.9.2**

* Added option to show message on the bottom of the screen
* Added option to show a button inside the message




TODOs
-----
Currently empty