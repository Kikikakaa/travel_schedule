import SwiftUI

class FiltersViewModel: ObservableObject {
    @Published var morning = false   // 06:00–12:00
    @Published var dayTime = false   // 12:00–18:00
    @Published var evening = false   // 18:00–00:00
    @Published var night = false     // 00:00–06:00
    @Published var transfers: TransfersChoice?
    
    enum TransfersChoice { case yes, no }
    
    var canApply: Bool {
        (morning || dayTime || evening || night) && transfers != nil
    }
    
    func setTransfers(_ value: TransfersChoice) {
        transfers = value
    }
}
