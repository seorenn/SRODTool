//
//  AppConfig.h
//  SRODTool
//
//  Created by Seorenn
//  Copyright (c) 2013 Seorenn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

+ (AppConfig *)sharedConfig;
- (NSString *)workingPath;
- (NSString *)destPath;
- (void)setWorkingPath:(NSString *)path;
- (void)setDestPath:(NSString *)path;

@end
