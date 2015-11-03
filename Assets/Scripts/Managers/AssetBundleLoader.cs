using UnityEngine;
using System.Collections;

public class AssetBundleLoader : MonoBehaviour 
{	
	public delegate void GameObjectLoadingFailed(string exception);
	public event GameObjectLoadingFailed OnGameObjectLoadingFailed;
	public delegate void GameObjectLoaded(GameObject gameObject);
	public event GameObjectLoaded OnGameObjectLoaded;
	
	private WWW www;
	public bool IsLoading = false;
	
	public double ProgressPercent 
	{
		get {
			if (www != null && IsLoading && www.assetBundle == null) {
				return www.progress;
			}
			
			return -1;
		}
	}
	
	public int BytesLoaded 
	{
		get {
			if (www != null && IsLoading && www.assetBundle == null) {
				return www.bytesDownloaded;
			} 
			
			return 0;
		}
	}
	
	public int TotalBytes 
	{
		get {
			if (www != null && IsLoading) {
				return www.size;
			} 
			
			return 0;
		}
	}
	
	public IEnumerator LoadGameObjectFromUrl(string url)
	{	
		this.IsLoading = true;
		print("[AssetLoader] Download asset bundle STARTED from url: " + url);
		
		while (!Caching.ready) 
		{
			yield return null;
		}
		
		using(www = WWW.LoadFromCacheOrDownload(url, 1))
		{	
			yield return www;	
			if (www.error == null) 
			{
				this.IsLoading = false;
				print("[AssetLoader] Downloading asset bundle DONE from url: " + url);	
				AssetBundle bundle = www.assetBundle;
				OnGameObjectLoaded(bundle.mainAsset as GameObject);	
				bundle.Unload(false);
				Object.Destroy(bundle);
				
			} 
			else 
			{
				this.IsLoading = false;
				print("[AssetLoader] Downloading asset bundle FAILED from url: " + url + " with error: " + www.error);
				OnGameObjectLoadingFailed(www.error);
			}
		}
	}
}
