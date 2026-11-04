using UnityEngine;

public class DrawMeshInstanced : MonoBehaviour
{
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;
    [SerializeField] private Vector3 position;
    [SerializeField] private float range;
    [SerializeField] private int copiesAmount;

    [SerializeField] private float rotationSpeed = 45f;

    private Matrix4x4[] matrices;
    private Vector3[] rotations;
    private MaterialPropertyBlock propertyBlock;

    private static readonly int ColorID =
        Shader.PropertyToID("_InstanceColor");

    void Start()
    {
        matrices = new Matrix4x4[copiesAmount];
        rotations = new Vector3[copiesAmount];

        propertyBlock = new MaterialPropertyBlock();

        int gridSize = Mathf.CeilToInt(Mathf.Sqrt(copiesAmount));

        Vector4[] colors = new Vector4[copiesAmount];

        for (int i = 0; i < copiesAmount; i++)
        {
            Color randomColor = Random.ColorHSV();
            colors[i] = randomColor;
        }

        for (int i = 0; i < copiesAmount; i++)
        {
            int xPos = (i % gridSize) * 2 + 1 - gridSize;
            int zPos = Mathf.FloorToInt(i / gridSize) * 2 + 1 - gridSize;

            Vector3 pos = new Vector3(
                position.x + (range / gridSize) * xPos,
                position.y,
                position.z + (range / gridSize) * zPos
            );

            rotations[i] = Random.insideUnitSphere * 360f;
            colors[i] = Random.ColorHSV();

            matrices[i] = Matrix4x4.TRS(
                pos,
                Quaternion.Euler(rotations[i]),
                Vector3.one
            );
        }

        propertyBlock.SetVectorArray("_InstanceColor", colors);
    }

    void Update()
    {
        for (int i = 0; i < copiesAmount; i++)
        {
            rotations[i] += Vector3.up * rotationSpeed * Time.deltaTime;

            Vector3 pos = matrices[i].GetColumn(3);

            matrices[i] = Matrix4x4.TRS(
                pos,
                Quaternion.Euler(rotations[i]),
                Vector3.one
            );
        }

        Graphics.DrawMeshInstanced(
            mesh,
            0,
            material,
            matrices,
            copiesAmount,
            propertyBlock
        );
    }
}