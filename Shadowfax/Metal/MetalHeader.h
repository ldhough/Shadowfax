//
//  MetalHeader.h
//  Shadowfax
//
//  Created by Lannie Hough on 11/23/20.
//

#ifndef MetalHeader_h
#define MetalHeader_h

#import <simd/simd.h>

typedef struct {
    float pixelWidth;
    float pixelHeight;
    matrix_float4x4 scaleMatrix;
    matrix_float4x4 translationMatrix;
    matrix_float4x4 modelMatrix; //Model
    matrix_float4x4 viewMatrix; //Camera
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
    matrix_float4x4 shadowMatrix; //for shadowmapping
} Uniforms;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    float intensity;
    vector_float3 attenuation;
} Light;

#endif /* MetalHeader_h */
