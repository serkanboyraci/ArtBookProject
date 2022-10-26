//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Ali serkan Boyracı  on 22.09.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var nameArray = [String]() // to use it fast, we tak only name and UUID data.
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
       
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked1))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) { //viewDidLoad works only one but viewWillAppear works every VC opens.
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil) // to use same thing with DetailsVC
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration  = content
        return cell
    }
    
                                                                                          
    @objc func addButtonClicked1() {
        selectedPainting = "" //to say, nothing selected
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
            
    }
    
    // to take data from AppDelegate
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false) // to see data only one time
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false //to do it fast in big data
        
        //if you can take error, you have to use it do-try-catch
        do {
            let results = try context.fetch(fetchRequest) //to fetch the data
            
            if results.count > 0 { // you should do this
                
                for result in results as! [NSManagedObject] { //all data in results(objectType), we want to take only name and id, we can easily take it if let structure and append it nameArray
                    if let name = result.value(forKey:"name") as? String {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    self.tableView.reloadData() //after taking new data, to refresh and show new data
                    
                }
                
                
                
            }
            
           
            
        } catch {
            print("ERROR!")
        }
      
        
    }
    
    //to send data DetailsVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row] // to say, there is selected painting.
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // to take selected data to delete
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            // to delete only one item
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                context.delete(result) //after this deleting from core data, no push back
                                nameArray.remove(at: indexPath.row) // to remove from index
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData() //reload tableview
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                
                                break // if u use name instead of id, name can be same with other items. id can't be same other ones.
                                // this is very safe side. to end for loop.
                                
                            }
                        }
                    }
                }
                
            } catch {
                
            }
            
            
            
            
        }
    }
    

                                                                                          

}

