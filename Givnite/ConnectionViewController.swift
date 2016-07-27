//
//  ConnectionViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/27/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase



class ConnectionViewController: UIViewController,UITableViewDelegate {
    
    
    let databaseRef = FIRDatabase.database().reference().child("https://givniteapp.firebaseio.com/")
    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp.appspot.com")
    let user = FIRAuth.auth()?.currentUser
    var numberOfRows: Int!
    
    var userIDArray = [String]()
    var connectedArray = [Int]()
    
    var connections = [User]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Connection"

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let connectionRef = databaseRef.child(user!.uid).child("connection")
        
        connectionRef.observeEventType(FIRDataEventType.Value, withBlock:{ (snapshot) -> Void in
            
            if let connections = snapshot.value! as? NSDictionary {
                self.numberOfRows = connections.count
                
                let allKeys = connections.allKeys as? [String]
                let allValues = connections.allValues as? [Int]
                
                self.userIDArray = allKeys!
                self.connectedArray = allValues!
                
                self.getsTheConnections()
              
                
                self.tableView.reloadData()
            }
            
            
        })

    }
    
    func getsTheConnections() {
        databaseRef.child("user").observeEventType(FIRDataEventType.Value, withBlock:{ (snapshot) -> Void in
          
            for user in self.userIDArray {
                
                if let userInfo = snapshot.value![user] as? NSDictionary {
                    
                    var someUser:User!
                    
                    if let name = userInfo["name"] as? String {
                        someUser.name = name
                    }
                    
                    if let school = userInfo["school"] as? String {
                        someUser.school = school
                    }
                    
                    if let image = userInfo["picture"] as? String {
                        
                        
                        if let image = NSCache.sharedInstance.objectForKey(user) as? UIImage{
                            someUser.picture = image
                        }

                        else {
                        
                            let profilePicRef = self.storageRef.child(user).child("profile_pic.jpg")
                            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                                if (error != nil) {
                                    // Uh-oh, an error occurred!
                                } else {
                                    var cacheImage = UIImage(data: data!)
                                    someUser.picture = cacheImage
                                    NSCache.sharedInstance.setObject(cacheImage!, forKey: user)
                                }
                            }
                        }

                        
                    }
                }
                
            }

            
        })
    }
  
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")! as! ChatTableViewCell
    
        return cell
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
