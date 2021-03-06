import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import AVKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    var table = [Videos]()
    var ref: DatabaseReference!
    
    
    @IBOutlet weak var Tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("videos")
        
        ref.observe(DataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                self.table.removeAll()
                
                for video in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let Object = video.value as? [String: AnyObject]
                    let Title = Object?["Title"]
                    let videolink = Object?["link"]
                    
                    let video = Videos(Title: Title as! String, link: videolink as! String)
                    self.table.append(video)
                    
                    self.Tableview.reloadData()
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Tableview.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        let video: Videos
        
        video = table[indexPath.row]
        cell.titleLabel.text = video.Title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let videoURL = URL(string: table[indexPath.row].link!) else {
            return
        }
        
        let player = AVPlayer(url: videoURL)
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            player.play()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
