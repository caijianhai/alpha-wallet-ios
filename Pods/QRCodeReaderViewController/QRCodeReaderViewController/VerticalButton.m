//
//  VerticalButton.m
//  QRCodeReaderViewControllerExample
//
//  Created by Vladyslav Shepitko on 25.05.2020.
//  Copyright © 2020 Stormbird PTE. LTD.
//

#import "VerticalButton.h"

@interface VerticalButton ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation VerticalButton

- (instancetype)initWithTitle:(NSString *)title image:(nullable UIImage *)image {
  self = [super init];
  if (self) {
    self.title = title;
    self.image = image;
    self.translatesAutoresizingMaskIntoConstraints = false;
    self.userInteractionEnabled = true;
    
    [self setupLayout];
  }
  return self;
}

-(void) setupLayout {
  
  self.textLabel = [[UILabel alloc] init];
  self.textLabel.text = self.title;
  self.textLabel.textAlignment = NSTextAlignmentCenter;
  self.textLabel.translatesAutoresizingMaskIntoConstraints = false;
  self.textLabel.userInteractionEnabled = false;
  self.textLabel.textColor = UIColor.whiteColor;
  self.textLabel.numberOfLines = 0;
    
  self.iconImageView = [[UIImageView alloc] init];
  self.iconImageView.image = self.image;
  self.iconImageView.translatesAutoresizingMaskIntoConstraints = false;
  [self.iconImageView setContentMode:UIViewContentModeScaleAspectFit];
  self.iconImageView.userInteractionEnabled = false;
  
  UIStackView *stackView = [[UIStackView alloc] init];
  stackView.axis = UILayoutConstraintAxisVertical;
  stackView.alignment = UIStackViewAlignmentCenter;
  stackView.spacing = 13.0f;
  stackView.translatesAutoresizingMaskIntoConstraints = false;
  stackView.userInteractionEnabled = false;
  
  [self addSubview: stackView];
  
  [stackView addArrangedSubview:self.iconImageView];
  [stackView addArrangedSubview:self.textLabel];
  
  [self.iconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  [self.iconImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

  [self.textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
  
  [NSLayoutConstraint activateConstraints:@[
    [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    [stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
    [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    
    [self.iconImageView.heightAnchor constraintEqualToConstant:24],
    [self.iconImageView.widthAnchor constraintEqualToConstant:24]
  ]];
}

@end
