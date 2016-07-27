//
//  ThirdViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/13.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit
import HealthKit

class ThirdViewController: UIViewController {
    let healthKitStore:HKHealthStore = HKHealthStore()
   
    @IBOutlet weak var stepLab: UILabel!
    @IBOutlet weak var heightLab: UILabel!
    @IBOutlet weak var weightLab: UILabel!
    @IBOutlet weak var songSegCont: UISegmentedControl!
    
    var step, height, weight:HKQuantitySample?
    var songManager = HHSongManager(fileName: "haha")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit { (success, error) in
            if success {
                self.getStep()
                self.getHeight()
                self.getWeight()
            } else {
                
            }
        }
        songSegCont.selectedSegmentIndex = songManager.type.rawValue
    }
    
    @IBAction func songChanged(sender: UISegmentedControl) {
        if let type = HHSongType(rawValue: sender.selectedSegmentIndex) {
            debugPrint("\(type)")
            songManager.type = type
        }
    }
    
    @IBAction func playSong(sender: AnyObject) {
        songManager.playSong()
    }
    
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
    {
        // 1. Build the Predicate
        let past = NSDate.distantPast() as NSDate
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            if let queryError = error {
                completion(nil,queryError)
                return;
            }
            // Get the first sample
            let mostRecentSample = results!.first as? HKQuantitySample
            // Execute the completion closure
            if completion != nil {
                completion(mostRecentSample,nil)
            }  
        }  
        // 5. Execute the Query  
        self.healthKitStore.executeQuery(sampleQuery)  
    }
    
    func readStep(startTime:NSDate, endTime:NSDate,completion: ((Int!, NSError!) -> Void)!) {
        debugPrint("\(startTime.yyyyMMddHHmmss()) \(endTime.yyyyMMddHHmmss())")
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startTime, endDate:endTime, options: .None)
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)

        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 0, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            if let queryError = error {
                completion(nil,queryError)
                return;
            }
            // Get the first sample
//            let mostRecentSample = results!.first as? HKQuantitySample
//            // Execute the completion closure
            var count = 0
            for sample in results! {
                let step = sample as! HKQuantitySample
                let cur = step.quantity.doubleValueForUnit(HKUnit.countUnit())
                count += Int(cur)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if completion != nil {
                    completion(count,nil)
                }
            })
            
        }
        // 5. Execute the Query
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func getStep() {
        readStep(NSDate().initial(), endTime: NSDate().initial().nextDay()) { (count, error) in
            if count != nil {
                self.stepLab.text = "今日步数：\(count) 步"
            }
        }
    }
    
    func getHeight() {
        
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        // 2. Call the method to read the most recent weight sample
        readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            if( error != nil )
            {
                debugPrint("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            var heightLocalizedString = "身高：Unknown"
            // 3. Format the weight to display it on the screen
            self.height = mostRecentWeight as? HKQuantitySample;
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                let heightFormatter = NSLengthFormatter()
                heightFormatter.forPersonHeightUse = true;
                heightLocalizedString = heightFormatter.stringFromMeters(meters)
            }
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.heightLab.text = "身高：" + heightLocalizedString
                //                self.updateBMI()
            });
        });
    }
    
    func getWeight() {
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        // 2. Call the method to read the most recent weight sample
        readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            if( error != nil )
            {
                debugPrint("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            var weightLocalizedString = "Unknown"
            // 3. Format the weight to display it on the screen
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.weightLab.text = "体重：" + weightLocalizedString
                //                self.updateBMI()
            });
        });
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
//            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
//            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
//            HKObjectType.workoutType()
            ])
        // 2. Set the types you want to write to HK Store
//        let healthKitTypesToWrite = Set([
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
//            HKQuantityType.workoutType()
//            ])
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if( completion != nil )  
            {  
                completion(success:success,error:error)  
            }  
        }  
    }
}
