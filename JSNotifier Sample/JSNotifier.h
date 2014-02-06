/*
 Copyright 2012 Jonah Siegle
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>

typedef enum {
    JSNotifierPositionBottom,
    JSNotifierPositionTop
} JSNotifierPosition;

typedef void (^JSNotifierCallbackBlock)();

@interface JSNotifier : UIView{
    
    @protected
    UILabel *_txtLabel;
    JSNotifierPosition _position;
}


- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title position:(JSNotifierPosition)position;

- (void)setAccessoryView:(UIView *)view animated:(BOOL)animated;

- (void)setTitle:(id)title animated:(BOOL)animated;

- (void)show;
- (void)showFor:(float)time;

- (void)hide;
- (void)hideIn:(float)seconds;

@property (nonatomic, strong) UIView *accessoryView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) UILineBreakMode lineBreakMode;

// Called after the view has been shown
@property (nonatomic, copy) JSNotifierCallbackBlock didShowBlock;

// Called after the view has been hidden
@property (nonatomic, copy) JSNotifierCallbackBlock didHideBlock;

@end

