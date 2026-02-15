import Foundation

struct RunXPBreakdown {
    let distance: Int
    let checkpoints: Int
    let hides: Int
    let food: Int
}

final class RankSystem {

    // XP formula tuning (keep simple)
    func xpForRun(_ run: RunXPBreakdown) -> Int {
        let distXP = run.distance / 10              // 1000 dist => 100 xp
        let cpXP = run.checkpoints * 60
        let hideXP = run.hides * 35
        let foodXP = run.food * 10
        return max(0, distXP + cpXP + hideXP + foodXP)
    }

    func currentRank(for totalXP: Int) -> PlayerRank {
        // highest rank where totalXP >= requiredXP
        var best: PlayerRank = .stray
        for def in RankCatalog.ranks {
            if totalXP >= def.requiredXP {
                best = def.rank
            }
        }
        return best
    }
}
