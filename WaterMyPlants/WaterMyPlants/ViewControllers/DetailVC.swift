//
//  DetailVC.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var plantNicknameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pushToWaterButton: UIBarButtonItem!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var injectedImage: UIImage?
    var injectedPlant: Plant?
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy"
        return dateFormatter
    }()
    var tableViewCellContent = ["Watering Schedule" : "Error", "Next Watering Date" : "Error"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateViews()
    }
    
    /// sets up view to their initial state
    private func setupViews() {
        imageView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        imageView.image = injectedImage // image
        guard let plant = injectedPlant else { return }
        plantNicknameLabel.text = plant.nickname // name
        descriptionLabel.text = plant.species ?? "" // species is being treated as a description
        setupTableView(plant: plant)
    }
    
    private func setupTableView(plant: Plant) {
        let wateringFrequencyParsing = plant.h2oFrequency?.components(separatedBy: ", ")
        let days = wateringFrequencyParsing?.last
        let nextWateringDate = wateringFrequencyParsing?.first
        
        self.tableViewCellContent["Watering Schedule"] = formatWateringScheduleString(days!)
        self.tableViewCellContent["Next Watering Date"] = nextWateringDate
    }
    
    private func formatWateringScheduleString(_ days: String) -> String {
        let daysInt = Int(days)!
        if daysInt == 1 {
            return "Every Day"
        } else if daysInt < 7 {
            return "Every \(days) Days"
        } else if daysInt == 7 {
            return "Every Week"
        } else {
            return "Every \(daysInt / 7) Weeks"
        }
    }
    
    private func calculateNextWateringDate() {
        
    }
        
    /// called to update any views that may have changes
    private func updateViews() { // FIXME: - should this VC just use observers here instead?
        guard let plant = injectedPlant else { return }
        togglePushToWaterButton(plant: plant)
    }
    
    private func togglePushToWaterButton(plant: Plant) {
        let parsedFrequencyString = plant.h2oFrequency?.components(separatedBy: ", ") // parse string
        let dateString = parsedFrequencyString?.first // date is first
        let date = dateFormatter.date(from: dateString!)!
        if date <= Date() {
            pushToWaterButton.title = "✓ Push to Water"
            pushToWaterButton.isEnabled = true
        } else {
            pushToWaterButton.title = ""
            pushToWaterButton.isEnabled = false
        }
    }
    
    @IBAction func pushToWaterButtonPressed(_ sender: UIBarButtonItem) {
        guard let plant = injectedPlant else { return }
        let parsedFrequencyString = plant.h2oFrequency?.components(separatedBy: ", ") // parse string
        let dateString = parsedFrequencyString?.first // date is first
        let daysString = parsedFrequencyString?.last // days are last
        let daysInt = Int(daysString!) // convert to int
        let date = dateFormatter.date(from: dateString!)// format dateString to date
        print("Old Date: \(dateString!)")
        let nextDate = Calendar.current.date(byAdding: .day, value: daysInt!, to: date!) // calculate nextDate
        let nextDateString = dateFormatter.string(from: nextDate!)
        print("New Date : \(nextDateString)")
        let h20Frequency = "\(nextDateString), \(daysString!)" // reformat string to be stored in coreData & network
        // save
        plant.h2oFrequency = h20Frequency
        try! CoreDataManager.shared.save()
        self.updateViews()
        pushToWaterButton.title = "Done!"
    }

}

// MARK: - TableView dataSource & delegate methods
extension DetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewCellContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = Array(tableViewCellContent.keys)[indexPath.row]
        cell.detailTextLabel?.text = Array(tableViewCellContent.values)[indexPath.row]
        return cell
    }
    
}
