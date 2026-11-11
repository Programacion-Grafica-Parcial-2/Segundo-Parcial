using UnityEngine;


[ExecuteAlways]
public class CharacterHoleController : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Transform target;      // el personaje
    [SerializeField] private Camera cam;             // si queda vacia, usa Camera.main

    [Header("Agujero")]
    [Tooltip("Radio del cilindro camara-personaje, en unidades del mundo.")]
    [SerializeField, Range(0f, 5f)] private float holeSize = 1f;

    [Tooltip("Ancho del borde difuminado, en unidades del mundo.")]
    [SerializeField, Range(0.01f, 3f)] private float edgeFade = 0.5f;

    [Tooltip("Para apuntar al pecho y no a los pies.")]
    [SerializeField] private Vector3 targetOffset = new Vector3(0f, 1f, 0f);

    private static readonly int PlayerViewportID = Shader.PropertyToID("_PlayerViewport");
    private static readonly int PlayerWorldPosID = Shader.PropertyToID("_PlayerWorldPos");
    private static readonly int CameraWorldPosID = Shader.PropertyToID("_CamWorldPos");
    private static readonly int HoleSizeID = Shader.PropertyToID("_HoleSize");
    private static readonly int EdgeFadeID = Shader.PropertyToID("_EdgeFade");

    private void Update()
    {
        if (target == null) return;
        Camera c = cam != null ? cam : Camera.main;
        if (c == null) return;

        // x, y = posicion en pantalla (0..1)   z = distancia a la camara   w = aspect
        Vector3 vp = c.WorldToViewportPoint(target.position + targetOffset);
        Shader.SetGlobalVector(PlayerViewportID, new Vector4(vp.x, vp.y, vp.z, c.aspect));
        Shader.SetGlobalVector(PlayerWorldPosID, target.position + targetOffset);
        Shader.SetGlobalVector(CameraWorldPosID, c.transform.position);
        Shader.SetGlobalFloat(HoleSizeID, holeSize);
        Shader.SetGlobalFloat(EdgeFadeID, edgeFade);
    }
}