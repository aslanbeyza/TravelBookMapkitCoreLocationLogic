//
//  ListViewController.swift
//  TravelBook
//
//  Created by Beyza Aslan on 26.02.2025.
//

import UIKit
import CoreData //Core dataya kaydettirdiğimiz verileri burda göstermek istiyorum o yüzden import ettirdim

class ListViewController: UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {  //viewDidLoad sadece bir kere çağırılıyodu
        super.viewDidLoad()
        //tableView ayarlarını yapalım
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)                                                              //önceki sayfada  ne yazdıysak aynısını yazmalı
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false) //Duplice şeyler olmasın diye
                self.idArray.removeAll(keepingCapacity: false) //Duplice şeyler olmasın diye
                for result in results as! [NSManagedObject] {
                    if let title  = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                    
                }
            }
        } catch  {
            print("Hata: \(error)")
        }
    }
    
    @objc func addButtonClicked(){
        print("Add butonuna tıklandı")
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = UITableViewCell()
          cell.textLabel?.text = titleArray[indexPath.row] //titlearraydeki index patte ne varsa onu göster kardesim demek buda
          return cell

      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = titleArray[indexPath.row]
        let selectedPlaceID = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toViewController", sender: (selectedPlace, selectedPlaceID))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            if let destinationVC = segue.destination as? ViewController {
                if let (selectedPlace, selectedPlaceID) = sender as? (String, UUID) {
                    destinationVC.selectedTitle = selectedPlace
                    destinationVC.selectedTitleID = selectedPlaceID
                }
            }
        }
    }

}
