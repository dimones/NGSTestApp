//
//  NGSMainTableViewController.h
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGS_API.h"
@interface NGSMainTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,NGSAPIDelegate>
@property (strong, nonatomic) IBOutlet UITableView *advertsTable;

@end
