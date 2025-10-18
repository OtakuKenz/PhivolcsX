import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack{
            Text("📘 About this app:")
                .font(.title)
            Text("""
            This app is an independent, non-commercial project created **for fun and educational purposes**.  
            It is **not affiliated with or endorsed by** the Philippine Institute of Volcanology and Seismology (PHIVOLCS).

            All earthquake data are retrieved from the **official PHIVOLCS website** and presented here for general informational use.  
            While efforts are made to keep the information accurate, **no guarantee** is made as to its completeness or timeliness.  
            For verified and official earthquake reports, please visit:  
            https://www.phivolcs.dost.gov.ph

            🤝 The developer is **open to cooperate or collaborate with PHIVOLCS and all other developers** to help improve public access and awareness regarding earthquake information.
            """)
            .multilineTextAlignment(.center)
            .padding()
            
            Spacer()
            
            Text("App version: 0.1")
                .foregroundStyle(.secondary)
        }
    }
}


#Preview {
    AboutView()
}
