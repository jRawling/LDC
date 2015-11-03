using UnityEngine;
using System.Collections;

public class GarageController : MonoBehaviour 
{
	AssetBundleLoader loader = new AssetBundleLoader();

	void Start () 
	{
		LoadCarFromUrl("file://" + Application.dataPath + "/Bundles/Cars/VW_Golf_Generic.unity3d");
	}
	
	void LoadCarFromUrl(string url)
	{
		print (url);
		StartCoroutine(loader.LoadGameObjectFromUrl (url));
	}
}
