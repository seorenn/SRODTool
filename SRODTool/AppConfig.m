//
//  AppConfig.m
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 30..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import "AppConfig.h"

#define SRODCFG_WORKINGPATH @"srodcfg_workingpath"
#define SRODCFG_DESTPATH    @"srodcfg_destpath"

@implementation AppConfig

+ (AppConfig *)sharedConfig
{
    static AppConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppConfig alloc] init];
    });
    return sharedInstance;
}

- (NSString *)workingPath
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SRODCFG_WORKINGPATH];
}

- (NSString *)destPath
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SRODCFG_DESTPATH];
}


- (void)setWorkingPath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:SRODCFG_WORKINGPATH];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDestPath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:SRODCFG_DESTPATH];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
