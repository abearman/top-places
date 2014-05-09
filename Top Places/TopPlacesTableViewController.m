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
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(downloadFlickrData)
                                                 object:nil];
    
    [thread start];
    
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
        NSString *subtitle = [place objectForKey:@"_content"];
        NSRange rangeForSubtitle = [subtitle rangeOfString:@", "];
        subtitle = [subtitle substringFromIndex:rangeForSubtitle.location + 1]; // Cuts out the title, comma, and space
        NSRange rangeForCountry = [subtitle rangeOfString:@", " options:NSBackwardsSearch];
        NSString *country = [subtitle substringFromIndex:rangeForCountry.location + 1];
        
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
        [self.countryToPlace setObject:currentPlacesForCountry forKey:country];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.countryToPlace allKeys] count];
}

// Sections (countries) are sorted alphabetically
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *countries = [self.countryToPlace allKeys];
    NSArray *sortedCountries = [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *key = [sortedCountries objectAtIndex:section];
    return [[self.countryToPlace objectForKey:key] count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
