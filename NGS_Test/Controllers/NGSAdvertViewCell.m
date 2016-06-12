//
//  NGSAdvertViewCell.m
//  NGS_Test
//
//  Created by Дмитрий Богомолов on 10.06.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "NGSAdvertViewCell.h"
#import "UIImageLoader.h"
@implementation NGSAdvertViewCell
@synthesize advertName,advertImage,advertPrice,advertTopText;

- (void) loadImage: (NSDictionary*) obj
{
    NSURL  *url = [NSURL URLWithString:
                   [NSString stringWithFormat:@"http://%@/%@.%@",obj[@"domain"], obj[@"file_name"], obj[@"file_extension"]]];
    [[UIImageLoader defaultLoader] loadImageWithURL:url hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
        self.advertImage.image = image;
        self.advertImage.contentMode = UIViewContentModeScaleAspectFit;
        
    } sendingRequest:^(BOOL didHaveCachedImage) {
        if(!didHaveCachedImage) {
            self.advertImage.image = [UIImage imageNamed:@"blank_image"];
            self.advertImage.contentMode = UIViewContentModeScaleToFill;
            
        }
    } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
        if(loadedFromSource == UIImageLoadSourceNetworkToDisk) {
            [UIView transitionWithView:self.advertImage
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.advertImage.image = image;
                            } completion:nil];
        }
    }];
}
@end
