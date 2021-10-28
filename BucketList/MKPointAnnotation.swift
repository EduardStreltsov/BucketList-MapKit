import MapKit

extension MKPointAnnotation: ObservableObject {
	public var wrappedTitle: String {
		get {
			title ?? ""
		}
		
		set {
			title = newValue
		}
	}
	public var wrappedSubtitle: String {
		get {
			subtitle ?? ""
		}
		
		set {
			subtitle = newValue
		}
	}
	
}
