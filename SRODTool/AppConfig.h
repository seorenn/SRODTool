//
//  AppConfig.h
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 30..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

+ (AppConfig *)sharedConfig;
- (NSString *)workingPath;
- (void)setWorkingPath:(NSString *)path;

@end
