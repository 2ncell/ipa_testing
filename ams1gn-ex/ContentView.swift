import SwiftUI
import WebKit // Import WebKit for embedding the website

// MARK: - Shared Models and Components

struct SoftwareItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let downloadURL: URL // Each item has its own unique URL
}

// PopButton is now defined globally so it can be used in both ContentView and CertificatesView
struct PopButton: View {
    let downloadURL: URL
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Trigger the pop animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                isPressed = true
            }
            
            // Reset the animation after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                    isPressed = false
                }
            }
            
            // Open the URL in Safari
            UIApplication.shared.open(downloadURL)
        }) {
            Text("Download")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .scaleEffect(isPressed ? 1.2 : 1.0) // Pop animation
        }
    }
}

// MARK: - Rain Effect

struct RainEffectView: View {
    @State private var raindrops: [Raindrop] = []
    
    struct Raindrop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var speed: CGFloat
        var length: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(raindrops) { raindrop in
                    Rectangle()
                        .fill(Color.white.opacity(0.7)) // White raindrop color
                        .frame(width: 2, height: raindrop.length)
                        .position(x: raindrop.x, y: raindrop.y)
                        .animation(.linear(duration: Double(raindrop.speed)), value: raindrop.y)
                }
            }
            .onAppear {
                // Start generating raindrops
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    let x = CGFloat.random(in: 0..<geometry.size.width)
                    let speed = CGFloat.random(in: 2..<5)
                    let length = CGFloat.random(in: 20..<50)
                    let raindrop = Raindrop(x: x, y: -length, speed: speed, length: length)
                    raindrops.append(raindrop)
                    
                    // Remove raindrops that have fallen off the screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(speed)) {
                        raindrops.removeAll { $0.id == raindrop.id }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Main Content View

struct ContentView: View {
    let softwareCatalog: [SoftwareItem] = [
        SoftwareItem(name: "Chimera", description: "Jailbreak for iOS 12 - 12.5.7", downloadURL: URL(string: "https://example.com/download/app1")!),
        SoftwareItem(name: "Electra", description: "Jailbreak for iOS 11 - 11.4.1", downloadURL: URL(string: "https://example.com/download/app2")!),
        SoftwareItem(name: "Taurine", description: "Jailbreak for iOS 14 - 14.8.0", downloadURL: URL(string: "https://example.com/download/app3")!),
        SoftwareItem(name: "Dopamine", description: "Jailbreak For iOS 15 - 16.6.1", downloadURL: URL(string: "https://example.com/download/app4")!),
        SoftwareItem(name: "Unc0ver", description: "Jailbreak For iOS 11 - 14.8", downloadURL: URL(string: "https://example.com/download/app5")!),
    ]
    
    @State private var showWebView = false // State to control the popup
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pink to Blue Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all) // Extend gradient to the edges
                
                // White Rain Overlay Effect
                RainEffectView()
                
                // Software Catalog List
                List {
                    // Add padding at the top of the list
                    Section {
                        ForEach(softwareCatalog) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                PopButton(downloadURL: item.downloadURL)
                            }
                            .padding(.vertical, 12)
                            .listRowBackground(Color.clear) // Make list rows transparent
                        }
                    }
                    .padding(.top, 20) // Add space between the subtitle and the list
                }
                .listStyle(PlainListStyle()) // Remove default list styling
                .navigationTitle("Software Catalog")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Toolbar items at the top
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 8) {
                            // Icons at the top
                            HStack(spacing: 16) {
                                // Pen Icon Button
                                Button(action: {
                                    // Show the popup with the embedded website
                                    showWebView = true
                                }) {
                                    Image(systemName: "pencil") // Pen icon
                                        .font(.system(size: 24))
                                        .foregroundColor(.white) // White color
                                }
                                
                                // Star Icon Button (Certificates)
                                NavigationLink(destination: CertificatesView()) {
                                    Image(systemName: "star.fill") // Star icon
                                        .font(.system(size: 24))
                                        .foregroundColor(.white) // White color
                                }
                                
                                // Download Icon Button (Downloads Page)
                                NavigationLink(destination: DownloadsView()) {
                                    Image(systemName: "arrow.down.circle.fill") // Download icon
                                        .font(.system(size: 24))
                                        .foregroundColor(.white) // White color
                                }
                            }
                            
                            // Heading
                            VStack(spacing: 8) {
                                // Cloud Icon
                                Image(systemName: "cloud.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                
                                // Title
                                Text("SignCloud IPA Catalog")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .bold()
                                
                                // Subtitle
                                Text("made with 💛 by fluffed")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showWebView) {
            // Popup with embedded website
            WebView(url: URL(string: "https://signer.apptesters.org")!)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - Certificates View

struct CertificatesView: View {
    let certificatesCatalog: [SoftwareItem] = [
        SoftwareItem(name: "Certificate 1", description: "This is the first certificate.", downloadURL: URL(string: "https://example.com/download/cert1")!),
        SoftwareItem(name: "Certificate 2", description: "This is the second certificate.", downloadURL: URL(string: "https://example.com/download/cert2")!),
        SoftwareItem(name: "Certificate 3", description: "This is the third certificate.", downloadURL: URL(string: "https://example.com/download/cert3")!),
    ]
    
    @Environment(\.presentationMode) var presentationMode // For the back button
    
    var body: some View {
        ZStack {
            // Pink to Blue Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all) // Extend gradient to the edges
            
            // White Rain Overlay Effect
            RainEffectView()
            
            // Certificates Catalog List
            List {
                // Add padding at the top of the list
                Section {
                    ForEach(certificatesCatalog) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            PopButton(downloadURL: item.downloadURL)
                        }
                        .padding(.vertical, 12)
                        .listRowBackground(Color.clear) // Make list rows transparent
                    }
                }
                .padding(.top, 20) // Add space between the subtitle and the list
            }
            .listStyle(PlainListStyle()) // Remove default list styling
            .navigationTitle("Certificates Catalog")
            .navigationBarTitleDisplayMode(.inline)
            
            // Back Button at the Bottom
            VStack {
                Spacer() // Push the button to the bottom
                Button(action: {
                    // Go back to the previous screen
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Main Page")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Downloads View

struct DownloadsView: View {
    let downloadsCatalog: [SoftwareItem] = [
        SoftwareItem(name: "Download 1", description: "This is the first download.", downloadURL: URL(string: "https://example.com/download/dl1")!),
        SoftwareItem(name: "Download 2", description: "This is the second download.", downloadURL: URL(string: "https://example.com/download/dl2")!),
        SoftwareItem(name: "Download 3", description: "This is the third download.", downloadURL: URL(string: "https://example.com/download/dl3")!),
        SoftwareItem(name: "Download 4", description: "This is the fourth download.", downloadURL: URL(string: "https://example.com/download/dl4")!),
        SoftwareItem(name: "Download 5", description: "This is the fifth download.", downloadURL: URL(string: "https://example.com/download/dl5")!),
        SoftwareItem(name: "Download 6", description: "This is the sixth download.", downloadURL: URL(string: "https://example.com/download/dl6")!),
        SoftwareItem(name: "Download 7", description: "This is the seventh download.", downloadURL: URL(string: "https://example.com/download/dl7")!),
        SoftwareItem(name: "Download 8", description: "This is the eighth download.", downloadURL: URL(string: "https://example.com/download/dl8")!),
        SoftwareItem(name: "Download 9", description: "This is the ninth download.", downloadURL: URL(string: "https://example.com/download/dl9")!),
        SoftwareItem(name: "Download 10", description: "This is the tenth download.", downloadURL: URL(string: "https://example.com/download/dl10")!),
        SoftwareItem(name: "Download 11", description: "This is the eleventh download.", downloadURL: URL(string: "https://example.com/download/dl11")!),
        SoftwareItem(name: "Download 12", description: "This is the twelfth download.", downloadURL: URL(string: "https://example.com/download/dl12")!),
    ]
    
    @Environment(\.presentationMode) var presentationMode // For the back button
    
    var body: some View {
        ZStack {
            // Pink to Blue Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all) // Extend gradient to the edges
            
            // White Rain Overlay Effect
            RainEffectView()
            
            // Downloads Catalog List
            List {
                // Add padding at the top of the list
                Section {
                    ForEach(downloadsCatalog) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            PopButton(downloadURL: item.downloadURL)
                        }
                        .padding(.vertical, 12)
                        .listRowBackground(Color.clear) // Make list rows transparent
                    }
                }
                .padding(.top, 20) // Add space between the subtitle and the list
            }
            .listStyle(PlainListStyle()) // Remove default list styling
            .navigationTitle("Downloads Catalog")
            .navigationBarTitleDisplayMode(.inline)
            
            // Back Button at the Bottom
            VStack {
                Spacer() // Push the button to the bottom
                Button(action: {
                    // Go back to the previous screen
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Main Page")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - WebView

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
