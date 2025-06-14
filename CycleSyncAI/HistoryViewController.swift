//
//  HistoryViewController.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 14/06/25.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let gradientLayer = CAGradientLayer()
    let dietButton = UIButton(type: .system)
    let workoutButton = UIButton(type: .system)
    let tableView = UITableView()

    var allPlans: [PlanModel] = []
    var filteredPlans: [PlanModel] = []
    var currentFilter: String = "diet"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupFilterButtons()
        setupTableView()

        allPlans = PlanHistoryManager.shared.loadPlans()
        filterPlans(for: currentFilter)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearHistory)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
    }

    func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupFilterButtons() {
        dietButton.setTitle("Diet Plans", for: .normal)
        workoutButton.setTitle("Workout Plans", for: .normal)

        [dietButton, workoutButton].forEach { button in
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont(name: "Avenir", size: 16)
            button.layer.cornerRadius = 12
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 6
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
        }

        applyGradient(to: dietButton, colors: [
            UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1).cgColor,
            UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1).cgColor
        ])

        applyGradient(to: workoutButton, colors: [
            UIColor(red: 0.8, green: 0.757, blue: 0.969, alpha: 1).cgColor,
            UIColor(red: 0.663, green: 0.776, blue: 1.0, alpha: 1).cgColor
        ])

        dietButton.addTarget(self, action: #selector(showDietPlans), for: .touchUpInside)
        workoutButton.addTarget(self, action: #selector(showWorkoutPlans), for: .touchUpInside)

        NSLayoutConstraint.activate([
            dietButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dietButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dietButton.widthAnchor.constraint(equalToConstant: 150),
            dietButton.heightAnchor.constraint(equalToConstant: 40),

            workoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            workoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            workoutButton.widthAnchor.constraint(equalToConstant: 150),
            workoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func applyGradient(to button: UIButton, colors: [CGColor]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        gradient.cornerRadius = 12
        button.layer.insertSublayer(gradient, at: 0)
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlanCell")
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dietButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func filterPlans(for type: String) {
        currentFilter = type
        filteredPlans = allPlans.filter { $0.type == type }
        tableView.reloadData()
    }
    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }

    @objc func showDietPlans() {
        filterPlans(for: "diet")
    }

    @objc func showWorkoutPlans() {
        filterPlans(for: "workout")
    }
    
    @objc func clearHistory() {
        let alert = UIAlertController(title: "Clear All History?",
                                      message: "This will permanently delete all saved plans.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            PlanHistoryManager.shared.clearPlans()
            self.allPlans = []
            self.filteredPlans = []
            self.tableView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(
                title: "Delete Plan?",
                message: "Are you sure you want to delete this plan?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let planToDelete = self.filteredPlans[indexPath.row]
                
                // Remove from full list
                if let indexInAll = self.allPlans.firstIndex(where: {
                    $0.dateLabel == planToDelete.dateLabel &&
                    $0.type == planToDelete.type &&
                    $0.content == planToDelete.content
                }) {
                    self.allPlans.remove(at: indexInAll)
                }
                
                // Remove from filtered list and update table
                self.filteredPlans.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Save updated list
                if let data = try? JSONEncoder().encode(self.allPlans) {
                    UserDefaults.standard.set(data, forKey: "savedPlans")
                }
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlans.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath)
        let plan = filteredPlans[indexPath.row]
        cell.textLabel?.text = "\(plan.dateLabel)"
        cell.textLabel?.font = UIFont(name: "Avenir", size: 16)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        cell.layer.cornerRadius = 8
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPlan = filteredPlans[indexPath.row]
        let detailVC = PlanDetailViewController(plan: selectedPlan)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
