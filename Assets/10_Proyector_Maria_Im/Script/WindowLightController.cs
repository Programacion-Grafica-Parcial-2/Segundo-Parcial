using UnityEngine;


[ExecuteAlways]
public class WindowLightController : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Light sun;                  // la Directional Light
    [SerializeField] private Projector windowProjector;  // el Projector puesto en la ventana

    [Header("Hora del dia")]
    [Tooltip("0 = medianoche, 6 = amanecer, 12 = mediodia, 18 = atardecer.")]
    [SerializeField, Range(0f, 24f)] private float hour = 12f;
    [SerializeField] private bool autoPlay = false;
    [Tooltip("Cuantos segundos reales dura un dia completo.")]
    [SerializeField, Min(1f)] private float secondsPerDay = 60f;

    [Header("Sol")]
    [Tooltip("Rotacion en Y del sol. Probar hasta que la luz entre por la ventana.")]
    [SerializeField, Range(0f, 360f)] private float azimuth = 90f;
    [Tooltip("Color de la luz a lo largo del dia (0 = 0:00, 0.5 = 12:00, 1 = 24:00).")]
    [SerializeField] private Gradient lightColor;
    [SerializeField, Min(0f)] private float sunIntensity = 1f;

    // Nombres EXACTOS del "Property Name" de los nodos en Amplify.
    private static readonly int ColorID = Shader.PropertyToID("_Color");
    private static readonly int IntensityID = Shader.PropertyToID("_Intensity");

    private Material _instance;

    // Valores iniciales cuando agregas el componente.
    private void Reset()
    {
        lightColor = new Gradient();
        lightColor.SetKeys(
            new[]
            {
                new GradientColorKey(new Color(0.10f, 0.12f, 0.30f), 0.00f), // noche
                new GradientColorKey(new Color(1.00f, 0.55f, 0.25f), 0.25f), // amanecer
                new GradientColorKey(new Color(1.00f, 0.96f, 0.85f), 0.50f), // mediodia
                new GradientColorKey(new Color(1.00f, 0.45f, 0.20f), 0.75f), // atardecer
                new GradientColorKey(new Color(0.10f, 0.12f, 0.30f), 1.00f), // noche
            },
            new[] { new GradientAlphaKey(1f, 0f), new GradientAlphaKey(1f, 1f) });
    }

    private void OnEnable()
    {
        // El Projector no soporta MaterialPropertyBlock, por eso se instancia el material.
        if (windowProjector != null && _instance == null && windowProjector.material != null)
        {
            _instance = new Material(windowProjector.material) { hideFlags = HideFlags.HideAndDontSave };
            windowProjector.material = _instance;
        }
        Apply();
    }

    private void OnDisable()
    {
        if (_instance == null) return;
        if (Application.isPlaying) Destroy(_instance);
        else DestroyImmediate(_instance);
        _instance = null;
    }

    private void Update()
    {
        if (autoPlay && Application.isPlaying)
            hour = (hour + Time.deltaTime * 24f / secondsPerDay) % 24f;

        Apply();
    }

    private void OnValidate() { Apply(); }

    private void Apply()
    {
        if (sun == null) return;

        // 6:00 -> el sol esta en el horizonte (pitch 0), 12:00 -> mirando hacia abajo (pitch 90).
        float pitch = hour / 24f * 360f - 90f;
        sun.transform.rotation = Quaternion.Euler(pitch, azimuth, 0f);

        // Altura del sol: 1 al mediodia, 0 en el horizonte, negativa de noche.
        float elevation = Mathf.Sin(pitch * Mathf.Deg2Rad);
        float day = Mathf.Clamp01(elevation * 3f);

        Color c = lightColor != null ? lightColor.Evaluate(hour / 24f) : Color.white;
        sun.color = c;
        sun.intensity = day * sunIntensity;

        if (windowProjector == null) return;

        // El projector sigue la direccion del sol: asi la sombra de la persiana
        // se desplaza y se estira a lo largo del dia.
        windowProjector.transform.rotation = sun.transform.rotation;

        if (_instance != null)
        {
            _instance.SetColor(ColorID, c);
            _instance.SetFloat(IntensityID, day);
        }
    }
}