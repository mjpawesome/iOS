//
//  HomeVC.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var horizontalCollectionView: UICollectionView!
    @IBOutlet weak var verticalCollectionView: UICollectionView!
    @IBOutlet weak var plusButton: UIButton!
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy"
        return dateFormatter
    }()
    var blockOperations = [BlockOperation]()
    private lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nickname", ascending: true)]
        let mainContext = CoreDataManager.shared.mainContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error Fetching -> HomeVC in VerticalCVFetchedResultsController: \(error)")
        }
        return fetchedResultsController
    }()
    var plantController = PlantController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendUserToLoginIfNecessary()
        fetchNewTasksFromServer()
        setupInitialViews()
        print(fetchedResultsController.fetchedObjects?.first?.h2oFrequency) // this print statement can be used to check which properties of the core data object are saving
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        horizontalCollectionView.reloadData()
    }
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    /// Checks if user is logged in. If the aren't, they are sent to login
    private func sendUserToLoginIfNecessary() {
        if !UserDefaults.standard.bool(forKey: "isLoggedIn") {
            performSegue(withIdentifier: "OnboardingSegue", sender: self)
        }
    }
 
    /// Calls the method in the plantController that will start syncing any new tasks and updates the FRC and views
    private func fetchNewTasksFromServer() {
        plantController.fet { (result) in
            DispatchQueue.main.async {
                self.horizontalCollectionView.reloadData()
            }
        }
    }
    
    /// sets up views to their intial state
    private func setupInitialViews() {
        setupPlusButton()
        setupNavigationBar()
    }
    
    /// sets up the plus button to it's initial state
    private func setupPlusButton() {
        // image
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        // shadow
        plusButton.layer.shadowColor = UIColor(red: 171/255, green: 178/255, blue: 186/255, alpha: 1).cgColor
        plusButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        plusButton.layer.shadowOpacity = 1
        plusButton.layer.shadowRadius = 4
        // shape
        plusButton.layer.cornerRadius = plusButton.frame.width / 2
        plusButton.layer.masksToBounds = false
    }
    
    /// sets up the navigation bar to it's initial state
    private func setupNavigationBar() {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [.font: UIFont(name: "HoeflerText-Black", size: 34)!]
    }
    
    /// locks the user back into the login/ signup screen until they log in again
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    /// segues to the CreatePlant VC
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        performSpringAnimation(forButton_: sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "HomeToCreatePlantVC", sender: self)
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
    
    // MARK: - Collection views data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == horizontalCollectionView {
            return filterAndSortDuePlants()?.count ?? 0
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == horizontalCollectionView {
            let horizontalCell = horizontalCollectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! HorizontalCVCell
            let plant = filterAndSortDuePlants()?[indexPath.row] // grab plant
            // badge
            horizontalCell.badgeLabel.text = assignBadgeText(plant: plant!)
            horizontalCell.badgeLabel.isHidden = horizontalCell.badgeLabel.text == "" ? true : false
            if let plantImage = plant?.imageURL { horizontalCell.imageView.downloaded(from: plantImage) } // image
            if let plantNickname = plant?.nickname { horizontalCell.nicknameLabel.text = plantNickname } // name
            stylizeCell(horizontalCell)
            return horizontalCell
        } else { // verticalCollectionView
            let  verticalCell = verticalCollectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCVCell
            let plant = fetchedResultsController.fetchedObjects?[indexPath.row] // grab plant
            if let plantImage = plant?.imageURL { verticalCell.imageView.downloaded(from: plantImage) } // image
            if let plantNickname = plant?.nickname { verticalCell.nicknameLabel.text = plantNickname } // name
            stylizeCell(verticalCell)
            return verticalCell
        }
    }
    /// Used to style the cells if there are many tweaks done to the cell. Otherwise this method may not be neccasary.
    func stylizeCell(_ cell: UICollectionViewCell) {
        cell.layer.cornerRadius = 12
    }
    
    private func assignBadgeText(plant: Plant) -> String { // FIXME: - this is saying things like "1 days ago" instead of "1 day ago". Why??
        // grab seconds between now and plant watering dueDate
        let date = dateFormatter.date(from: (plant.h2oFrequency?.components(separatedBy: ", ").first)!)
        let secondsAgo = Int(Date().timeIntervalSince(date!))
        // components
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let dayInSeconds = 60*60*24

        // return
        if secondsAgo < dayInSeconds {
            return ""
        } else if secondsAgo >= dayInSeconds && secondsAgo <= (2 * dayInSeconds) - 1  {
            return "1 day late"
        } else if secondsAgo >= 2 * dayInSeconds && secondsAgo < 7 * dayInSeconds {
            return "\(secondsAgo / day) days late"
        } else if secondsAgo >= 7 * dayInSeconds && secondsAgo < 14 * dayInSeconds - 1 {
            return "1 week late"
        } else {
            return "\(secondsAgo / week) weeks late"
        }

//        if secondsAgo < day {
//            return ""
//        } else if secondsAgo == day {
//            return "1 day late"
//        } else if secondsAgo < week {
//            return "\(secondsAgo / day) days late"
//        } else if secondsAgo == week {
//            return "1 week late"
//        } else {
//            return "\(secondsAgo / week) weeks late"
//        }
    }
    
    private func filterAndSortDuePlants() -> [Plant]? {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects as [Plant]? else { return nil }
        let filteredPlants = fetchedObjects.filter {
            dateFormatter.date(from: ($0.h2oFrequency?.components(separatedBy: ", ").first!)!)! <= Date()
        }
        let sortedPlants = filteredPlants.sorted {
            dateFormatter.date(from: ($0.h2oFrequency?.components(separatedBy: ", ").first!)!)! < dateFormatter.date(from: ($1.h2oFrequency?.components(separatedBy: ", ").first!)!)!
        }
        return sortedPlants
    }
    
    /// Customizes sizing for collectionViews
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == horizontalCollectionView {
            return CGSize(width: 97, height: 127)
        } else { // verticalCollectionView
            return CGSize(width: self.view.frame.width / 2 - 27, height: self.view.frame.width / 2)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VerticalShowDetail" { // FIXME: - horizontal Collection view shares same seg name.. should be unique
            guard let indexPath = verticalCollectionView.indexPathsForSelectedItems?.first,
                let detailVC = segue.destination as? DetailVC else { return }
            // inject image
            let verticalCell = verticalCollectionView.cellForItem(at: indexPath) as? VerticalCVCell
            if let verticalCellImage = verticalCell?.imageView.image {
                detailVC.injectedImage = verticalCellImage
            }
            // inject plant object
            let plant = fetchedResultsController.fetchedObjects?[indexPath.row]
            detailVC.injectedPlant = plant
        }
        if segue.identifier == "HorizontalShowDetail" {
            guard let indexPath = horizontalCollectionView.indexPathsForSelectedItems?.first,
                let detailVC = segue.destination as? DetailVC else { return }
            // inject image
            let horizontalCell = horizontalCollectionView.cellForItem(at: indexPath) as? HorizontalCVCell
            if let horizontalCellImage = horizontalCell?.imageView.image {
                detailVC.injectedImage = horizontalCellImage
            }
            // inject plant object
            let plant = filterAndSortDuePlants()?[indexPath.row]
            detailVC.injectedPlant = plant
        }
        if segue.identifier == "LogoutSegue" {
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
        }
    }
}

// MARK: - FRC delegate
extension HomeVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(String(describing: newIndexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.insertItems(at: [newIndexPath!])
//                           : self.horizontalCollectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.reloadItems(at: [indexPath!])
//                           : self.horizontalCollectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(String(describing: indexPath))")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.moveItem(at: indexPath!, to: newIndexPath!)
//                           : self.horizontalCollectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(String(describing: indexPath))")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.deleteItems(at: [indexPath!])
//                          :  self.horizontalCollectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        }
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                           : self.horizontalCollectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                           : self.horizontalCollectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
//                        controller == self.verticalCollectionView ?
                            self.verticalCollectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                            : self.horizontalCollectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        verticalCollectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
}
