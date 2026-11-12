using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    [SerializeField] private bool showHint = true;

    private static SceneSwitcher _instance;

    private void Awake()
    {
        // Evita duplicados si se vuelve a cargar la primera escena.
        if (_instance != null && _instance != this)
        {
            Destroy(gameObject);
            return;
        }
        _instance = this;
        DontDestroyOnLoad(gameObject);
    }

    private void Update()
    {
        int count = SceneManager.sceneCountInBuildSettings;
        if (count == 0) return;

        int current = SceneManager.GetActiveScene().buildIndex;

        if (Input.GetKeyDown(KeyCode.PageDown) || Input.GetKeyDown(KeyCode.N))
            Load((current + 1) % count);

        if (Input.GetKeyDown(KeyCode.PageUp) || Input.GetKeyDown(KeyCode.B))
            Load((current - 1 + count) % count);

        
        for (int i = 0; i < Mathf.Min(count, 11); i++)
        {
            if (Input.GetKeyDown(KeyCode.Alpha1 + i))
                Load(i);
        }
    }

    private void Load(int index)
    {
        SceneManager.LoadScene(index);
    }

    private void OnGUI()
    {
        if (!showHint) return;

        int count = SceneManager.sceneCountInBuildSettings;
        Scene s = SceneManager.GetActiveScene();
        GUI.Label(new Rect(10, 10, 600, 24),
            $"Escena {s.buildIndex + 1}/{count}: {s.name}   (N / B o 1-9 para cambiar)");
    }
}