using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PauseGame : MonoBehaviour
{
    string tip = "PauseGame";
    public bool paused = false;

    void OnPauseGame()
    {

        paused = !paused;
        if (paused)
        {
            tip = "StartGame";
        }
        else
        {
            tip = "PauseGame";
        }
    }

    void OnGUI()
    {

        if (GUILayout.Button(tip))
        {
            Object[] objects = FindObjectsOfType(typeof(GameObject));
            foreach (GameObject go in objects)
            {
                go.SendMessage("OnPauseGame", SendMessageOptions.DontRequireReceiver);
            }
        }
    }
}
