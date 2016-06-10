//
//  NGS_API.m
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "NGS_API.h"
#import <AFNetworking.h>
#define base_link @"http://do.ngs.ru/api/v1/adverts/?include=uploads,tags&fields=short_images,cost,update_date"


@implementation NGS_API
@synthesize delegate;
- (void) getAdverts:(NSUInteger) count andOffset:(NSUInteger) offset
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:[NSString stringWithFormat:@"%@&limit=%lu&offset=%lu",base_link,count,offset] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(NGSAPIDidRecieveResults:andResults:)])
            [self.delegate NGSAPIDidRecieveResults:self andResults:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(NGSAPIDidFail:andError:)])
            [self.delegate NGSAPIDidFail:self andError:error];
    }];
}
@end
