//
//  ImageCollectionCell.m
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "ImageCollectionCell.h"

@implementation ImageCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_selectedBtn setImage:[UIImage imageNamed:@"noselect@2x.png"] forState:UIControlStateNormal];
    [_selectedBtn setImage:[UIImage imageNamed:@"finished@2x.png"] forState:UIControlStateSelected];
    
}


@end
