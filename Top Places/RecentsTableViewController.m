//
//  RecentsTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "RecentsTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface RecentsTableViewController ()
@end

@implementation RecentsTableViewController

- (void)viewDidAppear:(BOOL)animated {
    self.photos = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentPhotos"];
    [self.tableView reloadData];
}

@end
