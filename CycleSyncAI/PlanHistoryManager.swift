//
//  PlanHistoryManager.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 14/06/25.
//

import Foundation

class PlanHistoryManager {
    static let shared = PlanHistoryManager()
    private let key = "savedPlans"

    func savePlan(_ plan: PlanModel) {
        var existing = loadPlans()
        existing.insert(plan, at: 0) // newest first
        if let data = try? JSONEncoder().encode(existing) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadPlans() -> [PlanModel] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PlanModel].self, from: data) else {
            return []
        }
        return decoded
    }

    func clearPlans() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func getAllDateLabels() -> [String] {
        return loadPlans().map { $0.dateLabel }
    }
}
