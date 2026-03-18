//
//  MemosView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/13.
//

import SwiftUI

struct MemosView: View {
    @ObservedObject var listDataStore: ListDataStore
    @ObservedObject var memoDataStore: MemoDataStore
    @ObservedObject var pathDataStore: PathDataStore
    
    @State private var newMemoNameText: String = ""
    @State private var newListNameText: String = ""
    
    @State private var renameListAlertIsPresent: Bool = false
    
    var body: some View {
        ZStack {
            if memoDataStore.nonCheckMemoIsLoading || memoDataStore.checkedMemoIsLoading {
                Text("データ取得中...")
            } else {
                if memoDataStore.nonCheckMemoArray.isEmpty && memoDataStore.checkedMemoArray.isEmpty {
                    Text("表示できるメモがありません")
                } else {
                    List {
                        if !memoDataStore.nonCheckMemoArray.isEmpty {
                            Section {
                                ForEach($memoDataStore.nonCheckMemoArray, id:\.id) { memo in
                                    MemosViewCell(memoDataStore: memoDataStore, pathDataStore: pathDataStore, memo: memo)
                                }
                                .onMove(perform: nonCheckMove)
                                .onDelete(perform: nonCheckDelete)
                            } header: {
                                Text("未完了")
                                    .padding(.top, 55)
                            }
                        }
                        if !memoDataStore.checkedMemoArray.isEmpty && memoDataStore.isShowChecked {
                            Section {
                                ForEach($memoDataStore.checkedMemoArray, id:\.id) { memo in
                                    MemosViewCell(memoDataStore: memoDataStore, pathDataStore: pathDataStore, memo: memo)
                                }
                                .onMove(perform: checkedMove)
                                .onDelete(perform: checkedDelete)
                            } header: {
                                Text("完了済")
                            }
                        }
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
                .padding(.horizontal)
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                toolBarMenu()
            })
        }
        .alert("リスト名を変更", isPresented: $renameListAlertIsPresent, actions: {
            TextField("新しいリスト名を入力", text: $newListNameText)
            Button(role: .cancel, action: {
                newListNameText = ""
            }, label: {
                Text("キャンセル")
            })
            Button(role: .confirm, action: {
                Task {
                    await CustomListRepository.updateListName(newName: newListNameText)
                    newListNameText = ""
                }
            }, label: {
                Text("変更")
            })
        }, message: {
            Text("新しいリスト名を入力してください。")
        })
        .navigationTitle(listDataStore.selectedList?.listName ?? "不明なリスト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            memoDataStore.isShowChecked = UserDefaultsRepository.get(Bool.self, key: "isShowChecked") ?? true
            memoDataStore.nonCheckMemoIsLoading = true
            memoDataStore.checkedMemoIsLoading = true
            MemoRepository.observeNonCheckMemos()
            MemoRepository.observeCheckedMemos()
        }
        .onDisappear() {
            MemoRepository.clearMemos()
        }
    }
    func nonCheckMove(fromSources: IndexSet, toDestination: Int) {
        Task { await MemoRepository.updateNonCheckOrders(from: fromSources, to: toDestination) }
    }
    func nonCheckDelete(at offsets: IndexSet) {
        
    }
    func checkedMove(fromSources: IndexSet, toDestination: Int) {
        Task { await MemoRepository.updateCheckOrders(from: fromSources, to: toDestination) }
    }
    func checkedDelete(at offsets: IndexSet) {
        
    }
    func toolBarMenu() -> some View {
        Menu {
            Button(action: {
                newListNameText = listDataStore.selectedList?.listName ?? ""
                renameListAlertIsPresent = true
            }, label: {
                Label("リスト名を変更", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            })
            if memoDataStore.isShowChecked {
                Button(action: {
                    memoDataStore.isShowChecked = false
                }, label: {
                    Label("完了済を非表示", systemImage: "eye.slash")
                })
            } else {
                Button(action: {
                    memoDataStore.isShowChecked = true
                }, label: {
                    Label("完了済を表示", systemImage: "eye")
                })
            }
            Menu {
                Menu {
                    Button(action: {
                        MemoRepository.sortNonCheckMemos(basedOn: .ascending)
                    }, label: {
                        Label("名前昇順", systemImage: "a.circle")
                    })
                    Button(action: {
                        MemoRepository.sortNonCheckMemos(basedOn: .descending)
                    }, label: {
                        Label("名前降順", systemImage: "z.circle")
                    })
                    Button(action: {
                        MemoRepository.sortNonCheckMemos(basedOn: .newest)
                    }, label: {
                        Label("更新日時", systemImage: "clock")
                    })
                    Button(action: {
                        MemoRepository.sortNonCheckMemos(basedOn: .custom)
                    }, label: {
                        Label("カスタム", systemImage: "hand.point.up")
                    })
                } label: {
                    Text("未完了を並べ替え")
                }
                Menu {
                    Button(action: {
                        MemoRepository.sortCheckedMemos(basedOn: .ascending)
                    }, label: {
                        Label("名前昇順", systemImage: "a.circle")
                    })
                    Button(action: {
                        MemoRepository.sortCheckedMemos(basedOn: .descending)
                    }, label: {
                        Label("名前降順", systemImage: "z.circle")
                    })
                    Button(action: {
                        MemoRepository.sortCheckedMemos(basedOn: .newest)
                    }, label: {
                        Label("更新日時", systemImage: "clock")
                    })
                    Button(action: {
                        MemoRepository.sortCheckedMemos(basedOn: .custom)
                    }, label: {
                        Label("カスタム", systemImage: "hand.point.up")
                    })
                } label: {
                    Text("完了済を並べ替え")
                }
            } label: {
                Label("並び替え", systemImage: "arrow.up.arrow.down")
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
    MemosView(listDataStore: .shared, memoDataStore: .shared, pathDataStore: .shared)
}
