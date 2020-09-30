using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class Dust : MonoBehaviour
{
    public float minWait, maxWait;
    public Vector2 min, max;
    public GameObject dustTemplate;

    private float waitGoal, t_waited;
    private ParticleSystem[] dust;
    private int cursor;

    void Start()
    {
        dust = new ParticleSystem[(int)(1.0f/minWait)];
        t_waited = 0.0f;
        waitGoal = UnityEngine.Random.Range(minWait, maxWait);
        cursor = 0;
    }

    void Update()
    {
        t_waited += Time.deltaTime;
        if(t_waited >= waitGoal)
        {
            // new dust clump
            if(!(dust[cursor] is null))
            {
                Destroy(dust[cursor].gameObject);
            }
            GameObject newDust = Instantiate(dustTemplate);
            newDust.transform.SetParent(transform);
            newDust.transform.position = new Vector2(UnityEngine.Random.Range(min.x, max.x), UnityEngine.Random.Range(min.y, max.y));
            dust[cursor] = newDust.GetComponent<ParticleSystem>();
            cursor = (cursor + 1) % dust.Length;

            t_waited = 0.0f;
            waitGoal = UnityEngine.Random.Range(minWait, maxWait);
        }
    }
}
