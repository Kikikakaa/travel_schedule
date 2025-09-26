import SwiftUI

struct Stories {
    let backgroundColor: Color
    let backgroundImage: UIImage?
    let title: String
    let description: String
    
    static let story1 = Stories(
        backgroundColor: .story1Background,
        backgroundImage: .story1,
        title: "TEXT TEXT TEXT",
        description: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 "
    )
    
    static let story2 = Stories(
        backgroundColor: .story2Background,
        backgroundImage: .story2,
        title: "TEXT TEXT TEXT",
        description: "Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 "
    )
    
    static let story3 = Stories(
        backgroundColor: .story3Background,
        backgroundImage: .story3,
        title: "TEXT TEXT TEXT",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 "
    )
    
    static let story4 = Stories(
        backgroundColor: .story1Background,
        backgroundImage: .story4,
        title: "TEXT TEXT TEXT",
        description: "Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 Text4 "
    )
    
    static let story5 = Stories(
        backgroundColor: .story2Background,
        backgroundImage: .story5,
        title: "TEXT TEXT TEXT",
        description: "Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 Text5 "
    )
    
    static let story6 = Stories(
        backgroundColor: .story3Background,
        backgroundImage: .story6,
        title: "TEXT TEXT TEXT",
        description: "Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 Text6 "
    )
}
