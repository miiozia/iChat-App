//
//  DataRefference.swift
//  iChat
//
//  Created by Marta Miozga on 02/10/2024.
//


import Foundation
import FirebaseFirestore

enum DataReference: String {
    case User
    case Recent
    case Messages
    case Typing
    case Groups
    case Keys
    case Sessions
}

func FirebaseReference(_ collectionReference: DataReference ) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}


