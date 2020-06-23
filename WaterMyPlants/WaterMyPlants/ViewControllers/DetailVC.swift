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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var waterThisPlantButton: UIButton!
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
        setupWaterThisPlantButton()
    }
    
    private func setupTableView(plant: Plant) {
        let wateringFrequencyParsing = plant.h2oFrequency?.components(separatedBy: ", ")
        let days = wateringFrequencyParsing?.last
        let nextWateringDate = wateringFrequencyParsing?.first
        
        self.tableViewCellContent["Watering Schedule"] = formatWateringScheduleString(days!)
        self.tableViewCellContent["Next Watering Date"] = nextWateringDate
    }
    
    private func setupWaterThisPlantButton() {
        waterThisPlantButton.setTitle("Water", for: .normal)
        // shadow
        waterThisPlantButton.layer.shadowColor = UIColor(red: 171/255, green: 178/255, blue: 186/255, alpha: 1).cgColor
        waterThisPlantButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        waterThisPlantButton.layer.shadowOpacity = 1
        waterThisPlantButton.layer.shadowRadius = 4
        // shape
        waterThisPlantButton.layer.cornerRadius = waterThisPlantButton.frame.width / 2
        waterThisPlantButton.layer.masksToBounds = false
    }
    
    private func formatWateringScheduleString(_ days: String) -> String {
        let daysInt = Int(days)! // convert input to int
        let day = 1
        let week = 7
        // return formatted string
        if daysInt == day {
            return "Every Day"
        } else if daysInt < week {
            return "Every \(days) Days"
        } else if daysInt == week {
            return "Every Week"
        } else {
            return "Every \(daysInt / week) Weeks"
        }
    }
        
    /// called to update any views that may have changes
    private func updateViews() { // FIXME: - should this VC just use observers here instead?
        guard let plant = injectedPlant else { return }
        toggleWaterThisPlantButton(plant: plant)
    }
    
    private func toggleWaterThisPlantButton(plant: Plant) {
        let parsedFrequencyString = plant.h2oFrequency?.components(separatedBy: ", ") // parse string
        let dateString = parsedFrequencyString?.first // date is first
        let date = dateFormatter.date(from: dateString!)!
        if date <= Date() { // check to see if the plant date is today or earlier
            // show
            waterThisPlantButton.alpha = 1 // FIXME: - remove?
            waterThisPlantButton.isEnabled = true
            waterThisPlantButton.isHidden = false
        } else {
            // hide
            waterThisPlantButton.alpha = 0 // FIXME: - remove?
            waterThisPlantButton.isEnabled = false
            waterThisPlantButton.isHidden = true
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func waterThisPlantButtonPressed(_ sender: UIButton) {
        guard let plant = injectedPlant else { return }
        waterThisPlantButton.isEnabled = false // we want to stop the user from pressing the button repeatedely
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
        // save update
        plant.h2oFrequency = h20Frequency
        try! CoreDataManager.shared.save() // TODO: <-- temporary. proper method call here
        // animate button to show the user that the UI is responding
        waterThisPlantButton.setTitle("Done!", for: .normal)
        performSpringAnimation(forButton_: sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateViews() // will hide button
        }
    }
    
    /// button will appear bounce when called
    private func performSpringAnimation(forButton_ button: UIButton) {
        UIButton.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIButton.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                button.transform = CGAffineTransform.identity
            }, completion: nil)
        }
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
