using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TAProPointLight : MonoBehaviour
{
    public enum LightingMode
    {
        Both,//0
        DiffuseOnly,//1
        SpecularOnly,//2
        VirtualLight,//3
    }

    public LightingMode lightingMode = LightingMode.Both;
    
    private Light light;

    [Range(0.0f,1.0f)]
    public float DiffuseWrap = 0.5f;

    // public Vector3 _Global_VirtualLightPos;
    public float _Global_VirtualLightFade;
    [ColorUsage(true,true)]
    public Color _Global_VirtualLightColor;
        
    // Start is called before the first frame update
    void Start()
    {
        light = GetComponent<Light>();
    }
    
    /*
    public class ShaderID
    {
        public static int _PointLightColorAndRange = Shader.PropertyToID("_PointLightColorAndRange");
        public static int _PointLightPos = Shader.PropertyToID("_PointLightPos");
    }
    */
    
    // Update is called once per frame

    int GetLightingMode()
    {
        if (lightingMode == LightingMode.Both)
        {
            return 0;
        }
        if (lightingMode == LightingMode.DiffuseOnly)
        {
            return 1;
        }
        else
        {
            return 2;
        }

        return 0;
    }
    
    void Update()
    {
        if (lightingMode == LightingMode.VirtualLight)
        {
    // public Vector3 _Global_VirtualLightPos;
    // public float _Global_VirtualLightFade;
    // public Color _Global_VirtualLightColor; 
            Vector4 _Global_VirtualLightPosAndFade = transform.position;
            _Global_VirtualLightPosAndFade.w = _Global_VirtualLightFade;
            
            Shader.SetGlobalVector("_Global_VirtualLightPosAndFade", _Global_VirtualLightPosAndFade);
            Shader.SetGlobalVector("_Global_VirtualLightColor", _Global_VirtualLightColor);
        }
        else
        {


            if (light.type == LightType.Point)
            {
                Vector4 _PointLightColorAndRange = light.color * light.intensity;
                _PointLightColorAndRange.w = light.range;

                Vector4 _PointLightPos = transform.position;
                _PointLightPos.w = GetLightingMode();

                Shader.SetGlobalVector("_PointLightColorAndRange", _PointLightColorAndRange);
                Shader.SetGlobalVector("_PointLightPos", _PointLightPos);
                Shader.SetGlobalFloat("_DiffuseWrap", DiffuseWrap);

                // Shader.SetGlobalVector(ShaderID._PointLightColorAndRange,_PointLightColorAndRange);
                // Shader.SetGlobalVector(ShaderID._PointLightPos,transform.position);
            }

            else if (light.type == LightType.Spot)
            {
                // float4 _SpotLightColorAndAngle;
                // float4 _SpotLightDir;
                // float4 _SpotLightPos;

                Vector4 _SpotLightColorAndRange = light.color * light.intensity;
                _SpotLightColorAndRange.w = light.range;
                Vector4 _SpotLightDirAndAngle = transform.forward;
                // _SpotLightDirAndAngle.w =Mathf.Cos( Mathf.Deg2Rad * light.spotAngle);
                _SpotLightDirAndAngle.w = Mathf.Deg2Rad * light.spotAngle * 0.5f;
                Vector4 _SpotLightPos = transform.position;
                _SpotLightPos.w = GetLightingMode();

                Shader.SetGlobalVector("_SpotLightColorAndRange", _SpotLightColorAndRange);
                Shader.SetGlobalVector("_SpotLightDirAndAngle", _SpotLightDirAndAngle);
                Shader.SetGlobalVector("_SpotLightPos", _SpotLightPos);
                Shader.SetGlobalFloat("_DiffuseWrap", DiffuseWrap);

            }
        }
    }
}
