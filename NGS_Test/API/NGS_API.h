//
//  NGS_API.h
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NGS_API;

@protocol NGSAPIDelegate <NSObject>
@required
- (void) NGSAPIDidRecieveResults: (NGS_API*) api
                      andResults: (id) results;
- (void) NGSAPIDidFail: (NGS_API*) api
              andError: (NSError*) error;
@end

@interface NGS_API : NSObject
{
    __weak id <NGSAPIDelegate> delegate;
}
@property (nonatomic, weak) id <NGSAPIDelegate> delegate;

- (void) getAdverts:(NSUInteger) count andOffset:(NSUInteger) offset;

@end
