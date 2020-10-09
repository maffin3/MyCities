//
//  CityNetDownloadStack.swift
//  MyCities
//
//  Created by Maciej Czech on 06/10/2020.
//

import UIKit

protocol CityNetDownloadStackDelegate: AnyObject {
    func cityImageDidDownloadFor(cityId: Int)
}


class CityNetDownloadStack: NSObject {
    
    weak var delegate:CityNetDownloadStackDelegate?

    var downloadSession:URLSession?
    var imgBaseUrlString:String?
    
    init(imgBaseUrlString:String, delegate:CityNetDownloadStackDelegate?, bgSessionId:String) {
        super.init()
        
        // set base image url path
        self.imgBaseUrlString = imgBaseUrlString
        self.delegate = delegate
        
        // configure url session
        let configuration = URLSessionConfiguration.background(withIdentifier:bgSessionId)
        configuration.allowsCellularAccess = true
                                                                                        
        self.downloadSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    // MARK:- External

    
    /// Download city pictures for array of cities
    /// - Parameter cities: array of cities to download picture for
    func downloadImagesForCities(cities: [CityData]) {
        for (_, item) in cities.enumerated() {
            downloadImageFor(city: item, force: false)
        }
    }
    
    
    /// Download city picture for a single city
    /// - Parameters:
    ///   - city: city object to download picture for
    ///   - force: if false, it will not download the picture again if it already exists
    func downloadImageFor(city:CityData, force:Bool) {

        // assumed file cache policy not to download again when downloaded already if not forced
        if !force && city.cityPicture() != nil {
            return
        }
        
        // create a download task in url session
        let downloadTask = self.downloadSession?.downloadTask(with: city.imageRemoteURL(baseImageRemotePath: self.imgBaseUrlString!)!)
        
        // set taskDescription, which can be used for custom usage - here additional verification when downloaded
        downloadTask?.taskDescription = String(city.cityId)
        
        // start download
        downloadTask?.resume()
    }
}

//
// MARK: - URL Session Delegate
//
extension CityNetDownloadStack: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

//
// MARK: - URL Session Download Delegate
//
extension CityNetDownloadStack: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        // get original request
        guard let sourceURL = downloadTask.originalRequest?.url else {
             return
        }
        
        // generate local path based on original request
        let destinationURL = CityData.imageFilePath(for: sourceURL)
        
        // remove if file already exists at the specified location
        let fileManager = FileManager.default
        
        if fileManager.isReadableFile(atPath: location.absoluteString) {
            print("downloaded file exists")
        }
        try? fileManager.removeItem(at: destinationURL)
        
        // copy to target location
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        // notify delegate
        if let cityId = Int(downloadTask.taskDescription ?? "") {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.cityImageDidDownloadFor(cityId: cityId)
            }
        }
    }
  
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
    }
}
