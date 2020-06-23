//
//  DetailVC.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var plantNicknameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pushToWaterButton: UIBarButtonItem!
    
    var injectedImage: UIImage?
    var injectedPlant: Plant?
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy"
        return dateFormatter
    }()
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        return cell
    }

}
