//
//  ParticipantRepository.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2026/03/20.
//

import Foundation
import FirebaseFirestore

@MainActor
class ParticipantRepository {
    static let roomDataStore: RoomDataStore = .shared
    static let participantDataStore: ParticipantDataStore = .shared
    
    //observe
    static func observeUserData(userId: String, authority: Authority.AuthorityEnum) {
        Firestore.firestore().collection("Users").document(userId).addSnapshotListener() { DataSnapshot, error in
            do {
                guard let user = try DataSnapshot?.data(as: User.self) else { return }
                switch authority {
                case .administrator:
                    participantDataStore.administrators.updateUserNameAndEmail(userId: userId, userName: user.userName, email: user.email)
                case .member:
                    participantDataStore.members.updateUserNameAndEmail(userId: userId, userName: user.userName, email: user.email)
                case .guest:
                    participantDataStore.guests.updateUserNameAndEmail(userId: userId, userName: user.userName, email: user.email)
                case .unknown:
                    return
                }
            } catch {
                print(error)
            }
        }
    }
    
    static func observeRoomParticipants() {
        guard let roomId = roomDataStore.selectedRoom?.roomId else { return }
        Firestore.firestore().collection("Rooms").document(roomId).addSnapshotListener() { DataSnapshot, error in
            do {
                guard let roomAuthorities = try DataSnapshot?.data(as: Room.self).authorities else { return }
                var administrators: [Participant] = []
                var members: [Participant] = []
                var guests: [Participant] = []
                for authority in roomAuthorities {
                    let participant = Participant(userId: authority.userId, authority: authority.authority, userName: nil, email: nil)
                    switch authority.authority {
                    case .administrator:
                        administrators.append(noDuplicate: participant)
                    case .member:
                        members.append(noDuplicate: participant)
                    case .guest:
                        guests.append(noDuplicate: participant)
                    case .unknown:
                        continue
                    }
                }
                participantDataStore.administrators = administrators
                participantDataStore.members = members
                participantDataStore.guests = guests
            } catch {
                print(error)
            }
        }
    }
}
