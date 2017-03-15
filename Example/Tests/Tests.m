//
//  TSMessagesTests.m
//  TSMessagesTests
//
//  Created by Felix Krause on 08/25/2014.
//  Copyright (c) 2014 Felix Krause. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"

SpecBegin(InitialSpecs)

describe(@"Show a new TSMessage notification", ^{
    before(^{
        [UIView setAnimationsEnabled:NO];
        [TSMessage dismissAllNotifications];
        expect([TSMessage queuedMessages]).after(5).will.haveCountOf(0);
    });
    
    it(@"matches view (error message)", ^{
        [TSMessage showNotificationWithTitle:@"Error" type:TSMessageNotificationTypeError];
        TSMessageView *view = [[TSMessage queuedMessages] lastObject];
        
        expect(view).to.haveValidSnapshotNamed(@"TSMessageViewErrorDefault");
    });

    fit(@"should handle spam dismissals", ^{
        [UIView setAnimationsEnabled:YES];
        
        [TSMessage showNotificationWithTitle:@"One" type:TSMessageNotificationTypeError];
        TSMessageView* currentView = [[TSMessage queuedMessages] firstObject];

        expect(currentView.title).to.equal(@"One");

        for (int i = 0; i < 5000; i++) {
            [TSMessage dismissAllNotifications];
        }

        expect(currentView.superview).after(5).will.beNil();
    });
});

SpecEnd
