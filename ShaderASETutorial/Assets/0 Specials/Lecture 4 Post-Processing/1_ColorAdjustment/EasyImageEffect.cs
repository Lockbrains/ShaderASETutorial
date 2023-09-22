using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class EasyImageEffect : MonoBehaviour
{
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    // Source: image from frame buffer
    // Destination: output image texture
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // 
        Graphics.Blit(source, destination, material); 
        

    }
}
