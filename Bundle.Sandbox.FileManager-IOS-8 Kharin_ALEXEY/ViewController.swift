
import UIKit
protocol UpdaterData {
    func updaterData()
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var contents: [URL]?
    
    var navigationControllerProperty: UINavigationController?
    
    @IBAction func popNavigation(_ sender: Any) {
        navigationControllerProperty?.popViewController(animated: true)
    }
    let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func addPicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickerImageUrl = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerImageURL")] as? URL, let pickerImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            
            let imageDocumentsUrl = documentsUrl.appendingPathComponent("Image - \(String(describing: pickerImage.description)) ")
            
            if !FileManager.default.fileExists(atPath: imageDocumentsUrl.path) {
                
                try? FileManager.default.copyItem(at: pickerImageUrl, to: imageDocumentsUrl)
                contents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                tableView.reloadData()
                print(pickerImage)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        contents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        let ascending = UserDefaults.standard.bool(forKey: Keys.BoolAscending.rawValue)
        let descending = UserDefaults.standard.bool(forKey: Keys.BoolDescending.rawValue)
        
        if ascending  {
            contents?.sort(by: { $1.path > $0.path })
            tableView.reloadData()
        } else if  descending {
            contents?.sort(by: { $1.path < $0.path })
            tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let removeItem = self.contents?[indexPath.row]
            guard let item = removeItem else { return }
            
            contents?.remove(at: indexPath.row)
            try? FileManager.default.removeItem(at: item)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let savetyContents = contents else { return 0 }
        
        return savetyContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        guard let savetyContents = contents else { return cell }
        let data = try! Data(contentsOf: savetyContents[indexPath.row])
        cell.imageView?.image = UIImage(data: data)
        cell.imageView?.contentMode = .scaleToFill
        cell.textLabel?.text = savetyContents[indexPath.row].path
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension ViewController: UpdaterData {
    
    func updaterData() {
        
        let ascending = UserDefaults.standard.bool(forKey: Keys.BoolAscending.rawValue)
        let descending = UserDefaults.standard.bool(forKey: Keys.BoolDescending.rawValue)
        
        if ascending  {
            contents?.sort(by: { $1.path > $0.path })
            tableView.reloadData()
        } else if descending {
            contents?.sort(by: { $1.path < $0.path })
            tableView.reloadData()
        }
    }
}
