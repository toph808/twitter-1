//
//  ComposeViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeViewControllerDelegate <NSObject>

- (void)didTweet:(Tweet *)tweet;

@optional
- (void)didTweetSuccessfully;

@end

@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Tweet *replyToTweet;
@property (nonatomic, strong) User *messageToUser;

@property (nonatomic, weak) id <ComposeViewControllerDelegate> delegate;

@end
