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
            let plant = fetchedResultsController.object(at: indexPath)
            if let plantImage = plant.imageURL {
                verticalCell.imageView.downloaded(from: plantImage)
            }
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
    }
    
}

// MARK: - FRC delegate
extension HomeVC: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        verticalCollectionView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        verticalCollectionView.endUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                    didChange sectionInfo: NSFetchedResultsSectionInfo,
//                    atSectionIndex sectionIndex: Int,
//                    for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            verticalCollectionView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
//        case .delete:
//            verticalCollectionView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
//        default:
//            break
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                    didChange anObject: Any,
//                    at indexPath: IndexPath?,
//                    for type: NSFetchedResultsChangeType,
//                    newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            guard let newIndexPath = newIndexPath else { return }
//            verticalCollectionView.insertRows(at: [newIndexPath], with: .automatic)
//        case .update:
//            guard let indexPath = indexPath else { return }
//            verticalCollectionView.reloadRows(at: [indexPath], with: .automatic)
//        case .move:
//            guard let oldIndexPath = indexPath,
//                let newIndexPath = newIndexPath else { return }
//            verticalCollectionView.deleteRows(at: [oldIndexPath], with: .automatic)
//            verticalCollectionView.insertRows(at: [newIndexPath], with: .automatic)
//        case .delete:
//            guard let indexPath = indexPath else { return }
//            verticalCollectionView.deleteRows(at: [indexPath], with: .automatic)
//        @unknown default:
//            break
//        }
//    }
}
