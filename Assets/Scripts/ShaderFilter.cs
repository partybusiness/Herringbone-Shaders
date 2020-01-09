using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderFilter : MonoBehaviour {

    [SerializeField]
    private Material filterMaterial;

    [ExecuteInEditMode]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, filterMaterial);
    }
}
