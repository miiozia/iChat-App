//
//  StorageFile.swift
//  iChat
//
//  Created by Marta Miozga on 04/10/2024.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class StorageFirebase {
    class func imageUpload(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storagReference = storage.reference(forURL: kFILTERREFERENCE).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.5)
        var task: StorageUploadTask!
        task = storagReference.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error when uploading image \(error!.localizedDescription)")
                return
            }
            storagReference.downloadURL { (url, error) in
                guard let downloadURL = url else{
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?)-> Void){
      let imagefileName = fileNameFrom(fileUrl: imageUrl)
        
        if filesAtPath(path: imagefileName){
            //get it locally
            print("We have local image")
            if let contentsOfFile = UIImage(contentsOfFile: filesFromDocDirectory(fileName: imagefileName)){
                completion(contentsOfFile)
                
            }else {
                print("Could not convert local image")
                completion(UIImage(named: "avatar" ))
            }
            
        }else {
            //download from direbase
            print("Get it form firebase ")
            
            if imageUrl != ""{
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        
                        //saving locally
                        //filestorage and saveFirleLocally - inne nazwy usun!!
                        StorageFirebase.localSaveFile(fileDate: data!, fileName: imagefileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    }else {
                        print("There is no document in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                       
                    }
                }
            }
        }
    }
    
    
    //Mark: saving locally
    class func localSaveFile(fileDate: NSData, fileName: String){
       let docUrl = getURL().appendingPathComponent(fileName, isDirectory: false )
        
        fileDate.write(to: docUrl, atomically: true)
    }
   
}


//MARK: Helpers
func filesFromDocDirectory(fileName: String) -> String{
    return getURL().appendingPathComponent(fileName).path
}

func getURL() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func filesAtPath(path: String) -> Bool{
    var isExist = false
    let filePath = filesFromDocDirectory(fileName: path)
    let fileManager = FileManager.default
    
    isExist = fileManager.fileExists(atPath: filePath)
    
    return isExist
    
  //  return FileManager.default.fileExists(atPath: filesFromDocDirectory(fileName: path))
    
}
