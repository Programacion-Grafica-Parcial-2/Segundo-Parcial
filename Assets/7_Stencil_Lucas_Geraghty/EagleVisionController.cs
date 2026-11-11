using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EagleVisionController : MonoBehaviour
{
    [SerializeField] private Transform player;
    [SerializeField] private Material eagleVisionMaterial;
    [SerializeField] private KeyCode activateKey = KeyCode.E;
    [SerializeField] private float expansionSpeed = 10f;
    [SerializeField] private float maxRadius = 50f;
    [SerializeField] private Transform waveSphere;
    [SerializeField] private float sphereScaleMultiplier = 2f;

    private float radius;
    private bool visionActive;
    private bool expanding;

    private void Update()
    {
        if(Input.GetKeyDown(activateKey))
        {
            SwapVision();
        }
        if (expanding)
        {
            radius += expansionSpeed * Time.deltaTime;
            if (radius >= maxRadius)
            {
                radius = maxRadius;
                expanding = false;
            }
        }
        waveSphere.localScale = Vector3.one * radius * sphereScaleMultiplier;
        UpdateShader();
    }
    private void SwapVision()
    {
        visionActive = !visionActive;
            radius = 0f;
        if (visionActive)
        {
            expanding = true;
        }
        else expanding = false;
    }
    private void UpdateShader()
    {
        eagleVisionMaterial.SetVector("_PlayerPosition", player.position);
        eagleVisionMaterial.SetFloat("_WaveRadius", radius);
        float active;
        if (visionActive)
        {
            active = 1;
        } else active = 0;
        eagleVisionMaterial.SetFloat("_EagleVisionActive", active);
    }
}
