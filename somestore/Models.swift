
//
//  Models.swift
//  somestore
//
//  Created by Kanat A on 12/03/2017.
//  Copyright © 2017 ak. All rights reserved.
//

import UIKit

class FeaturedApps: NSObject {
    // контейнер обжект (вместо общего массива для всех категорий)
    
    var bannerCategory: AppCategory?
    var appCategories: [AppCategory]?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "categories" {
            appCategories = [AppCategory]()
            
            // раскидаем по items
            for dict in (value as? [[String:Any]])! {
                let appCategory = AppCategory()
                appCategory.setValuesForKeys(dict)
                appCategories?.append(appCategory)
            }
        } else if key == "bannerCategory" {
            bannerCategory = AppCategory()
            // для header
            bannerCategory?.setValuesForKeys(value as! [String : Any])
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

class AppCategory: NSObject {
    
    var name: String?
    var category: String?
    
    // data source for items
    var apps: [App]?
    
    var type: String?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "apps" {
            // зайдем в apps и раскидаем его по items
            apps = [App]()
            for dict in value as! [[String: AnyObject]] {
                let app = App()
                app.setValuesForKeys(dict)
                apps?.append(app)
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    static func fetchFeaturedApps(completionHandler: @escaping (FeaturedApps)->() ) {
         let urlString = "https://api.myjson.com/bins/rb2gf"
        
        URLSession.shared.dataTask(with: URL(string: urlString)! ) { (data, responce, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? [])
                return
            }
            
            do {
                let json = try(JSONSerialization.jsonObject(with: data!, options: .mutableContainers))  as? [String:Any]
                
                let featuredApps = FeaturedApps()
                
                // весь json распределим по ключам
                featuredApps.setValuesForKeys(json!)
  
                DispatchQueue.main.async {
                    completionHandler(featuredApps)
                }
                
            } catch let err {
                print(err)
            }
    
        }.resume()
    }
    
    
    // хард код
    static func bestNewAppsCategory() -> [AppCategory] {
        
        let bestCategory = AppCategory()
        bestCategory.name = "Best new category"
        
        let bestCategory2 = AppCategory()
        bestCategory2.name = "Best new game"
        
        var apps = [App]()
        var apps2 = [App]()
        
        let frozenApp = App()
        frozenApp.name = "Disney Channel Build It"
        frozenApp.imageName = "frozen"
        frozenApp.price = NSNumber(value: 5.99)
        frozenApp.category = "Games"
        apps.append(frozenApp)
        
        let frozenApp2 = App()
        frozenApp2.name = "Apple build it"
        frozenApp2.imageName = "starwars"
        frozenApp2.price = NSNumber(value: 4.07)
        frozenApp2.category = "Games"
        apps2.append(frozenApp2)
        
        bestCategory.apps = apps
        bestCategory2.apps = apps2
        
        return [bestCategory, bestCategory2]
    }
}

class App: NSObject {
    
    var id: NSNumber?
    var name: String?
    var category: String?
    var imageName: String?
    var price: NSNumber?
    
    var screenshots: [String]?
    var desc: String?
    var appInformation: AnyObject?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "description" {
            // тк "desc" не совпадает с "description"
            self.desc = value as! String?
        } else  {
            super.setValue(value, forKey: key)
        }
    }
}



/*
 static func fetchFeaturedApps(completionHandler: @escaping ([AppCategory])->() ) {
 
 let urlString = "https://api.myjson.com/bins/rb2gf"
 
 URLSession.shared.dataTask(with: URL(string: urlString)! ) { (data, responce, error) in
 
 if error != nil {
 print(error?.localizedDescription ?? [])
 return
 }
 
 do {
 let json = try(JSONSerialization.jsonObject(with: data!, options: .mutableContainers))  as? [String:Any]

 var appCategories = [AppCategory]()
 for dictionary in (json?["categories"] as? NSArray)! {
 let appCategory = AppCategory()
 // appCategory's properties == keys
 appCategory.setValuesForKeys(dictionary as! [String : Any])
 appCategories.append(appCategory)
 }
 
 DispatchQueue.main.async {
 completionHandler(appCategories)
 }
 
 } catch let err {
 print(err)
 }
 
 }.resume()
 }
 */

