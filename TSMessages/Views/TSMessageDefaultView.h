//
//  TSMessageDefaultView.h
//  Pods
//
//  Created by Fedya Skitsko on 4/4/14.
//
//

#import <UIKit/UIKit.h>

#import "TSMessageView.h"
#import "TSMessageDefaultItem.h"

@interface TSMessageDefaultView : TSMessageView

@property (nonatomic, strong) TSMessageDefaultItem *item;

@end