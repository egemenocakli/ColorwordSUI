import Foundation
import SwiftUI
import SwiftUICore
struct AddNewWordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var addNewWordVM = AddNewWordViewModel()
    
    @State var showPicker = false
    @State private  var showNewWordGroupWidget = false
    
    
    
    //TODO: yeni kelime eklenirken çekilen dil listeleri gösterilceki kelime seçilenin altına eklenece
    //TODO: Yeni liste ekle yeri olacak bu metod oraya çağırılacak
    //widgetlar dağıtılacak ve temizlenecek.
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                
                
                if(addNewWordVM.userWordGroups.count == 0){
                    
                    ProgressView("loading")
                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                        .task {
                            Task{
                                try await addNewWordVM.createWordGroup(languageListName: "wordLists")
                            }
                        }
                    
                }else {
                    GeometryReader { geometry in
                        VStack {
                            
                            ///Kaydedilen listeyi en son seçileni en üste gelecek şekilde gösterir.
                            if(!showNewWordGroupWidget) {
                                UserWordListPicker(addNewWordVM: addNewWordVM,showNewWordGroupWidget: $showNewWordGroupWidget)
                                
                            }else {
                                
                                Text("enter_new_word_list_name")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                HStack{
                                    //TODO: bu text editorler common widgeta eklenecek
                                    
                                    TextEditor(text: $addNewWordVM.newWordGroupName)
                                        .fontWeight(.bold)
                                        .font(.system(size: Constants.FontSizeConstants.large))
                                        .foregroundStyle(Color.textColorWhite)
                                        .padding(16)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.white.opacity(0.05).blur(radius: 50))
                                        .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                                        .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                                        .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                                        .padding(.trailing, 10)
                                        .frame(minHeight: 40, maxHeight: 70)
                                        .limitTextEditorCharacters($addNewWordVM.newWordGroupName, limit: 15)
                                    
                                    
                                    
                                    Button( action:  {
                                        if(!addNewWordVM.newWordGroupName.isEmpty){
                                            
                                            Task{
                                                do {
                                                    try await addNewWordVM.createWordGroup(languageListName: addNewWordVM.newWordGroupName)
                                                    addNewWordVM.newWordGroupName = ""
                                                    
                                                }catch {
                                                    debugPrint("Yeni kelime grubu eklenemedi")
                                                    addNewWordVM.newWordGroupName = ""
                                                }
                                                
                                                showNewWordGroupWidget = false
                                            }
                                        }
                                        
                                    }) {
                                        Image(systemName: Constants.IconTextConstants.correctFillButton)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.green)
                                            .background(.white)
                                            .clipShape(Circle())
                                    }
                                    .padding(.trailing, 8)
                                    
                                    Button( action:  {
                                        showNewWordGroupWidget = false
                                    }) {
                                        Image(systemName: Constants.IconTextConstants.wrongButtonCircleFill)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.red)
                                            .background(.white)
                                            .clipShape(Circle())
                                        
                                    }
                                    .padding(.trailing, 16)
                                    
                                    
                                }
                            }
                            
                            
                            
                            Text("select_target_language")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 50)
                                .foregroundStyle(.white)
                            
                            LanguagePicker(selectedLanguage: addNewWordVM.mainLanguage ?? supportedLanguages[46], targetLanguage: addNewWordVM.mainLanguage ?? supportedLanguages[117], addNewWordVM: addNewWordVM)
                                .padding(10)
                            
                            
                            TextEditor(text: $addNewWordVM.enteredWord)
                                .fontWeight(.bold)
                                .font(.system(size: Constants.FontSizeConstants.x2Large))
                                .foregroundStyle(Color.textColorWhite)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.white.opacity(0.05).blur(radius: 50))
                                .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                                .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                                .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                                .frame(minHeight: 60, maxHeight: 110)
                                .limitTextEditorCharacters($addNewWordVM.enteredWord, limit: 40)
                            Button(action: {
                                Task{
                                    await addNewWordVM.translate(text: addNewWordVM.enteredWord, from: addNewWordVM.mainLanguage ?? supportedLanguages[46], to: addNewWordVM.targetLanguage ?? supportedLanguages[117])
                                }
                                
                            }) {
                                Text("translate")
                                
                            }
                            .foregroundStyle(Constants.ColorConstants.whiteColor)
                            .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                            .background(.translateButton)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                            Spacer()
                            
                            if let errorMessage = addNewWordVM.errorMessage {
                                Text("error" + ": \(errorMessage)")
                                    .foregroundColor(.red)
                            } else {
                                
                                DetectLangText(addNewWordVM: addNewWordVM)
                                
                                Text(addNewWordVM.translatedText)
                                    .fontWeight(.bold)
                                    .font(.system(size: Constants.FontSizeConstants.x4Large))
                                    .foregroundStyle(Color.textColorWhite)
                                    .padding(10)
                                
                                
                            }
                            
                            Spacer()
                            FabButton(action: {
                                
                                Task {
                                    do{
                                        try await addNewWordVM.addNewWord()
                                    }catch {
                                        
                                    }
                                }
                            }, backgroundColor: .addFabButton,
                                      foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                                      cornerRadius: Constants.SizeRadiusConstants.medium,
                                      buttonImageName: Constants.IconTextConstants.addButtonRectangle)
                        }
                    }
                    
                    .animation(.easeInOut, value: showNewWordGroupWidget)
                    
                    .onAppear(){
                        addNewWordVM.loadAzureKFromKeychain()
                        
                        Task{
                            do {
                                try await addNewWordVM.getFavLanguages()
                                try await addNewWordVM.getWordGroups()
                            }catch{
                                throw error
                            }
                        }
                        if !addNewWordVM.userWordGroups.contains(addNewWordVM.selectedUserWordGroup) {
                            addNewWordVM.selectedUserWordGroup = addNewWordVM.userWordGroups.first ?? ""
                        }
                    }
                    
                    
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                    .preferredColorScheme(themeManager.colorScheme)
                    
                }
            }
        }
        
    }
}
   
//
//#Preview {
//    AddNewWordView()
//}
