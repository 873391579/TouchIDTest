//
//  ImageCollectionVC.m
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "ImageCollectionVC.h"
#import "ImageCollectionCell.h"
#import "ImagePickerController.h"
#import "ZJAsset.h"

#define ZJScreen_width [[UIScreen mainScreen] bounds].size.width
@interface ImageCollectionVC ()<ImagePickerControllerDelegate>
{
    NSDictionary *addDic;
}
//设置间距
@property (nonatomic,assign)CGFloat spacing;
//设置列数
@property (nonatomic,assign)NSInteger columnCount;
@property (nonatomic,strong)NSMutableArray *imageArray;
@end

@implementation ImageCollectionVC

static NSString * const reuseIdentifier = @"ImageCollectionCell";
/**
 * 注册Cell Header和FooterView
 * 便于在UICollectionViewDataSource中使用
 */
- (void) registerConfigCollectionView{
//设置弹性效果
    self.collectionView.alwaysBounceVertical = YES;
    // 注册cell时，注意是加载的Nib还是Class
    [self.collectionView registerNib:[UINib nibWithNibName:reuseIdentifier bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    /*
     [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
     
     //注册headerView 注意也是有Nib和Class区分的
     
     [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderReusableView"];
     
     //获取含有UICollectionReusableView的Nib文件。
     UINib *headerNib = [UINib nibWithNibName: @"CollectionHeaderReusableView"
     bundle: [NSBundle mainBundle]];
     
     //注册重用View
     [self.collectionView registerNib: headerNib
     forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
     withReuseIdentifier: @"CollectionHeaderReusableView"];
     
     
     //注册FooterView
     UINib *footerNib = [UINib nibWithNibName: @"CollectionFooterReusableView"
     bundle:[ NSBundle mainBundle]];
     
     [self.collectionView registerNib: footerNib
     forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
     withReuseIdentifier: @"CollectionFooterReusableView"];
     */
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // Uncomment the following line to preserve selection between presentations
//     self.clearsSelectionOnViewWillAppear = NO;
    self.spacing = 5.0;
    self.columnCount = 3;
    UIImage *image = [UIImage imageNamed:@"添加图片@2x.png"];
    addDic = [NSDictionary dictionaryWithObjectsAndKeys:image,@"fit",image,@"thumbnail", nil];
    [self registerConfigCollectionView];
    
}

- (NSMutableArray*)imageArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
        [_imageArray addObject:addDic];
    }
    return _imageArray;
    
}

#pragma Mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"count"]) {
        UIImage *addImage = [UIImage imageNamed:@"添加图片@2x.png"];
        NSMutableArray *array = (NSMutableArray*)object;
        if ([array containsObject:addImage]) {
            NSUInteger index = [array indexOfObject:addImage];
            [array exchangeObjectAtIndex:index withObjectAtIndex:array.count-1];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectedBtn.hidden = YES;
    cell.imageView.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = _imageArray[indexPath.row][@"thumbnail"];
    UIImage *image = _imageArray[indexPath.row][@"thumbnail"];
    NSData *data1 = UIImagePNGRepresentation(image);
    NSData *data2 = UIImageJPEGRepresentation(image, 1);
    
    NSLog(@"data1 = %.2f ,data2 = %.2f",data1.length/1024.0,data2.length/1024.0);
    // Configure the cell,
    
    return cell;
}
#pragma mark <UICollectionViewDelegateFlowLayout>
/**
 * 改变Cell的尺寸
 */
- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath: (NSIndexPath *)indexPath{
    
    CGFloat size = (ZJScreen_width - (_columnCount-1) * _spacing) / _columnCount;
    return CGSizeMake(size ,size);

}

/**
 * Section的上下左右边距--UIEdgeInsetsMake(上, 左, 下, 右);逆时针
 */
- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView
                        layout: (UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex: (NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


/**
 * Section中每个Cell的上下边距
 */
- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex: (NSInteger)section{
    
    return _spacing;

}

/**
 * Section中每个Cell的左右边距
 */
- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex: (NSInteger)section{
    
    return _spacing;

}

/**
 * headerView的大小
 */
- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection: (NSInteger)section{
    return CGSizeMake(0, 0);
}

/**
 * footerView的大小
 */
- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection: (NSInteger)section{
    return CGSizeMake(0, 0);
}



#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item == _imageArray.count-1) {
        ImagePickerController *imagePicker = [[ImagePickerController alloc] init];
        imagePicker.delegate = self;
        //returnType这个属性建议使用默认asset，而不是返回图片image
        NSInteger imageCount = arc4random()%3;
        NSInteger columnCount = arc4random()%3;
        switch (imageCount) {
            case 0:
                imagePicker.imageCount = -1;
                break;
            case 1:
                 imagePicker.imageCount = 1;
                break;

            case 2:
                imagePicker.imageCount = 4;
                 break;

            default:
                break;
        }
        switch (columnCount) {
            case 0:
                imagePicker.columnCount = ZColumnCountFour;
                break;
            case 1:
                imagePicker.columnCount = ZColumnCountThree;
                break;
            case 2:
                imagePicker.columnCount = ZColumnCountTwo;
                break;
                
            default:
                break;
        }
  
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }else{
        
    }
}
#pragma mark <ImagePickerControllerDelegate>
- (void)imagePicker:(ImagePickerController *)picker didSelectPhotoSets:(NSArray *)selectedImage
{
   __block UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity setColor:[UIColor whiteColor]];
    activity.bounds = CGRectMake(0, 0, 120, 120);
    activity.backgroundColor = [UIColor grayColor];
    activity.alpha = 0.8;
    activity.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    [activity startAnimating];
    [self.view addSubview:activity];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (id sender in selectedImage){
            [self.imageArray addObject:[self setImageFit:(ALAsset*)sender]];
            
        }
        
        if ([selectedImage.firstObject isKindOfClass:[ALAsset class]]) {
            [[ZJAsset shareZJAsset] clearData];
        }
        
        if ([_imageArray containsObject:addDic]) {
            [_imageArray removeObject:addDic];
            [_imageArray addObject:addDic];
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activity stopAnimating];
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_imageArray.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        });
    });
    
    
}

- (NSDictionary*)setImageFit:(id)asset{
    
    if ([asset isKindOfClass:[ALAsset class]]) {
        UIImage *thumbnail = [[ZJAsset shareZJAsset] getImageFromAsset:asset type:PhotoTypeThumbnail];
        UIImage *fit = [[ZJAsset shareZJAsset] getImageFromAsset:asset type:PhotoTypeScreenSize];
        if (thumbnail) {
            return @{@"thumbnail":thumbnail,@"fit":fit};
        }
    }
    else if ([asset isKindOfClass:[UIImage class]]){
        return @{@"thumbnail":asset,@"fit":asset};
    }
    
    return @{};
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
