using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blit : MonoBehaviour
{
    [SerializeField] Material material;

    // --- Agregado: lista de materiales para ir cambiando con una tecla ---
    [SerializeField] Material[] materials;
    [SerializeField] KeyCode cycleKey = KeyCode.Tab;
    private int index = 0;

    private void Start()
    {
        // Arranca con el primero de la lista (si la lista tiene algo).
        if (materials != null && materials.Length > 0)
            material = materials[0];
    }

    private void Update()
    {
        if (materials == null || materials.Length == 0) return;

        if (Input.GetKeyDown(cycleKey))
        {
            index = (index + 1) % materials.Length;
            material = materials[index];
        }
    }
    // ---------------------------------------------------------------------

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}