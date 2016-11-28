//
//  TFImageActivityItemProvider.m
//  RNShare
//
//  Created by Kevin Matidza on 2016/11/28.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "TFImageActivityItemProvider.h"

@interface TFImageActivityItemProvider()

@property (strong, nonatomic) NSData* base64EncodedData;

@end

@implementation TFImageActivityItemProvider

- (instancetype)initWithImageData:(NSData*) imageData
{
    self = [super initWithPlaceholderItem:@""];
    
    if (self) {
        self.base64EncodedData = imageData;
    }
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
    return self.base64EncodedData;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.placeholderItem;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    NSString* bundleDisplayName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"%@ - image data", bundleDisplayName];
}

@end


