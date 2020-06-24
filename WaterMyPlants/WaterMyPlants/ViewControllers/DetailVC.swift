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
    // edit menu
    @IBOutlet var editMenuPopover: UIView!
    @IBOutlet weak var editMenuPlantNameTextfield: UITextField!
    @IBOutlet weak var editMenuDescriptionLabel: UITextField!
    @IBOutlet weak var editMenuPickerView: UIPickerView!
    @IBOutlet weak var editMenuSaveButton: UIButton!
    @IBOutlet weak var editMenuDeleteButton: UIButton!
    
    var injectedImage: UIImage?
    var injectedPlant: Plant?
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy"
        return dateFormatter
    }()
    var tableViewCellContent = ["Watering Schedule" : "Error", "Next Watering Date" : "Error"]
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    let numbers = ["1", "2", "3", "4", "5", "6", "7"] // picker view
    let calendarComponents = ["days", "weeks"] // picker view
    var number: Int = 1 // pickerViewDefault
    var multiplier: Int = 1 // pickerViewDefault
    var dayCountFromPicker: Int? // this contains the time interval the user has selected in the picker view (in days)
    
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
        setupTableView(plant: plant)
        setupWaterThisPlantButton()
        setupPopover()
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editMenuSaveButton.layer.cornerRadius = 15
        editMenuDeleteButton.layer.cornerRadius = 15
    }
    
    private func setupPopover() {
        editMenuPopover.layer.cornerRadius = 15
        editMenuPopover.layer.masksToBounds = true
        editMenuPopover.backgroundColor = .systemFill
        editMenuPopover.alpha = 0
        // assign outlets existing text
        guard let plant = injectedPlant else { return }
        editMenuPlantNameTextfield.text = plant.nickname
        editMenuDescriptionLabel.text = plant.species // treating species as description
        
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
        plantNicknameLabel.text = plant.nickname // name
        descriptionLabel.text = plant.species ?? "" // species is being treated as a description
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
        if editMenuPopover.alpha == 1 { //close if already open
            UIView.animate(withDuration: 0.5) {
                // popover
                self.editMenuPopover.alpha = 0
                self.editMenuPopover.removeFromSuperview()
                // blur
                self.blurEffectView.alpha = 0
                self.blurEffectView.removeFromSuperview()
                // editButton
                self.editButton.title = "Edit"
            }
        } else {
            self.view.addSubview(editMenuPopover)
            editMenuPopover.alpha = 0
            // fade in
            UIView.animate(withDuration: 0.5) {
                // blur
                self.view.addSubview(self.blurEffectView)
                self.blurEffectView.alpha = 1
                // popover
                self.editMenuPopover.alpha = 1
                self.editMenuPopover.superview?.bringSubviewToFront(self.editMenuPopover)
                // editButton
                self.editButton.title = "Close"
            }
            // set location
            editMenuPopover.center = self.view.center
        }
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
    
    private func setInitialH20date(dayCountFromPicker: Int) -> String {
        "\(Date()), \(dayCountFromPicker)"
    }
    
    @IBAction func editMenuSaveButtonPressed(_ sender: UIButton) {
        performSpringAnimation(forButton_: editMenuSaveButton)
        guard let imageURL = self.injectedPlant?.imageURL,
            let nickname = editMenuPlantNameTextfield.text,
            !nickname.isEmpty,
            let injectedPlant = injectedPlant else { return }
        // format h20freq
        let date = dateFormatter.string(from: Date())
        let days = dayCountFromPicker ?? 1 // default catches when the user doesn't change the picker
        let h2oFrequency = "\(date), \(days)" // date holds the due date, days hold the the repeat frequency
        // description (using species as description)
        let description = editMenuDescriptionLabel.text ?? ""
        // create plant object
        //        let newPlant = Plant(species: description,
        //                             nickname: nickname,
        //                             h2oFreqency: h2oFrequency,
        //                             userID: "\(AuthService.activeUser?.identifier)", // FIXME: - this value is reading as nil. Investigate this to get the right value
        //            imageURL: imageURL)
        // FIXME: - the code below is altering the objects directly, while above is creating a new object to delete old and replace with new. which to use depends on network call below
        injectedPlant.nickname = nickname
        injectedPlant.species = description // treating species as description
        injectedPlant.h2oFrequency = h2oFrequency
        print("\(AuthService.activeUser?.identifier)")
        // save to coreData
        try! CoreDataManager.shared.save() // FIXME: - <-- this is should really be built into the controller method  below with catch block
        // send to server
        // TODO: call update method on the plant controller to replace the old object with the newly updated one
        // plantController.update(
        // animate and refresh views to give the user feedback that their change saved
        editMenuSaveButton.setTitle("Saved!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.updateViews()
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.5) {
                // popover
                self.editMenuPopover.alpha = 0
                self.editMenuPopover.removeFromSuperview()
                // blur
                self.blurEffectView.alpha = 0
                self.blurEffectView.removeFromSuperview()
                // editButton
                self.editButton.title = "Edit"
            }
        })
    }
    
    @IBAction func editMenuDeleteButtonPressed(_ sender: UIButton) {
        performSpringAnimation(forButton_: editMenuDeleteButton)
        
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

extension DetailVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return self.numbers.count }
        else { return self.calendarComponents.count }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return self.numbers[row] }
        else { return self.calendarComponents[row] }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 { number = Int(numbers[row])! } // grab number
        if component == 1 { multiplier = calendarComponents[row] == "days" ? 1 : 7 } // multiplier should be 7 if weeks was selected
        print("\(number) * \(multiplier) = \(number * multiplier)") // test
        self.dayCountFromPicker = number * multiplier // save day count
    }
    
}
