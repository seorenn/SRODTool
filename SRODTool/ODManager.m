//
//  ODManager.m
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 27..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import "ODManager.h"

@implementation ODFile
@synthesize name = _name;
@synthesize file = _file;
@synthesize coupleFile;
- (id)initWithFile:(SRFile *)f
{
    self = [super init];
    if (self) {
        _name = [NSString stringWithString:[f name]];
        _file = f;
        self.coupleFile = nil;
    }
    return self;
}
- (BOOL)coupled
{
    if (self.coupleFile != nil) return YES;
    return NO;
}
@end



@implementation ODManager

@synthesize movieFiles = _movieFiles;
@synthesize subtitleFiles = _subtitleFiles;

- (id)init
{
    self = [super init];
    if (self) {
        NSError *error = nil;
        regexMovie = [NSRegularExpression regularExpressionWithPattern:@".*\\.(mp4|mov|m4v|mkv|avi|mpg|mpeg|mpe|flv|wmv|asf|asx|rm|rmv|rmvb|divx|vob|mp4v|3gp|skm|k3g|ogm)$" options:NSRegularExpressionCaseInsensitive error:&error];
        regexSubtitle = [NSRegularExpression regularExpressionWithPattern:@".*\\.(smi|sami|srt|ssa|ass)$" options:NSRegularExpressionCaseInsensitive error:&error];
    }
    return self;
}

- (BOOL)isMovieFile:(SRFile *)file
{
    NSRange r = [regexMovie rangeOfFirstMatchInString:[file name] options:NSMatchingReportProgress range:NSMakeRange(0, [[file name] length])];
    if (r.location == NSNotFound && r.length == 0) return NO;
    return YES;
}

- (BOOL)isSubtitleFile:(SRFile *)file
{
    NSRange r = [regexSubtitle rangeOfFirstMatchInString:[file name] options:NSMatchingReportProgress range:NSMakeRange(0, [[file name] length])];
    if (r.location == NSNotFound && r.length == 0) return NO;
    return YES;
}

- (void)refresh
{
    NSArray *files = [[SRFileManager sharedManager] walkPath:[self targetDir] withDepthLimit:[self targetDepth]];
    
    NSMutableArray *tmpMovies = [[NSMutableArray alloc] init];
    NSMutableArray *tmpSubtitles = [[NSMutableArray alloc] init];
    
    for (SRFile *f in files) {
        if ([self isMovieFile:f]) {
            [tmpMovies addObject:[[ODFile alloc] initWithFile:f]];
        } else if ([self isSubtitleFile:f]) {
            [tmpSubtitles addObject:[[ODFile alloc] initWithFile:f]];
        }
    }
    
    _movieFiles = [NSArray arrayWithArray:tmpMovies];
    _subtitleFiles = [NSArray arrayWithArray:tmpSubtitles];
}

- (NSString *)targetDir
{
    // TODO: Ready for New Version.
    // User can switch target directory in new version.
    return [[SRFileManager sharedManager] pathForDownload];
}

- (int)targetDepth
{
    // TODO: Ready for New Version.
    // User can switch target directory walking depth.
    return 1;
}

@end
