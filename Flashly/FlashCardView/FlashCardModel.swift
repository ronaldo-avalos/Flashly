//
//  FlashCardModel.swift
//  Flashly
//
//  Created by Ronaldo Avalos on 09/12/24.
//

import Foundation
import UIKit

struct FlashCardModel {
    let id: UUID
    let question: String
    let answer: String
    let imageName: String?
    
    static func questions() -> [FlashCardModel] {
        return [
            FlashCardModel(
                id: UUID(),
                question: "Describe el ciclo cardíaco y su importancia.",
                answer: "El ciclo cardíaco comprende la contracción (sístole) y relajación (diástole) del corazón, asegurando la circulación de sangre oxigenada al cuerpo y el retorno de sangre desoxigenada a los pulmones.",
                imageName: "heart"
            ),
            FlashCardModel(
                id: UUID(),
                question: "¿Qué es la insuficiencia cardíaca y cómo se clasifica?",
                answer: "La insuficiencia cardíaca es la incapacidad del corazón para bombear suficiente sangre. Se clasifica en insuficiencia sistólica (fracción de eyección reducida) y diastólica (función de llenado comprometida).",
                imageName: "heartFailure"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Caso clínico: Paciente de 40 años con dolor precordial súbito irradiado a brazo izquierdo. ¿Cuál es tu diagnóstico inicial?",
                answer: "Sospecha de infarto agudo de miocardio. Realizar electrocardiograma y marcadores cardíacos (troponinas) de inmediato.",
                imageName: "ekg"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Explica el mecanismo fisiológico de la ventilación pulmonar.",
                answer: "La ventilación pulmonar ocurre mediante inspiración activa, donde el diafragma y los músculos intercostales expanden los pulmones, y espiración pasiva, cuando los músculos se relajan.",
                imageName: "lungs"
            ),
            FlashCardModel(
                id: UUID(),
                question: "¿Qué es el síndrome de dificultad respiratoria aguda (SDRA)?",
                answer: "El SDRA es una inflamación pulmonar grave caracterizada por hipoxemia refractaria, disminución de la compliance pulmonar y edema alveolar.",
                imageName: "ards"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Caso clínico: Paciente con fiebre, tos productiva y dolor pleurítico. Radiografía muestra consolidación en lóbulo inferior derecho. ¿Diagnóstico probable?",
                answer: "Neumonía bacteriana. Confirmar con cultivos y considerar iniciar antibióticos empíricos.",
                imageName: "pneumonia"
            ),
            FlashCardModel(
                id: UUID(),
                question: "¿Qué es el eje eléctrico del corazón y cómo se interpreta?",
                answer: "El eje eléctrico refleja la dirección del flujo de despolarización ventricular en el plano frontal, evaluado mediante derivaciones del electrocardiograma.",
                imageName: "ekgAxis"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Explica la fisiopatología de la diabetes mellitus tipo 1.",
                answer: "La diabetes tipo 1 es una enfermedad autoinmune en la que los linfocitos T destruyen las células beta del páncreas, causando deficiencia de insulina.",
                imageName: "pancreas"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Caso clínico: Paciente de 15 años con poliuria, polidipsia y pérdida de peso. Glucosa en ayuno de 300 mg/dL. ¿Próximo paso?",
                answer: "Diagnóstico de diabetes mellitus tipo 1. Iniciar insulina y plan educativo sobre manejo y monitoreo.",
                imageName: "diabetes"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Describe las fases de la coagulación sanguínea.",
                answer: "La coagulación tiene tres fases: 1) formación del tapón plaquetario primario, 2) cascada de coagulación para formar fibrina, y 3) fibrinólisis para resolver el coágulo.",
                imageName: "bloodCoagulation"
            ),
            FlashCardModel(
                id: UUID(),
                question: "Caso clínico: Paciente con hemartrosis recurrente. Pruebas revelan tiempo de tromboplastina prolongado. ¿Diagnóstico probable?",
                answer: "Hemofilia. Determinar si es tipo A (deficiencia de factor VIII) o tipo B (deficiencia de factor IX).",
                imageName: "hemophilia"
            )
        ]
    }
}
