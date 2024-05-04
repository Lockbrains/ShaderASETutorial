using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class HoloTargetPos : MonoBehaviour
{
    public string Name = "_Global_TargetPos";

    // Start is called before the first frame update
    void Start()
    {
    }

    void Update()
    {
        Vector4 pos = transform.position;
        Shader.SetGlobalVector(Name, pos);
    }
}

