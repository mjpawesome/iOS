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
    
    var blockOperations = [BlockOperation]()
    private lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nickname", ascending: false)]
        let mainContext = CoreDataManager.shared.mainContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error Fetching -> HomeVC in fetchedResultsController: \(error)")
        }
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendUserToLoginIfNecessary()
        setupInitialViews()
        print(fetchedResultsController.fetchedObjects?.first?.species) // this print statement can be used to check which properties of the core data object are saving
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
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
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
            return 10
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == horizontalCollectionView {
            let horizontalCell = horizontalCollectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! HorizontalCVCell
            // TODO: call to load the image
            stylizeCell(horizontalCell)
            return horizontalCell
        } else { // verticalCollectionView
            let  verticalCell = verticalCollectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCVCell
            // TODO: call to load the image
            let plant = fetchedResultsController.fetchedObjects?[indexPath.row]
            if let plantImage = plant?.imageURL { verticalCell.imageView.downloaded(from: plantImage) }
            if let plantNickname = plant?.nickname { verticalCell.nicknameLabel.text = plantNickname }
            stylizeCell(verticalCell)
            return verticalCell
        }
    }
        /// Used to style the cells if there are many tweaks done to the cell. Otherwise this method may not be neccasary.
        func stylizeCell(_ cell: UICollectionViewCell) {
            cell.layer.cornerRadius = 12
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
            let plant = fetchedResultsController.fetchedObjects?[indexPath.row]
            detailVC.plantNicknameLabel?.text = plant?.nickname ?? "No name"
            if let plantImage = plant?.imageURL {
                detailVC.imageView.downloaded(from: plantImage)
            }
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
                        self.verticalCollectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.verticalCollectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(String(describing: indexPath))")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.verticalCollectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(String(describing: indexPath))")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.verticalCollectionView!.deleteItems(at: [indexPath!])
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
                        self.verticalCollectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.verticalCollectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.verticalCollectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
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
