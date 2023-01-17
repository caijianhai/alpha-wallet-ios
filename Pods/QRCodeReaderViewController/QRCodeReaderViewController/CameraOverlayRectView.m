//
//  CameraOverlayRectView.m
//  QRCodeReaderViewControllerExample
//
//  Created by Vladyslav Shepitko on 25.05.2020.
//  Copyright © 2020 Stormbird PTE. LTD.
//

#import "CameraOverlayRectView.h"
#import "QRCodeReaderView.h"

@implementation CameraOverlayRectView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.lineWidth = 5;
    self.lineLength = 50;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  
  CGRect offsetRect = [QRCodeReaderView readerRectFromRect: rect];

  [self.backgroundColor setFill];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);

  CGFloat halfWidth = _lineWidth / 2;
  CGContextSetLineWidth(context, _lineWidth);

  CGRect linesRect = CGRectInset(offsetRect, halfWidth, halfWidth);
  CGFloat x = linesRect.origin.x;
  CGFloat y = linesRect.origin.y;
  CGFloat w = linesRect.size.width;
  CGFloat h = linesRect.size.height;

  CGContextMoveToPoint(context, x, y - halfWidth);
  CGContextAddLineToPoint(context, x, y + _lineLength - halfWidth);

  CGContextMoveToPoint(context, x, y);
  CGContextAddLineToPoint(context, x + _lineLength, y);

  CGContextMoveToPoint(context, x + w, y - halfWidth);
  CGContextAddLineToPoint(context, x + w, y + _lineLength - halfWidth);

  CGContextMoveToPoint(context, x + w, y);
  CGContextAddLineToPoint(context, x + w - _lineLength, y);

  CGContextMoveToPoint(context, x, y + h + halfWidth);
  CGContextAddLineToPoint(context, x, y + h - _lineLength);

  CGContextMoveToPoint(context, x, y + h);
  CGContextAddLineToPoint(context, x + _lineLength, y + h);

  CGContextMoveToPoint(context, x + w, y + h + halfWidth);
  CGContextAddLineToPoint(context, x + w, y + h - _lineLength);

  CGContextMoveToPoint(context, x + w, y + h);
  CGContextAddLineToPoint(context, x + w - _lineLength, y + h);

  CGContextStrokePath(context);
}

@end
