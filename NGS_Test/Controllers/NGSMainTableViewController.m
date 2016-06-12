//
//  NGSMainTableViewController.m
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "NGSMainTableViewController.h"
#import "NGSAdvertViewCell.h"
#import <UIScrollView+InfiniteScroll.h>
#import <Social/Social.h>

#define time_pattern @"yyyy-MM-dd'T'HH:mm:ssZZZ"
#define time_pattern_out @"dd.MM.yyyy"
#define CELL_ID @"NGS_CELL"

@interface NGSMainTableViewController()
{
    NGS_API *api;
    //Data storage
    NSMutableDictionary *tags;
    NSMutableDictionary *uploads;
    NSMutableArray *adverts;
    //Counters for adverts
    NSUInteger offset;
    //Bool
}
@property (strong, nonatomic) NGS_API *api;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation NGSMainTableViewController
@synthesize advertsTable,api,refreshControl;

- (void) viewDidLoad{
    [super viewDidLoad];
    self.title = @"Объявления";
    //Init refreshControl
    refreshControl = [UIRefreshControl new];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Идет обновление"];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [advertsTable addSubview:refreshControl];
    //Init UITableView with their delegates
    advertsTable.delegate = self;
    advertsTable.dataSource = self;
    advertsTable.rowHeight = UITableViewAutomaticDimension;
    advertsTable.estimatedRowHeight = 50.0f;
    //Init API
    api = [NGS_API new];
    api.delegate = self;
    //Init storage pointers
    [self initStorage];
    //Get first part of data
    [api getAdverts:20 andOffset:0];
    offset += 20;
    //Add infinite scroll table
    advertsTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    
    // setup infinite scroll
    [advertsTable addInfiniteScrollWithHandler:^(UITableView* tableView) {
        [api getAdverts:20 andOffset:offset];
        offset += 20;
    }];
    //    
    //    advertsTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    //    
    //    [advertsTable addInfiniteScrollWithHandler:^(id scrollView) {
    //        [api getAdverts:20 andOffset:offset];
    //        offset += 20;
    //    }];
    //Hide last separator
    advertsTable.tableFooterView = [UIView new];
}
- (void) refresh{
    [api getAdverts:20 andOffset:0];
}
- (void) initStorage{
    tags = [NSMutableDictionary new];
    uploads = [NSMutableDictionary new];
    adverts = [NSMutableArray new];
}
#pragma mark Support functions
- (NSString *) stringFromDate: (NSDate*) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:time_pattern_out];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate!=nil?stringFromDate:@"";
}

- (NSDate *) dateFromString:(NSString*) string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:time_pattern];
    NSDate *date = [[dateFormatter dateFromString:string] dateByAddingTimeInterval:6*60*60];
    return date;
}

- (NSString*) getResolvedTagsString:(NSArray*) _tags{
    __block NSString *outstring = @"";
    [_tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        outstring = [outstring stringByAppendingString:[tags[obj][@"title"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                    withString:[[tags[obj][@"title"] substringToIndex:1] capitalizedString]]];
    }];
    return outstring;
}

#pragma mark - delegate UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id pTemp = adverts[indexPath.row];
    id obj;
    if (![pTemp[@"short_images"][@"main"] isKindOfClass:[NSNull class]]) {
        obj = uploads[pTemp[@"short_images"][@"main"][@"links"][@"origin"]];
    }
    
    NSURL  *url = [NSURL URLWithString:
                   [NSString stringWithFormat:@"http://%@/%@.%@",obj[@"domain"], obj[@"file_name"], obj[@"file_extension"]]];
    NSArray *activityItems = @[pTemp[@"title"],url];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{
        
    }];
    
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NGSAdvertViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    if (!cell) {
        cell = [NGSAdvertViewCell new];
    }
    id pTemp = adverts[indexPath.row];
    cell.advertName.text = pTemp[@"title"];
    cell.advertTopText.text = [NSString stringWithFormat:@"%@ • %@",[self getResolvedTagsString:pTemp[@"links"][@"tags"]],[self stringFromDate:[self dateFromString:pTemp[@"update_date"]]]];
    
    if (((NSNumber*)pTemp[@"cost"]).integerValue != 0)
        cell.advertPrice.text = [((NSNumber*)pTemp[@"cost"]).stringValue stringByAppendingString:@" руб."];
    else cell.advertPrice.text = @"цена не указана";
    
    if (![pTemp[@"short_images"][@"main"] isKindOfClass:[NSNull class]]) {
        [cell loadImage:uploads[pTemp[@"short_images"][@"main"][@"links"][@"origin"]]];
    }
    else
    {
        [cell.advertImage setImage:[UIImage imageNamed:@"blank_image.png"]];
        cell.advertImage.contentMode = UIViewContentModeScaleToFill;
        
    }
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [adverts count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - delegate NGSAPIDelegate
- (void) NGSAPIDidFail:(NGS_API *)api andError:(NSError *)error
{
    if (refreshControl.refreshing)
        [refreshControl endRefreshing];
    NSLog(@"ERROR\n________________________");
    NSLog(@"%@",error);
}

- (void) NGSAPIDidRecieveResults:(NGS_API *)api andResults:(id)results
{
    //Turn all recieved tags to storage
    [[results[@"linked"][@"tags"] allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![tags objectForKey:obj])
            [tags setObject:results[@"linked"][@"tags"][obj] forKey:obj];
    }];
    [[results[@"linked"][@"uploads"] allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![uploads objectForKey:obj])
            [uploads setObject:results[@"linked"][@"uploads"][obj] forKey:obj];
    }];
    //Temp array for next comparsions
    NSMutableArray *tAdverts = [NSMutableArray arrayWithArray:adverts];
    [tAdverts addObjectsFromArray:results[@"adverts"]];
    //Sort array of dictionaries by date
    
    NSArray *sortedArray = [tAdverts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[self dateFromString:[obj2 valueForKey:@"update_date"]] compare:[self dateFromString:[obj1 valueForKey:@"update_date"]]];
    }];
    [tAdverts removeAllObjects];
    [tAdverts addObjectsFromArray:sortedArray];
    NSSet *set = [NSSet setWithArray:tAdverts];
    
    [adverts removeAllObjects];
    [adverts addObjectsFromArray:[set allObjects]];
    [advertsTable reloadData];
    [advertsTable finishInfiniteScroll];
    if (refreshControl.refreshing)
        [refreshControl endRefreshing];
    
}
@end
