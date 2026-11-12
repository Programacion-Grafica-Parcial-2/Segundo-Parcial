using UnityEngine;

/// Camara para mirar la carta:
///   - Flechas izquierda/derecha: orbita alrededor de la carta.
///   - Flechas arriba/abajo: sube o baja la camara en la orbita.
///   - Mouse: mueve la vista de la camara (mirar alrededor), con limite para no perder la carta.
///   - Rueda del mouse: acerca o aleja.
///   - Esc: libera el cursor. Click: lo vuelve a capturar.
///
/// Se pone en la Main Camera. En "Target" va la carta.

public class CardOrbitCamera : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Transform target;           // la carta
    [SerializeField] private Vector3 targetOffset = Vector3.zero;

    [Header("Orbita")]
    [SerializeField, Min(0.1f)] private float distance = 3f;
    [SerializeField, Min(0f)] private float orbitSpeed = 90f;       // grados por segundo
    [SerializeField] private Vector2 pitchLimits = new Vector2(-60f, 80f);

    [Header("Mouse (mirar alrededor)")]
    [SerializeField, Min(0f)] private float mouseSensitivity = 2f;
    [Tooltip("Cuanto puede desviarse la mirada del centro de la carta, en grados.")]
    [SerializeField, Range(0f, 90f)] private float maxLookAngle = 45f;
    [Tooltip("Si esta activo, la mirada vuelve sola al centro cuando no mueves el mouse.")]
    [SerializeField] private bool recenter = false;
    [SerializeField, Min(0f)] private float recenterSpeed = 4f;

    [Header("Zoom")]
    [SerializeField, Min(0f)] private float zoomSpeed = 2f;
    [SerializeField] private Vector2 distanceLimits = new Vector2(1f, 10f);

    private float _yaw;          // orbita horizontal
    private float _pitch = 15f;  // orbita vertical
    private float _lookYaw;      // desvio de la mirada por el mouse
    private float _lookPitch;

    private void Start()
    {
        if (target != null)
        {
            // Arranca desde donde esta la camara en la escena.
            Vector3 dir = transform.position - (target.position + targetOffset);
            distance = Mathf.Clamp(dir.magnitude, distanceLimits.x, distanceLimits.y);
            Vector3 e = Quaternion.LookRotation(-dir).eulerAngles;
            _yaw = e.y;
            _pitch = NormalizeAngle(e.x);
        }
        LockCursor(true);
    }

    private void Update()
    {
        // Esc libera el cursor, click lo captura de nuevo.
        if (Input.GetKeyDown(KeyCode.Escape)) LockCursor(false);
        if (Input.GetMouseButtonDown(0) && Cursor.lockState != CursorLockMode.Locked) LockCursor(true);
    }

    private void LateUpdate()
    {
        if (target == null) return;

        // --- Flechas: orbita ---
        float h = 0f, v = 0f;
        if (Input.GetKey(KeyCode.RightArrow)) h += 1f;
        if (Input.GetKey(KeyCode.LeftArrow)) h -= 1f;
        if (Input.GetKey(KeyCode.UpArrow)) v += 1f;
        if (Input.GetKey(KeyCode.DownArrow)) v -= 1f;

        _yaw += h * orbitSpeed * Time.deltaTime;
        _pitch += v * orbitSpeed * Time.deltaTime;
        _pitch = Mathf.Clamp(_pitch, pitchLimits.x, pitchLimits.y);

        // --- Mouse: mirar alrededor ---
        if (Cursor.lockState == CursorLockMode.Locked)
        {
            _lookYaw += Input.GetAxis("Mouse X") * mouseSensitivity;
            _lookPitch -= Input.GetAxis("Mouse Y") * mouseSensitivity;
        }

        if (recenter && Mathf.Approximately(Input.GetAxis("Mouse X"), 0f)
                     && Mathf.Approximately(Input.GetAxis("Mouse Y"), 0f))
        {
            float k = 1f - Mathf.Exp(-recenterSpeed * Time.deltaTime);
            _lookYaw = Mathf.Lerp(_lookYaw, 0f, k);
            _lookPitch = Mathf.Lerp(_lookPitch, 0f, k);
        }

        _lookYaw = Mathf.Clamp(_lookYaw, -maxLookAngle, maxLookAngle);
        _lookPitch = Mathf.Clamp(_lookPitch, -maxLookAngle, maxLookAngle);

        // --- Zoom ---
        distance -= Input.mouseScrollDelta.y * zoomSpeed * 0.5f;
        distance = Mathf.Clamp(distance, distanceLimits.x, distanceLimits.y);

        // --- Posicion y rotacion ---
        Vector3 center = target.position + targetOffset;
        Quaternion orbit = Quaternion.Euler(_pitch, _yaw, 0f);

        transform.position = center + orbit * new Vector3(0f, 0f, -distance);
        transform.rotation = orbit * Quaternion.Euler(_lookPitch, _lookYaw, 0f);
    }

    private static void LockCursor(bool locked)
    {
        Cursor.lockState = locked ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !locked;
    }

    private static float NormalizeAngle(float a)
    {
        while (a > 180f) a -= 360f;
        while (a < -180f) a += 360f;
        return a;
    }
}