using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowMatCap : MonoBehaviour
{
    public List<Texture2D> MatCaps;

    int index = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (MatCaps.Count != null)
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                index = (index + 1) % MatCaps.Count;
                Shader.SetGlobalTexture("_MatCap", MatCaps[index]);
                print("index:"+index);
            }
        }
    }
}
