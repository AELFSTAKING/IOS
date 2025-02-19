//
//  FSActionSheetConfig.m
//  FSActionSheet
//
//  Created by Steven on 6/8/16.
//  Copyright © 2016 Steven. All rights reserved.
//

#import "FSActionSheetConfig.h"

// float
CGFloat const FSActionSheetDefaultMargin      = 10;     ///< 默认边距 (标题四边边距, 选项靠左或靠右时距离边缘的距离)
CGFloat const FSActionSheetContentMaxScale    = 0.65;   ///< 弹窗内容高度与屏幕高度的默认比例
CGFloat const FSActionSheetRowHeight          = 50;     ///< 行高
CGFloat const FSActionSheetTitleLineSpacing   = 2.5;    ///< 标题行距
CGFloat const FSActionSheetTitleKernSpacing   = 0.5;    ///< 标题字距
CGFloat const FSActionSheetItemTitleFontSize  = 16;     ///< 选项文字字体大小, default is 16.
CGFloat const FSActionSheetItemContentSpacing = 5;      ///< 选项图片和文字的间距
// color
NSString * const FSActionSheetTitleColor           = @"#BBBED6"; ///< 标题颜色
NSString * const FSActionSheetBackColor            = @"#F5F6FA"; ///< 背景颜色
NSString * const FSActionSheetRowNormalColor       = @"#FFFFFF"; ///< 单元格背景颜色
NSString * const FSActionSheetRowHighlightedColor  = @"#F1F1F5"; ///< 选中高亮颜色
NSString * const FSActionSheetRowTopLineColor      = @"#F5F6FA"; ///< 单元格顶部线条颜色
NSString * const FSActionSheetItemNormalColor      = @"#BBBED6"; ///< 选项默认颜色
NSString * const FSActionSheetItemHighlightedColor = @"#0091FF"; ///< 选项高亮颜色
