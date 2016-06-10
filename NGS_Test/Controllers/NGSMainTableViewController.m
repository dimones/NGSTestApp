//
//  NGSMainTableViewController.m
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "NGSMainTableViewController.h"
#import "NGSAdvertViewCell.h"

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
}
@end

@implementation NGSMainTableViewController
@synthesize advertsTable;

- (void) viewDidLoad{
    [super viewDidLoad];
    self.title = @"Объявления";
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
        outstring = [outstring stringByAppendingString:tags[obj][@"title"]];
    }];
    return outstring;
}

#pragma mark - delegate UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        cell.advertPrice.text = ((NSNumber*)pTemp[@"cost"]).stringValue;
    else cell.advertPrice.text = @"Не указано";
    NSLog(@"%ld",indexPath.row);
    if (![pTemp[@"short_images"][@"main"] isKindOfClass:[NSNull class]]) {
        [cell loadImage:uploads[pTemp[@"short_images"][@"main"][@"links"][@"origin"]]];
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
    NSLog(@"ERROR\n________________________");
    NSLog(@"%@",error);
}

- (void) NGSAPIDidRecieveResults:(NGS_API *)api andResults:(id)results
{
    NSLog(@"RESULTS\n________________________");
    //    NSLog(@"%@",results);
    //Turn all recieved tags to storage
    [[results[@"linked"][@"tags"] allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![tags objectForKey:obj])
            [tags setObject:results[@"linked"][@"tags"][obj] forKey:obj];
    }];
    [[results[@"linked"][@"uploads"] allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![uploads objectForKey:obj])
            [uploads setObject:results[@"linked"][@"uploads"][obj] forKey:obj];
    }];
    [adverts addObjectsFromArray:results[@"adverts"]];
    [self.tableView reloadData];
}
@end
