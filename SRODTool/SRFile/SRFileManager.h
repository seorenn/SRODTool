//
//  SRFileManager.h
//  SRToolkit for Cocoa
//
//  Created by Seorenn
//

#import <Foundation/Foundation.h>

@interface SRFileManager : NSObject {
    NSFileManager *_sharedFM;
}

+ (SRFileManager *)sharedManager;

- (NSString *)pathForDownload;
- (NSString *)pathForMovie;
- (NSURL *)urlForDownload;
- (BOOL)isDirectory:(NSString *)path;

- (int)depthOfPath:(NSString *)path fromRootPath:(NSString *)rootPath;

- (NSArray *)walkPath:(NSString *)path;
- (NSArray *)walkPath:(NSString *)path withHidden:(BOOL)hidden;
- (NSArray *)walkPath:(NSString *)path withDepthLimit:(int)limit;
- (NSArray *)walkPath:(NSString *)path withDepthLimit:(int)limit withHidden:(BOOL)hidden;

- (BOOL)touchPath:(NSString *)path;

@end
