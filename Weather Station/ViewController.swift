//
//  ViewController.swift
//  Weather Station
//
//  Created by Buliga Alexandru on 15.03.2021.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let daysOfWeek : [String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var daysValues: [DayWeek] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempText: UILabel!
    @IBOutlet weak var humText: UILabel!
    var liveDataRef: DatabaseReference! = Database.database().reference()
    var daysDataRef: DatabaseReference! = Database.database().reference()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myGroup = DispatchGroup()
        
        _ = liveDataRef.child("Live").observe(DataEventType.value, with: { (snapshot) in
            let data = snapshot.value as? [String : Int] ?? [:]
            
            if let temp = data["temp"]{
                print(temp)
                self.tempText.text = String(temp)
            }
            if let hum = data["hum"]{
                print(hum)
                self.humText.text = String(hum)
            }
            
            
            
        }) { (error) in
            print("EROARE:\(error)")
        }
        
        
        for day in daysOfWeek{
            myGroup.enter()
            daysDataRef.child("Days").child("\(day)").observeSingleEvent(of: .value, with: { snapshot in
                
                let data = snapshot.value as? [String : Int] ?? [:]
                let newDay = DayWeek(hTemp: String(data["hTemp"]!), hHum: String(data["hHum"]!), lTemp: String(data["lTemp"]!), lHum: String(data["lHum"]!))
                self.daysValues.append(newDay)
                
                
                myGroup.leave()
            }) { (error) in
                print("EROARE:\(error)")
            }
        }
        myGroup.notify(queue: .main)
        {
            self.tableView.reloadData()
            for
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! weatherCell
        if !daysValues.isEmpty{
            cell.dayLabel.text = daysOfWeek[indexPath.row]
            cell.highTemp.text = daysValues[indexPath.row].hTemp
            cell.lowTemp.text = daysValues[indexPath.row].lTemp
            cell.highHum.text = daysValues[indexPath.row].hHum
            cell.lowHum.text = daysValues[indexPath.row].lHum
        }
        return cell
    }
    
    
}
