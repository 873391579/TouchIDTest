//
//  ImagePickerController.h
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZColumnCount) {
    ZColumnCountFour = 4,
    ZColumnCountThree = 3,
    ZColumnCountTwo = 2,
};
typedef NS_ENUM(NSUInteger, ZReturnType) {
    ZReturnTypeUIImage = 0,
    ZReturnTypeAsset = 1,// if you want to get lots photos, you'd better use this mode for memory!!!
};

#define ZJScreen_width [[UIScreen mainScreen] bounds].size.width
#define ZJScreen_height [[UIScreen mainScreen] bounds].size.height

#define Not_Limit_Image_Count          -1

@class ImagePickerController;
@protocol ImagePickerControllerDelegate<NSObject>
@optional
- (void)didCancelImagePickerController;
- (void)imagePicker:(ImagePickerController *)picker didSelectPhotoSets:(NSArray *)selectedImage;

@end


@interface ImagePickerController : UIViewController
/*
 可以选择几张图片,默认-1不受限制
 */
@property(nonatomic,assign,readwrite)NSInteger imageCount;
/*
 图片显示列数，默认ZColumnCountFour
 */
@property (nonatomic,assign,readwrite)ZColumnCount columnCount;
/*
 回调返回的数据类型，默认ZReturnTypeAsset
 */
@property (nonatomic,assign,readwrite)ZReturnType returnType;

@property (weak, nonatomic) id <ImagePickerControllerDelegate>  delegate;


@end
