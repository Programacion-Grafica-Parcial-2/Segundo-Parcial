using UnityEngine;

public class CameraRenderTexture : MonoBehaviour
{
    public Camera RTCamera;
    private RenderTexture renderTexture;
    private bool drawn;
    private void Start()
    {
        if (RTCamera == null)
        {
            RTCamera = GetComponent<Camera>();
            RTCamera.enabled = false;
        }
        renderTexture = new RenderTexture(640, 360, 16);
        renderTexture.Create();
        RTCamera.targetTexture = renderTexture;
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            RTCamera.Render();
            drawn = true;
        }
    }
    private void OnGUI()
    {
        if (drawn && Event.current.type.Equals(EventType.Repaint))
        {
            Graphics.DrawTexture(new Rect(10, 10, 100, 100), renderTexture);
        }
    }
}
