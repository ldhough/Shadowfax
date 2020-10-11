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
    float4 pos [[attribute(0)]];
    //float4 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],//,
                              constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut vertexOut {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.pos//,
        //.color = in.color
    };
    return vertexOut;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(0, 0, 1, 1);//in.color;
}

//Ghost shader
