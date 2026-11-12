using UnityEngine;

/// <summary>
/// Controla la "hora del dia": rota el sol (Directional Light), hace que el Projector
/// de la ventana siga la direccion del sol, y ajusta el color y la intensidad de la luz.
///
/// Va en cualquier GameObject de la escena (por ejemplo un Empty "DayController").
/// Funciona con el Projector del Built-in Render Pipeline.
/// </summary>
[ExecuteAlways]
public class WindowLightController : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Light sun;                  // la Directional Light
    [SerializeField] private Projector windowProjector;  // el Projector puesto en la ventana

    [Tooltip("Material del Projector (el asset del Project). Si queda vacio usa el que tenga el Projector.")]
    [SerializeField] private Material projectorMaterial;

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

    // En Play: copia propia del material. En el editor: el material original.
    private Material _instance;
    private Material _target;

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
        if (windowProjector != null)
        {
            // Si no se asigno, guardamos el material que ya tiene el Projector.
            if (projectorMaterial == null)
                projectorMaterial = windowProjector.material;

            if (Application.isPlaying)
            {
                // El Projector no soporta MaterialPropertyBlock, por eso se instancia el material.
                // Solo en Play: en el editor NO se reemplaza el material, porque la escena
                // guardaria una referencia vacia (y en el build el Projector quedaria sin material).
                if (_instance == null && projectorMaterial != null)
                {
                    _instance = new Material(projectorMaterial) { name = projectorMaterial.name + " (Instance)" };
                    windowProjector.material = _instance;
                }
                _target = _instance;
            }
            else
            {
                _target = projectorMaterial; // vista previa en el editor
            }
        }

        Apply();
    }

    private void OnDisable()
    {
        if (_instance == null) return;

        // Dejamos el material original puesto en el Projector.
        if (windowProjector != null && projectorMaterial != null)
            windowProjector.material = projectorMaterial;

        Destroy(_instance);
        _instance = null;
        _target = null;
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

        // El projector sigue la direccion del sol: asi la sombra de la ventana
        // se desplaza y se estira a lo largo del dia.
        windowProjector.transform.rotation = sun.transform.rotation;

        if (_target != null)
        {
            _target.SetColor(ColorID, c);
            _target.SetFloat(IntensityID, day);
        }
    }
}