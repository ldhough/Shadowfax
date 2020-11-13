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
    float3 worldPos;
    float3 normal;
    float2 uv;
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]],
                             constant float &timer [[buffer(2)]]) {
    float2 uv = in.uv;
    
    VertexOut vertexOut {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.pos,
        .worldPos = (uniforms.modelMatrix * in.pos).xyz //Have vert pos & normal in world space
        ,.normal = uniforms.normalMatrix * in.normal
        ,.uv = uv
    };
    return vertexOut;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> objTex [[texture(0)]],
                              constant float &timer [[buffer(1)]],
                              constant Light &sunlight [[buffer(2)]],
                              constant bool &lightSource [[buffer(3)]]) {
    constexpr sampler defaultSampler;
    //constexpr sampler textureSampler(filter::linear, address::repeat);
    float4 color = objTex.sample(defaultSampler, float2(in.uv.x, in.uv.y));
    if (!lightSource) {
        float3 lightDir = normalize(in.worldPos - sunlight.position);
        float3 normalDir = normalize(in.normal);
        float difIntensity = saturate(-dot(lightDir, normalDir));
        float3 newColor = sunlight.color * float3(color.x, color.y, color.z) * difIntensity;
        //newColor *= 100;
    //    float3 lightDir = normalize(-sunlight.position);
    //    float3 normalDir = normalize(in.normal);
    //    float difIntensity = saturate(-dot(lightDir, normalDir));
    //    float3 diffuseColor = 0;
    //    diffuseColor += sunlight.color * float3(color.x, color.y, color.z) * difIntensity;
    //    color = float4(diffuseColor, 1);
        
        if (newColor.r < 0.1 && newColor.g < 0.1 && newColor.b < 0.1) {
            newColor = float3(color.r * 0.1, color.g * 0.1, color.b * 0.1);
        }
        
        color = float4(newColor, 1);
    }
    return color;
}

//Ghost shader
