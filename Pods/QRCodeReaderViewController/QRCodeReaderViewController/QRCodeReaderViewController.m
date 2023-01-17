/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderViewController.h"
#import "QRCameraSwitchButton.h"
#import "QRCodeReaderView.h"
#import "QRToggleTorchButton.h"
#import "CameraMaskedOverlayView.h"
#import "CameraOverlayRectView.h"
#import "VerticalButton.h"

@interface QRCodeReaderViewController ()
@property (strong, nonatomic) UILabel              *titleLabel;
@property (strong, nonatomic) VerticalButton       *switchCameraButton;
@property (strong, nonatomic) VerticalButton       *toggleTorchButton;
@property (strong, nonatomic) VerticalButton       *chooseFromPhotoLibraryButton;
@property (strong, nonatomic) VerticalButton       *myQRCodeButton;
@property (strong, nonatomic) QRCodeReaderView     *cameraView;
@property (strong, nonatomic) UIButton             *cancelButton;
@property (strong, nonatomic) QRCodeReader         *codeReader;
@property (assign, nonatomic) BOOL                 startScanningAtLoad;
@property (assign, nonatomic) BOOL                 showSwitchCameraButton;
@property (assign, nonatomic) BOOL                 showTorchButton;
@property (assign, nonatomic) BOOL                 showChooseFromPhotoLibraryButton;
@property (assign, nonatomic) BOOL                 showMyQRCodeButton;
@property (strong, nonatomic) NSString             *chooseFromPhotoLibraryButtonTitle;
@property (strong, nonatomic) CameraMaskedOverlayView          *cameraMaskedOverlayView;
@property (strong, nonatomic) CameraOverlayRectView      *cameraOverlayRectView;
@property (strong, nonatomic) UIStackView          *controlsStackView;
@property (strong, nonatomic) UIColor              *bordersColor;
@property (strong, nonatomic) NSString             *message;
@property (strong, nonatomic) NSString             *torchTitle;
@property (strong, nonatomic) UIImage              *chooseFromPhotoLibraryButtonImage;
@property (strong, nonatomic) UIImage              *torchImage;
@property (strong, nonatomic) NSString             *myQRCodeTitle;
@property (strong, nonatomic) UIImage              *myQRCodeImage;

@property (copy, nonatomic) void (^completionBlock) (NSString * __nullable);

@end

@implementation QRCodeReaderViewController

- (void)dealloc
{
  [self stopScanning];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
  return [self initWithCancelButtonTitle:nil];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle
{
  return [self initWithCancelButtonTitle:cancelTitle metadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle chooseFromPhotoLibraryButtonTitle:(NSString*)chooseFromPhotoLibraryButtonTitle
{
  QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    return [self initWithCancelButtonTitle:cancelTitle codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:NO showTorchButton:NO showMyQRCodeButton: NO chooseFromPhotoLibraryButtonTitle:chooseFromPhotoLibraryButtonTitle bordersColor: UIColor.lightGrayColor messageText: nil torchTitle:nil torchImage:nil chooseFromPhotoLibraryButtonImage:nil myQRCodeText:nil myQRCodeImage:nil];
}

- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
  return [self initWithCancelButtonTitle:nil metadataObjectTypes:metadataObjectTypes];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
  QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:metadataObjectTypes];

  return [self initWithCancelButtonTitle:cancelTitle codeReader:reader];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader
{
  return [self initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:true];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad
{
  return [self initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:startScanningAtLoad showSwitchCameraButton:YES showTorchButton:NO];
}

- (id)initWithCancelButtonTitle:(nullable NSString *)cancelTitle codeReader:(nonnull QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad showSwitchCameraButton:(BOOL)showSwitchCameraButton showTorchButton:(BOOL)showTorchButton
{
    return [self initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:startScanningAtLoad showSwitchCameraButton:YES showTorchButton:NO showMyQRCodeButton: NO chooseFromPhotoLibraryButtonTitle:nil bordersColor:UIColor.lightGrayColor messageText: nil torchTitle:nil torchImage:nil chooseFromPhotoLibraryButtonImage:nil myQRCodeText:nil myQRCodeImage:nil];
}

- (nonnull id)initWithCancelButtonTitle:(nullable NSString *)cancelTitle codeReader:(nonnull QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad showSwitchCameraButton:(BOOL)showSwitchCameraButton showTorchButton:(BOOL)showTorchButton showMyQRCodeButton:(BOOL)showMyQRCodeButton chooseFromPhotoLibraryButtonTitle:(nullable NSString*)chooseFromPhotoLibraryButtonTitle bordersColor: (nullable UIColor*) bordersColor messageText: (nullable NSString *)message torchTitle: (nullable NSString*)torchTitle torchImage: (nullable UIImage*) torchImage chooseFromPhotoLibraryButtonImage: (nullable UIImage*) chooseFromPhotoLibraryButtonImage myQRCodeText: (NSString*) myQRCodeText myQRCodeImage: (nullable UIImage*) myQRCodeImage {
  if ((self = [super init])) {
    self.view.backgroundColor   = [UIColor blackColor];
    self.bordersColor           = bordersColor;
    self.codeReader             = codeReader;
    self.startScanningAtLoad    = startScanningAtLoad;
    self.showSwitchCameraButton = showSwitchCameraButton;
    self.showTorchButton        = showTorchButton;
    self.showMyQRCodeButton     = showMyQRCodeButton;
    self.showChooseFromPhotoLibraryButton = chooseFromPhotoLibraryButtonTitle != nil;
    self.chooseFromPhotoLibraryButtonTitle = chooseFromPhotoLibraryButtonTitle;
    self.message = message;
    self.torchImage = torchImage;
    self.torchTitle = torchTitle;
    self.chooseFromPhotoLibraryButtonImage = chooseFromPhotoLibraryButtonImage;
    self.myQRCodeTitle = myQRCodeText;
    self.myQRCodeImage = myQRCodeImage;

    [self setupUIComponentsWithCancelButtonTitle:cancelTitle];
    [self setupAutoLayoutConstraints];

    [_cameraView.layer insertSublayer:_codeReader.previewLayer atIndex:0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    __weak __typeof__(self) weakSelf = self;

    [codeReader setCompletionWithBlock:^(NSString *resultAsString) {
      if (weakSelf.completionBlock != nil) {
        weakSelf.completionBlock(resultAsString);
      }

      if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(reader:didScanResult:)]) {
        [weakSelf.delegate reader:weakSelf didScanResult:resultAsString];
      }
    }];
  }
  return self;
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle];
}

+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
  return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle metadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:startScanningAtLoad];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad showSwitchCameraButton:(BOOL)showSwitchCameraButton showTorchButton:(BOOL)showTorchButton
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:startScanningAtLoad showSwitchCameraButton:showSwitchCameraButton showTorchButton:showTorchButton];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (_startScanningAtLoad) {
    [self startScanning];
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self stopScanning];

  [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  _codeReader.previewLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  [_cameraView setNeedsDisplay];
  [_cameraMaskedOverlayView setNeedsDisplay];
  [_cameraOverlayRectView setNeedsDisplay];
}

#pragma mark - Controlling the Reader

- (void)startScanning {
  [_codeReader startScanning];
}

- (void)stopScanning {
  [_codeReader stopScanning];
}

#pragma mark - Managing the Orientation

- (void)orientationChanged:(NSNotification *)notification
{
  [_cameraView setNeedsDisplay];
  [_cameraMaskedOverlayView setNeedsDisplay];
  [_cameraOverlayRectView setNeedsDisplay];

  if (_codeReader.previewLayer.connection.isVideoOrientationSupported) {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    _codeReader.previewLayer.connection.videoOrientation = [QRCodeReader videoOrientationFromInterfaceOrientation:
                                                            orientation];
  }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
  self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components

- (void)setupUIComponentsWithCancelButtonTitle:(NSString *)cancelButtonTitle
{
  self.cameraView                                       = [[QRCodeReaderView alloc] init];
  _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
  _cameraView.clipsToBounds                             = YES;
    
  self.cameraMaskedOverlayView = [[CameraMaskedOverlayView alloc] init];
  
  _cameraMaskedOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
  _cameraMaskedOverlayView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
  
  self.cameraOverlayRectView = [[CameraOverlayRectView alloc] init];
  _cameraOverlayRectView.translatesAutoresizingMaskIntoConstraints = NO;
  _cameraOverlayRectView.backgroundColor = UIColor.clearColor;
  _cameraOverlayRectView.tintColor = self.bordersColor;
  _cameraOverlayRectView.lineLength = 50.0f;
  _cameraOverlayRectView.lineWidth = 3.0f;
  
  [self.view addSubview:_cameraView];
  [self.view addSubview:_cameraMaskedOverlayView];
  [self.view addSubview:_cameraOverlayRectView];

  self.controlsStackView = [[UIStackView alloc] init];
  _controlsStackView.axis = UILayoutConstraintAxisHorizontal;
  _controlsStackView.translatesAutoresizingMaskIntoConstraints = NO;
  _controlsStackView.distribution = UIStackViewDistributionFillEqually;
  _controlsStackView.spacing = 20;
    
  [_codeReader.previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

  if ([_codeReader.previewLayer.connection isVideoOrientationSupported]) {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    _codeReader.previewLayer.connection.videoOrientation = [QRCodeReader videoOrientationFromInterfaceOrientation:orientation];
  }

  if (_showSwitchCameraButton && [_codeReader hasFrontDevice]) {
    _switchCameraButton = [[VerticalButton alloc] initWithTitle:NSLocalizedString(@"Switch", @"Switch") image:nil];

    [_switchCameraButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [_switchCameraButton addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsStackView addArrangedSubview:_switchCameraButton];
  }

  if (_showTorchButton && [_codeReader isTorchAvailable]) {
    _toggleTorchButton = [[VerticalButton alloc] initWithTitle: self.torchTitle image: self.torchImage];
    
    [_toggleTorchButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [_toggleTorchButton addTarget:self action:@selector(toggleTorchAction:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsStackView addArrangedSubview:_toggleTorchButton];
  }
  
  if(_message) {
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    _titleLabel.text = _message;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = UIColor.whiteColor;
      
    [self.view addSubview:_titleLabel];
  }

  if (_showMyQRCodeButton && _myQRCodeTitle) {
    _myQRCodeButton = [[VerticalButton alloc] initWithTitle:_myQRCodeTitle image:_myQRCodeImage];

    [_myQRCodeButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [_myQRCodeButton addTarget:self action:@selector(myQRCodeSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsStackView addArrangedSubview:_myQRCodeButton];
  }

  if (_showChooseFromPhotoLibraryButton) {
    _chooseFromPhotoLibraryButton = [[VerticalButton alloc] initWithTitle:_chooseFromPhotoLibraryButtonTitle image:_chooseFromPhotoLibraryButtonImage];
    
    [_chooseFromPhotoLibraryButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [_chooseFromPhotoLibraryButton addTarget:self action:@selector(chooseFromPhotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsStackView addArrangedSubview:_chooseFromPhotoLibraryButton];
  }

  if (cancelButtonTitle) {
    self.cancelButton                                       = [[UIButton alloc] init];
    
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsStackView addArrangedSubview:_cancelButton];
  }
  
  [self.view addSubview:_controlsStackView];
}

- (void)setupAutoLayoutConstraints
{
    NSLayoutYAxisAnchor * topLayoutAnchor;
    NSLayoutYAxisAnchor * bottomLayoutAnchor;
    NSLayoutXAxisAnchor * leftLayoutAnchor;
    NSLayoutXAxisAnchor * rightLayoutAnchor;
    if (@available(iOS 11.0, *)) {
      topLayoutAnchor = self.view.safeAreaLayoutGuide.topAnchor;
      bottomLayoutAnchor = self.view.safeAreaLayoutGuide.bottomAnchor;
      leftLayoutAnchor = self.view.safeAreaLayoutGuide.leftAnchor;
      rightLayoutAnchor = self.view.safeAreaLayoutGuide.rightAnchor;
    } else {
      topLayoutAnchor = self.topLayoutGuide.topAnchor;
      bottomLayoutAnchor = self.bottomLayoutGuide.bottomAnchor;
      leftLayoutAnchor = self.view.leftAnchor;
      rightLayoutAnchor = self.view.rightAnchor;
    }

  NSDictionary *views = NSDictionaryOfVariableBindings(_cameraView);

  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView]|" options:0 metrics:nil views:views]];
  
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:nil views:views]];
  
  if (_titleLabel) {
    [NSLayoutConstraint activateConstraints:@[
      [_titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
      [_titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
      [_titleLabel.topAnchor constraintEqualToAnchor:topLayoutAnchor constant: 60],
    ]];
  }
  
  [NSLayoutConstraint activateConstraints:@[
    [_controlsStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [_controlsStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [_controlsStackView.bottomAnchor constraintEqualToAnchor:bottomLayoutAnchor constant:-20],
    
    [_cameraMaskedOverlayView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
    [_cameraMaskedOverlayView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
    [_cameraMaskedOverlayView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [_cameraMaskedOverlayView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    
    [_cameraOverlayRectView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
    [_cameraOverlayRectView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
    [_cameraOverlayRectView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [_cameraOverlayRectView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
  ]];
}

- (void)switchDeviceInput
{
  [_codeReader switchDeviceInput];
}

#pragma mark - Catching Button Events

- (void)cancelAction:(UIButton *)button
{
  [_codeReader stopScanning];

  if (_completionBlock) {
    _completionBlock(nil);
  }

  if (_delegate && [_delegate respondsToSelector:@selector(readerDidCancel:)]) {
    [_delegate readerDidCancel:self];
  }
}

- (void)switchCameraAction:(UIButton *)button
{
  [self switchDeviceInput];
}

- (void)toggleTorchAction:(UIButton *)button
{
  [_codeReader toggleTorch];
}

- (void)chooseFromPhotoLibrary:(UIButton *)button
{
  UIImagePickerController *viewController = [UIImagePickerController new];
  viewController.delegate = self;
  viewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [self presentViewController:viewController animated:YES completion:nil];
}

- (void)myQRCodeSelected:(UIButton *)button
{
  if (_delegate && [_delegate respondsToSelector:@selector(reader:myQRCodeSelected:)]) {
    [_delegate reader:self myQRCodeSelected:button];
  }
}


@end

@implementation QRCodeReaderViewController(UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  [self dismissViewControllerAnimated:YES completion:nil];
  CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
  NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
  if (features.count >= 1) {
    CIQRCodeFeature *feature = [features objectAtIndex:0];
    NSString *scannedResult = feature.messageString;
    if (_completionBlock) {
      _completionBlock(scannedResult);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(reader:didScanResult:)]) {
      [_delegate reader:self didScanResult:scannedResult];
    }
  }
}

@end
