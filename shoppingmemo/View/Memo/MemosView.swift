//
//  MemosView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/13.
//

import SwiftUI

struct MemosView: View {
    @ObservedObject var userDataStore: UserDataStore
    @ObservedObject var roomDataStore: RoomDataStore
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var memoDataStore: MemoDataStore
    
    @State private var newMemoNameText: String = ""
    
    var body: some View {
        ZStack {
            List {
                if !memoDataStore.nonCheckMemoArray.isEmpty {
                    Section {
                        ForEach(memoDataStore.nonCheckMemoArray, id:\.id) { memo in
                            MemosViewCell(roomDataStore: roomDataStore, listDataStore: listDataStore, memoDataStore: memoDataStore, memo: memo)
                        }
                        .onMove(perform: nonCheckMove)
                        .onDelete(perform: nonCheckDelete)
                    } header: {
                        Text("未完了")
                            .padding(.top, 55)
                    }
                }
                if !memoDataStore.checkedMemoArray.isEmpty {
                    Section {
                        ForEach(memoDataStore.checkedMemoArray, id:\.id) { memo in
                            MemosViewCell(roomDataStore: roomDataStore, listDataStore: listDataStore, memoDataStore: memoDataStore, memo: memo)
                        }
                        .onMove(perform: checkedMove)
                        .onDelete(perform: checkedDelete)
                    } header: {
                        Text("完了済")
                    }
                }
            }
            VStack {
                TextField("アイテムを追加", text: $newMemoNameText, onCommit: {
                    Task {
                        await MemoRepository.createMemo(memoName: newMemoNameText)
                        newMemoNameText = ""
                    }
                    
                })
                .padding()
                .glassEffect(.regular.tint(.accentColor))
                Spacer()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                toolBarMenu()
            })
        }
        .navigationTitle(listDataStore.selectedList?.listName ?? "不明なリスト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            MemoRepository.obserbeMemos()
        }
    }
    func nonCheckMove(fromSources: IndexSet, toDestination: Int) {
        memoDataStore.nonCheckMemoArray.move(fromOffsets: fromSources, toOffset: toDestination)
    }
    func nonCheckDelete(at offsets: IndexSet) {
        
    }
    func checkedMove(fromSources: IndexSet, toDestination: Int) {
        memoDataStore.checkedMemoArray.move(fromOffsets: fromSources, toOffset: toDestination)
    }
    func checkedDelete(at offsets: IndexSet) {
        
    }
    func toolBarMenu() -> some View {
        Menu {
            Button(action: {
                
            }, label: {
                Label("リスト名を変更", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            })
            Button(action: {
                
            }, label: {
                Label("完了済を表示", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            })
            Menu {
                Button(action: {
                    
                }, label: {
                    Label("五十音昇順", systemImage: "a.circle")
                })
                Button(action: {
                    
                }, label: {
                    Label("五十音降順", systemImage: "z.circle")
                })
                Button(action: {
                    
                }, label: {
                    Label("新しい順", systemImage: "clock")
                })
                Button(action: {
                    
                }, label: {
                    Label("カスタム", systemImage: "hand.point.up")
                })
            } label: {
                Text("未完了を並べ替え")
            }
            Menu {
                Button(action: {
                    
                }, label: {
                    Label("五十音昇順", systemImage: "a.circle")
                })
                Button(action: {
                    
                }, label: {
                    Label("五十音降順", systemImage: "z.circle")
                })
                Button(action: {
                    
                }, label: {
                    Label("新しい順", systemImage: "clock")
                })
                Button(action: {
                    
                }, label: {
                    Label("カスタム", systemImage: "hand.point.up")
                })
            } label: {
                Text("完了済を並べ替え")
            }
            Divider()
            Button(role: .destructive, action: {
                
            }, label: {
                Label("完了項目を削除", systemImage: "trash")
            })
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

#Preview {
    MemosView(userDataStore: UserDataStore.shared, roomDataStore: RoomDataStore.shared, listDataStore: ListDataStore.shared, memoDataStore: MemoDataStore.shared)
}
