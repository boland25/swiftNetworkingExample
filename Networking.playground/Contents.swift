//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import PlaygroundSupport



typealias JSONDictionary = [String: AnyObject]

struct Episode {
    let id: String
    let title: String
}

extension Episode {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
    
    static let all = Resource<[Episode]>(url: url, parseJSON:{ json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Episode.init)
    })

}

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json =  try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}
let url = URL(string: "localhost:8080/episodes.json")!


final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { (data, _, _) in
            print("test")
            let result = data.flatMap(resource.parse)
            completion(result)
        }.resume()
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true

Webservice().load(resource: Episode.all) { (result) in
    print("result \(result)")
}