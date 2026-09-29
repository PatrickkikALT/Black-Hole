using TMPro;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways]
[DisallowMultipleComponent]
public class BlackHoleUI : MonoBehaviour
{
    public BlackHole target;

    [Header("Widgets")] [SerializeField] private Slider massSlider;

    [SerializeField] private Slider diskRadiusSlider;
    [SerializeField] private Slider densitySlider;
    [SerializeField] private Slider temperatureSlider;
    [SerializeField] private Slider stepsSlider;
    [SerializeField] private Toggle dopplerToggle;
    [SerializeField] private Toggle redshiftToggle;
    [SerializeField] private TextMeshProUGUI metricsLabel;

    private bool _suppress;

    private void Update()
    {
        metricsLabel.text =
            "Rs (Schwarzschild)  " + target.SchwarzschildRadius.ToString("F4") + "  local\n" +
            "R_photon  " + target.PhotonSphereRadius.ToString("F4") + "  (1.5 Rs)\n" +
            "R_isco  " + target.IscoRadius.ToString("F4") + "  (3 Rs)\n" +
            "Bound radius  " + target.BoundRadius.ToString("F3");
    }

    private void OnEnable()
    {
        PullFromTarget();
    }
    

    private void PullFromTarget()
    {
        _suppress = true;
        massSlider.value = target.mass;
        diskRadiusSlider.value = target.diskOuterRadius;
        densitySlider.value = target.diskDensity;
        temperatureSlider.value = target.temperature;
        stepsSlider.value = target.raymarchSteps;
        dopplerToggle.isOn = target.enableDopplerEffect;
        redshiftToggle.isOn = target.enableRedshift;
        _suppress = false;
    }

    public void PushToTarget()
    {
        if (_suppress)
            return;

        target.mass = massSlider.value;
        target.diskOuterRadius = diskRadiusSlider.value;
        target.diskInnerRadius = Mathf.Max(target.PhotonSphereRadius * 1.05f, 0.02f);
        target.diskDensity = densitySlider.value;
        target.temperature = temperatureSlider.value;
        target.raymarchSteps = Mathf.RoundToInt(stepsSlider.value);
        target.enableDopplerEffect = dopplerToggle.isOn;
        target.enableRedshift = redshiftToggle.isOn;
        target.PushMaterial();
    }

    public void OnSliderChanged(float _)
    {
        PushToTarget();
    }

    public void OnToggleChanged(bool _)
    {
        PushToTarget();
    }
}