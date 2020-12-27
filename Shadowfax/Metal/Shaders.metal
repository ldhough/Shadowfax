//
//  Shaders.metal
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

#include <metal_stdlib>
#import "MetalHeader.h"
using namespace metal;

struct VertexIn {
    float4 pos [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPos;
    float3 normal;
    float2 uv;
    float4 color;
    float4 shadowPosition;
};

struct PosIn {
    float4 pos [[attribute(0)]];
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]],
                             constant float &timer [[buffer(2)]]) {
    float2 uv = in.uv;
    
    VertexOut vertexOut {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.pos,
        .worldPos = (uniforms.modelMatrix * in.pos).xyz //Have vert pos & normal in world space
        ,.normal = uniforms.normalMatrix * in.normal
        ,.uv = uv,
        .shadowPosition = uniforms.shadowMatrix * uniforms.modelMatrix * in.pos
    };
    
    return vertexOut;
}

vertex float4 vertex_shadow(const PosIn in [[stage_in]],
                            constant Uniforms &uniforms [[buffer(1)]]) {
    matrix_float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    return mvp * in.pos;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> objTex [[texture(0)]],
                              constant float &timer [[buffer(1)]],
                              constant Light &sunlight [[buffer(2)]],
                              constant bool &obeyLighting [[buffer(3)]],
                              depth2d<float> shadowTexture [[texture(1)]]) { //True for ordinary objects, false for light sources or other objects we want full illumination on
    constexpr sampler defaultSampler;

    float4 color = objTex.sample(defaultSampler, float2(in.uv.x, in.uv.y));
    if (obeyLighting) {
        
        float3 lightDir = normalize(in.worldPos - sunlight.position);
        float3 normalDir = normalize(in.normal);
        float difIntensity = saturate(-dot(lightDir, normalDir));
        float3 newColor = sunlight.color * float3(color.x, color.y, color.z) * difIntensity;
        
        if (newColor.r < 0.1 && newColor.g < 0.1 && newColor.b < 0.1) { //Ambient lighting
            newColor = float3(color.r * 0.1, color.g * 0.1, color.b * 0.1);
        }
        
        color = float4(newColor, 1);
    }
    
    //WORKING ON SHADOWS
    
    float2 shadowPos = in.shadowPosition.xy;
    shadowPos = shadowPos * 0.5 + 0.5;
    shadowPos.y = 1 - shadowPos.y;
    constexpr sampler shadowSampler(coord::normalized, filter::linear, address::clamp_to_edge, compare_func::less);
    float shadowSample = shadowTexture.sample(shadowSampler, shadowPos);
    float currentSample = in.shadowPosition.z / in.shadowPosition.w;
    if (currentSample > shadowSample) {
        color *= 0.5;
    }
    
    //END WORKING ON SHADOWS
    
    return color;
}

kernel void compute(texture2d<float, access::read> inTex [[texture(0)]],
                            texture2d<float, access::write> outMap [[texture(1)]],
                            uint2 id [[thread_position_in_grid]]) {
    float4 color = inTex.read(id);
    outMap.write(color, id);
}

//Ghost shader
