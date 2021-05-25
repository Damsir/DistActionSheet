/*
 作者：  吴定如 <75081647@qq.com>
 文件：  DistActionSheet.h
 版本：  1.0.5
 地址：  https://github.com/Damsir/DistActionSheet
 描述：  类似微信ActionSheet控件,支持横竖屏切换,视图直接放置于keyWindow上
 更新：  适配iPhone X系列,圆角,高度等
 */

#import "DistActionSheet.h"

//static inline BOOL isIPhoneXSeries() {
//    BOOL iPhoneXSeries = NO;
//    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
//        return iPhoneXSeries;
//    }
//    if (@available(iOS 11.0, *)) {
//        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
//        if (mainWindow.safeAreaInsets.bottom > 0.0) {
//            iPhoneXSeries = YES;
//        }
//    }
//    return iPhoneXSeries;
//}

#define SH_iPhoneX_Serial \
({BOOL iPhoneXSeries = NO; \
if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) { \
(iPhoneXSeries); \
} \
if (@available(iOS 11.0, *)) { \
iPhoneXSeries = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0; \
} \
(iPhoneXSeries);})

#define kCancelRowHeight (SH_iPhoneX_Serial ? 48.0f + 34.0f : 48.0f)

//static const CGFloat kRowHeight = 48.0f;
static const CGFloat kRowHeight = 60.0f;
static const CGFloat kRowLineHeight = 1.0f;
static const CGFloat kSeparatorHeight = 8.0f;
static const CGFloat kTitleFontSize = 16.0f;
static const CGFloat kButtonTitleFontSize = 19.0f;
static const NSTimeInterval kAnimateDuration = 0.3f;

@interface DistActionSheet ()

/** block回调 */
@property (copy, nonatomic) DistActionSheetBlock actionSheetBlock;
/** 背景图片 */
@property (strong, nonatomic) UIView *backgroundView;
/** 弹出视图 */
@property (strong, nonatomic) UIView *actionSheetView;

/**
 * 收起视图
 */
- (void)dismiss;

/**
 * 通过颜色生成图片
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end

@implementation DistActionSheet

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil handler:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil handler:nil];
}

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(DistActionSheetBlock)actionSheetBlock {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _actionSheetBlock = actionSheetBlock;
        
        CGFloat actionSheetHeight = 0;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        _backgroundView.alpha = 0;
        [self addSubview:_backgroundView];
        
        _actionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
        _actionSheetView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//        _actionSheetView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
//        _actionSheetView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
        _actionSheetView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        [self addSubview:_actionSheetView];
        
        UIImage *normalImage = [self imageWithColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        UIImage *highlightedImage = [self imageWithColor:[UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f]];
        
        if (title && title.length > 0) {
            actionSheetHeight += kRowLineHeight;
            
            CGFloat titleHeight = ceil([title boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTitleFontSize]} context:nil].size.height) + 20*2;
            titleHeight = titleHeight > kRowHeight ? titleHeight : kRowHeight;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, actionSheetHeight, self.frame.size.width, titleHeight)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            titleLabel.text = title;
            titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
            titleLabel.textColor = [UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
            titleLabel.numberOfLines = 0;
            [_actionSheetView addSubview:titleLabel];
            
            actionSheetHeight += titleHeight;
        }
        
        if (otherButtonTitles && [otherButtonTitles count] > 0) {
            for (int i = 0; i < otherButtonTitles.count; i++) {
                actionSheetHeight += kRowLineHeight;
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, actionSheetHeight, self.frame.size.width, kRowHeight);
                button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                button.tag = i+1;
                button.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
                [button setTitle:otherButtonTitles[i] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                [button setBackgroundImage:normalImage forState:UIControlStateNormal];
                [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_actionSheetView addSubview:button];
                
                actionSheetHeight += kRowHeight;
            }
        }
        
        if (destructiveButtonTitle && destructiveButtonTitle.length > 0) {
            actionSheetHeight += kRowLineHeight;
            
            UIButton *destructiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            destructiveButton.frame = CGRectMake(0, actionSheetHeight, self.frame.size.width, kRowHeight);
            destructiveButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            destructiveButton.tag = -1;
            destructiveButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
            [destructiveButton setTitle:destructiveButtonTitle forState:UIControlStateNormal];
            [destructiveButton setTitleColor:[UIColor colorWithRed:230.0f/255.0f green:66.0f/255.0f blue:66.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [destructiveButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_actionSheetView addSubview:destructiveButton];
            
            actionSheetHeight += kRowHeight;
        }
        
        if (cancelButtonTitle && cancelButtonTitle.length > 0) {
            actionSheetHeight += kSeparatorHeight;
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.frame = CGRectMake(0, actionSheetHeight, self.frame.size.width, kRowHeight);
//            cancelButton.frame = CGRectMake(0, actionSheetHeight, self.frame.size.width, kCancelRowHeight);
            cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            cancelButton.tag = 0;
            cancelButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
            [cancelButton setTitle:cancelButtonTitle ?: @"取消" forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [cancelButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_actionSheetView addSubview:cancelButton];
            
            actionSheetHeight += kRowHeight;
//            actionSheetHeight += kCancelRowHeight;
            
//            if (SH_iPhoneX_Serial) {
//                // 适配iPhoneX系列
//                cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 25, 0);
//            }
        }
        
        _actionSheetView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, actionSheetHeight);
        // 圆角
        [self addCornerRadius:15.0 corners:UIRectCornerTopLeft | UIRectCornerTopRight view:_actionSheetView];
    }
    
    return self;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(DistActionSheetBlock)actionSheetBlock {
    return [[self alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles handler:actionSheetBlock];
}

+ (void)showActionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(DistActionSheetBlock)actionSheetBlock {
    DistActionSheet *distActionSheet = [self actionSheetWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles handler:actionSheetBlock];
    [distActionSheet show];
}

- (void)show {
    // 在主线程中处理,否则在viewDidLoad方法中直接调用,会先加本视图,后加控制器的视图到UIWindow上,导致本视图无法显示出来,这样处理后便会优先加控制器的视图到UIWindow上
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self];
                break;
            }
        }
        
//        [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.backgroundView.alpha = 1.0f;
//            self.actionSheetView.frame = CGRectMake(0, self.frame.size.height-self.actionSheetView.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
//        } completion:nil];
        [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backgroundView.alpha = 1.0f;
            self.actionSheetView.frame = CGRectMake(0, self.frame.size.height-self.actionSheetView.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
        } completion:nil];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0f;
        self.actionSheetView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.backgroundView];
    if (!CGRectContainsPoint(self.actionSheetView.frame, point)) {
        if (self.actionSheetBlock) {
            self.actionSheetBlock(self, 0);
        }
        [self dismiss];
    }
}

- (void)buttonClicked:(UIButton *)button {
    if (self.actionSheetBlock){
        self.actionSheetBlock(self, button.tag);
    }
    [self dismiss];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 设置一个普通圆角(圆角位置)
 
 @param radius 圆角半径
 @param corners 圆角位置
 */
- (void)addCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners view:(UIView *)view {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
    
    // 提高性能
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DistActionSheet dealloc");
#endif
}

@end

