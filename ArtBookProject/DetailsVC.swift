//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Ali serkan Boyracı  on 22.09.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  { // you have to add these libraries. to back and forth activity in VC's.
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var artistText: UITextField!
    @IBOutlet var yearText: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true // to hide save button
            
            //Core Data
            
            //to see UUID
            //let stringUUID = chosenPaintingId!.uuidString
            //print(stringUUID)
            // to take data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            // to adding filter
            
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!) //format= %@ means = CVARG means id=%@ = idstring
    
            fetchRequest.returnsObjectsAsFaults = false
           
            do {
                let results = try context.fetch(fetchRequest) //gives object, you should do it for loop
                if results.count > 0 { //you should do this
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data { //we define in .xcdatamodeld as binarydata
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                        
                        
                    }
                    
                }
                
                
            } catch {
                
            }
            
            
            
            
        } else {
            
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            
            
        }
        
        
        

        //Recognizers
        //close keyboard-cant open again
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true //to enable to user tapped to image
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
    }
    

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() { //to go to the photo gallery
        let picker = UIImagePickerController()
        picker.delegate = self // to use picker functions
        picker.sourceType = .photoLibrary //to take data source
        picker.allowsEditing = true //to edit photo
        present(picker, animated: true)
    }
    
    // after selecting photo, to go back VC
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage //you can select .originalImage or editedImage
        
        saveButton.isEnabled = true // to save button activated
        self.dismiss(animated: true, completion: nil) // to close selecting window (picker)
    }
    
    
    
    
    
    @IBAction func saveClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // to reach AppDelegate funcitons and give it a variable
        let context = appDelegate.persistentContainer.viewContext // after reaching functions to use supporting functions.
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context) //we named Paintings in .xcdatamodeld
        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!) { //if user enters false data.
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id") // it gives id automatically
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5) //to reduce photo quality
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("SAVED")
        } catch {
            print("ERROR")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil) // to send notification to other VC
        //other VC taking notification after we give them other duty.

        self.navigationController?.popViewController(animated: true) // to go back previous VC, but can't see new saved items.

        

        
        
    }
    
    

 

}
