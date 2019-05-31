//
//  CustomAnnotationView.h
//  MapMiddlewareDemo
//
//  Created by tabsong on 17/3/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QMapKit/QAnnotationView.h>

@interface CustomAnnotationView : QAnnotationView


@property (nonatomic, strong) NSString * address;

@property (nonatomic, strong) NSString * iconImageStr;



@end
