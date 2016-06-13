//
//  MyCustomView.m
//  MyCircleScrollviewDemo
//
//  Created by ramborange on 16/6/12.
//  Copyright © 2016年 ______MyCompanyName______. All rights reserved.
//

#import "MyCustomView.h"

@implementation MyCustomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _NoLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _NoLabel.font = [UIFont systemFontOfSize:30];
        _NoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_NoLabel];
    }
    return self;
}

@end
