//TEST:SIMPLE(filecheck=SPV): -target spirv -O0 -fvk-use-scalar-layout

// Specializing a callee whose argument is `ByteAddressBuffer.Load<T>()` must preserve
// the `alignment` operand of `byteAddressBufferLoad`; check that `makeRay` is specialized
// to take the offset and alignment as separate `uint` parameters.

struct Frame
{
    float4x4 a;
    float4x4 b;
    float3 v;
    float pad;
};

float3 makeRay(Frame f)
{
    float4 w = mul(float4(0, 0, 0, 1), f.b);
    return w.xyz + f.v;
}

uniform ByteAddressBuffer buf;
uniform RWTexture2D<float4> outTexture;
uniform uint width;
uniform uint height;

[shader("compute")]
[numthreads(8, 8, 1)]
void computeMain(uint3 dtid : SV_DispatchThreadID)
{
    if (dtid.x >= width || dtid.y >= height) return;
    Frame f = buf.Load<Frame>(0);
    outTexture[dtid.xy] = float4(makeRay(f), 1);
}

// SPV: %makeRay = OpFunction %v3float None %{{.*}}
// SPV-NEXT: %{{.*}} = OpFunctionParameter %uint
// SPV-NEXT: %{{.*}} = OpFunctionParameter %uint
