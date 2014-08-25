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
        [TSMessage dismissActiveNotification];
    });
    
    it(@"matches view (error message)", ^{
        [TSMessage showNotificationWithTitle:@"Error" type:TSMessageNotificationTypeError];
        TSMessageView *view = [[TSMessage queuedMessages] lastObject];
        
        expect(view).to.haveValidSnapshotNamed(@"TSMessageViewErrorDefault");
    });
});

SpecEnd
