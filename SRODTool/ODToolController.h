//
//  ODToolController.h
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 28..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODManager.h"

@interface ODToolController : NSObject <NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *moviesTableView;
@property (weak) IBOutlet NSTableView *subtitlesTableView;

@property (nonatomic, strong) ODManager *manager;

// connected with controller
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *subtitles;

@property (weak) ODFile *selectingMovieFile;
@property (assign) NSInteger selectingMovieIndex;
@property (weak) ODFile *selectingSubtitleFile;
@property (assign) NSInteger selectingSubtitleIndex;

- (void)movie:(ODFile *)movie CoupleWithSubtitle:(ODFile *)subtitle;
- (void)updateSubtitleSelectionForMovie:(ODFile *)movie;
- (IBAction)resetAllCouples:(id)sender;

@end
