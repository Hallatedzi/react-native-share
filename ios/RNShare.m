#import <MessageUI/MessageUI.h>
#import "RNShare.h"
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "GenericShare.h"
#import "WhatsAppShare.h"
#import "GooglePlusShare.h"
#import "EmailShare.h"
#import "TFMessageActivityItemProvider.h"
#import "TFImageActivityItemProvider.h"

@implementation RNShare
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

/*
 * The `anchor` option takes a view to set as the anchor for the share
 * popup to point to, on iPads running iOS 8. If it is not passed, it
 * defaults to centering the share popup on screen without any arrows.
 */
- (CGRect)sourceRectInView:(UIView *)sourceView
             anchorViewTag:(NSNumber *)anchorViewTag
{
    if (anchorViewTag) {
        UIView *anchorView = [self.bridge.uiManager viewForReactTag:anchorViewTag];
        return [anchorView convertRect:anchorView.bounds toView:sourceView];
    } else {
        return (CGRect){sourceView.center, {1, 1}};
    }
}

RCT_EXPORT_METHOD(showShareActionSheetWithOptions:(NSDictionary *)options
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
    if (RCTRunningInAppExtension()) {
        RCTLogError(@"Unable to show action sheet from app extension");
        return;
    }
    
    NSMutableArray<id> *items = [NSMutableArray array];
    NSString *message = [RCTConvert NSString:options[@"message"]];
    if (message) {
        [items addObject:message];
    }
    NSURL *URL = [RCTConvert NSURL:options[@"url"]];
    NSData* data;
    
    if (URL) {
        if (URL.fileURL || [URL.scheme.lowercaseString isEqualToString:@"data"]) {
            NSError *error;
            data = [NSData dataWithContentsOfURL:URL
                                                 options:(NSDataReadingOptions)0
                                                   error:&error];
            if (!data) {
                failureCallback(error);
                return;
            }
            [items addObject:data];
        } else {
            [items addObject:URL];
        }
    }
    if (items.count == 0) {
        RCTLogError(@"No `url` or `message` to share");
        return;
    }
    
    BOOL shouldUseCustomItemProvider = [RCTConvert BOOL:options[@"shouldUseCustomItemProvider"]];
    
    UIActivityViewController *shareController;
    
    if (shouldUseCustomItemProvider) {
        
        NSMutableArray<id>* activityItemProviders = [[NSMutableArray alloc] init];
        
        if (message) {
            [activityItemProviders addObject:[[TFMessageActivityItemProvider alloc] initWithMessage:message]];
        }
        
        if (data) {
            [activityItemProviders addObject:[[TFImageActivityItemProvider alloc] initWithImageData:data]];
        }
        
        shareController = [[UIActivityViewController alloc] initWithActivityItems:activityItemProviders applicationActivities:nil];
    } else {
        shareController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    }
    
    NSString *subject = [RCTConvert NSString:options[@"subject"]];
    if (subject) {
        [shareController setValue:subject forKey:@"subject"];
    }
    
    NSArray *excludedActivityTypes = [RCTConvert NSStringArray:options[@"excludedActivityTypes"]];
    if (excludedActivityTypes) {
        shareController.excludedActivityTypes = excludedActivityTypes;
    }
    
    UIViewController *controller = RCTPresentedViewController();
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    
    if (![UIActivityViewController instancesRespondToSelector:@selector(setCompletionWithItemsHandler:)]) {
        // Legacy iOS 7 implementation
        shareController.completionHandler = ^(NSString *activityType, BOOL completed) {
            successCallback(@[@(completed), RCTNullIfNil(activityType)]);
        };
    } else
        
#endif
        
    {
        // iOS 8 version
        shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, __unused NSArray *returnedItems, NSError *activityError) {
            if (activityError) {
                failureCallback(activityError);
            } else {
                successCallback(@[@(completed), RCTNullIfNil(activityType)]);
            }
        };
        
        shareController.modalPresentationStyle = UIModalPresentationPopover;
        NSNumber *anchorViewTag = [RCTConvert NSNumber:options[@"anchor"]];
        if (!anchorViewTag) {
            shareController.popoverPresentationController.permittedArrowDirections = 0;
        }
        shareController.popoverPresentationController.sourceView = controller.view;
        shareController.popoverPresentationController.sourceRect = [self sourceRectInView:controller.view anchorViewTag:anchorViewTag];
    }
    
    [controller presentViewController:shareController animated:YES completion:nil];
    
    shareController.view.tintColor = [RCTConvert UIColor:options[@"tintColor"]];
}

RCT_EXPORT_METHOD(shareSingle:(NSDictionary *)options
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
    
    NSString *social = [RCTConvert NSString:options[@"social"]];
    if (social) {
        NSLog(social);
        if([social isEqualToString:@"facebook"]) {
            NSLog(@"TRY OPEN FACEBOOK");
            GenericShare *shareCtl = [[GenericShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback serviceType: SLServiceTypeFacebook];
        } else if([social isEqualToString:@"twitter"]) {
            NSLog(@"TRY OPEN Twitter");
            GenericShare *shareCtl = [[GenericShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback serviceType: SLServiceTypeTwitter];
        } else if([social isEqualToString:@"googleplus"]) {
            NSLog(@"TRY OPEN google plus");
            GooglePlusShare *shareCtl = [[GooglePlusShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"whatsapp"]) {
            NSLog(@"TRY OPEN whatsapp");
            
            WhatsAppShare *shareCtl = [[WhatsAppShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"email"]) {
            NSLog(@"TRY OPEN email");
            EmailShare *shareCtl = [[EmailShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        }
    } else {
        RCTLogError(@"No exists social key");
        return;
    }
}

@end
