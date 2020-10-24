//
//  Shaders.metal
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

#include <metal_stdlib>
#import "Shadowfax-Bridging-Header.h"
using namespace metal;

struct VertexIn {
    float4 pos [[attribute(0)]]; //should be float3?
    float3 normal [[attribute(1)]]; //normal
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]],
                             constant float &timer [[buffer(2)]]) {
    float2 uv = in.uv;
    
    VertexOut vertexOut {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.pos
        ,.uv = uv
    };
    return vertexOut;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> objTex [[texture(0)]],
                              constant float &timer [[buffer(1)]]) {
    constexpr sampler defaultSampler;
    constexpr sampler textureSampler(filter::linear, address::repeat);
    float4 color = objTex.sample(defaultSampler, float2(in.uv.x, in.uv.y));
    return color;
}

//Ghost shader
