import Foundation
import SwiftUI
import SwiftUICore
struct AddNewWordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var addNewWordVM = AddNewWordViewModel()
    
    @State var showPicker = false
    @State private  var showNewWordGroupWidget = false
    
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
                                
                                CreateNewWordGroup(addNewWordVM: addNewWordVM,showNewWordGroupWidget: $showNewWordGroupWidget)
                            }
                            

                            TextWidget(text: "select_target_language", font: .largeTitle,paddingEdges: .top, paddingValue: 50, foregroundColor: Constants.ColorConstants.whiteColor,fontWeight: .bold)

                            
                            LanguagePicker(selectedLanguage: addNewWordVM.mainLanguage ?? supportedLanguages[46], targetLanguage: addNewWordVM.mainLanguage ?? supportedLanguages[117], addNewWordVM: addNewWordVM)
                                .padding(Constants.PaddingSizeConstants.xxSmallSize)
                            
                            //TODO: widgetları düzenle
                            
                            TranslateTextEditorWidget(addNewWordVM: addNewWordVM)
                            
                            TranslateButton(addNewWordVM: addNewWordVM)
                            
                            if let errorMessage = addNewWordVM.errorMessage {
                                Text("error" + ": \(errorMessage)")
                                    .foregroundColor(.red)
                            } else {
                                
                                DetectLangText(addNewWordVM: addNewWordVM)
                                
                                Text(addNewWordVM.translatedText)
                                    .fontWeight(.bold)
                                    .font(.system(size: Constants.FontSizeConstants.x4Large))
                                    .foregroundStyle(Color.textColorWhite)
                                    .padding(Constants.PaddingSizeConstants.xxSmallSize)
                                
                                
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
