//
//  PlanModel.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 14/06/25.
//


import Foundation

struct PlanModel: Codable {
    let type: String         // "diet" or "workout"
    let dateLabel: String    // Jun 14 or Jun 14-22
    let content: String      // HTML or plain text
}
