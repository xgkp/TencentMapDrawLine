//
//  CustomAnnotationView.m
//  MapMiddlewareDemo
//
//  Created by tabsong on 17/3/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "CustomAnnotationView.h"

@interface CustomAnnotationView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation CustomAnnotationView


- (void)setAddress:(NSString *)address
{
    _address = address;
    self.label.text = [NSString stringWithFormat:@"%@",address];
}

#pragma mark - Setup

-(void)setIconImageStr:(NSString *)iconImageStr
{
    _iconImageStr = iconImageStr;
    UIImage * image = [UIImage imageNamed:_iconImageStr];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = CGRectMake(0, 0, 24, 38);
    [self addSubview:self.imageView];
}

- (void)setupLabelAndImage
{
    
    CGRect r = CGRectMake(0, 0, 24, 38);
    self.imageView = [[UIImageView alloc] initWithFrame:r];
    [self addSubview:self.imageView];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 38)];
    imageView.image = [UIImage imageNamed:@"home_bg_address"];
    [self addSubview:imageView];
}

#pragma mark - Life Cycle

- (instancetype)initWithAnnotation:(id<QAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])
    {
        
        self.bounds = CGRectMake(0, 0, 24, 38);
        [self setupLabelAndImage];
        self.centerOffset = CGPointMake(0, 0);
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

@end
