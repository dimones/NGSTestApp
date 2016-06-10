//
//  NGSAdvertViewCell.h
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NGSAdvertViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *advertImage;
@property (weak, nonatomic) IBOutlet UILabel *advertTopText;
@property (weak, nonatomic) IBOutlet UILabel *advertName;
@property (weak, nonatomic) IBOutlet UILabel *advertPrice;

- (void) loadImage: (NSDictionary*) obj;
@end