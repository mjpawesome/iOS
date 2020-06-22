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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateViews()
    }
    
    /// sets up view to their initial state
    private func setupViews() {
        imageView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    /// called to update any views that may have changes
    private func updateViews() { // FIXME: - should this VC just use observers here instead?
        imageView.image = injectedImage
        guard let plant = injectedPlant else { return }
        plantNicknameLabel.text = plant.nickname
    }
    
    @IBAction func pushToWaterButtonPressed(_ sender: UIBarButtonItem) {
        guard let plant = injectedPlant else { return }
        let parsedFrequencyString = plant.h2oFrequency?.components(separatedBy: ", ") // parse string
        let dateString = parsedFrequencyString?.first // date is first
        let daysString = parsedFrequencyString?.last // days are last
        let daysInt = Int(daysString!)
        // format dateString to date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy"
        let date = dateFormatter.date(from: dateString!)
        print("Old Date: \(dateString!)")
        let nextDate = Calendar.current.date(byAdding: .day, value: daysInt!, to: date!) // calculate nextDate
        let nextDateString = dateFormatter.string(from: nextDate!)
        print("New Date : \(nextDateString)")
        let h20Frequency = "\(nextDateString), \(daysString!)" // reformat string to be stored in coreData & network
        // save
        plant.h2oFrequency = h20Frequency
        try! CoreDataManager.shared.save()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        return cell
    }

}
