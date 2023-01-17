//
//  CameraMaskedOverlayView.m
//  QRCodeReaderViewControllerExample
//
//  Created by Vladyslav Shepitko on 25.05.2020.
//  Copyright © 2020 Stormbird PTE. LTD.
//

#import "CameraMaskedOverlayView.h"
#import "QRCodeReaderView.h"

@implementation CameraMaskedOverlayView

- (void)drawRect:(CGRect)rect {
  
    CGRect offsetRect = [QRCodeReaderView readerRectFromRect:rect];

    [self.backgroundColor setFill];
  
    UIRectFill(rect);
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, nil, offsetRect);
    CGPathAddRect(path, nil, self.bounds);
    layer.path = path;
    layer.fillRule = kCAFillRuleEvenOdd;
  
    self.layer.mask = layer;
} 

@end
