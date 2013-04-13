TSMessages
==========

This framework provides an easy to use class to show little notification views on the top of the screen. (à la Tweetbot). 

The notification moves from the top of the screen underneath the navigation bar and stays there for a few seconds, depending on the length of the displayed text. To dismiss a notification before the time runs out, the user can swipe it to the top or just tap it.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots)

It is very easy to add new notification types with a different design. Add the new type to the notificationType enum, add the needed design properties to the configuration file and set the name of the theme (used in the config file and images) in TSMessagesView.m inside the switch case. 

**Take a look at the Example project to see how to use this library.** You have to open the workspace, not the project file, since the Example project uses cocoapods.

Currently installation can just be done by dragging in all folders besides the example project. In the future we'll provide a regular cocoapod for easier integration.

To show notifications use the following code:
--------

```objective-c
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:kNotificationError];
```

You don't need to do anything with TSMessageView, except you want to modify the behavior or the types of the notification itself.

If you don't want a detailed description (text underneath the title) you don't need to set one. The notification will automatically resize itself properly. There are different initializer available.

![Warning](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationWarning.png)
![Success](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationSuccess.png)
![Error](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationError.png)
![Message](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationMessage.png)

This project requires ARC.

If you have ideas how to improve this library please let me know or send a pull request.