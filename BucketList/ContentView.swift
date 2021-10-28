//
//  ContentView.swift
//  BucketList
//
//  Created by Eduard Streltsov on 21.04.2021.
//

import SwiftUI
import LocalAuthentication
import MapKit

struct ContentView: View {
	
	@State private var isUnlocked = false
	@State private var centerCoordinate = CLLocationCoordinate2D()
	@State private var locations = [CodableMKPointAnnotation]()
	@State private var selectedPlace: MKPointAnnotation?
	@State private var showingPlaceDetails = false
	@State private var showingEditScreen = false
	
	var body: some View {
		ZStack {
			if isUnlocked {
				MapView(centerCoordinate: $centerCoordinate, annotations: locations,
					selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails)
					.edgesIgnoringSafeArea(.all)
				Circle()
					.fill(Color.blue)
					.opacity(0.3)
					.frame(width: 32, height: 32)
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							let newLocation = CodableMKPointAnnotation()
							newLocation.coordinate = centerCoordinate
							locations.append(newLocation)
							
							selectedPlace = newLocation
							showingEditScreen = true
						}) {
							Image(systemName: "plus")
						}
							.padding()
							.background(Color.black.opacity(0.75))
							.foregroundColor(.white)
							.font(.title)
							.clipShape(Circle())
							.padding(.trailing)
					}
				}
			} else {
				Button("Unlock  Places") {
					authenticate()
				}
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.clipShape(Capsule())
			}
		}
			.onAppear(perform: loadData)
			.alert(isPresented: $showingPlaceDetails) {
				Alert(title: Text(selectedPlace?.title ?? "Unknown"),
					message: Text(selectedPlace?.subtitle ?? "Missing place information"),
					primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
					showingEditScreen = true
				})
			}
			.sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
				if selectedPlace != nil {
					EditView(placemark: selectedPlace!)
				}
			}
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	func loadData() {
		let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
		
		do {
			let data = try Data(contentsOf: filename)
			locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
		} catch {
			print("Unable to load saved data.")
			print(error.localizedDescription)
		}
	}
	
	func saveData() {
		do {
			let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
			let data = try JSONEncoder().encode(locations)
			try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
		} catch {
			print("Unable to save data.")
			print(error.localizedDescription)
		}
	}
	
	func authenticate() {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "We need to know that's you using app"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason
			) { success, error in
				DispatchQueue.main.async {
					if success {
						isUnlocked = true
					} else {
					
					}
				}
			}
		} else {
		
		}
	}
	
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
