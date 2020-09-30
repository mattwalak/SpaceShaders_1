using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialPerlinColor : MonoBehaviour
{
    public int dataCount = 1000;
    public float rps = 0.01f;
    Material material;

    void Awake()
    {
        material = GetComponent<MeshRenderer>().material;
    }

    float[] GenerateData(int length)
    {
        float[] data = new float[length];
        for (int i = 0; i < length; i++)
        {
            float rand = UnityEngine.Random.Range(0.0f, 3.0f);
            if (rand < 1.0f)
            {
                data[i] = 1.0f;
            }
            else if (rand < 2.0f)
            {
                data[i] = 0.0f;
            }
            else
            {
                data[i] = -1.0f;
            }
        }
        return data;
    }

    void Start()
    {
        material.SetFloatArray("_PerlinDataA", GenerateData(dataCount));
        material.SetFloatArray("_PerlinDataB", GenerateData(dataCount));
        material.SetFloatArray("_ColorDataA", GenerateData(dataCount));
        material.SetFloatArray("_ColorDataB", GenerateData(dataCount));
        material.SetFloat("_RPS", rps);
    }
}
