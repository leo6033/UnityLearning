using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExitButton : MonoBehaviour
{
    public void Click()
    {
        Debug.Log("Button Clicked. TestClick.");
        Application.Quit();
    }
}
