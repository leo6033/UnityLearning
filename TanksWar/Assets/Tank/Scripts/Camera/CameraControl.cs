using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    public float m_DampTime = 0.2f;                         // 相机对焦时间
    public float m_ScreenEdgeBuffer = 4f;                   // 最上面/最下面的目标和屏幕边缘之间的空间。
    public float m_Minsize = 6.5f;                          // 相机的最小正投影尺寸。
    [HideInInspector] public Transform[] m_Targets;                           // 所有目标

    private Camera m_Camera;                                //  摄像机
    private float m_ZoomSpeed;
    private Vector3 m_MoveVelocity;
    private Vector3 m_DesiredPosition;

    private void Awake()
    {
        m_Camera = GetComponentInChildren<Camera>();
    }

    private void FixedUpdate()
    {
        // 移动相机位置
        Move();
        // 改变相机 size
        Zoom();
    }

    private void Move()
    {
        // 计算所有目标的平均位置
        FindAveragePosition();
        // 平滑移动
        transform.position = Vector3.SmoothDamp(transform.position, m_DesiredPosition, ref m_MoveVelocity, m_DampTime);
    }

    private void FindAveragePosition()
    {
        Vector3 averagePos = new Vector3();
        int numTargets = 0;

        for(int i = 0; i < m_Targets.Length; i++)
        {
            if (!m_Targets[i].gameObject.activeSelf) continue;

            averagePos += m_Targets[i].position;
            numTargets++;
        }

        if (numTargets > 0)
            averagePos /= numTargets;

        averagePos.y = transform.position.y;

        m_DesiredPosition = averagePos;
    }

    private void Zoom()
    {
        // 根据需要的位置调整所需的尺寸，并平稳过渡到所需的尺寸
        float requierdSize = FindRequiredSize();
        m_Camera.orthographicSize = Mathf.SmoothDamp(m_Camera.orthographicSize, requierdSize, ref m_ZoomSpeed, m_DampTime);
    }


    private float FindRequiredSize()
    {
        // 在其局部空间中找到摄像机的移动方向。
        Vector3 desiredLocalPos = transform.InverseTransformPoint(m_DesiredPosition);
        float size = 0f;

        for(int i = 0; i < m_Targets.Length; i++)
        {
            if (!m_Targets[i].gameObject.activeSelf) continue;

            // 在相机的局部空间中找到目标的位置。
            Vector3 targetLocalPos = transform.InverseTransformPoint(m_Targets[i].position);
            // 从相机的局部空间的期望位置找到目标的位置。
            Vector3 desiredPosToTarget = targetLocalPos - desiredLocalPos;
            // 从当前的大小和坦克的距离中选择最大的“向上”或“向下”的相机。
            size = Mathf.Max(size, Mathf.Abs(desiredPosToTarget.y));
            
            size = Mathf.Max(size, Mathf.Abs(desiredPosToTarget.x) / m_Camera.aspect);
        }

        size += m_ScreenEdgeBuffer;
        size = Mathf.Max(size, m_Minsize);

        return size;
    }

    public void SetStarPositionAndSize()
    {
        FindAveragePosition();

        transform.position = m_DesiredPosition;

        m_Camera.orthographicSize = FindRequiredSize();
    }

}
