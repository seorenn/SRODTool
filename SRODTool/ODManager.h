//
//  ODManager.h
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 27..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRFile.h"
#import "SRFileManager.h"

@interface ODFile : NSObject
@property (readonly) NSString *name;
@property (readonly) SRFile *file;
@property (weak) SRFile *coupleFile;
- (id)initWithFile:(SRFile *)f;
- (BOOL)coupled;
@end


@interface ODManager : NSObject {
    NSRegularExpression *regexMovie;
    NSRegularExpression *regexSubtitle;
}

@property (readonly) NSArray *movieFiles;
@property (readonly) NSArray *subtitleFiles;

- (void)refresh;

@end
