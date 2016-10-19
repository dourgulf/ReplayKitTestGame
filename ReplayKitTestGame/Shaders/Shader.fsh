//
//  Shader.fsh
//  ReplayKitTestGame
//
//  Created by darwin on 16/10/19.
//  Copyright © 2016年 JCLive. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
