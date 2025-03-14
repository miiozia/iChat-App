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
    //MARK: - Images
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
           
            if let contentsOfFile = UIImage(contentsOfFile: filesFromDocDirectory(fileName: imagefileName)){
                completion(contentsOfFile)
            }else {
                print("Could not convert local image")
                completion(UIImage(named: "avatar" ))
            }
            
        }else {
            //download from firebase
            print("Get it form firebase ")
            
            if imageUrl != ""{
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        
                        //saving locally
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
    
    
    
    //MARK: - Video
    
    class func videoUpload(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        
        let storagReference = storage.reference(forURL: kFILTERREFERENCE).child(directory)
        
        var task: StorageUploadTask!
        
        task = storagReference.putData(video as Data, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error when uploading video \(error!.localizedDescription)")
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
    
    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool,_ videoFileName: String)-> Void){
        
        let videoURL = URL(string: videoLink)
      let videofileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if filesAtPath(path: videofileName){
            completion(true, videofileName)
            
        }else{
                let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: videoURL!)
                    if data != nil {
                        
                        //saving locally
                        StorageFirebase.localSaveFile(fileDate: data!, fileName: videofileName)
                        DispatchQueue.main.async {
                            completion(true,videofileName)
                        }
                        
                    }else {
                        print("There is no document in database")
                       
                    }
                }
            }
        }
    
    //MARK: - Audio
    class func audioUpload(_ audioName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        let fileName = audioName + ".m4a"
        
        let storageReference = storage.reference(forURL: kFILTERREFERENCE).child(directory)
        
        var task: StorageUploadTask!
        
        if filesAtPath(path: fileName){
            if let audioData = NSData(contentsOfFile: filesFromDocDirectory(fileName: fileName)){
                
                task = storageReference.putData(audioData as Data, metadata: nil, completion: { (metadata, error) in
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("Error when uploading audio \(error!.localizedDescription)")
                        return
                    }
                    storageReference.downloadURL { (url, error) in
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
            } else{
                print("Error, nothing to upload")
            }
        }
    }
    
    class func downloadAudio(audioLink: String, completion: @escaping (_ audioName: String)-> Void){
        
        
      let audioName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        
        if filesAtPath(path: audioName){
            completion(audioName)
        }else{
                let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: URL(string: audioLink)!)
                    
                    if data != nil {
                        //saving locally
                        StorageFirebase.localSaveFile(fileDate: data!, fileName: audioName)
                        DispatchQueue.main.async {
                            completion(audioName)
                        }
                        
                    }else {
                        print("There is no audio document in database")
                    }
                }
            }
        }

    
//MARK: -  saving locally
    class func localSaveFile(fileDate: NSData, fileName: String){
       let docUrl = getURL().appendingPathComponent(fileName, isDirectory: false )
        fileDate.write(to: docUrl, atomically: true)
    }
}


//MARK: - Helpers
func filesFromDocDirectory(fileName: String) -> String{
    return getURL().appendingPathComponent(fileName).path
}

func getURL() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func filesAtPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: filesFromDocDirectory(fileName: path))
}
