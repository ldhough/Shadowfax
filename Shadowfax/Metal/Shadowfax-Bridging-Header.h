//
//  Shadowfax-Bridging-Header.h
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

#ifndef Shadowfax_Bridging_Header_h
#define Shadowfax_Bridging_Header_h

#import <simd/simd.h>

typedef struct {
    float pixelWidth;
    float pixelHeight;
    matrix_float4x4 scaleMatrix;
    matrix_float4x4 translationMatrix;
    matrix_float4x4 modelMatrix; //Model
    matrix_float4x4 viewMatrix; //Camera
    matrix_float4x4 projectionMatrix;
} Uniforms;

#endif /* Shadowfax_Bridging_Header_h */
