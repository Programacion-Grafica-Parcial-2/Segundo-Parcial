using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterLikecontroller : MonoBehaviour
{
    
    [SerializeField]Rigidbody2D rb;
    
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            rb.AddForce(new Vector2(-100,0),ForceMode2D.Force);
        }
        if (Input.GetKeyDown(KeyCode.D))
        {
            rb.AddForce(new Vector2(100,0),ForceMode2D.Force);
        }
        if (Input.GetKeyDown(KeyCode.W))
        {
            rb.AddForce(new Vector2(0,10),ForceMode2D.Impulse);
        }
    }
}
