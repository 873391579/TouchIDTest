//
//  BottonMenu.h
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define Menu_Global_Color          RGBA(57, 185, 238, 0.98)

typedef void(^CompletionCancel)();

@class BottonMenu;
@protocol BottonMenuDelegate<NSObject>
- (void)bottonMenu:(BottonMenu *)bottonView didMakeSureAction:(UIButton *)selectBtn;

@end
@interface BottonMenu : UIView
@property (nonatomic,copy)CompletionCancel completion;
@property(nonatomic,weak)id<BottonMenuDelegate> delegate;
@property (nonatomic,strong)UIButton *selectBtn;
@property(nonatomic,copy)NSString  *confirmText;

- (instancetype)initWithFrame:(CGRect)frame cancelAction:(CompletionCancel)completion;

@end
