using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu (menuName = "AI/Decisions/Scan")]
public class ScanDecision : Decision
{
    public override bool Decide(StateController controller)
    {
        bool noEnemyInsight = Scan(controller);
        return noEnemyInsight;
    }

    private bool Scan(StateController controller)
    {
        controller.navMeshAgent.isStopped = true;
        controller.transform.Rotate(0, controller.enemyStats.searchingTurnSpeed * Time.deltaTime, 0);
        return controller.CheckIfCountDownElapsed(controller.enemyStats.searchDuration);
    }
}
