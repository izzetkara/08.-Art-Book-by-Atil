//
//  detailsVC.swift
//  Art Book
//
//  Created by İzzet Kara on 26.06.2019.
//  Copyright © 2019 Izzet Kara. All rights reserved.
//

import UIKit
import CoreData
class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenPainting = ""
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenPainting != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            //datayi yakalamasi icin asagidaki kodu yaziyorum.
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
            
            fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting) //xcdatamodeld de name in nereye esit oldugunu bul demek.
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
            let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        nameText.text = self.chosenPainting
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data:  imageData)
                            self.imageView.image = image
                        }
                        
                    }
                }
                
                
            } catch {
                
            }
            
            
            
            
        }
        
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailsVC.selectImage)) //Önemli: Burada UITapGestureRecognizer'da Tap ı unuttuğum için galeriyi açamadım. Keyfim kaçtı. Ama şimdi mutlu oldum. Bu sorunu gördüğümde bir daha unutmam.
        imageView.addGestureRecognizer(gestureRecognizer)
       
        print(chosenPainting)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Pictures", into: context)
        
        //attributes
        
        newArt.setValue(artistText.text, forKey: "artist")
        newArt.setValue(nameText.text, forKey: "name")
        
        if let year = Int(yearText.text!) {
            
            newArt.setValue(year, forKey: "year")
        }
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5) // 0.5 boyutu yarıya indirdim. zipledim gibi birşey.
        newArt.setValue(data, forKey: "image")
       
        do {
            try context.save()
            print("No Error")
        } catch {
            print("Error")
        }
        //try and catch formatı
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPicture"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    


    
}
