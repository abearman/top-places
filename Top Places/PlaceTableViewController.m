//
//  PlaceTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "PlaceTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface PlaceTableViewController ()
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *imageTitle;
@end

@implementation PlaceTableViewController

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
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
    } else if (([title length] == 0) && ([description length] > 0)) {
        cell.textLabel.text = description;
    } else {
        cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

- (void) downloadImageForPhoto: (NSDictionary *)photo {
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    self.imageURL = [[ff class] URLforPhoto:photo format:FlickrPhotoFormatLarge];
    self.imageTitle = [photo objectForKey:FLICKR_PHOTO_TITLE];
    [self performSegueWithIdentifier:@"DisplayPhoto" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    [self downloadImageForPhoto: photo];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PhotoViewController *pvc = [segue destinationViewController];
    pvc.imageURL = self.imageURL;
    pvc.title = self.imageTitle;
}

@end



