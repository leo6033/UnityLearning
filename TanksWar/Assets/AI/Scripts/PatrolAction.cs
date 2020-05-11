using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu (menuName ="AI/Actions/Patrol")]
public class PatrolAction : Action
{
    public override void Act(StateController controller)
    {
        Patrol(controller);
    }

    private void Patrol(StateController controller)
    {
        controller.navMeshAgent.destination = controller.wayPointList[controller.nextwayPoint].position;
        //controller.navMeshAgent.isStopped = false;
        controller.navMeshAgent.Resume();

        if(controller.navMeshAgent.remainingDistance <= 
            controller.navMeshAgent.stoppingDistance && !controller.navMeshAgent.pathPending)
        {
            controller.nextwayPoint = (controller.nextwayPoint + 1) % controller.wayPointList.Count;
        }
    }
}
