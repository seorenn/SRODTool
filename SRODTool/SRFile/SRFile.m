//
//  SRFile.m
//  SRToolkit for Cocoa
//
//  Created by Seorenn
//

#import "SRFile.h"

@implementation SRFile

@synthesize name = _name;
@synthesize containerPath = _containerPath;

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _sharedFM = [NSFileManager defaultManager];
        self.originalPath = path;
        self.path = path;
        [self fetchNames];
    }
    return self;
}

- (void)fetchNames
{
    if (!self.path) {
        _name = nil;
        _containerPath = nil;
    } else {
        _name = [self.path lastPathComponent];
        _containerPath = [self.path stringByDeletingLastPathComponent];
    }
}

- (BOOL)hasExtensionName:(NSString *)extName
{
    if (!self.name) return NO;
    
    NSString *ext = [[self name] pathExtension];
    if ([ext length] <= 0) return NO;
    
    if ([ext isEqualToString:extName]) return YES;
    return NO;
}

- (BOOL)hasExtensionFromNames:(NSArray *)extNames
{
    for (NSString *extName in extNames) {
        if ([self hasExtensionName:extName]) return YES;
    }
    return NO;
}

- (void)remove
{
    if (!self.path || !self.originalPath) return;
    
    NSError *error = nil;
    [_sharedFM removeItemAtPath:self.path error:&error];
    
    if (error) {
        NSLog(@"[SRFile remove] Error: %@", error);
    } else {
        self.path = nil;
        self.originalPath = nil;
    }
}

- (void)renameTo:(NSString *)name
{
    if (!self.path || !self.originalPath) return;

    NSString *path = [[self containerPath] stringByAppendingPathComponent:name];
    [self moveTo:path];
    
    self.path = path;
    [self fetchNames];
}

- (void)moveTo:(NSString *)path
{
    if (!self.path || !self.originalPath) return;
    
    BOOL isDirectory = NO;
    
    NSError *error = nil;
    [_sharedFM moveItemAtPath:self.path toPath:path error:&error];
    
    if (error) {
        NSLog(@"[SRFile moveTo] Error: %@", error);
        return;
    }

    if ([_sharedFM fileExistsAtPath:path isDirectory:&isDirectory])
    {
        if (isDirectory == NO) {
            self.path = path;
        }
        else {
            self.path = [path stringByAppendingPathComponent:self.name];
        }
        [self fetchNames];
    }
}

// Restore file name and path
- (void)restore
{
    if ([self.path isEqualToString:self.originalPath] == NO) {
        NSLog(@"[RESTORE] %@ -> %@", self.path, self.originalPath);
        [self moveTo:self.originalPath];
    }
}

- (BOOL)isDirectory
{
    BOOL isDirectory = NO;
    [_sharedFM fileExistsAtPath:self.path isDirectory:&isDirectory];
    return isDirectory;
}

- (BOOL)isFile
{
    return ![self isDirectory];
}

- (BOOL)isHidden
{
    return [[self name] hasPrefix:@"."];
}

@end
