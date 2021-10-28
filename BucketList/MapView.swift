import SwiftUI
import MapKit


struct MapView: UIViewRepresentable {
	
	@Binding var centerCoordinate: CLLocationCoordinate2D
	var annotations: [MKPointAnnotation]
	@Binding var selectedPlace: MKPointAnnotation?
	@Binding var showingPlaceDetails: Bool
	
	
	class Coordinator: NSObject, MKMapViewDelegate {
		var parent: MapView
		
		init(_ parent: MapView) {
			self.parent = parent
		}
		
		func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
			parent.centerCoordinate = mapView.centerCoordinate
		}
		
		func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
			let identifier = "Placemark"
			
			var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
			
			if annotationView == nil {
				annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				annotationView?.canShowCallout = true
				annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
			} else {
				annotationView?.annotation = annotation
			}
			
			return annotationView
		}
		
		func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
		             calloutAccessoryControlTapped control: UIControl) {
			guard let placemark = view.annotation as? MKPointAnnotation else { return }
			
			parent.selectedPlace = placemark
			parent.showingPlaceDetails = true
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIView(context: Context) -> UIViewType {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		
		return mapView
	}
	
	func updateUIView(_ view: MKMapView, context: Context) {
		if annotations.count != view.annotations.count {
			view.removeAnnotations(view.annotations)
			view.addAnnotations(annotations)
		}
	}
}
