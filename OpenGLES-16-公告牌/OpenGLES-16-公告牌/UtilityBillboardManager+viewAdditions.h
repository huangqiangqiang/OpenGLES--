//
//  UtilityBillboardManager+viewAdditions.h
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityBillboardManager.h"

typedef struct
{
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 textureCoords;
}
BillboardVertex;

@interface UtilityBillboardManager (viewAdditions)

- (void)drawWithEyePosition:(GLKVector3)eyePosition
              lookDirection:(GLKVector3)lookDirection
                   upVector:(GLKVector3)upVector;

@end
