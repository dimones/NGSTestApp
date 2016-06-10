//
//  NGSAdvertViewCell.m
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "NGSAdvertViewCell.h"

@implementation NGSAdvertViewCell
@synthesize advertName,advertImage,advertPrice,advertTopText;

- (void) loadImage: (NSDictionary*) obj
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //Build URL for download image
        NSURL  *url = [NSURL URLWithString:
                       [NSString stringWithFormat:@"http://%@/%@.%@",obj[@"domain"], obj[@"file_name"], obj[@"file_extension"]]];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if (urlData) {
            __block UIImage *img = [UIImage imageWithData:urlData];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
                
                [img drawAtPoint:CGPointZero];
                
                img = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectMake(0, 0, advertImage.frame.size.width, advertImage.frame.size.height));
                // or use the UIImage wherever you like
                [advertImage setImage:[UIImage imageWithCGImage:imageRef]];
                CGImageRelease(imageRef);
            });
            
        }
    });
}
@end
