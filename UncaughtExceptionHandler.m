//
//  UncaughtExceptionHandler.m
//  JRPlot
//
//  Created by __无邪_ on 15/2/3.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import <sys/sysctl.h>

#define Mail @"osmk@qq.com"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;


NSString *devicePlatform(){
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) {
        
        platform = @"iPhone";
        
    } else if ([platform isEqualToString:@"iPhone1,2"]) {
        
        platform = @"iPhone 3G";
        
    } else if ([platform isEqualToString:@"iPhone2,1"]) {
        
        platform = @"iPhone 3GS";
        
    } else if ([platform isEqualToString:@"iPhone3,1"]||[platform isEqualToString:@"iPhone3,2"]||[platform isEqualToString:@"iPhone3,3"]) {
        
        platform = @"iPhone 4";
        
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        
        platform = @"iPhone 4S";
        
    } else if ([platform isEqualToString:@"iPhone5,1"]||[platform isEqualToString:@"iPhone5,2"]) {
        
        platform = @"iPhone 5";
        
    }else if ([platform isEqualToString:@"iPhone5,3"]||[platform isEqualToString:@"iPhone5,4"]) {
        
        platform = @"iPhone 5C";
        
    }else if ([platform isEqualToString:@"iPhone6,2"]||[platform isEqualToString:@"iPhone6,1"]) {
        
        platform = @"iPhone 5S";
        
    }else if ([platform isEqualToString:@"iPhone7,2"]) {
        
        platform = @"iPhone 6";
        
    }else if ([platform isEqualToString:@"iPhone7,1"]) {
        
        platform = @"iPhone 6 plus";
        
    }else if ([platform isEqualToString:@"iPod4,1"]) {
        
        platform = @"iPod touch 4";
        
    }else if ([platform isEqualToString:@"iPod5,1"]) {
        
        platform = @"iPod touch 5";
        
    }else if ([platform isEqualToString:@"iPod3,1"]) {
        
        platform = @"iPod touch 3";
        
    }else if ([platform isEqualToString:@"iPod2,1"]) {
        
        platform = @"iPod touch 2";
        
    }else if ([platform isEqualToString:@"iPod1,1"]) {
        
        platform = @"iPod touch";
        
    } else if ([platform isEqualToString:@"iPad3,2"]||[platform isEqualToString:@"iPad3,1"]) {
        
        platform = @"iPad 3";
        
    } else if ([platform isEqualToString:@"iPad2,2"]||[platform isEqualToString:@"iPad2,1"]||[platform isEqualToString:@"iPad2,3"]||[platform isEqualToString:@"iPad2,4"]) {
        
        platform = @"iPad 2";
        
    }else if ([platform isEqualToString:@"iPad1,1"]) {
        
        platform = @"iPad 1";
        
    }else if ([platform isEqualToString:@"iPad2,5"]||[platform isEqualToString:@"iPad2,6"]||[platform isEqualToString:@"iPad2,7"]) {
        
        platform = @"ipad mini";
        
    } else if ([platform isEqualToString:@"iPad3,3"]||[platform isEqualToString:@"iPad3,4"]||[platform isEqualToString:@"iPad3,5"]||[platform isEqualToString:@"iPad3,6"]) {
        
        platform = @"ipad 3";

    }
    
    return platform;
}



NSString* getAppInfo()
{
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@--%@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         devicePlatform(),
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    //	    [UIDevice currentDevice].uniqueIdentifier];
    NSLog(@"Crash!!!! %@", appInfo);
    return appInfo;
}


void MySignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    if(signal==11)
    {//可能是内存不足
        UIAlertView * tip2 = [[UIAlertView alloc]initWithTitle:@"可能原因:key" message:@"内存不足" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [tip2 show];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:
                                     [NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:
      [NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.\n" @"%@", nil), signal, getAppInfo()] userInfo:
      [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]] waitUntilDone:YES];
    
}


@interface UncaughtExceptionHandler ()<UIAlertViewDelegate>
@end
@implementation UncaughtExceptionHandler

+(void)InstallUncaughtExceptionHandler{
    signal(SIGABRT, MySignalHandler);
    signal(SIGILL, MySignalHandler);
    signal(SIGSEGV, MySignalHandler);
    signal(SIGFPE, MySignalHandler);
    signal(SIGBUS, MySignalHandler);
    signal(SIGPIPE, MySignalHandler);
}
+ (NSArray *)backtrace{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++){
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex{
    if (anIndex == 0){
        dismissed = YES;
    }
}
- (void)handleException:(NSException *)exception{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
                                                    message:
                          [NSString stringWithFormat:NSLocalizedString(@"You can try to continue but the application may be unstable.\n" @"%@\n%@", nil),[exception reason], [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
      delegate:self
      cancelButtonTitle:NSLocalizedString(@"Quit", nil)
      otherButtonTitles:NSLocalizedString(@"Continue", nil), nil];
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed){
        for (NSString *mode in (__bridge NSArray *)allModes){
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]){
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }else{
        [exception raise];
    }
}

void UncaughtExceptionHandlers (NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *urlStr = [NSString stringWithFormat:
                        @"mailto://%@?subject=bug报告&body=感谢您的配合!<br><br><br>""错误详情:<br>%@<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",Mail,getAppInfo(),name,reason,[arr componentsJoinedByString:@"<br>"]];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
    
    //或者直接用代码，输入这个崩溃信息，以便在console中进一步分析错误原因
    NSLog(@"1heqin, CRASH: %@", exception);
    NSLog(@"heqin, Stack Trace: %@", [exception callStackSymbols]);
}

@end

