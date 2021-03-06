//
//  NumberPlateRecognizerService.swift
//  Wegli
//
//  Created by Eugen Pirogoff on 26.11.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Foundation
import OpenALPRSwift

enum NumberPlateRecognizerError: String, Error {
    case someError = "Some error in openALPR."
    case noPlateFound = "No plate found."
    case noMatchingPlateFound = "No matching plate found, set confidence delimiter lower."
}

enum NumberPlateRecognizerRegionPattern: String {
    case de = "de"
}

enum NumberPlateRecognizerCountry: String {
    case eu = "eu"
}

class NumberPlateRecognizerService {

    public static var sharedInstance = NumberPlateRecognizerService()

    public var scannedNumberPlatesLog: [NumberPlate]

    private let scanner: OAScanner
    private var confidenceDelimiter: Float = Float(80.0)

    private init(){
        scanner = OAScanner(country: NumberPlateRecognizerCountry.eu.rawValue, patternRegion: NumberPlateRecognizerRegionPattern.de.rawValue)
        scannedNumberPlatesLog = [NumberPlate]()
    }

    public func setConfidenceDelimiter(value: Float) {
        print("NumberPlateRecognizerService : set new confident delimiter to : \(value)")
        confidenceDelimiter = value
    }

    public func scan(images: [UIImage], completionHandler: @escaping (Result<[NumberPlate], NumberPlateRecognizerError>) -> Void ) {
        print("NumberPlateRecognizerService : scanning \(images.count) images")

        var recognizedPlates = [NumberPlate]()
        var accumulatedErrors = [NumberPlateRecognizerError]()

        for (index, image) in images.enumerated() {
            self.scan(image: image) { result in
                switch result {
                    case .success(let plates):
                        recognizedPlates.append(contentsOf: plates)
                    case .failure(let error):
                        accumulatedErrors.append(error)
                }

                // check if this is the last imagescanningresult we switch over here
                if index == (images.count - 1) {
                    // there seems to be something recognized that is not below the delimiter
                    if recognizedPlates.count > 0 {
                        completionHandler(.success(recognizedPlates))
                    } else if let error = accumulatedErrors.last {
                        // sadly we omit the other maybe occured errors here
                        completionHandler(.failure(error))
                    }
                }
            }
        }

    }

    public func scan(image: UIImage, path: String? = nil, completionHandler: @escaping (Result<[NumberPlate], NumberPlateRecognizerError>) -> Void ) {

        scanner.scanImage(image, onSuccess: { plates in
            guard let plates = plates else {
                completionHandler(.failure(.noPlateFound))
                return
            }

            // maybe we find more than one plate in the image
            var matchingPlates = [NumberPlate]()

            for plate in plates {
                // filter plate by confidence
                if self.confidenceDelimiter.isLess(than: plate.confidence) {
                    guard var unwrappedPlate = NumberPlate(from: plate) else {
                        return
                    }

                    // add path if available
                    if let path = path {
                        unwrappedPlate.imageName = path
                    }

                    self.scannedNumberPlatesLog.append(unwrappedPlate)
                    matchingPlates.append(unwrappedPlate)
                }
            }

            // error, no matching plates found, otherwise success
            if matchingPlates.count > 0 {
                completionHandler(.success(matchingPlates))
            } else {
                completionHandler(.failure(.noMatchingPlateFound))
            }
        }) { error in
            // general error by openALPR
            completionHandler(.failure(.someError))
        }
    }
}
