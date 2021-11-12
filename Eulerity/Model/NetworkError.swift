//
//  NetworkError.swift
//  Eulerity
//
//  Created by Chris Park on 11/10/21.
//

import Foundation

enum NetworkError: String, Error {
    case invalidURL = "Invalid URL!"
    case failedToRetrieveData = "Failed to retrieve data!"
    case failedToUploadData = "Failed to upload image!"
}
