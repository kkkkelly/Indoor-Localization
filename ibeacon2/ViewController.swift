//
//  ViewController.swift
//  ibeacon2
//
//  Created by 陳芳瑩 on 2021/5/18.
//

import UIKit
import CoreLocation


struct Queue<String> {
  private var elements: [String] = []
  //var count = elements.count
    

  mutating func enqueue(_ value: String) {
    elements.append(value)
  }

  mutating func dequeue() -> String? {
    guard !elements.isEmpty else {
      return nil
    }
    return elements.removeFirst()
  }

  var head: String? {
    return elements.first
  }

  var tail: String? {
    return elements.last
  }
    //
    var countq: Int{
        return elements.count
    }

}


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var flag = 0
    
    var m1a = 0.0
    var m1r = 0
    var m2a = 0.0
    var m2r = 0
    var m3a = 0.0
    var m3r = 0
    
    var queue = Queue<String>()
    var q_list = [0,0,0,0,0,0,0,0,0,0,0]
    
    //database
    let database = [
        ["node":1,"M1R": -57.237288, "M1A": 3.270162, "M2R": -70.500000, "M2A": 18.014426, "M3R": -70.237288, "M3A": 13.772667],//"M3A": 15.772667
        ["node":2,"M1R": -58.431034, "M1A": 4.069739, "M2R": -73.578947, "M2A": 26.420462, "M3R": -66.206897, "M3A": 10.292472],
        ["node":3,"M1R": -60.631579, "M1A": 5.511689, "M2R": -69.224138, "M2A": 17.572351, "M3R": -67.571429, "M3A": 12.525454],
        ["node":4,"M1R": -61.000000, "M1A": 5.347962, "M2R": -67.214286, "M2A": 9.870832, "M3R": -64.491228, "M3A": 9.482230],//"M2A": 12.870832
        ["node":5,"M1R": -65.857143, "M1A": 8.909880, "M2R": -69.403509, "M2A": 13.802625, "M3R": -61.464286, "M3A": 5.570231],
        ["node":6,"M1R": -57.534483, "M1A": 8.647217, "M2R": -63.561404, "M2A": 7.885474, "M3R": -59.189655, "M3A": 4.420806],//M1A": 3.647217
        ["node":7,"M1R": -58.672414, "M1A": 4.101472, "M2R": -58.859649, "M2A": 3.863915, "M3R": -68.275862, "M3A": 13.801335],
        ["node":8,"M1R": -63.070175, "M1A": 7.064021, "M2R": -59.508772, "M2A": 4.297352, "M3R": -61.000000, "M3A": 5.891848],
        ["node":9,"M1R": -66.396552, "M1A": 10.489942, "M2R": -64.754386, "M2A": 5.925062, "M3R": -69.087719, "M3A": 12.023889],//"M2A": 7.925062,"M3A": 16.023889
        ["node":10,"M1R": -69.607143, "M1A": 14.099214, "M2R": -60.894737, "M2A": 5.049280, "M3R": -64.508772, "M3A": 8.973547],
        ["node":11,"M1R": -75.465517, "M1A": 34.995261, "M2R": -66.775862, "M2A": 10.955372, "M3R": -51.827586, "M3A": 1.678611]
        
    ]
    

    @IBOutlet weak var monitorResultTextView: UITextView!
    @IBOutlet weak var rangingResultTextView: UITextView!
    @IBOutlet weak var dataTextView: UITextView!
    
    let uuid = "87200F78-4201-4A4A-BD19-B7F8C5B7376D"
        //"8C38EF3C-32D9-4DFD-A86B-865E2C5A192C"
    //my"87200F78-4201-4A4A-BD19-B7F8C5B7376D"
    let identfier = "Kelly region"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways{
                locationManager.requestAlwaysAuthorization()
            }
        }
        let region = CLBeaconRegion(proximityUUID: UUID.init(uuidString: uuid)!, identifier: identfier)
        
        locationManager.delegate = self
        
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
    }

    @IBAction func collectdataPressed(_ sender: Any) {
        flag=1
        dataTextView.text = "start testing....\n"
        m1a = 0.0
        m1r = 0
        m2a = 0.0
        m2r = 0
        m3a = 0.0
        m3r = 0
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        monitorResultTextView.text = "did start monitoring \(region.identifier)\n" + monitorResultTextView.text
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        monitorResultTextView.text = "did enter\n" + monitorResultTextView.text
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        monitorResultTextView.text = "did exit\n" + monitorResultTextView.text
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            monitorResultTextView.text = "state inside\n" + monitorResultTextView.text
            if CLLocationManager.isRangingAvailable(){
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
            }
        case .outside:
            monitorResultTextView.text = "state outside\n" + monitorResultTextView.text
            manager.stopMonitoring(for: region)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        rangingResultTextView.text = ""
        let orderedBeaconArray = beacons.sorted(by: { (b1, b2) -> Bool in
            return b1.rssi > b2.rssi
        })
        var check = 0
        
        
        for beacon in beacons {
            var proximityString = ""
            switch beacon.proximity {
            case .far:
                proximityString = "far"
            case .near:
                proximityString = "near"
            case .immediate:
                proximityString = "immediate"
            default :
                proximityString = "unknow"
            }
            rangingResultTextView.text = rangingResultTextView.text +
                "Major: \(beacon.major) " +  "Minor: \(beacon.minor)" + " "+"RSSI: \(beacon.rssi)" + "\n" + "Proximity: \(proximityString)" + "\n" +
                "Accuracy: \(beacon.accuracy)" + "\n"
            
            //check if there are three beacons online
            if (beacons.count != 3 && flag != 0) {
                if flag==1{
                    dataTextView.text = dataTextView.text + "please press button again\n"
                    flag = 0
                }else {
                    dataTextView.text = dataTextView.text + "unknow\n"
                    //flag = flag-1
                    check = 0
                }
                break;
            }else{
                check = 1
            }
            
            
            //write data
            if flag != 0{
                /*
                dataTextView.text = dataTextView.text +
                    "Major: \(beacon.major)" + " Minor: \(beacon.minor)" + "\n" +
                    "RSSI: \(beacon.rssi)" + " Proximity: \(proximityString)" +
                    " Accuracy: \(beacon.accuracy)" + "\n";
                 */
                //average
                /*
                if beacon.minor == 1{
                    m1r = m1r + beacon.rssi
                    m1a = m1a + beacon.accuracy
                }else if beacon.minor == 2{
                    m2r = m2r + beacon.rssi
                    m2a = m2a + beacon.accuracy
                }else if beacon.minor == 3{
                    m3r = m3r + beacon.rssi
                    m3a = m3a + beacon.accuracy
                }
                */
                //queue+dictionary
                if beacon.minor == 1{
                    m1r = beacon.rssi
                    m1a = beacon.accuracy
                }else if beacon.minor == 2{
                    m2r = beacon.rssi
                    m2a = beacon.accuracy
                }else if beacon.minor == 3{
                    m3r = beacon.rssi
                    m3a = beacon.accuracy
                }
                
                
            }
            
        }
        
        
        if flag != 0 && check==1{
            location()
            flag = flag + 1;
        }
        
        /*
        if flag == 10 {
            testAverage()
            location()
            flag = 0
        }
        if flag != 0{
            dataTextView.text = dataTextView.text + "*\n"
            flag = flag + 1;
        }
        */
        
    }
    
    
    func testAverage(){
        m1a = m1a/Double(flag)
        m1r = m1r/flag
        m2a = m2a/Double(flag)
        m2r = m2r/flag
        m3a = m3a/Double(flag)
        m3r = m3r/flag
        dataTextView.text = dataTextView.text + "m1a = \(m1a)"+"\n" + "m1r = \(m1r)"+"\n" + "m2a = \(m2a)"+"\n" + "m2r = \(m2r)"+"\n" + "m3a = \(m3a)"+"\n" + "m3r = \(m3r)"+"\n"
    }
    
    func location(){
        // for difference
        //var dataArray = [[String:Any]]()
        var rssi1 = 0.0
        var acc1 = 0.0
        var rssi2 = 0.0
        var acc2 = 0.0
        var rssi3 = 0.0
        var acc3 = 0.0
        // weight from database
        var distance1 = 0.0
        var arr1 = [Double]()
        /*
        // same weight
        var distance2 = 0.0
        var arr2 = [Double]()
        //let k be weight
        var distance3 = 0.0
        var arr3 = [Double]()
        let k = 0.7
        */
        // Linear weight of Accuracy
        var distance4 = 0.0
        var arr4 = [Double]()
        
        for data in database{
            let M1Rdata = data["M1R"] ?? 0.0
            let M1Adata = data["M1A"] ?? 0.0
            let M2Rdata = data["M2R"] ?? 0.0
            let M2Adata = data["M2A"] ?? 0.0
            let M3Rdata = data["M3R"] ?? 0.0
            let M3Adata = data["M3A"] ?? 0.0
            //let Node = data["node"]?.hashValue
            
            //compare to database
            rssi1 = M1Rdata - Double(m1r)
            acc1 = M1Adata - m1a
            rssi2 = M2Rdata - Double(m2r)
            acc2 = M2Adata - m2a
            rssi3 = M3Rdata - Double(m3r)
            acc3 = M3Adata - m3a
            
            
            distance1 = abs(rssi1/M1Rdata)+abs(acc1/M1Adata)+abs(rssi2/M2Rdata)+abs(acc2/M2Adata)+abs(rssi3/M3Rdata)+abs(acc3/M3Adata)
            arr1.append(distance1)
            /*
            distance2 = abs(rssi1)+abs(acc1)+abs(rssi2)+abs(acc2)+abs(rssi3)+abs(acc3)
            arr2.append(distance2)
            
            distance3 = abs(rssi1)*(1.0-k) + abs(acc1)*k+abs(rssi2)*(1.0-k) + abs(acc2)*k + abs(rssi3)*(1.0-k) + abs(acc3)*k
            
            arr3.append(distance3)
            */
            
            //
            let max_A = 40.0
            var w1 = (max_A - m1a)/max_A
            if w1 < 0{
                w1 = 0
            }
            var w2 = (max_A - m2a)/max_A
            if w2 < 0{
                w2 = 0
            }
            var w3 = (max_A - m3a)/max_A
            if w3 < 0{
                w3 = 0
            }
            distance4 = w1*(abs(rssi1/M1Rdata)+abs(acc1/M1Adata))+w2*(abs(rssi2/M2Rdata)+abs(acc2/M2Adata))+w3*(abs(rssi3/M3Rdata)+abs(acc3/M3Adata))
            
            arr4.append(distance4)

                


            /*
            dataTextView.text = dataTextView.text+"\n"+"difference of m1r: \(rssi1),m1a: \(acc1)"+"\n"+"difference of m2r: \(rssi2),m2a: \(acc2)"+"\n"+"difference of m3r: \(rssi3),m3a: \(acc3)"+"\n distance1 : \(distance1)\n distance2: \(distance2)"
            */
            //dataArray.append(["name":data["node"],"M1R":rssi,"M1A":acc])
        }
        var minindex1 = 0
        var mindistance1 = 100.0
        var minindex2 = 0
        var mindistance2 = 100.0
        
        //dataTextView.text = dataTextView.text+"distance:\n"
        
        for (index, item) in arr1.enumerated() {
            
            //dataTextView.text = dataTextView.text+"node \(index+1):\n--\(item)\(arr4[index])\n"
            
            //calculate minimum
            if item<mindistance1{
                minindex1 = index+1
                mindistance1 = item
            }
            if arr4[index]<mindistance2{
                minindex2 = index+1
                mindistance2 = arr4[index]
                
            }
        }
        //dataTextView.text = dataTextView.text+"Near to node \(minindex1)\n"
        //dataTextView.text = dataTextView.text+"Near to node \(minindex2)\n"
        
        windows(num: minindex1)
        
        
    }
    func windows(num: Int)  {
        var maxnum = 0
        var maxindex = 0
        queue.enqueue("\(num)")
        q_list[num-1] = q_list[num-1]+1
        //dataTextView.text = dataTextView.text+"node:\(num) count in queue:\(queue.countq)\n"
        if queue.countq > 10{
            let delete = queue.dequeue()
            //dataTextView.text = dataTextView.text+"delete:"+delete!+"\n"
            let myInt2 = Int(delete!) ?? 0
            //dataTextView.text = dataTextView.text+"\(myInt2)\n"
            q_list[myInt2-1] = q_list[myInt2-1]-1
            //dataTextView.text = dataTextView.text+"\(q_list)\n"
            dataTextView.text = "\(q_list)\n"
            for (index, item) in q_list.enumerated() {
                if item>maxnum{
                    maxindex = index+1
                    maxnum = item
                }
            }
            if maxindex<5{
                dataTextView.text = dataTextView.text+"I am in the living room.\n"
            }else if maxindex>10{
                dataTextView.text = dataTextView.text+"I am in the Porch.\n"
            }else if maxindex==5{
                dataTextView.text = dataTextView.text+"I am in work area.\n"
            }else {
                dataTextView.text = dataTextView.text+"I am in the dining room.\n"
            }
            dataTextView.text = dataTextView.text+"Near to node\(maxindex)\n"
         
        }else{
            dataTextView.text = dataTextView.text+".\n"
        }
        
    }
    
    
    
}

