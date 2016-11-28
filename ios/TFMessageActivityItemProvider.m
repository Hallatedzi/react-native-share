//
//  TFActivityItemProvider.m
//  RNShare
//
//  Created by Kevin Matidza on 2016/11/28.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "TFMessageActivityItemProvider.h"

@interface TFMessageActivityItemProvider()

@property (strong, nonatomic) NSString* message;

@end

@implementation TFMessageActivityItemProvider

- (instancetype)initWithMessage:(NSString*) message
{
    self = [super initWithPlaceholderItem:@""];
    
    if (self) {
        self.message = message;
    }
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
    if ([activityType.lowercaseString containsString:@"whatsapp"]) {
        return @"";
    }

    return self.message;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.placeholderItem;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    NSString* bundleDisplayName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"%@ - message value: %@", bundleDisplayName, self.message];
}

@end
