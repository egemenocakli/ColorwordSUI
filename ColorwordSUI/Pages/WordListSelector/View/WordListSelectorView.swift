import SwiftUI

struct WordListSelectorView: View {
    @StateObject var wordListSelectorVM = WordListSelectorViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    let selectedTargetPage: String

    @State private var showAddNewWordGroupWidget = false
    @State private var showDeleteWordGroupWidget = false
    @State private var showDialog = false
    @State private var selectedSharedListName: String = ""

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    Constants.ColorConstants.loginLightThemeBackgroundGradient
                        .edgesIgnoringSafeArea(.all)

                    ScrollView {
                        if !wordListSelectorVM.isUserReady && wordListSelectorVM.userWordGroups.isEmpty {
                            ProgressView("loading")
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                                .padding(.top, geometry.size.height * 0.3)
                                .task {
                                    try? await wordListSelectorVM.createWordGroup(languageListName: "wordLists")
                                }
                        } else {
                            VStack(alignment: .leading, spacing: Constants.PaddingSizeConstants.smallSize) {
                                if showAddNewWordGroupWidget {
                                    WordListCreateNewWordGroup(
                                        wordListSelectorVM: wordListSelectorVM,
                                        showNewWordGroupWidget: $showAddNewWordGroupWidget
                                    )
                                    .padding(.horizontal)
                                } else {
                                    Text("your_custom_word_list")
                                        .foregroundStyle(Color(.textColorW))
                                        .font(.title2).bold()
                                        .padding(.leading)
                                }

                                ForEach(wordListSelectorVM.userWordGroups, id: \.self) { groupName in
                                    let displayText: LocalizedStringKey = groupName == "wordLists" ? "word_lists" : LocalizedStringKey(groupName)

                                    HStack {
                                        NavigationLink(destination: getDestinationView(groupName: groupName)) {
                                            Text(displayText)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.wordListSelectorCardColor)
                                                .cornerRadius(Constants.SizeRadiusConstants.xxSmall)
                                                .padding(.horizontal)
                                                .foregroundStyle(Color(.textColorW))
                                        }

                                        if showDeleteWordGroupWidget {
                                            IconButton(
                                                iconName: Constants.IconTextConstants.deleteButtonRectangle,
                                                backgroundColor: .translateButton,
                                                foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                                                frameWidth: 24,
                                                frameHeight: 24,
                                                paddingEdge: .trailing,
                                                paddingValue: 8,
                                                radius: Constants.SizeRadiusConstants.xSmall
                                            ) {
                                                Task {
                                                    withAnimation {
                                                        wordListSelectorVM.userWordGroups.removeAll { $0 == groupName }
                                                    }
                                                    try? await wordListSelectorVM.deleteWordGroup(languageListName: groupName)
                                                    await wordListSelectorVM.waitForUserInfoAndFetchLists()
                                                }
                                            }
                                        }
                                    }
                                }

                                VStack(alignment: .leading, spacing: Constants.PaddingSizeConstants.smallSize) {
                                    Text("predefined_word_list")
                                        .font(.title2).bold()
                                        .padding(.leading)
                                        .foregroundStyle(Color(.textColorW))

                                    ForEach(wordListSelectorVM.sharedWordGroups, id: \.self) { groupName in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                                                .fill(Color.wordListSelectorSharedCardColor)

                                            HStack {
                                                Text(groupName)
                                                    .foregroundStyle(Color(.textColorW))
                                                Spacer()
                                                IconButton(
                                                    iconName: Constants.IconTextConstants.addButtonRectangle,
                                                    backgroundColor: .white.opacity(0.1),
                                                    foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                                                    frameWidth: 16,
                                                    frameHeight: 16,
                                                    paddingEdge: .trailing,
                                                    paddingValue: 8,
                                                    radius: Constants.SizeRadiusConstants.xxSmall
                                                ) {
                                                    selectedSharedListName = groupName
                                                    showDialog = true
                                                }
                                            }
                                            .padding()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                            .animation(.easeInOut, value: wordListSelectorVM.userWordGroups)
                        }
                    }

                    VStack {
                        Spacer()
                        FabButton(
                            action: { showAddNewWordGroupWidget.toggle() },
                            backgroundColor: .addFabButton,
                            foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                            cornerRadius: Constants.SizeRadiusConstants.medium,
                            buttonImageName: Constants.IconTextConstants.addButtonRectangle
                        )

                        FabButton(
                            action: { showDeleteWordGroupWidget.toggle() },
                            backgroundColor: .deleteFabButton,
                            foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                            cornerRadius: Constants.SizeRadiusConstants.medium,
                            buttonImageName: Constants.IconTextConstants.deleteButtonRectangle
                        )
                    }
//TODO: Düzenlenecek, wordlists localization.
                    if showDialog {
                        AddToListDialogView(
                            userLists: wordListSelectorVM.userWordGroups,
                            onConfirm: { selectedListName, wordCount in
                                Task {
//                                    await $wordListSelectorVM.addWords(
//                                        from: selectedSharedListName,
//                                        to: selectedListName,
//                                        count: wordCount
//                                    )
                                    showDialog = false
                                }
                            },
                            onCancel: {
                                showDialog = false
                            }
                        )
                    }
                }
                .animation(.easeInOut, value: showDeleteWordGroupWidget)
                .animation(.easeInOut, value: showAddNewWordGroupWidget)
            }
        }
        .environment(\.locale, .init(identifier: languageManager.currentLanguage))
    }

    private func getDestinationView(groupName: String) -> AnyView {
        switch selectedTargetPage {
        case "wordList":
            return AnyView(WordListView(selectedWordListName: groupName))
        case "multipleChoiceTest":
            return AnyView(MchoiceTestView(selectedWordListName: groupName))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct AddToListDialogView: View {
    let userLists: [String]
    let onConfirm: (_ selectedList: String, _ wordCount: Int) -> Void
    let onCancel: () -> Void

    @State private var selectedList: String
    @State private var selectedCount: Int = 10
    let wordCounts = [10, 25, 50, 100]

    init(userLists: [String], onConfirm: @escaping (_ selectedList: String, _ wordCount: Int) -> Void, onCancel: @escaping () -> Void) {
        self.userLists = userLists
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _selectedList = State(initialValue: userLists.first ?? "")
    }

    var body: some View {
        Color.black.opacity(0.1)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 20) {
                    Text("Kelime Listesi Seç")
                        .font(.headline)

                    Picker("Liste", selection: $selectedList) {
                        ForEach(userLists, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)

                    HStack {
                        ForEach(wordCounts, id: \.self) { count in
                            Button(action: {
                                selectedCount = count
                            }) {
                                Text("\(count)")
                                    .padding()
                                    .background(selectedCount == count ? .blue : .gray)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    HStack {
                        Button("İptal", action: onCancel)
                            .padding()
                        Spacer()
                        Button("Ekle") {
                            onConfirm(selectedList, selectedCount)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .frame(width: 320)
                .background(.thinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
            )
    }
}
