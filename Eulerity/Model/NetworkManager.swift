//
//  Network.swift
//  Eulerity
//
//  Created by Chris Park on 11/10/21.
//

import Foundation
import UIKit

protocol NetworkManagerProtocol {
    func loadImageData(completion: @escaping (Result<[Image], NetworkError>) -> Void)
    func loadUploadURL(completion: @escaping (Result<Url, NetworkError>) -> Void)
    func uploadImage(uploadURL: String, appid: String, original: String, fileName: String, image: UIImage?, completion: @escaping (Result<String, NetworkError>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    private let urlString = "http://eulerity-hackathon.appspot.com/"
    private var task: URLSessionDataTask?
    private let fields = ["appid", "file", "original"]
    
    func loadImageData(completion: @escaping (Result<[Image], NetworkError>) -> Void) {
        guard let url = URL(string: urlString + "image") else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }
        
        task?.cancel()
        
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.failedToRetrieveData))
                }
                return
            }
            
            do {
                let jsonResults = try JSONDecoder().decode([Image].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(jsonResults))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.failedToRetrieveData))
                }
            }
        }
        
        task?.resume()
    }
    
    func loadUploadURL(completion: @escaping (Result<Url, NetworkError>) -> Void) {
        guard let url = URL(string: urlString + "upload") else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }
        
        task?.cancel()
        
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.failedToRetrieveData))
                }
                return
            }
            
            do {
                let jsonResults = try JSONDecoder().decode(Url.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(jsonResults))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.failedToRetrieveData))
                }
            }
        }
        
        task?.resume()
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        var data = Data()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")

        return data
    }
    
    // Uploads file to given URL
    func uploadImage(uploadURL: String, appid: String, original: String, fileName: String, image: UIImage?, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let image = image,
              let fileData = image.jpegData(compressionQuality: 0),
              let url = URL(string: uploadURL) else {
                  completion(.failure(.failedToUploadData))
                  return
              }
        let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var httpBody = Data()

        httpBody.appendString(convertFormField(named: fields[0], value: appid, using: boundary))
        httpBody.append(convertFileData(fieldName: fields[1], fileName: fileName, mimeType: "image/jpeg", fileData: fileData, using: boundary))
        httpBody.appendString(convertFormField(named: fields[2], value: original, using: boundary))
        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                DispatchQueue.main.async {
                    completion(.success("Successfully uploaded image!"))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.failedToUploadData))
                }
            }
        }.resume()
    }
}
