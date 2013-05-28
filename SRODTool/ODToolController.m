//
//  ODToolController.m
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 28..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import "ODToolController.h"

@implementation ODToolController

@synthesize manager = _manager;
@synthesize movies;
@synthesize subtitles;

- (id)init
{
    self = [super init];
    if (self) {
        self.manager = [[ODManager alloc] init];
        [self.manager refresh];
        
        self.movies = self.manager.movieFiles;
        self.subtitles = self.manager.subtitleFiles;
    }
    return self;
}

//- (void)awakeFromNib
//{
//    NSLog(@"awakeFromNib");
//}

- (NSInteger)indexOfCoupledSubtitleForMovie:(ODFile *)movie
{
    if (!movie || !movie.coupleFile) return -1;
    
    for (NSInteger i=0; i < [self.subtitles count]; i++) {
        ODFile *sf = [self.subtitles objectAtIndex:i];
        if (movie.coupleFile == sf.file) {
            return i;
        }
    }
    return -1;
}

- (void)updateTables
{
    [self.moviesTableView reloadData];
    [self.subtitlesTableView reloadData];
}

- (void)reset
{
    for (ODFile *mf in self.movies) {
        mf.coupleFile = nil;
    }
    for (ODFile *sf in self.subtitles) {
        sf.coupleFile = nil;
    }
    [self.moviesTableView deselectAll:nil];
    [self.subtitlesTableView deselectAll:nil];
    
    [self updateTables];
}

- (void)movie:(ODFile *)movie CoupleWithSubtitle:(ODFile *)subtitle
{
//    NSLog(@"Coupling Movie [%@] with Subtitle [%@]", movie.name, subtitle.name);
    movie.coupleFile = subtitle.file;
    subtitle.coupleFile = movie.file;
    // TODO
    
    [self updateTables];
}

- (void)updateSubtitleSelectionForMovie:(ODFile *)movie
{
    NSInteger sidx = [self indexOfCoupledSubtitleForMovie:movie];
    if (sidx < 0) {
//        NSLog(@"Not coupled movie");
        [self.subtitlesTableView deselectAll:nil];
        return;
    }
    [self.subtitlesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:sidx] byExtendingSelection:NO];
    ODFile *sfile = [self.subtitles objectAtIndex:sidx];
    
//    NSLog(@"Movie [%@] coupled with [%@]", movie.name, sfile.name);
    // TODO
}

- (IBAction)resetAllCouples:(id)sender
{
    [self reset];
}

- (void)resetCoupleOfMovie:(ODFile *)movie
{
    if (movie.coupleFile == nil) return;
    
    for (ODFile *sf in self.subtitles) {
        if (sf.file == movie.coupleFile) {
            sf.coupleFile = nil;
        }
    }
    movie.coupleFile = nil;
}

- (BOOL)alreadyCoupledMovie:(ODFile *)movie withSubtitle:(ODFile *)subtitle
{
    if (movie.coupleFile == nil || subtitle.coupleFile == nil) return NO;
    if (movie.coupleFile == subtitle.file) return YES;
    return NO;
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tv = notification.object;
//    NSLog(@"Tableview selection did changed: row %ld", tv.selectedRow);
    if (tv.selectedRow < 0) {
        // calling by deselecting... ignore
        return;
    }
    
    if (tv == self.moviesTableView) {
//        NSLog(@"[MOVIES] Selection Changed...");
        self.selectingMovieFile = [self.movies objectAtIndex:tv.selectedRow];
        [self updateSubtitleSelectionForMovie:self.selectingMovieFile];
    }
    else if (tv == self.subtitlesTableView) {
//        NSLog(@"[SUBTITLES] Selection Changed...");
        ODFile *currentSelection = [self.subtitles objectAtIndex:tv.selectedRow];
        if ([self alreadyCoupledMovie:self.selectingMovieFile withSubtitle:currentSelection] == NO) {
//            NSLog(@"Fresh subtitle");
            self.selectingSubtitleFile = currentSelection;
            [self resetCoupleOfMovie:self.selectingMovieFile];
            [self movie:self.selectingMovieFile CoupleWithSubtitle:self.selectingSubtitleFile];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    // Prevent subtitle selection when movie not selected.
    if (tableView == self.moviesTableView) return YES;
    if (self.selectingMovieFile) {
        ODFile *sfile = [self.subtitles objectAtIndex:row];
        if (sfile.coupleFile == nil) return YES;
        return NO;
    }
    return NO;
}

@end
