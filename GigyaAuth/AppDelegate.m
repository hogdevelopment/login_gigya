//
//  AppDelegate.m
//  GigyaAuth
//
//  Created by shinoy on 1/20/14.
//  Copyright (c) 2014 shinoy. All rights reserved.
//

#import "AppDelegate.h"
#import <GigyaSDK/Gigya.h>

//change API key here
#define ApiKey @"3_7MqzwGmlHY1SIzdGUKu7u20YiW5oBvzzBCZS7MpahR7_71q88LpaWyusERHsMcuz"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Gigya initWithAPIKey:ApiKey];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:
                    (NSString *)sourceApplication annotation:(id)annotation
{
    return [Gigya handleOpenURL:url sourceApplication:sourceApplication
                     annotation:annotation];
}
							
@end
