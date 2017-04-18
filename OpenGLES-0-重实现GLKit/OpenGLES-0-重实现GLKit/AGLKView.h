//
//  AGLKView.h
//  OpenGLES-0-重新实现GLKView
//
//  Created by 黄强强 on 17/3/23.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef enum {
    AGLKViewDrawableDepthFormatNone = 0,
    AGLKViewDrawableDepthFormat16
}AGLKViewDrawableDepthFormat;

@protocol AGLKViewDelegate;

@interface AGLKView : UIView
@property (nonatomic, weak) id<AGLKViewDelegate> delegate;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint depthRenderBuffer;

@property (nonatomic, assign) NSInteger drawableWidth;
@property (nonatomic, assign) NSInteger drawableHeight;
@property (nonatomic, assign) AGLKViewDrawableDepthFormat drawableDepthFormat;
@end


@protocol AGLKViewDelegate <NSObject>
- (void)aglkview:(AGLKView *)view drawInRect:(CGRect)rect;
@end
