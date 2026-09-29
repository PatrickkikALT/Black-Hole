using UnityEngine;

[ExecuteAlways]
[DisallowMultipleComponent]
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class BlackHole : MonoBehaviour
{
    private static readonly int MassId = Shader.PropertyToID("_BH_Mass");
    private static readonly int DiskInnerId = Shader.PropertyToID("_BH_DiskInner");
    private static readonly int DiskOuterId = Shader.PropertyToID("_BH_DiskOuter");
    private static readonly int HotColorId = Shader.PropertyToID("_BH_AccretionHotColor");
    private static readonly int CoolColorId = Shader.PropertyToID("_BH_AccretionCoolColor");
    private static readonly int DensityId = Shader.PropertyToID("_BH_DiskDensity");
    private static readonly int TemperatureId = Shader.PropertyToID("_BH_Temperature");
    private static readonly int StepsId = Shader.PropertyToID("_BH_StepCount");
    private static readonly int DopplerId = Shader.PropertyToID("_BH_EnableDoppler");
    private static readonly int RedshiftId = Shader.PropertyToID("_BH_EnableRedshift");
    private static readonly int BoundRadiusId = Shader.PropertyToID("_BH_BoundRadius");

    [Header("Relativity")] 
    [Min(0.001f)] public float mass = 0.03f;

    [Header("Accretion Disk")] 
    [Min(0.01f)] public float diskInnerRadius = 0.065f;
    [Min(0.02f)] public float diskOuterRadius = 0.38f;
    [ColorUsage(true, true)] public Color accretionHotColor = new(6f, 3.4f, 1.45f, 1f);
    [ColorUsage(true, true)] public Color accretionCoolColor = new(1.35f, 0.38f, 0.09f, 1f);
    [Min(0f)] public float diskDensity = 1.35f;
    [Min(0.05f)] public float temperature = 1.35f;

    [Header("Integration")] [Range(48, 256)]
    public int raymarchSteps = 192;

    public bool enableDopplerEffect = true;
    public bool enableRedshift = true;
    
    private MaterialPropertyBlock _block;

    private MeshFilter _filter;
    private MeshRenderer _renderer;

    public float SchwarzschildRadius => 2f * Mathf.Max(mass, 0.001f);
    public float PhotonSphereRadius => 1.5f * SchwarzschildRadius;
    public float IscoRadius => 3f * SchwarzschildRadius;

    public float BoundRadius
    {
        get
        {
            Mesh mesh = _filter.sharedMesh;
            Vector3 e = mesh.bounds.extents;
            return Mathf.Max(e.x, Mathf.Max(e.y, e.z));
        }
    }

    private void OnEnable()
    {
        _filter = GetComponent<MeshFilter>();
        _renderer = GetComponent<MeshRenderer>();
        _block ??= new MaterialPropertyBlock();
        PushMaterial();
    }

    private void OnDisable()
    {
        if (_renderer != null)
            _renderer.SetPropertyBlock(null);
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.color = Color.black;
        Gizmos.DrawWireSphere(Vector3.zero, SchwarzschildRadius);
        Gizmos.color = new Color(1f, 0.85f, 0.2f, 0.9f);
        Gizmos.DrawWireSphere(Vector3.zero, PhotonSphereRadius);
        Gizmos.color = new Color(0.3f, 0.85f, 1f, 0.9f);
        Gizmos.DrawWireSphere(Vector3.zero, IscoRadius);
        Gizmos.color = new Color(1f, 0.45f, 0.1f, 0.7f);
        Gizmos.DrawWireSphere(Vector3.zero, diskOuterRadius);
    }

    private void OnValidate()
    {
        if (isActiveAndEnabled && _block != null)
            PushMaterial();
    }

    public void PushMaterial()
    {
        _renderer.GetPropertyBlock(_block);
        _block.SetFloat(MassId, Mathf.Max(mass, 0.001f));
        _block.SetFloat(DiskInnerId, Mathf.Max(diskInnerRadius, 0.01f));
        _block.SetFloat(DiskOuterId, Mathf.Max(diskOuterRadius, diskInnerRadius + 0.02f));
        _block.SetColor(HotColorId, accretionHotColor);
        _block.SetColor(CoolColorId, accretionCoolColor);
        _block.SetFloat(DensityId, Mathf.Max(diskDensity, 0f));
        _block.SetFloat(TemperatureId, Mathf.Max(temperature, 0.05f));
        _block.SetFloat(StepsId, Mathf.Clamp(raymarchSteps, 32, 256));
        _block.SetFloat(DopplerId, enableDopplerEffect ? 1f : 0f);
        _block.SetFloat(RedshiftId, enableRedshift ? 1f : 0f);
        _block.SetFloat(BoundRadiusId, BoundRadius);
        _renderer.SetPropertyBlock(_block);
    }
}