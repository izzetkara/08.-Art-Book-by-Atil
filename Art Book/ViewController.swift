//
//  ViewController.swift
//  Art Book
//
//  Created by İzzet Kara on 26.06.2019.
//  Copyright © 2019 Izzet Kara. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
   

    @IBOutlet weak var tableView: UITableView!
    
    //Normalde burada 4 array tanimlamak mantiksiz. Cunku tableview de sadece isimler gozukecek. Sadece name arrayi tanimlayip uzerine tiklandiginda diger verileri almak daha mantikli.
    var nameArray = [String]()
    var artistArray = [String]()
    var yearArray = [Int]()
    var imageArray = [UIImage]()
    var selectedPainting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getInfo()
    }
    
    //viewWillAppear fonksiyonu her zaman ViewControlleri gordugumuzde o ekrani cagiriyor.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getInfo), name: NSNotification.Name("newPicture"), object: nil)
    }
    
    
    @objc func getInfo() {
        
        nameArray.removeAll(keepingCapacity: false)
        yearArray.removeAll(keepingCapacity: false)
        artistArray.removeAll(keepingCapacity: false)
        imageArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //datayi yakalamasi icin asagidaki kodu yaziyorum.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    
                    if let artist = result.value(forKey: "artist") as? String {
                        self.artistArray.append(artist)
                    }
                    
                    if let year = result.value(forKey: "year") as? Int {
                        self.yearArray.append(year)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data { //data olarak alip sonradan image e ceviricez
                        let image = UIImage(data: imageData)
                        self.imageArray.append(image!)
                    }
                    
                    self.tableView.reloadData()
                    
                }
            }
            
        } catch {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! detailsVC
            destinationVC.chosenPainting = selectedPainting
        
            
        }
    }
    //sola cekince silme islemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String {
                        if name == nameArray[indexPath.row] {
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            artistArray.remove(at: indexPath.row)
                            yearArray.remove(at: indexPath.row)
                            imageArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            //do try catch i tekrar yazmamizi istiyor.
                            
                            do {
                                try context.save()
                            } catch {
                                
                            }
                            break //bunun anlami for loop u kir bunu yapmazsam ne olur bosuna calisir.
                        }
                    }
                }
            } catch {
                
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    
    
    
}

