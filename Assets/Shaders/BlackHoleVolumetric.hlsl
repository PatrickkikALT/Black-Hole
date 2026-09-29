#ifndef BLACK_HOLE_VOLUMETRIC_INCLUDED
#define BLACK_HOLE_VOLUMETRIC_INCLUDED

#ifndef BH_PI
#define BH_PI 3.14159265358979323846
#endif

float _BH_Mass;
float _BH_DiskInner;
float _BH_DiskOuter;
float4 _BH_AccretionHotColor;
float4 _BH_AccretionCoolColor;
float _BH_DiskDensity;
float _BH_Temperature;
float _BH_StepCount;
float _BH_EnableDoppler;
float _BH_EnableRedshift;
float _BH_BoundRadius;

float BH_Hash21(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

float BH_Noise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float a = BH_Hash21(i);
    float b = BH_Hash21(i + float2(1, 0));
    float c = BH_Hash21(i + float2(0, 1));
    float d = BH_Hash21(i + float2(1, 1));
    return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

float BH_Fbm(float2 p)
{
    float v = 0.0;
    float a = 0.5;
    float2x2 m = float2x2(0.80, 0.60, -0.60, 0.80);
    [unroll]
    for (int i = 0; i < 4; i++)
    {
        v += a * BH_Noise(p);
        p = mul(m, p) * 2.05 + 11.7;
        a *= 0.5;
    }
    return v;
}

float3 BH_Blackbody(float kelvin)
{
    float k = clamp(kelvin, 800.0, 40000.0) / 100.0;
    float3 srgb;
    srgb.r = (k <= 66.0) ? 1.0 : saturate(1.292936186 * pow(k - 60.0, -0.1332047592));
    srgb.g = (k <= 66.0)
                 ? saturate(0.3900815787 * log(k) - 0.6318414438)
                 : saturate(1.129890897 * pow(k - 60.0, -0.0755148492));
    srgb.b = (k >= 66.0) ? 1.0 : ((k <= 19.0) ? 0.0 : saturate(0.5432067891 * log(k - 10.0) - 1.1962540891));
    return pow(max(srgb, 1e-5), 2.2);
}

bool BH_IntersectBox(float3 ro, float3 rd, float3 halfSize, out float tEnter, out float tExit)
{
    float3 inv = rcp(rd);
    float3 t0 = (-halfSize - ro) * inv;
    float3 t1v = (halfSize - ro) * inv;
    float3 n = min(t0, t1v);
    float3 f = max(t0, t1v);
    tEnter = max(max(n.x, n.y), n.z);
    tExit = min(min(f.x, f.y), f.z);
    return tExit >= max(tEnter, 0.0);
}

float3 BH_Accel(float3 p, float rs, float h2)
{
    float r2 = max(dot(p, p), 1e-12);
    float r = sqrt(r2);
    return -(1.5 * rs) * h2 * p / (r2 * r2 * r);
}

float3 BH_SampleSceneColor(float2 uv, float lod)
{
    #if defined(UNITY_SHADER_VARIABLES_INCLUDED)
    uv = clamp(uv, 0.001, 0.999);
    return SampleCameraColor(uv, lod) * GetInverseCurrentExposureMultiplier();
    #else
    return float3(0.008, 0.01, 0.016);
    #endif
}

float3 BH_SampleLensedBackground(float3 localExitDir, float2 screenUV)
{
    #if defined(UNITY_SHADER_VARIABLES_INCLUDED)
    float3 worldDir = TransformObjectToWorldDir(localExitDir, true);
    float4 clipPos = TransformWorldToHClip(GetCurrentViewPosition() + worldDir * _ProjectionParams.z);
    float2 uv = screenUV;
    if (abs(clipPos.w) > 1e-5)
        uv = clipPos.xy / clipPos.w * 0.5 + 0.5;
    return BH_SampleSceneColor(saturate(uv), 0.35);
    #else
    return BH_SampleSceneColor(screenUV, 0.0);
    #endif
}

float BH_Streaks(float rho, float phi, float time)
{
    float omega = pow(max(rho, 0.02), -0.55);
    float acc = 0.0;
    [unroll]
    for (int s = 0; s < 5; s++)
    {
        float p = phi - time * omega * 0.22 - s * 0.11;
        float n = BH_Fbm(float2(rho * 3.8, p * 2.4));
        float g = BH_Noise(float2(rho * 8.5, p * 9.0 + s));
        float hot = BH_Noise(float2(rho * 5.0 + 4.2, p * 0.7));
        float lane = saturate(n * 0.65 + g * 0.35);
        acc += pow(lane, 2.8) + pow(saturate(hot), 5.5) * 1.6;
    }
    return acc * 0.2;
}

float3 BH_DiskEmission(float3 hit, float3 dir, float mass, float rs, float diskInner, float diskOuter,
                       float densityMul, float temperature, bool doppler, bool redshift)
{
    float rho = length(hit.xz);
    if (rho < diskInner || rho > diskOuter)
        return 0.0;

    float span = max(diskOuter - diskInner, 1e-4);
    float u = saturate((rho - diskInner) / span);
    float rRel = max(rho / max(diskInner, 1e-4), 1.0);

    float tEmit = (1850.0 + 4200.0 * temperature) * pow(rRel, -0.72);

    float time = 0.0;
    #if defined(UNITY_SHADER_VARIABLES_INCLUDED)
    time = _TimeParameters.x;
    #endif

    float phi = atan2(hit.z, hit.x);
    float streaks = BH_Streaks(rho, phi, time);
    float structure = 0.06 + 1.55 * streaks;

    float innerLip = 1.0 + 2.4 * exp(-pow((rho - diskInner) / max(span * 0.07, 1e-4), 2.0));
    float outerFade = smoothstep(diskOuter, diskOuter - span * 0.22, rho);
    float radial = outerFade * innerLip;
    float flux = pow(max(1.0 - u, 0.015), 1.1) * (0.4 + 2.6 / rRel);

    float shift = 1.0;
    if (doppler)
    {
        float beta = min(sqrt(saturate(mass / max(rho, rs * 1.05))), 0.72);
        float gamma = rsqrt(max(1.0 - beta * beta, 1e-4));
        float3 tangent = normalize(float3(-hit.z, 0.0, hit.x));
        float ndot = length(dir) > 1e-8 ? dot(dir / length(dir), tangent) : 0.0;
        float rel = 1.0 / max(gamma * (1.0 - beta * ndot), 0.12);
        shift *= lerp(1.0, rel, 0.28);
    }
    if (redshift)
        shift *= sqrt(max(1.0 - rs / max(rho, rs * 1.02), 0.0));

    float tObs = clamp(tEmit * shift, 1400.0, 6800.0);
    float3 bb = BH_Blackbody(tObs);
    float3 gold = lerp(_BH_AccretionCoolColor.rgb, _BH_AccretionHotColor.rgb, saturate((tObs - 1600.0) / 3800.0));
    float3 col = lerp(bb, max(gold, 0.04), 0.62);

    float boost = pow(shift, 2.0);
    float intensity = densityMul * radial * structure * flux * boost * (90.0 + 220.0 * temperature);
    return col * intensity;
}

void BlackHoleMarch(
    float3 localCamPos,
    float3 localRayDir,
    float mass,
    float diskInner,
    float diskOuter,
    float stepCount,
    float2 screenUV,
    out float4 outColor)
{
    mass = max(mass, 1e-5);
    float rs = 2.0 * mass;
    float bound = max(_BH_BoundRadius, 0.05);
    float3 rd = normalize(localRayDir);
    float3 box = float3(bound, bound, bound);

    float tEnter, tExit;
    if (!BH_IntersectBox(localCamPos, rd, box, tEnter, tExit))
    {
        outColor = float4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    tEnter = max(tEnter, 0.0);
    if (tExit <= tEnter)
    {
        outColor = float4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    float3 P = localCamPos + rd * (tEnter + 1e-4);
    float3 D = rd;
    float3 l = cross(P, D);
    float h2 = max(dot(l, l), 1e-12);

    uint steps = (uint)clamp(stepCount, 64.0, 256.0);
    float photonSphere = 1.5 * rs;
    float diskIn = clamp(diskInner, photonSphere * 1.02, photonSphere * 1.08);
    float diskOut = min(max(diskOuter, diskIn + 0.04), bound * 0.78);
    float densityMul = max(_BH_DiskDensity, 0.0);
    float temperature = max(_BH_Temperature, 0.05);
    bool doppler = _BH_EnableDoppler > 0.5;
    bool redshift = _BH_EnableRedshift > 0.5;

    float3 glow = 0.0;
    float transmittance = 1.0;
    bool captured = false;
    float travelled = 0.0;
    float travelBudget = bound * 16.0;
    float rMin = 1e9;
    float prevY = P.y;

    [loop]
    for (uint i = 0; i < steps; i++)
    {
        float r2 = dot(P, P);
        float r = sqrt(max(r2, 1e-12));
        rMin = min(rMin, r);

        if (r <= rs * 1.001 || any(isnan(P)))
        {
            captured = true;
            break;
        }

        if (r < photonSphere * 0.99 && dot(P, D) < 0.0)
        {
            captured = true;
            break;
        }

        if (any(abs(P) > box + 0.002) && travelled > 1e-4)
            break;
        if (travelled > travelBudget)
            break;

        float close = saturate(1.0 - abs(r - photonSphere) / max(5.0 * rs, 1e-4));
        float dt = r * lerp(0.072, 0.016, close);
        dt *= 192.0 / (float)steps;

        if (P.y * D.y < 0.0)
        {
            float tPlane = abs(P.y) / max(abs(D.y), 1e-6);
            dt = min(dt, max(tPlane * 0.5, bound * 0.0006));
        }
        dt = clamp(dt, bound * 0.0012, bound * 0.04);

        float3 a0 = BH_Accel(P, rs, h2);
        float3 P1 = P + D * dt + 0.5 * a0 * dt * dt;
        float3 a1 = BH_Accel(P1, rs, h2);
        float3 D1 = D + 0.5 * (a0 + a1) * dt;

        if (prevY * P1.y <= 0.0)
        {
            float denom = prevY - P1.y;
            float tHit = abs(denom) > 1e-8 ? saturate(prevY / denom) : 0.5;
            float3 hit = lerp(P, P1, tHit);
            hit.y = 0.0;
            float rho = length(hit.xz);

            if (rho >= diskIn && rho <= diskOut)
            {
                float3 emit = BH_DiskEmission(hit, D1, mass, rs, diskIn, diskOut,
                                              densityMul, temperature, doppler, redshift);
                float span = max(diskOut - diskIn, 1e-4);
                float u = saturate((rho - diskIn) / span);
                float radial = smoothstep(diskOut, diskOut - span * 0.22, rho);
                float optical = saturate((0.88 + 0.12 * densityMul) * (1.0 - 0.35 * u) * radial);
                glow += transmittance * emit;
                transmittance *= (1.0 - optical);
            }
        }

        P = P1;
        D = D1;
        prevY = P.y;
        travelled += dt;
        if (transmittance < 0.001)
            break;
    }
    
    if (!captured && rMin < photonSphere * 0.96)
        captured = true;

    float skim = exp(-abs(rMin - photonSphere) / max(0.05 * rs, 1e-4));
    if (!captured)
        glow += skim * BH_Blackbody(5600.0) * lerp(_BH_AccretionHotColor.rgb, 1.0, 0.4) * (14.0 * temperature);
    
    float3 rgb = max(glow, 0.0);
    float alpha = captured ? 1.0 : saturate(1.0 - transmittance);
    outColor = float4(rgb, alpha);
}

void BlackHoleMarch_float(float3 LocalCamPos, float3 LocalRayDir, float Mass, float DiskInner,
                          float DiskOuter, float StepCount, float2 ScreenUV, out float4 OutColor)
{
    BlackHoleMarch(LocalCamPos, LocalRayDir, Mass, DiskInner, DiskOuter, StepCount, ScreenUV, OutColor);
}

#endif
