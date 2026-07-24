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
    @EnvironmentObject private var watchDataStore: WatchDataStore
    @EnvironmentObject private var pathDataStore: PathDataStore
    @State private var newMemoNameText: String = ""
    @State private var newListNameText: String = ""
    @State private var renameListNameAlertIsPresent: Bool = false
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
                                        DeleteIconButton {
                                            nonCheckDelete(memoId: memo.memoId)
                                        }
                                    }
                            }
                            .onMove(perform: nonCheckMove)
                        } header: {
                            Text("MemosView.List.unCheckSection.header.Text")
                                .frame(height: 80, alignment: .bottom)
                        }
                    } emptyContent: {}
                    BoolSwitchView(isEmpty: memoDataStore.checkedMemoArray.isEmpty || !memoDataStore.isShowChecked) {
                        Section {
                            ForEach(memoDataStore.checkedMemoArray, id:\.memoId) { memo in
                                MemosViewCell(memo: memo)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        DeleteIconButton {
                                            checkedDelete(memoId: memo.memoId)
                                        }
                                    }
                            }
                            .onMove(perform: checkedMove)
                        } header: {
                            Text("MemosView.List.checkedSection.header.Text")
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
            //MARK: 表示分岐
            if watchDataStore.isReachable {
                ToolbarItem(placement: .topBarTrailing) {
                    //                HelpButton()
                    WatchButton()
                }
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                toolBarMenu()
            }
        }
        .alert("MemosView.renameListNameAlert.title", isPresented: $renameListNameAlertIsPresent) {
            renameListNameAlertActions()
        } message: {
            Text("MemosView.renameListNameAlert.message")
        }
        .alert("MemosView.deleteCheckedMemosAlert.title", isPresented: $deleteCheckedMemosAlertIsPresent) {
            deleteCheckedMemosAlertActions()
        } message: {
            Text("MemosView.deleteCheckedMemosAlert.message")
        }
        .navigationTitle(listDataStore.listArray.selected?.listName ?? "MemosView.navigationTitle.unknownListName")
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
                renameListNameAlertIsPresent = true
            } label: {
                Label("MemosView.toolBarMenu.renameListName.Label", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            if memoDataStore.isShowChecked {
                Button {
                    memoDataStore.isShowChecked = false
                } label: {
                    Label("MemosView.toolBarMenu.unShowChecked.Label", systemImage: "eye.slash")
                }
            } else {
                Button {
                    memoDataStore.isShowChecked = true
                } label: {
                    Label("MemosView.toolBarMenu.showChecked.Label", systemImage: "eye")
                }
            }
            Menu {
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.ascending)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.unCheckedSort.ToggleLabel.A-Z", systemImage: "a.circle") {
                        memoDataStore.nonCheckSort == .ascending
                    }
                }
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.descending)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.unCheckedSort.ToggleLabel.Z-A", systemImage: "z.circle") {
                        memoDataStore.nonCheckSort == .descending
                    }
                }
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.newest)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.unCheckedSort.ToggleLabel.newest", systemImage: "clock") {
                        memoDataStore.nonCheckSort == .newest
                    }
                }
                Button {
                    MemoRepository.sortNonCheckMemos(basedOn: MemoDataStore.SortModeEnum.custom)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.unCheckedSort.ToggleLabel.custom", systemImage: "hand.point.up") {
                        memoDataStore.nonCheckSort == .custom
                    }
                }

            } label: {
                Text("MemosView.toolBarMenu.unCheckedSort.Text")
            }
            Menu {
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.ascending)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.checkedSort.ToggleLabel.A-Z", systemImage: "a.circle") {
                        memoDataStore.checkedSort == .ascending
                    }
                }
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.descending)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.checkedSort.ToggleLabel.Z-A", systemImage: "z.circle") {
                        memoDataStore.checkedSort == .descending
                    }
                }
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.newest)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.checkedSort.ToggleLabel.newest", systemImage: "clock") {
                        memoDataStore.checkedSort == .newest
                    }
                }
                Button {
                    MemoRepository.sortCheckedMemos(basedOn: MemoDataStore.SortModeEnum.custom)
                } label: {
                    ToggleLabel(title: "MemosView.toolBarMenu.checkedSort.ToggleLabel.custom", systemImage: "hand.point.up") {
                        memoDataStore.checkedSort == .custom
                    }
                }
            } label: {
                Text("MemosView.toolBarMenu.checkedSort.Text")
            }
            Divider()
            Button(role: .destructive) {
                deleteCheckedMemosAlertIsPresent = true
            } label: {
                Label("MemosView.toolBarMenu.deleteChecked.Label", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    @ViewBuilder
    func renameListNameAlertActions() -> some View {
        TextField("MemosView.renameListNameAlertActions.TextField.title", text: $newListNameText)
        CancelButton {
            newListNameText = ""
        }
        Button(role: .confirm) {
            Task {
                await CustomListRepository.updateListName(newName: newListNameText)
                newListNameText = ""
            }
        } label: {
            Text("MemosView.renameListAlertActions.Button.title")
        }
    }
    @ViewBuilder
    func deleteCheckedMemosAlertActions() -> some View {
        CancelButton()
        DeleteButton {
            memoDataStore.checkedMemoIsLoading = true
            Task { await MemoRepository.deleteCheckedMemos() }
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
