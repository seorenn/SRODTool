//
//  AppDelegate.m
//  SRODTool
//
//  Created by Seorenn
//  Copyright (c) 2013 Seorenn. All rights reserved.
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
    [[ODManager sharedManager] restoreAllSubtitlePaths];
}

@end
