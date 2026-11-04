using UnityEngine;

[ExecuteAlways]
public class CharacterHoleController : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Transform target;      // el personaje
    [SerializeField] private Camera cam;             // si queda vacia, usa Camera.main

    [Header("Agujero")]
    [Tooltip("Radio del agujero. Se mide en alturas de pantalla (0.15 = 15% del alto).")]
    [SerializeField, Range(0f, 0.6f)] private float holeSize = 0.15f;

    [Tooltip("Ancho del borde difuminado. Con 0 el borde es duro.")]
    [SerializeField, Range(0.001f, 0.4f)] private float edgeFade = 0.08f;

    [Tooltip("Para apuntar al pecho y no a los pies.")]
    [SerializeField] private Vector3 targetOffset = new Vector3(0f, 1f, 0f);

    // Nombres EXACTOS del "Property Name" de los nodos en Amplify.
    private static readonly int PlayerViewportID = Shader.PropertyToID("_PlayerViewport");
    private static readonly int HoleSizeID = Shader.PropertyToID("_HoleSize");
    private static readonly int EdgeFadeID = Shader.PropertyToID("_EdgeFade");

    private void Update()
    {
        if (target == null) return;
        Camera c = cam != null ? cam : Camera.main;
        if (c == null) return;

        // x, y = posicion en pantalla (0..1). z = distancia a la camara. w = aspect.
        Vector3 vp = c.WorldToViewportPoint(target.position + targetOffset);
        Shader.SetGlobalVector(PlayerViewportID, new Vector4(vp.x, vp.y, vp.z, c.aspect));
        Shader.SetGlobalFloat(HoleSizeID, holeSize);
        Shader.SetGlobalFloat(EdgeFadeID, edgeFade);
    }
}