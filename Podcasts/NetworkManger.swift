 //
 //  Network.swift
 //  Podcasts
 //
 //  Created by Abdalah Omar on 11/3/20.
 //  Copyright © 2020 Abdallah. All rights reserved.
 //
 
 import Foundation
 import Alamofire
 import FeedKit
 
 class NetworkManger{
    
    static let shared = NetworkManger()
    let baseItunseSearchUrl = "https://itunes.apple.com/search?"
    typealias EpisodeDownlaodCompleteTuple = (fileUrl:String,episodeTitle:String)
    
    
    func fetchPhotoPodcasts(searchText:String,completion: @escaping([Results]) ->Void){
        let parameters = ["term":searchText,"media":"podcast"]
        AF.request(baseItunseSearchUrl,method: .get,parameters: parameters,encoding: URLEncoding.default,headers: nil).responseData { dataRespnse in
            if let err      = dataRespnse.error{
                print(err.localizedDescription)
                return
            }
            guard let data = dataRespnse.data else{return}
            
            do{
                let encoder = JSONDecoder()
                let searchResult = try encoder.decode(SearchResults.self, from: data)
                completion(searchResult.results)
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    func fetchEpisode(feedURL:String,completion: @escaping([Episode]) ->Void){
        let secureFeddURL = feedURL.contains("https") ? feedURL : feedURL.replacingOccurrences(of: "http", with: "https")
        
        guard let url       = URL(string: secureFeddURL) else{return}
        DispatchQueue.global(qos: .background).async {
            let parser      = FeedParser(URL: url)
            parser.parseAsync { result in
                switch result {
                case .success(let feed):
                    feed.rssFeed
                    switch feed {
                    case let .rss(feed):
                        completion(feed.toEpisode())
                        break
                    default :
                        print("Found Feed   ")
                        break
                    }
                case .failure(let error):
                    print("Failed tp parse XML Feed:",error)
                    
                }
            }
        }
        
    }
    
    
    func downloadEpisode(episode:Episode){
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        AF.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
           
            let name = NSNotification.Name(Constant.downloadProgress)
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["title":episode.title,"progress":progress.fractionCompleted])
        }.response { (resp) in
            print( resp.description)
            if resp.error == nil , let url = resp.fileURL?.description{
                //notification
                let downloadComplete = NSNotification.Name(Constant.downloadComplete)
                let episodeDownlaodComplete = EpisodeDownlaodCompleteTuple(resp.fileURL?.description ?? "",episode.title)
                
                NotificationCenter.default.post(name: downloadComplete, object: episodeDownlaodComplete, userInfo: nil)
                var downlaodEpisode = UserDefaults.standard.downlaodEpisodes()
                guard let index = downlaodEpisode.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else {return}
                downlaodEpisode[index].fileUrl = url
                do{
                    let data = try JSONEncoder().encode(downlaodEpisode)
                    UserDefaults.standard.set(data, forKey: Constant.downloadEpisodeKey)
                }catch let error {
                    print("Failed to encode downlaod episode:",error)
                }
            }
        }
    }
 }
