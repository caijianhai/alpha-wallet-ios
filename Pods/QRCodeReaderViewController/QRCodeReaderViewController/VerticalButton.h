//
//  VerticalButton.h
//  QRCodeReaderViewControllerExample
//
//  Created by Vladyslav Shepitko on 25.05.2020.
//  Copyright © 2020 Stormbird PTE. LTD.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VerticalButton : UIControl

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title image:(nullable UIImage *)image;
@end

NS_ASSUME_NONNULL_END
