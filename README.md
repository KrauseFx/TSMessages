TSMessages
==========

This framework provides an easy to use class to display message views (à la Tweetbot).

The message moves from the top of the screen underneath the navigation bar and stays there for a few seconds, depending on the length of the displayed text. To dismiss a message before the time runs out, the user can swipe it to the top or just tap it.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots).

It is very easy to add new message types with a different design. Add the new type to the message type enum, add the needed design properties to the configuration file and set the name of the theme (used in the config file and images) in TSMessagesView.m inside the switch case.

**Take a look at the Example project to see how to use this library.** You have to open the workspace, not the project file, since the Example project uses cocoapods.

Follow the developer on Twitter: [KrauseFx](http://twitter.com/krausefx) (Felix Krause)

## Installation

### From CocoaPods

Add `pod 'TSMessages'` to your Podfile.

### Manually

Drag the whole folder into your project and remove the example project. This library requires ARC.

Drag HexColors{.h/.m} from Submodules/HexColors/Classes into your project.

To display messages use the following code:
--------

```objective-c
    [TSMessage displayMessageWithTitle:title
                              subtitle:subtitle
                                  type:TSMessageTypeError];

    // Add a button to the message
    TSMessageView *view = [TSMessage messageWithTitle:@"New version available"
                                             subtitle:@"Please update our app"
                                                 type:TSMessageTypeDefault];

    [view setButtonWithTitle:NSLocalizedString(@"Update", nil) callback:^(TSMessageView *messageView) {
        [messageView dismiss];

        [TSMessage displayMessageWithTitle:NSLocalizedString(@"Thanks for updating", nil)
                                  subtitle:nil
                                      type:TSMessageTypeSuccess];
    }];

    [view displayOrEnqueue];

    // Use a custom design file
    [TSMessage addCustomDesignFromFileWithName:@"AlternativeDesign.json"];
```

The following properties can be set:

* **viewController**: The view controller to show the message in. This might be the navigation controller.
* **title**: The title of the message view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The message type (Message, Warning, Error, Success)
* **duration**: The duration the message should be displayed (optional)
* **callback**: The block that should be executed, when the user dismissed the message by swiping it away (optional)

Except the title and the message type, all of the listed values are optional

You don't need to do anything with TSMessageView, except you want to modify the behavior or the types of the message itself.

If you don't want a detailed description (the text underneath the title) you don't need to set one. The message will automatically resize itself properly.

![iOS 7 Error](http://www.toursprung.com/wp-content/uploads/2013/09/error_ios7.png)
![iOS 7 Message](http://www.toursprung.com/wp-content/uploads/2013/09/warning_ios7.png)

This project requires ARC.

If you have ideas how to improve this library please let me know or send a pull request.

Changes
-----

**0.9.4**
* Added new initializer (Sorry about that, it was necessary)
* Added easy way to customize the design with an additional design file
* Added iOS 7 support

**0.9.3**

* Added new customization options for buttons (font size, custom background image, separate font and shadow color)
* Added method to dismiss the currently active message
* Added option to show a message until it is dismissed by the user
* Added option to disable dismissing message by the user
* Added method to check whether a message is currently being displayed
* Fixed auto rotation when message is displayed on the bottom

**0.9.2**

* Added option to show message on the bottom of the screen
* Added option to show a button inside the message


TODOs
-----
* Fix/improve blur effect
* Potentially support UIKit Dynamics
