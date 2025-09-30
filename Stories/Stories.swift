import SwiftUI

struct Stories {
    let backgroundColor: Color
    let backgroundImage: UIImage?
    let title: String
    let description: String
    
    static let story1 = Stories(
        backgroundColor: .story1Background,
        backgroundImage: .story1,
        title: "Сила машиниста",
        description: "За штурвалом железного зверя — опыт и спокойствие. Тысячи километров за плечами, и каждый рейс как новая история."
    )
    
    static let story2 = Stories(
        backgroundColor: .story2Background,
        backgroundImage: .story2,
        title: "Дежурная по вагону",
        description: "Служба в форме — это не только строгий взгляд и ответственность, но и теплые улыбки, которые встречают пассажиров в пути."
    )
    
    static let story3 = Stories(
        backgroundColor: .story3Background,
        backgroundImage: .story3,
        title: "Поезд в джунглях",
        description: "Гул локомотива, зелень вокруг и встреча культур. Поезд соединяет города и сердца, проходя сквозь самые дикие места планеты."
    )
    
    static let story4 = Stories(
        backgroundColor: .story1Background,
        backgroundImage: .story4,
        title: "Пустой вагон",
        description: "Тишина, мягкий свет и запах старого дерева. Вагон хранит истории тысяч людей, которые уже уехали дальше."
    )
    
    static let story5 = Stories(
        backgroundColor: .story2Background,
        backgroundImage: .story5,
        title: "Свет надежды",
        description: "Взгляд, устремлённый в будущее. Проводница хранит спокойствие и уверенность, когда ночь и дорога кажутся бесконечными."
    )
    
    static let story6 = Stories(
        backgroundColor: .story3Background,
        backgroundImage: .story6,
        title: "Пассажиры прошлого",
        description: "Суровые лица, молчаливые взгляды. Каждый везёт с собой свои истории, и вагон становится зеркалом целой эпохи."
    )
}
