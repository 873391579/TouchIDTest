//
//  ZJAsset.h
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef NS_ENUM(NSUInteger, PhotoType) {
    
    PhotoTypeThumbnail = 0,
    PhotoTypeScreenSize,
    PhotoTypeFullResolution,
    
};

@interface ZJAsset : NSObject


+(ZJAsset*)shareZJAsset;
/*
 图片排序，默认Yes.
 */
@property (nonatomic,assign,readwrite)BOOL photoSort;
/*
 相册专辑反向排序，默认Yes
 */
@property (nonatomic,assign,readwrite)BOOL albumReverse;
/*
 显示图片的像素
 */
@property (nonatomic,assign,readwrite)PhotoType photoType;

//获取相册资源列表
- (void)getGroupList:(void (^)(NSArray *))result;
// get photos from specific album with ALAssetsGroup object
- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result;
// get photos from specific album with index of album array
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result;
// get photos from camera roll
- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error;

- (NSInteger)getGroupCount;
- (NSInteger)getPhotoCountOfCurrentGroup;
- (NSDictionary *)getGroupInfo:(NSInteger)nIndex;

- (void)clearData;

// utils
- (UIImage *)getCroppedImage:(NSURL *)urlImage;
- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(PhotoType)nType;
- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(PhotoType)nType;
- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex;


@end
