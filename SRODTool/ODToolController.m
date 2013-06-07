//
//  ODToolController.m
//  SRODTool
//
//  Created by Heeseung Seo on 13. 5. 28..
//  Copyright (c) 2013년 seorenn. All rights reserved.
//

#import "ODToolController.h"

#import "AppDelegate.h"
#import "AppConfig.h"

@implementation ODToolController

@synthesize manager = _manager;
@synthesize movies;
@synthesize subtitles;

- (id)init
{
    self = [super init];
    if (self) {
        self.manager = [ODManager sharedManager];
        [self refresh];
    }
    return self;
}

- (void)refresh
{
    [self.manager refresh];
    self.movies = self.manager.movieItems;
    self.subtitles = self.manager.subtitleItems;
}

- (void)updateWorkingPath:(NSString *)path
{
    [self.pathControl setURL:[NSURL fileURLWithPath:path]];
}

//#define NORMTEST(s) { \
//    NSLog(@"[NORM] [%@] -> [%@]", (s), [self.manager normalizedName:(s)]); \
//}
- (void)awakeFromNib
{
    // TESTING
//    NORMTEST(@"[This is test] Test String 00 (test test value).avi");
//    NORMTEST(@"[This is test] Test  String    00     (test test value)     .avi");
//    NORMTEST(@"[한글테스트] 한글 이름이 들어간 Test  String  은  00  되는가   (test test value)     .avi");
    
    //NSLog(@"awakeFromNib");
    [self updateWorkingPath:[self.manager workingPath]];
    
    [self.moviesTableView setTarget:self];
    [self.moviesTableView setDoubleAction:@selector(doubleClicked:)];
}

- (void)doubleClicked:(id)object
{
    if (object != self.moviesTableView) return;
    
    NSInteger row = [self.moviesTableView clickedRow];
    ODItem *file = [self.manager.movieItems objectAtIndex:row];
//    NSLog(@"doubledClicked with row %ld -> %@", row, file.name);
    
    [file.file openWithAssociatedApp];
}

- (NSInteger)indexOfCoupledSubtitleForMovie:(ODItem *)movie
{
    return movie.tag;
//    if (!movie || !movie.couple) return -1;
//    
//    for (NSInteger i=0; i < [self.subtitles count]; i++) {
//        ODItem *s = [self.subtitles objectAtIndex:i];
//        if (movie.couple == s) {
//            return i;
//        }
//    }
//    return -1;
}

- (void)updateTables
{
    [self.moviesTableView reloadData];
    [self.subtitlesTableView reloadData];
}

- (void)reset
{
    for (ODItem *m in self.movies) {
        m.tag = -1;
    }
    for (ODItem *s in self.subtitles) {
        s.tag = -1;
    }
    [self.manager restoreAllSubtitlePaths];
    
    [self.moviesTableView deselectAll:nil];
    [self.subtitlesTableView deselectAll:nil];
    
    [self updateTables];
}

- (void)movie:(ODItem *)movie CoupleWithSubtitle:(ODItem *)subtitle
{
    NSLog(@"Coupling Movie [#%ld %@] with Subtitle [#%ld %@]", self.selectingMovieIndex, movie.name, self.selectingSubtitleIndex, subtitle.name);
    
    [self.manager coupleSubtitleIndex:self.selectingSubtitleIndex withMovieIndex:self.selectingMovieIndex];
    
    self.manager.modified = YES;
    [self updateTables];
}

- (void)updateSubtitleSelectionForMovie:(ODItem *)movie
{
    NSInteger sidx = [self indexOfCoupledSubtitleForMovie:movie];
    if (sidx < 0) {
//        NSLog(@"Not coupled movie");
        [self.subtitlesTableView deselectAll:nil];
        return;
    }
    [self.subtitlesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:sidx] byExtendingSelection:NO];
}

- (IBAction)resetAllCouples:(id)sender
{
    [self reset];
}

- (IBAction)pressedChangeFolder:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setResolvesAliases:YES];
    
    NSString *panelTitle = @"Choose Working Folder";
    [panel setTitle:panelTitle];
    
    NSString *promptString = @"Choose";
    [panel setPrompt:promptString];
    
    AppDelegate *ad = [[NSApplication sharedApplication] delegate];
    
    [panel beginSheetModalForWindow:[ad window] completionHandler:^(NSInteger result) {
        [panel orderOut:ad];
        
        if (result != NSOKButton) {
            // Canceled
            return;
        }
        
        NSURL *url = [[panel URLs] objectAtIndex:0];
        NSString *path = [url path];
        [self updateWorkingPath:path];
        [[AppConfig sharedConfig] setWorkingPath:path];
        [self reset];
        [self.manager refresh];
        [self updateTables];
    }];
}

- (void)normalizeNamesOfItems:(NSArray *)items
{
    for (ODItem *item in items) {
        NSString *nn = [self.manager normalizedName:[item.file name]];
        if ([nn isEqualToString:[item.file name]]) continue;
        
        [item.file renameTo:nn];
    }
}

- (void)trashOrphanedSubtitles
{
    for (ODItem *item in self.subtitles) {
        if (item.tag < 0) {
            [item.file trash];
        }
    }
}

- (void)trashBlankDirectories
{
    NSArray *dirs = [self.manager dirs];
    for (SRFile *dir in dirs) {
        if ([self.manager filesInDirectory:dir.path] == 0) {
            [dir trash];
        }
    }
}

- (IBAction)pressedPerform:(id)sender
{
    [self normalizeNamesOfItems:self.movies];
    [self normalizeNamesOfItems:self.subtitles];
    [self trashOrphanedSubtitles];
    [self trashBlankDirectories];
    self.manager.modified = NO;
    [self refresh];
    [self updateTables];
}

//- (void)resetCoupleOfMovie:(ODItem *)movie
//{
//    if (movie.tag < 0) return;
//    
//    for (ODItem *s in self.subtitles) {
//        if (s == movie.couple) {
//            s.couple = nil;
//        }
//    }
//    movie.couple = nil;
//}

- (BOOL)alreadyCoupledMovie:(ODItem *)movie withSubtitle:(ODItem *)subtitle
{
    if (movie.tag < 0 || subtitle.tag < 0) return NO;
    
    ODItem *tmpSubtitle = [self.manager.subtitleItems objectAtIndex:movie.tag];
    if (tmpSubtitle == subtitle) return YES;
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
        self.selectingMovieIndex = tv.selectedRow;
        self.selectingMovieFile = [self.movies objectAtIndex:tv.selectedRow];
        [self updateSubtitleSelectionForMovie:self.selectingMovieFile];
    }
    else if (tv == self.subtitlesTableView) {
//        NSLog(@"[SUBTITLES] Selection Changed...");
        ODItem *currentSelection = [self.subtitles objectAtIndex:tv.selectedRow];
        if ([self alreadyCoupledMovie:self.selectingMovieFile withSubtitle:currentSelection] == NO) {
//            NSLog(@"Fresh subtitle");
            self.selectingSubtitleIndex = tv.selectedRow;
            self.selectingSubtitleFile = currentSelection;
//            [self resetCoupleOfMovie:self.selectingMovieFile];
            [self movie:self.selectingMovieFile CoupleWithSubtitle:self.selectingSubtitleFile];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    // Prevent subtitle selection when movie not selected.
    if (tableView == self.moviesTableView) return YES;
    if (self.selectingMovieFile) {
        ODItem *sitem = [self.subtitles objectAtIndex:row];
        if (sitem.tag < 0) return YES;
    }
    return NO;
}

@end
