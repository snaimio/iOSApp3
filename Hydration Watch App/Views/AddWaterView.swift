//
//  AddWaterView.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-21.
//

import SwiftUI

struct AddWaterView: View {
    @EnvironmentObject var manager: HydrationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var amount = 250
    
    var body: some View {
        VStack(spacing: 10) {
            Text("💧 Custom Log")
                .font(.headline)
                .padding(.top, 4)
            
            // Big Amount Text - Unique Color (Orange)
            Text("\(amount) ml")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
            
            HStack(spacing: 14) {
                Button(action: { if amount > 50 { amount -= 50 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                HStack(spacing: 4) {
                    ForEach([250, 500, 750], id: \.self) { preset in
                        Button("\(preset)") {
                            amount = preset
                        }
                        .font(.caption2)
                        .fontWeight(.medium)
                        .frame(width: 30, height: 24)
                        .background(amount == preset ? Color.orange : Color.gray.opacity(0.12))
                        .cornerRadius(6)
                        .foregroundColor(amount == preset ? .white : .orange)
                        .buttonStyle(.plain)
                    }
                }
                
                Button(action: { if amount < 2000 { amount += 50 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
            
            // Confirm Button - Purple
            Button(action: {
                manager.addWater(amount)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Confirm")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple)
                        .shadow(color: .purple.opacity(0.4), radius: 6)
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}
