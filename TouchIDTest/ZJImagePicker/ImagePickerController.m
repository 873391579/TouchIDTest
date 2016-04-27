//
//  ImagePickerController.m
//  Tabbar
//
//  Created by Jion on 16/4/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "ImagePickerController.h"
#import "ZJAsset.h"
#import "BottonMenu.h"
#import "ImageCollectionCell.h"

@interface ImagePickerController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BottonMenuDelegate>

@property(nonatomic,strong)ZJAsset               *asset;
@property (nonatomic,strong)NSMutableDictionary  *selectedDic;
@property (nonatomic,strong)BottonMenu           *bottonMenu;
@property(nonatomic,strong)UICollectionView      *collectionPhotoList;
@property(nonatomic,strong)UIView                *previewBgView;
@property(nonatomic,strong)UIImageView           *previewImgView;
@property (nonatomic,strong)NSIndexPath          *rememberIndex;
//设置间距
@property (nonatomic,assign)CGFloat spacing;

@end

@implementation ImagePickerController
static NSString * const reuseIdentifier = @"ImageCollectionCell";
- (id)init{
    if (self = [super init]) {
        //设置默认属性
        _imageCount = Not_Limit_Image_Count;
        _columnCount = ZColumnCountFour;
        _returnType = ZReturnTypeAsset;
        _spacing = 5.0;
    }
    return self;
}

#pragma mark - initCollectionView
- (void)initCollectionView{
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 19, ZJScreen_width, 1)];
    line.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    _collectionPhotoList = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, ZJScreen_width, ZJScreen_height - 44-20) collectionViewLayout:flowLayout];
    _collectionPhotoList.alwaysBounceVertical = YES;
    _collectionPhotoList.allowsMultipleSelection = YES;
    _collectionPhotoList.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _collectionPhotoList.delegate = self;
    _collectionPhotoList.dataSource = self;
    [self.view addSubview:_collectionPhotoList];
    
    [_collectionPhotoList registerNib:[UINib nibWithNibName:reuseIdentifier bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    if (_imageCount != 1) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMultipleSelection:)];
        [self.view addGestureRecognizer:pan];
    }
}

#pragma mark - for bottom menu
- (void)initBottomMenu{
    __weak __typeof(self)tmpSelf = self;
    self.bottonMenu = [[BottonMenu alloc] initWithFrame:CGRectMake(0, ZJScreen_height-44,ZJScreen_width , 44) cancelAction:^{
        if ([self.delegate respondsToSelector:@selector(didCancelImagePickerController)]) {
            [self.delegate didCancelImagePickerController];
        }
        [tmpSelf dismissViewControllerAnimated:YES completion:nil];
    } ];
    self.bottonMenu.delegate = self;
    [self.view addSubview:self.bottonMenu];
    [self showSelectedCount:0];
}

- (void)showSelectedCount:(NSInteger)count{
    if (_imageCount == Not_Limit_Image_Count) {
        _bottonMenu.confirmText = [NSString stringWithFormat:@"确定(%ld)", (long)count];
        
    }else if(_imageCount <= 1){
        
        _bottonMenu.selectBtn.hidden = YES;
        
    }else{
        _bottonMenu.confirmText = [NSString stringWithFormat:@"确定(%ld/%ld)",(long)count, (long)_imageCount];
    }
    
}

#pragma mark --BottonMenuDelegate
-(void)bottonMenu:(BottonMenu *)bottonView didMakeSureAction:(UIButton *)selectBtn
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:_selectedDic.count];
    NSArray *keys = [_selectedDic keysSortedByValueUsingSelector:@selector(compare:)];
    if (_returnType == ZReturnTypeUIImage) {
        for (NSNumber *key in keys) {
            [resultArray addObject:[_asset getImageAtIndex:[key integerValue] type:PhotoTypeScreenSize]];
        }
        
    }else{
        for (NSNumber *key in keys){
            [resultArray addObject:[_asset getAssetAtIndex:[key integerValue]]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(imagePicker:didSelectPhotoSets:)]) {
        [_delegate imagePicker:self didSelectPhotoSets:resultArray];
    }
    
}

#pragma mark-- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Menu_Global_Color;
    // Do any additional setup after loading the view.
    
    [self initBottomMenu];
    [self readAlbumList];
    [self initCollectionView];
    
}

#pragma mark 读取相册资源
-(void)readAlbumList{
    _asset = [ZJAsset shareZJAsset];
    [_asset getGroupList:^(NSArray *groups){
        id fristGroup = [_asset getGroupInfo:0];
        NSLog(@"相机胶卷:%@",fristGroup);
        [self showPhotosInGroup:0];
    }];
    
}
#pragma mark - for photos
- (void)showPhotosInGroup:(NSInteger)nIndex{
    if (_imageCount == Not_Limit_Image_Count) {
        _selectedDic = [[NSMutableDictionary alloc] init];
        
    }
    else if (_imageCount > 1){
        _selectedDic = [[NSMutableDictionary alloc] initWithCapacity:_imageCount];
        
    }
    
    [_asset getPhotoListOfGroupByIndex:nIndex result:^(NSArray *aPhotos) {
        
        [_collectionPhotoList reloadData];
        
        _collectionPhotoList.alpha = 0.3;
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationDelay:0.1];
            _collectionPhotoList.alpha = 1.0;
        }];
        if (aPhotos.count>0) {
            [_collectionPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:aPhotos.count-1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionTop) animated:NO];
        }
    }];
}
#pragma mark --setter getter
- (UIView*)previewBgView
{
    if (!_previewBgView) {
        _previewBgView = [[UIView alloc] initWithFrame:self.view.frame];
        _previewBgView.backgroundColor = [UIColor blackColor];
        _previewBgView.alpha = 0;
        [self.view addSubview:_previewBgView];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHidePreviewBgView:)];
        [_previewBgView addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHidePreviewBgView:)];
        [_previewBgView addGestureRecognizer:tap];
        
    }
    return _previewBgView;
}

- (UIImageView*)previewImgView
{
    if (!_previewImgView) {
        _previewImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
        _previewImgView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImgView.autoresizingMask = _previewBgView.autoresizingMask;
        [_previewBgView addSubview:_previewImgView];
    }
    return _previewImgView;
}

#pragma mark--手势
- (void)onLongGestureForPreview:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.view.tag) {
        [self showPreview:gestureRecognizer.view.tag];
    }
}
- (void)panHidePreviewBgView:(UIPanGestureRecognizer*)pan{
    CGPoint translation = [pan translationInView:self.view];
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            if (_previewBgView.alpha < 0.7) {
                CGPoint center = _previewImgView.center;
                if (_previewImgView.center.y > _previewBgView.center.y) {
                    center.y = ZJScreen_height * 1.2;
                }
                else if (_previewImgView.center.y < _previewBgView.center.y){
                    center.y = -ZJScreen_height * 1.2;
                }
                _previewImgView.center = center;
                [self hidePreviewImageView];
            }else{
                _previewBgView.alpha = 0.98;
                _previewImgView.center = _previewBgView.center;
            }
            
        }];
        
    }else{
        _previewImgView.center = CGPointMake(_previewImgView.center.x + translation.x, _previewImgView.center.y + translation.y);
        [pan setTranslation:CGPointMake(0, 0) inView:self.view];
        _previewBgView.alpha = 1.0 - ABS(_previewImgView.center.y - _previewBgView.center.y)/(ZJScreen_height/2.0);
    }
}
- (void)tapHidePreviewBgView:(UITapGestureRecognizer*)tap{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self hidePreviewImageView];
        }];
        
    }
}

- (void)panMultipleSelection:(UIPanGestureRecognizer*)pan{
    double screenY = [pan locationInView:self.bottonMenu].y;
    if (screenY >= 0) {
        return;
    }
    if (_previewBgView.alpha == 0) {
        double X = [pan locationInView:_collectionPhotoList].x;
        double Y = [pan locationInView:_collectionPhotoList].y;
        for (ImageCollectionCell *cell in _collectionPhotoList.visibleCells) {
            float cellSX = cell.frame.origin.x;
            float cellEX = cell.frame.origin.x + cell.frame.size.width;
            float cellSY = cell.frame.origin.y;
            float cellEY = cell.frame.origin.y + cell.frame.size.height;
            if (X >= cellSX && X <= cellEX && Y >= cellSY && Y <= cellEY){
                NSIndexPath *indexPath = [_collectionPhotoList indexPathForCell:cell];
                if (_rememberIndex != indexPath) {
                    if (_selectedDic[@(indexPath.row)] == nil && _imageCount > _selectedDic.count) {
                        cell.selectedBtn.selected = YES;
                        _selectedDic[@(indexPath.row)] = @(_selectedDic.count);
                    }else{
                        cell.selectedBtn.selected = NO;
                        [_selectedDic removeObjectForKey:@(indexPath.row)];
                    }
                }
                _rememberIndex = indexPath;
                
            }
        }
        
        if (pan.state == UIGestureRecognizerStateEnded) {
            _rememberIndex = nil;
            [self showSelectedCount:_selectedDic.count];
            _collectionPhotoList.scrollEnabled = YES;
        }
    }
}

- (void)hidePreviewImageView{
    [self.view bringSubviewToFront:self.bottonMenu];
    _previewBgView.alpha = 0;
    
}

- (void)showPreview:(NSInteger)index{
    [self.view bringSubviewToFront:self.previewBgView];
    self.previewImgView.image = [_asset getImageAtIndex:index type:PhotoTypeScreenSize];
    self.previewImgView.center = self.previewBgView.center;
    [UIView animateWithDuration:0.2 animations:^(void) {
        
        self.previewBgView.alpha = 0.98;
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_asset getPhotoCountOfCurrentGroup];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongGestureForPreview:)];
    longTap.minimumPressDuration = 0.3;
    [cell.contentView addGestureRecognizer:longTap];
    longTap.view.tag = indexPath.row;
    
    cell.imageView.image= [_asset getImageAtIndex:indexPath.row type:PhotoTypeThumbnail];
    //防止重用出错
    if (_selectedDic[@(indexPath.row)] == nil) {
        cell.selectedBtn.selected = NO;
    }else{
        cell.selectedBtn.selected = YES;
    }
    
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

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_imageCount > 1 || _imageCount == Not_Limit_Image_Count) {
        ImageCollectionCell *cell = (ImageCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.selectedBtn.selected) {
            cell.selectedBtn.selected = NO;
            [_selectedDic removeObjectForKey:@(indexPath.row)];
            
        }else{
            if (_selectedDic[@(indexPath.row)] == nil && _imageCount > _selectedDic.count) {
                cell.selectedBtn.selected = YES;
                _selectedDic[@(indexPath.row)] = @(_selectedDic.count);
            }
        }
        
        [self showSelectedCount:_selectedDic.count];
    }
    else{
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (_returnType == ZReturnTypeUIImage) {
            if ([_delegate respondsToSelector:@selector(imagePicker:didSelectPhotoSets:)]) {
                [_delegate imagePicker:self didSelectPhotoSets:@[[_asset getImageAtIndex:indexPath.row type:PhotoTypeScreenSize]]];
                
            }
            
        }else{
            if ([_delegate respondsToSelector:@selector(imagePicker:didSelectPhotoSets:)]) {
                [_delegate imagePicker:self didSelectPhotoSets:@[[_asset getAssetAtIndex:indexPath.row]]];
                
            }
        }
        
    }
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionCell *cell = (ImageCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selectedBtn.selected) {
        cell.selectedBtn.selected = NO;
        [_selectedDic removeObjectForKey:@(indexPath.row)];
    }else{
        if (_selectedDic[@(indexPath.row)] == nil && _imageCount > _selectedDic.count) {
            cell.selectedBtn.selected = YES;
            _selectedDic[@(indexPath.row)] = @(_selectedDic.count);
        }
    }
    [self showSelectedCount:_selectedDic.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_returnType == ZReturnTypeUIImage) {
        [_asset clearData];
    }
   
}
//是否隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
