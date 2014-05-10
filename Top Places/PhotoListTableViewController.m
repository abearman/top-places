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

@interface PhotoListTableViewController ()
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSDictionary *photo;
@end

@implementation PhotoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSURL *)imageURL {
    if (!_imageURL) {
        _imageURL = [[NSURL alloc] init];
    }
    return _imageURL;
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

- (void) downloadImageForPhoto: (NSDictionary *)photo {
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    self.imageURL = [[ff class] URLforPhoto:photo format:FlickrPhotoFormatLarge];
}

- (void)addPhotoToListOfRecents {
    NSMutableArray *recentPhotos = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentPhotos"];
    if (recentPhotos == nil) {
        recentPhotos = [[NSMutableArray alloc] init];
        [recentPhotos addObject:self.photo];
    } else {
        recentPhotos = [[NSMutableArray alloc] initWithArray:recentPhotos];
        if (![recentPhotos containsObject:self.photo]) {
            [recentPhotos addObject:self.photo];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:recentPhotos forKey:@"recentPhotos"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    self.photo = [self.photos objectAtIndex:indexPath.row];
    [self downloadImageForPhoto:self.photo];
    
    PhotoViewController *pvc = [segue destinationViewController];
    pvc.imageURL = self.imageURL;
    pvc.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    [self addPhotoToListOfRecents];
}





@end
