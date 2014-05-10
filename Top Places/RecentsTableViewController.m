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

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    self.photos = [defaults objectForKey:@"recentPhotos"];
}

@end
