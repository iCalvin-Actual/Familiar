import Foundation
import Synchronization
import Testing
@testable import Familiar

struct ImageLoaderTests {

    @Test func plainBuilderSendsTheURLAsGiven() {
        let url = URL(string: "https://example.com/a.png")!
        #expect(PlainRequestBuilder().urlRequest(for: ImageRequest(url: url)).url == url)
    }

    @Test(arguments: [429, 500, 503])
    func serverTroubleIsWorthRetrying(_ code: Int) {
        #expect(URLSessionImageLoader.isTransient(ImageLoadingError.badStatus(code)))
    }

    @Test func missingThingsAreNot() {
        #expect(!URLSessionImageLoader.isTransient(ImageLoadingError.badStatus(404)))
        #expect(!URLSessionImageLoader.isTransient(ImageLoadingError.undecodable))
        #expect(!URLSessionImageLoader.isTransient(URLError(.cannotFindHost)))
        #expect(URLSessionImageLoader.isTransient(URLError(.timedOut)))
    }

    @Test func retriesUntilTheServerRecovers() async throws {
        let url = Stub.url("recovers", statuses: [503, 200])
        _ = try await Stub.loader.image(for: ImageRequest(url: url))
        #expect(Stub.requestCount(for: url) == 2)
    }

    @Test func givesUpOnA404Straight() async {
        let url = Stub.url("gone", statuses: [404])
        await #expect(throws: ImageLoadingError.badStatus(404)) {
            try await Stub.loader.image(for: ImageRequest(url: url))
        }
        #expect(Stub.requestCount(for: url) == 1)
    }

    @Test func builderShapesTheRequest() async throws {
        struct Sized: RequestBuilder {
            func urlRequest(for request: ImageRequest) -> URLRequest {
                var components = URLComponents(url: request.url, resolvingAgainstBaseURL: false)!
                components.queryItems = [URLQueryItem(name: "w", value: "\(Int((request.pointSize?.width ?? 0) * request.scale))")]
                return URLRequest(url: components.url!)
            }
        }
        let url = Stub.url("sized", statuses: [200])
        let loader = URLSessionImageLoader(session: Stub.session, builder: Sized())
        _ = try await loader.image(for: ImageRequest(url: url, pointSize: CGSize(width: 80, height: 80), scale: 2))
        #expect(Stub.lastQuery(for: url) == "w=160")
    }
}

/// Answers each test's URL with its own queue of statuses, so tests can run
/// in parallel without sharing state.
private final class Stub: URLProtocol {
    private struct Route {
        var statuses: [Int]
        var count = 0
        var lastQuery: String?
    }

    private static let routes = Mutex<[String: Route]>([:])

    static let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [Stub.self]
        return URLSession(configuration: configuration)
    }()

    static let loader = URLSessionImageLoader(session: session)

    static func url(_ name: String, statuses: [Int]) -> URL {
        let key = "\(name)-\(UUID().uuidString)"
        routes.withLock { $0[key] = Route(statuses: statuses) }
        return URL(string: "https://stub.test/\(key)")!
    }

    static func requestCount(for url: URL) -> Int {
        routes.withLock { $0[url.lastPathComponent]?.count ?? 0 }
    }

    static func lastQuery(for url: URL) -> String? {
        routes.withLock { $0[url.lastPathComponent]?.lastQuery }
    }

    /// A 1×1 PNG.
    private static let png = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")!

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let url = request.url!
        let status = Self.routes.withLock { routes -> Int in
            guard var route = routes[url.lastPathComponent] else { return 404 }
            let status = route.statuses[min(route.count, route.statuses.count - 1)]
            route.count += 1
            route.lastQuery = url.query()
            routes[url.lastPathComponent] = route
            return status
        }
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: status == 200 ? Self.png : Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
