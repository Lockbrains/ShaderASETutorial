using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[ExecuteAlways]
public class HandGlass : MonoBehaviour
{
    public Transform GlassCenter;
    public Transform GlassAxis;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //传入旋转坐标中心
        Vector3 centerPos = GlassCenter.transform.position;
        Shader.SetGlobalVector("_GlassCenter",new Vector4(centerPos.x,centerPos.y,centerPos.z,1));
        
        //传入旋转轴
        Vector4 GlassAxisVec = new Vector4();
        Vector3 axisPos = GlassAxis.transform.position;
        GlassAxisVec.x = axisPos.x - centerPos.x;
        GlassAxisVec.y = axisPos.y - centerPos.y;
        GlassAxisVec.z = axisPos.z - centerPos.z;

        Shader.SetGlobalVector("_GlassAxis",new Vector4(GlassAxisVec.x,GlassAxisVec.y,GlassAxisVec.z,1));

    }
}
