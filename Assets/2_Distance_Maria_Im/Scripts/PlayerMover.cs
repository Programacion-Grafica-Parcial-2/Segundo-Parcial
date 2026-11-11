using UnityEngine;

public class PlayerMover : MonoBehaviour
{
    [SerializeField, Min(0f)] private float speed = 4f;

    private void Update()
    {
        float x = Input.GetAxisRaw("Horizontal");
        float z = Input.GetAxisRaw("Vertical");

        Vector3 move = new Vector3(x, 0f, z);
        if (move.sqrMagnitude > 1f) move.Normalize();

        transform.position += move * speed * Time.deltaTime;
    }
}