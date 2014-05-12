//
//  PhotoListTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/10/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "NSUserDefaultsAccess.h"

#define PHOTOS_PER_PLACE 50

@interface PhotoListTableViewController ()
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSDictionary *photo;
@end

@implementation PhotoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)refreshTable:(UIRefreshControl *)refreshControl {
    [self downloadFlickrData];
    [refreshControl endRefreshing];
}

- (NSURL *)imageURL {
    if (!_imageURL) {
        _imageURL = [[NSURL alloc] init];
    }
    return _imageURL;
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Photo"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if (([title length] > 0) && ([description length] > 0)) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = description;
    } else if (([title length] > 0) && ([description length] == 0)) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = @"";
    } else if (([title length] == 0) && ([description length] > 0)) {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    self.photo = [self.photos objectAtIndex:indexPath.row];
    
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    self.imageURL = [[ff class] URLforPhoto:self.photo format:FlickrPhotoFormatLarge];
    
    PhotoViewController *pvc = [segue destinationViewController];
    pvc.imageURL = self.imageURL;
    pvc.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    NSUserDefaultsAccess *nsuda = [[NSUserDefaultsAccess alloc] init];
    [nsuda addPhotoToListOfRecentsWithPhoto:self.photo];
}

- (void) downloadFlickrData {
    self.photos = nil;
    
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    NSURL *url = [[ff class] URLforPhotosInPlace:self.placeId maxResults:PHOTOS_PER_PLACE];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:url]) {
                    NSData *data = [NSData dataWithContentsOfURL:localfile];
                    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSArray *photos = [results valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.photos = photos;
                    });
                }
            }
        }];
    [task resume];
}



@end
