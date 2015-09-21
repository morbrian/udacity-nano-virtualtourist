//
//  FlickrService.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation

class FlickrService {
    private var restApiKey: String!
    
    private var webClient: WebClient!
    
    // singleton instance
    class func sharedInstance() -> FlickrService {
        struct Static {
            static let instance = FlickrService(client: WebClient(), restApiKey: "867c554976ca67d26bcdfad0b29435b2")
        }
        return Static.instance
    }
    
    // Initialize with app specific keys and id
    // client: insteance of a WebClient
    // restApiKey: a developer API Key provided by registering with the Flickr service.
    private init(client: WebClient, restApiKey: String) {
        self.webClient = client
        self.restApiKey = restApiKey
    }
    
    // Fetch a list of objects from the Parse service for the specified class type.
    func fetchPhotosNearCoordinates(#latitude: Double, longitude: Double, radiusKm: Double = 10,
        completionHandler: (photoUrls: [NSURL]?, error: NSError?) -> Void) {
            Logger.info("fetch near...")
            var parameterList: [String:AnyObject] = [
                FlickrParameter.ApiKey:restApiKey,
                FlickrParameter.Method:FlickrMethod.FlickrPhotosSearch,
                FlickrParameter.Extras:FlickrParameterValue.ExtrasUrlm,
                FlickrParameter.ResponseFormat:FlickrParameterValue.DataFormatJson,
                FlickrParameter.NoJsonCallback:FlickrParameterValue.NoJsonCallbackOn,
                FlickrParameter.Lat:latitude,
                FlickrParameter.Lon:longitude,
                FlickrParameter.Radius:radiusKm,
                FlickrParameter.PerPage:40,
                FlickrParameter.Page: random() % 10
            ]
            
            if let request = webClient.createHttpRequestUsingMethod(WebClient.HttpGet, forUrlString: "\(FlickrService.BaseUrl)",
                includeParameters: parameterList) {
                    Logger.info("Send Request To: \(request.URL)")
                    webClient.executeRequest(request) { jsonData, error in
                        if let status  = jsonData?.valueForKey(FlickrJsonKey.Stat) as? String
                            where status == FlickrJsonValue.Ok {
                                
                            if let jsonKvp: AnyObject = jsonData?.valueForKey(FlickrJsonKey.Photos),
                                photoObjects = jsonKvp.valueForKey(FlickrJsonKey.Photo) as? [AnyObject] {
                                    var urlStrings = photoObjects.map({$0.valueForKey(FlickrJsonKey.ImageUrl) as? String}).filter(){$0 != nil}
                                    var urlOptional = urlStrings.map({NSURL(string: $0!)}).filter({$0 != nil})
                                    var urls = urlOptional.reduce([NSURL]()) { base, value in
                                        var basePlus = base
                                        basePlus.append(value!)
                                        return basePlus
                                    }
                                completionHandler(photoUrls: urls, error: nil)
                            } else {
                                completionHandler(photoUrls: nil, error: FlickrService.errorForCode(ErrorCode.ResponseContainedNoPhotosObjects))
                            }
                        } else if let status  = jsonData?.valueForKey(FlickrJsonKey.Stat) as? String
                            where status == FlickrJsonValue.Fail {
                                if let message = jsonData?.valueForKey(FlickrJsonKey.Message) as? String {
                                    completionHandler(photoUrls: nil,
                                        error: FlickrService.errorWithMessage(message, code: ErrorCode.ResponseStatusWithMessage.rawValue))
                                } else {
                                    completionHandler(photoUrls: nil, error: FlickrService.errorForCode(ErrorCode.ResponseHadFaildStatusButNoMessage))
                                }
                        } else if let error = error {
                            completionHandler(photoUrls: nil, error: error)
                        }
                    }
            } else {
                completionHandler(photoUrls: nil, error: WebClient.errorForCode(.UnableToCreateRequest))
            }
    }
    
}

// MARK: - Constants

extension FlickrService {
    
    static let BaseUrl = "https://api.flickr.com/services/rest"
    
    struct FlickrMethod {
        static let FlickrPhotosSearch = "flickr.photos.search"
    }
    
    struct FlickrParameter {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let PerPage = "per_page"
        static let Page = "page"
        static let ResponseFormat = "format"
        static let NoJsonCallback = "nojsoncallback"
        static let Lat = "lat"
        static let Lon = "lon"
        static let Radius = "radius"
        static let RadiusUnits = "radius_units"
        static let Media = "media"
        static let ContentType = "content_type"
        static let Extras = "extras"
    }
    
    struct FlickrParameterValue {
        static let ContentTypePhotosOnly = "1"
        static let ExtrasUrlm = "url_m"
        static let DataFormatJson = "json"
        static let NoJsonCallbackOn = "1"
    }

    struct FlickrJsonKey {
        static let Stat = "stat"
        static let Message = "message"
        static let Photos = "photos"
        static let Photo = "photo"
        static let ImageUrl = "url_m"
    }
    
    struct FlickrJsonValue {
        static let Ok = "ok"
        static let Fail = "fail"
    }
    
}


// MARK: - Errors

extension FlickrService {
    
    private static let ErrorDomain = "FlickrService"
    
    private enum ErrorCode: Int, Printable {
        case ResponseContainedNoPhotosObjects = 1, ResponseHadNoStatus, ResponseStatusWithMessage, ResponseHadFaildStatusButNoMessage
        
        var description: String {
            switch self {
            case ResponseContainedNoPhotosObjects: return "Response data did not have a photos or photo item in the results."
            case ResponseHadNoStatus: return "Response did not have expected data but also did not provided a status indicator."
            case ResponseStatusWithMessage: return "Response failed and includes status message"
            case ResponseHadFaildStatusButNoMessage: return "Response indicated failure but did not provide a message"
            default: return "Unknown Error"
            }
        }
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // createErrorWithCode
    // helper function to simplify creation of error object
    private static func errorForCode(code: ErrorCode) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : code.description]
        return NSError(domain: FlickrService.ErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
    
    static func errorWithMessage(message: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : message]
        return NSError(domain: FlickrService.ErrorDomain, code: code, userInfo: userInfo)
    }
}
