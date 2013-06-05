//
//  ODManager.m
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 27..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import "ODManager.h"

#import "AppConfig.h"

#pragma mark - ODItem

@implementation ODItem
@synthesize name = _name;
@synthesize file = _file;
@synthesize tag;
- (id)initWithFile:(SRFile *)f
{
    self = [super init];
    if (self) {
        _name = [NSString stringWithString:[f name]];
        _file = f;
        self.tag = -1;
    }
    return self;
}
- (BOOL)coupled
{
    if (self.tag >= 0) return YES;
    return NO;
}
@end

#pragma mark - NSString with Strip feature

@implementation NSString (SSToolkitAdditions)

#pragma mark Trimming Methods

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)strip {
    return [[self stringByTrimmingLeadingWhitespaceAndNewlineCharacters] stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
}

@end

#pragma mark - ODManager

@implementation ODManager

@synthesize movieItems = _movieItems;
@synthesize subtitleItems = _subtitleItems;
@synthesize modified;

+ (ODManager *)sharedManager
{
    static ODManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ODManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSError *error = nil;
        regexMovie = [NSRegularExpression regularExpressionWithPattern:@".*\\.(mp4|mov|m4v|mkv|avi|mpg|mpeg|mpe|flv|wmv|asf|asx|rm|rmv|rmvb|divx|vob|mp4v|3gp|skm|k3g|ogm)$" options:NSRegularExpressionCaseInsensitive error:&error];
        regexSubtitle = [NSRegularExpression regularExpressionWithPattern:@".*\\.(smi|sami|srt|ssa|ass)$" options:NSRegularExpressionCaseInsensitive error:&error];
        
        regexVender = [NSRegularExpression regularExpressionWithPattern:@"^(\\[.+\\]).+$" options:NSRegularExpressionCaseInsensitive error:&error];
        regexInfo = [NSRegularExpression regularExpressionWithPattern:@".+\\(.+\\).+$" options:NSRegularExpressionCaseInsensitive error:&error];
        
        self.movieItems = [[NSMutableArray alloc] init];
        self.subtitleItems = [[NSMutableArray alloc] init];
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
    if (self.modified &&
        [self.movieItems count] > 0 &&
        [self.subtitleItems count] > 0) {
        [self restoreAllSubtitlePaths];
    }
    
    self.modified = NO;
    
    NSArray *files = [[SRFileManager sharedManager] walkPath:[self workingPath]
                                              withDepthLimit:[self targetDepth]];
    
    NSMutableArray *tmpMovies = [[NSMutableArray alloc] init];
    NSMutableArray *tmpSubtitles = [[NSMutableArray alloc] init];
    
    for (SRFile *f in files) {
        if ([self isMovieFile:f]) {
            [tmpMovies addObject:[[ODItem alloc] initWithFile:f]];
        } else if ([self isSubtitleFile:f]) {
            [tmpSubtitles addObject:[[ODItem alloc] initWithFile:f]];
        }
    }
    
    [self.movieItems removeAllObjects];
    [self.movieItems addObjectsFromArray:tmpMovies];
    
    [self.subtitleItems removeAllObjects];
    [self.subtitleItems addObjectsFromArray:tmpSubtitles];
}

- (NSString *)workingPath
{
    NSString *path = [[AppConfig sharedConfig] workingPath];
    if (!path) {
        path = [[SRFileManager sharedManager] pathForDownload];
    }
    
    return path;
}

- (int)targetDepth
{
    // TODO: Ready for New Version.
    // User can switch target directory walking depth.
    return 1;
}

- (NSString *)pathOfNewSubtitle:(ODItem *)subtitleFile forMovieFile:(ODItem *)movieFile
{
    NSString *targetPath = movieFile.file.containerPath;
    NSString *movieName = movieFile.file.name;
    NSString *movieWithoutExt = [movieName stringByDeletingPathExtension];
    NSString *subtitleExtName = [subtitleFile.file.name pathExtension];
    
    NSString *newPathWithoutExt = [targetPath stringByAppendingPathComponent:movieWithoutExt];
    NSString *newPath = [newPathWithoutExt stringByAppendingPathExtension:subtitleExtName];
    
    return newPath;
}

- (void)coupleSubtitleIndex:(NSInteger)subtitleIndex withMovieIndex:(NSInteger)movieIndex
{
    ODItem *movie = [self.movieItems objectAtIndex:movieIndex];
    ODItem *subtitle = [self.subtitleItems objectAtIndex:subtitleIndex];
    
    [self cancelCoupleOfMovieFile:movie];
//    [self cancelCoupleOfSubtitleFile:subtitle];
    
    NSString *newSubtitlePath = [self pathOfNewSubtitle:subtitle forMovieFile:movie];
    
    //NSLog(@"New Subtitle Path = %@", newSubtitlePath);
    
    [subtitle.file moveTo:newSubtitlePath];
    
    movie.tag = subtitleIndex;
    subtitle.tag = movieIndex;
    
    self.modified = YES;
}

- (void)cancelCoupleOfMovieFile:(ODItem *)movieItem
{
    if (movieItem.tag < 0) return;
    
    ODItem *coupledSubtitleItem = [self.subtitleItems objectAtIndex:movieItem.tag];
    [coupledSubtitleItem.file restore];
    coupledSubtitleItem.tag = -1;
    movieItem.tag = -1;
}

//- (void)cancelCoupleOfSubtitleFile:(ODItem *)subtitleItem
//{
//    if (!subtitleItem.couple) return;
//    
//    ODItem *coupleItem = subtitleItem.couple;
//    subtitleItem.couple = nil;
//    
//    for (ODItem *o in self.movieFiles) {
//        if (o == coupleItem) {
//            o.couple = nil;
//            break;
//        }
//    }
//    
//    [subtitleItem.file restore];
//}

- (void)restoreAllSubtitlePaths
{
    for (ODItem *f in self.subtitleItems) {
        [f.file restore];
    }
}

- (NSRange)rangeMatchedPattern:(NSRegularExpression *)regex fromString:(NSString *)string
{
    //return [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    NSArray *rs = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, [string length])];
    
    if (!rs || [rs count] < 2) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    NSLog(@"[MATCH] ORIGINAL: %@", string);
    for (NSTextCheckingResult *r in rs) {
        NSLog(@"[MATCH] - %ld, %ld", r.range.location, r.range.length);
    }
    
    NSTextCheckingResult *res = [rs objectAtIndex:1];
    return res.range;
}

- (NSString *)normalizedName:(NSString *)name
{
    NSRange r;
    NSString *strVendorRemoved = nil;
    NSString *strInfoRemoved = nil;
    NSString *clearName = nil;
    
    r = [self rangeMatchedPattern:regexVender fromString:name];
    if (r.location != NSNotFound && r.length > 0) {
        strVendorRemoved = [name stringByReplacingCharactersInRange:r withString:@""];
    } else {
        strVendorRemoved = [NSString stringWithString:name];
    }
    
    r = [self rangeMatchedPattern:regexInfo fromString:strVendorRemoved];
    if (r.location != NSNotFound && r.length > 0) {
        strInfoRemoved = [strVendorRemoved stringByReplacingCharactersInRange:r withString:@""];
    } else {
        strInfoRemoved = [NSString stringWithString:strVendorRemoved];
    }
    
    // TODO: strInfoRemoved -> remove continuous whitespaces -> clearName
    // This is temporary code
    clearName = [NSString stringWithString:strInfoRemoved];
    
    return [clearName strip];
}

@end
