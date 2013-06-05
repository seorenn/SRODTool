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
@property (weak) IBOutlet NSPathControl *pathControl;

@property (nonatomic, strong) ODManager *manager;

// connected with controller
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *subtitles;

@property (weak) ODItem *selectingMovieFile;
@property (assign) NSInteger selectingMovieIndex;
@property (weak) ODItem *selectingSubtitleFile;
@property (assign) NSInteger selectingSubtitleIndex;

- (void)movie:(ODItem *)movie CoupleWithSubtitle:(ODItem *)subtitle;
- (void)updateSubtitleSelectionForMovie:(ODItem *)movie;
- (IBAction)resetAllCouples:(id)sender;
- (IBAction)pressedChangeFolder:(id)sender;

@end
