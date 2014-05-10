//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSMutableDictionary *countryToPlace;

@end

@implementation TopPlacesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    /*NSThread *thread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(downloadFlickrData)
                                                 object:nil];
    
    [thread start];*/
    [self downloadFlickrData];
    
}

- (NSMutableDictionary *)countryToPlace {
    if (!_countryToPlace) {
        _countryToPlace = [[NSMutableDictionary alloc] init];
    }
    return _countryToPlace;
}

- (void)downloadFlickrData {
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    NSURL *url = [[ff class] URLforTopPlaces];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *places = [results valueForKeyPath:@"places.place"];
    
    for (NSDictionary *place in places) {
        NSString *title = [place objectForKey:@"woe_name"];
        NSString *content = [place objectForKey:@"_content"];
        
        NSRange rangeForCountry = [content rangeOfString:@", " options:NSBackwardsSearch];
        NSString *country = [content substringFromIndex:rangeForCountry.location + 1];
        
        NSRange rangeForSubtitle = [content rangeOfString:@", "];
        NSString *subtitle = [content substringFromIndex:rangeForSubtitle.location + 1]; // Cuts out the title, comma, and space
        
        
        NSDictionary *place = [[NSDictionary alloc] initWithObjectsAndKeys:
                               title, @"title",
                               subtitle, @"subtitle",
                               nil];
        
        NSMutableArray *currentPlacesForCountry = [self.countryToPlace objectForKey:country];
        if (currentPlacesForCountry == nil) {
            currentPlacesForCountry = [[NSMutableArray alloc] initWithObjects:place, nil];
        } else {
            [currentPlacesForCountry addObject:place];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [currentPlacesForCountry sortedArrayUsingDescriptors:sortDescriptors];
        currentPlacesForCountry =[NSMutableArray arrayWithArray:sortedArray];
        
        [self.countryToPlace setObject:currentPlacesForCountry forKey:country];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.countryToPlace allKeys] count];
}

// Sections (countries) are sorted alphabetically
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sortedCountries = [self sortedCountryKeys];
    NSString *key = [sortedCountries objectAtIndex:section];
    return [[self.countryToPlace objectForKey:key] count];
}

- (NSArray *)sortedCountryKeys {
    NSArray *countries = [self.countryToPlace allKeys];
    return [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *country = [[self sortedCountryKeys] objectAtIndex:indexPath.section];
    NSArray *places = [self.countryToPlace objectForKey:country];
    NSDictionary *place = [places objectAtIndex:indexPath.row];
    NSString *title = [place objectForKey:@"title"];
    NSString *subtitle = [place objectForKey:@"subtitle"];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sortedCountries = [self sortedCountryKeys];
    return [sortedCountries objectAtIndex:section];
}


@end
