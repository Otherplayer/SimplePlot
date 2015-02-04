//
//  UncaughtExceptionHandler.h
//  JRPlot
//
//  Created by __无邪_ on 15/2/3.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UncaughtExceptionHandler : NSObject
{
    BOOL dismissed;
}
void UncaughtExceptionHandlers (NSException *exception);
+ (void) InstallUncaughtExceptionHandler;




+ (NSArray *)backtrace;
- (void)handleException:(NSException *)exception;
@end
