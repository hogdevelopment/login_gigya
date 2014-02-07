//
//  UserDataSingleton.h
//  BespokeLocationV2
//
//  Created by shinoy on 2/7/14.
//  Copyright (c) 2014 Hogarth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogInView.h"

//This sigleton can be used to share the user details anyware in the app only by importing this singleton

@interface UserDataSingleton : NSObject

@property (nonatomic,strong) NSString * nickName;
@property (nonatomic,strong) NSString * firstName;
@property (nonatomic,strong) NSString * lastName;
@property (nonatomic,strong) NSString * email;
@property (nonatomic,strong) NSString * age;
@property (nonatomic,strong) NSString * gender;

+(UserDataSingleton *) userSingleton;

@end

