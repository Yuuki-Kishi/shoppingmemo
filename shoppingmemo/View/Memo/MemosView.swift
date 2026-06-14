//
//  MemosView.swift
//  shoppingmemo
//
//  Created by 岸　優樹 on 2025/09/13.
//

import SwiftUI

struct MemosView: View {
    @EnvironmentObject private var listDataStore: ListDataStore
    @EnvironmentObject private var memoDataStore: MemoDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var newMemoNameText: String = ""
    @State private var newListNameText: String = ""
    @State private var renameListAlertIsPresent: Bool = false
    @State private var deleteCheckedMemosAlertIsPresent: Bool = false
    @FocusState private var focus: Bool
    
    var body: some View {
        ZStack {
            BoolSwitchView(isEmpty: isShowNoDataLabel(), isLoading: isLoading()) {
                List {
                    BoolSwitchView(isEmpty: memoDataStore.nonCheckMemoArray.isEmpty) {
                        Section {
                            ForEach(memoDataStore.nonCheckMemoArray, id:\.memoId) { memo in
                                MemosViewCell(memo: memo)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        DeleteButton {
                                            nonCheckDelete(memoId: memo.memoId)
                                        }
                                    }
                            }
                            .onMove(perform: nonCheckMove)
                        } header: {
                            Text("未完了")
                                .frame(height: 80, alignment: .bottom)
                        }
                    } emptyContent: {}
                    BoolSwitchView(isEmpty: memoDataStore.checkedMemoArray.isEmpty || !memoDataStore.isShowChecked) {
                        Section {
                            ForEach(memoDataStore.checkedMemoArray, id:\.memoId) { memo in
                                MemosViewCell(memo: memo)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        DeleteButton {
                                            checkedDelete(memoId: memo.memoId)
                                        }
                                    }
                            }
                            .onMove(perform: checkedMove)
                        } header: {
                            Text("完了済")
                                .frame(height: checkedMemosHeight(), alignment: .bottom)
                        }
                    } emptyContent: {}
                }
            } emptyContent: {}
            ClearTextField(text: $newMemoNameText, focus: $focus) {
                Task {
                    await MemoRepository.createMemo(memoName: newMemoNameText)
                    newMemoNameText = ""
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focus = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HelpButton()
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                toolBarMenu()
            }
        }
        .alert("リスト名を変更", isPresented: $renameListAlertIsPresent) {
            renameListAlertActions()
        } message: {
            Text("新しいリスト名を入力してください。")
        }
        .alert("本当に完了済を全て削除しますか？", isPresented: $deleteCheckedMemosAlertIsPresent) {
            deleteCheckedMemosAlertActions()
        } message: {
            Text("この操作は取り消すことができません。")
        }
        .navigationTitle(listDataStore.listArray.selected?.listName ?? "不明なリスト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            onAppear()
        }
    }
    func isShowNoDataLabel() -> Bool {
        if memoDataStore.nonCheckMemoArray.isEmpty && memoDataStore.checkedMemoArray.isEmpty { return true }
        if memoDataStore.nonCheckMemoArray.isEmpty && !memoDataStore.isShowChecked { return true }
        return false
    }
    func isLoading() -> Bool {
        memoDataStore.nonCheckMemoIsLoading || memoDataStore.checkedMemoIsLoading
    }
    func nonCheckMove(fromSources: IndexSet, toDestination: Int) {
        Task { await MemoRepository.updateNonCheckOrders(from: fromSources, to: toDestination) }
    }
    func nonCheckDelete(memoId: String) {
        memoDataStore.nonCheckMemoIsLoading = true
        Task { await MemoRepository.deleteMemo(memoId: memoId) }
    }
    func checkedMove(fromSources: IndexSet, toDestination: Int) {
        Task { await MemoRepository.updateCheckOrders(from: fromSources, to: toDestination) }
    }
    func checkedDelete(memoId: String) {
        memoDataStore.checkedMemoIsLoading = true
        Task { await MemoRepository.deleteMemo(memoId: memoId) }
    }
    func checkedMemosHeight() -> CGFloat {
        memoDataStore.nonCheckMemoArray.isEmpty && memoDataStore.isShowChecked ? 80 : 0
    }
    func toolBarMenu() -> some View {
        Menu {
            Button {
                newListNameText = listDataStore.listArray.selected?.listName ?? ""
                renameListAlertIsPresent = true
            } label: {
                Label("リスト名を変更", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            if memoDataStore.isShowChecked {
                Button {
                    memoDataStore.isShowChecked = false
                } label: {
                    Label("完了済を非表示", systemImage: "eye.slash")
                }
            } else {
                Button {
                    memoDataStore.isShowChecked = true
                } label: {
                    Label("完了済を表示", systemImage: "eye")
                }
            }
            Menu {
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.ascending)
                } label: {
                    ToggleLabel(title: "タイトル昇順", systemImage: "a.circle") {
                        memoDataStore.nonCheckSort == .ascending
                    }
                }
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.descending)
                } label: {
                    ToggleLabel(title: "タイトル降順", systemImage: "z.circle") {
                        memoDataStore.nonCheckSort == .descending
                    }
                }
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.newest)
                } label: {
                    ToggleLabel(title: "更新日時", systemImage: "clock") {
                        memoDataStore.nonCheckSort == .newest
                    }
                }
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.custom)
                } label: {
                    ToggleLabel(title: "カスタム", systemImage: "hand.point.up") {
                        memoDataStore.nonCheckSort == .custom
                    }
                }

            } label: {
                Text("未完了を並べ替え")
            }
            Menu {
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.ascending)
                } label: {
                    ToggleLabel(title: "タイトル昇順", systemImage: "a.circle") {
                        memoDataStore.checkedSort == .ascending
                    }
                }
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.descending)
                } label: {
                    ToggleLabel(title: "タイトル降順", systemImage: "z.circle") {
                        memoDataStore.checkedSort == .descending
                    }
                }
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.newest)
                } label: {
                    ToggleLabel(title: "更新日時", systemImage: "clock") {
                        memoDataStore.checkedSort == .newest
                    }
                }
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.custom)
                } label: {
                    ToggleLabel(title: "カスタム", systemImage: "hand.point.up") {
                        memoDataStore.checkedSort == .custom
                    }
                }
            } label: {
                Text("完了済を並べ替え")
            }
            Divider()
            Button(role: .destructive) {
                deleteCheckedMemosAlertIsPresent = true
            } label: {
                Label("完了項目を削除", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    @ViewBuilder
    func renameListAlertActions() -> some View {
        TextField("新しいリスト名を入力", text: $newListNameText)
        Button(role: .cancel) {
            newListNameText = ""
        } label: {
            Text("キャンセル")
        }
        Button(role: .confirm) {
            Task {
                await CustomListRepository.updateListName(newName: newListNameText)
                newListNameText = ""
            }
        } label: {
            Text("変更")
        }
    }
    @ViewBuilder
    func deleteCheckedMemosAlertActions() -> some View {
        Button(role: .cancel) {} label: {
            Text("キャンセル")
        }
        Button(role: .destructive) {
            memoDataStore.checkedMemoIsLoading = true
            Task { await MemoRepository.deleteCheckedMemos() }
        } label: {
            Text("削除")
        }
    }
    func onAppear() {
        memoDataStore.isShowChecked = UserDefaultsRepository.get(Bool.self, key: "isShowChecked") ?? true
        let nonCheckSortString = UserDefaultsRepository.get(String.self, key: "nonCheckSort") ?? "ascending"
        memoDataStore.nonCheckSort = MemoDataStore.SortModeEnum(rawValue: nonCheckSortString) ?? .ascending
        let checkedSortString = UserDefaultsRepository.get(String.self, key: "checkedSort") ?? "ascending"
        memoDataStore.checkedSort = MemoDataStore.SortModeEnum(rawValue: checkedSortString) ?? .ascending
        memoDataStore.nonCheckMemoIsLoading = true
        memoDataStore.checkedMemoIsLoading = true
        MemoRepository.clearMemos()
        MemoRepository.observeNonCheckMemos() { memoDataStore.nonCheckMemoIsLoading = false }
        MemoRepository.observeCheckedMemos() { memoDataStore.checkedMemoIsLoading = false }
    }
    func nonCheckSortToggleIsOn(sortMode: MemoDataStore.SortModeEnum) -> Bool {
        memoDataStore.nonCheckSort == sortMode
    }
    func checkedSortToggleIsOn(sortMode: MemoDataStore.SortModeEnum) -> Bool {
        memoDataStore.checkedSort == sortMode
    }
}

#Preview {
    MemosView()
}
