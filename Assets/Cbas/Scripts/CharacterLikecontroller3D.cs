using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterLikecontroller3D : MonoBehaviour
{
    
    [SerializeField]Rigidbody rb;
    
    void Update()
    {
        if (Input.GetKey(KeyCode.A))
        {
            rb.AddForce(new Vector3(-10,0,0),ForceMode.Force);
        }
        if (Input.GetKey(KeyCode.D))
        {
            rb.AddForce(new Vector3(10,0,0),ForceMode.Force);
        }
    }
}
