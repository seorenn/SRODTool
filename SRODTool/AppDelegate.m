//
//  AppDelegate.m
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 27..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"application will terminate...");
    [[ODManager sharedManager] restoreAllSubtitlePaths];
}

@end
