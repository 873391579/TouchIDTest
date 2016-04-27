//
//  BottonMenu.m
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "BottonMenu.h"

@interface BottonMenu()
@property (nonatomic,assign)CGSize  size;

@end

@implementation BottonMenu
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _size = frame.size;
        self.backgroundColor = Menu_Global_Color;
        [self buildUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame cancelAction:(CompletionCancel)completion{
   self = [super initWithFrame:frame];
    if (self) {
        _size = frame.size;
        self.backgroundColor = Menu_Global_Color;
        _completion = completion;
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _size.width/2, _size.height)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"相机胶卷";
    [self addSubview:titleLabel];
    
    CGFloat offset = 20;
    CGFloat weid = (_size.width/2 - offset)/2;
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake(_size.width/2, 0, weid, _size.height);
    [_selectBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(makeSureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(_size.width - weid, 0, weid, _size.height);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelDismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
}

-(void)setConfirmText:(NSString *)confirmText{
    [_selectBtn setTitle:confirmText forState:UIControlStateNormal];
}

- (void)makeSureAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(bottonMenu:didMakeSureAction:)]) {
        [_delegate bottonMenu:self didMakeSureAction:sender];
    }
    
}

- (void)cancelDismiss{
    _completion();
}

@end
