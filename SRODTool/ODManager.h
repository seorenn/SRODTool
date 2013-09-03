//
//  ODManager.h
//  SRODTool
//
//  Created by Seorenn
//  Copyright (c) 2013 Seorenn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRFile.h"
#import "SRFileManager.h"

@interface ODItem : NSObject
@property (readonly) NSString *name;
@property (readonly) SRFile *file;
@property NSInteger tag;
- (id)initWithFile:(SRFile *)f;
- (id)initWithName:(NSString *)name;
- (BOOL)coupled;
@end


@interface ODManager : NSObject {
    NSRegularExpression *regexMovie;
    NSRegularExpression *regexSubtitle;
    
    NSRegularExpression *regexVender;
    NSRegularExpression *regexInfo;
}

@property (strong) NSMutableArray *movieItems;
@property (strong) NSMutableArray *subtitleItems;
@property BOOL modified;

+ (ODManager *)sharedManager;

- (void)refresh;
- (NSString *)workingPath;
- (NSString *)destPath;
- (void)coupleSubtitleIndex:(NSInteger)subtitleIndex withMovieIndex:(NSInteger)movieIndex;
- (void)cancelCoupleOfMovieFile:(ODItem *)movieItem;
//- (void)cancelCoupleOfSubtitleFile:(ODItem *)subtitleItem;
- (void)restoreAllSubtitlePaths;
- (NSString *)normalizedName:(NSString *)name;
- (NSArray *)dirs;
- (NSInteger)filesInDirectory:(NSString *)path;

@end
