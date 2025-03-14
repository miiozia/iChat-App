//
//  DataRefference.swift
//  iChat
//
//  Created by Marta Miozga on 02/10/2024.
//

//inaczej FCollectionreference - usun

import Foundation
import FirebaseFirestore

//FCollectionReferecne
enum DataReference: String {
    case User
    case Recent
}

func FirebaseReference(_ collectionReference: DataReference ) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}


