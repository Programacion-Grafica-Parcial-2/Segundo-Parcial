using UnityEngine;
using UnityEngine.UI;

public class WaterImpact : MonoBehaviour
{
    [SerializeField] Image waterImage;
    Material mat;

    void Awake()
    {
        mat = new Material(waterImage.material); 
        waterImage.material = mat;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        Vector3 p = other.transform.position;
        mat.SetVector("_ImpactPos", new Vector4(p.x, p.y, 0, 0));
        mat.SetFloat("_ImpactStart", Time.timeSinceLevelLoad);
    }
}