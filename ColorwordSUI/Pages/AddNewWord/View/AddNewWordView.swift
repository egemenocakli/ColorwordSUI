import Foundation
import SwiftUI
import SwiftUICore

struct AddNewWordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var addNewWordVM = AddNewWordViewModel()
    
    @State var showPicker = false


    //TODO: yeni kelime eklenirken çekilen dil listeleri gösterilceki kelime seçilenin altına eklenece
    //TODO: Yeni liste ekle yeri olacak bu metod oraya çağırılacak
    
    //TODO: localization eklenecek
    //widgetlar dağıtılacak ve temizlenecek.
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    VStack {
                        
                        //Geçerli dil listesi
                        
                        HStack {
                            
                            Text("Seçili Dil Listeniz:")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Picker("Selection", selection: Binding<String>(
                                get: { addNewWordVM.selectedUserWordGroup },
                                set: { addNewWordVM.selectedUserWordGroup = $0 }
                            )) {
                                ForEach(addNewWordVM.userWordGroups, id: \.self) { userWordGroup in
                                    Text(userWordGroup)
                                        .tag(userWordGroup)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                            .background(.pickerButton)
                            .accentColor(.pickerButtonText)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
                            .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            //                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            //                            addNewWordVM.mainLanguage = selectedLanguage ?? supportedLanguages[46]
                            //                            debugPrint("değiştirdim", selectedLanguage?.id as Any)
                            //                        }
                            
                            
                            //Tıklanınca bir alan açılsın text girilsin aşağıdaki metoda verilsin.
                            Button( action:  {
                                do {
                                    Task{
                                        try await addNewWordVM.createWordGroup(languageListName: "asd")
                                    }
                                }catch {
                                    debugPrint("Yeni kelime grubu eklenemedi")
                                }
                            }) {
                                Image(systemName: Constants.IconTextConstants.addButtonRectangle)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16) // doğrudan ikon boyutu
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.green.opacity(1))
                                    .clipShape(Circle())
                            }

                        }

                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        Text("Hedef dil seçiniz")
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
                                    //TODO: en son kullanılan hangisiyse onu al. fav listten
                                    await addNewWordVM.translate(text: addNewWordVM.enteredWord, from: addNewWordVM.mainLanguage ?? supportedLanguages[46], to: addNewWordVM.targetLanguage ?? supportedLanguages[117])
                                }

                            }) {
                                Text("Çevir")
                                
                            }
                            .foregroundStyle(Constants.ColorConstants.whiteColor)
                            .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                            .background(.translateButton)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                            Spacer()
                            
                            if let errorMessage = addNewWordVM.errorMessage {
                                Text("Hata: \(errorMessage)")
                                    .foregroundColor(.red)
                            } else {
                                
                                DetectedLangText(addNewWordVM: addNewWordVM)

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
        

        //TODO: taşınacak mümkünse
        struct LanguagePicker: View {
            @State  var selectedLanguage: Language? //= supportedLanguages[0]
            @State  var targetLanguage: Language? //= supportedLanguages[0]
            
            @ObservedObject var addNewWordVM: AddNewWordViewModel

            
            
            var body: some View {
                
                HStack {
                    
                    
                    Picker("Selection", selection: $selectedLanguage) {
                        ForEach(addNewWordVM.mainLangList, id: \.id) { language in
                            Text(language.name)
                                .tag(language)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    .background(.pickerButton)
                    .accentColor(.pickerButtonText)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
                    .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .onChange(of: selectedLanguage) { oldValue, newValue in
                        addNewWordVM.mainLanguage = selectedLanguage ?? supportedLanguages[46]
                        debugPrint("değiştirdim", selectedLanguage?.id as Any)
                    }
                    
                    Button{
                        //TODO: başlangıçta içeriklerinin nill olması sıkıntı. cacheten son seçilen olarak gelecek.
                        selectedLanguage = addNewWordVM.targetLanguage ?? supportedLanguages[117]
                        targetLanguage = addNewWordVM.mainLanguage ?? supportedLanguages[46]
                        addNewWordVM.mainLanguage = targetLanguage
                        addNewWordVM.targetLanguage = selectedLanguage
                    }label: {
                        Image(systemName: "arrow.left.arrow.right")
                            .frame(width: 60,height: 60)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    //TODO: fav list eklencek veritabanına
                    Picker("Selection", selection: $targetLanguage) {
                        ForEach(addNewWordVM.targetLangList, id: \.id) { language in
                            Text(language.name)
                                .tag(language)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    .background(.pickerButton)
                    .accentColor(.pickerButtonText)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
                    .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .onChange(of: targetLanguage) { oldValue, newValue in
                        addNewWordVM.targetLanguage = targetLanguage ?? supportedLanguages[117]
                        debugPrint("değiştirdim", targetLanguage?.id as Any)

                    }
                }
            }
        }
    
    //Gelen güven değerini de ekleyeceğim.
    struct DetectedLangText: View {
        @ObservedObject var addNewWordVM: AddNewWordViewModel

        
        var body: some View {

            if (addNewWordVM.detectedLanguageId != nil && addNewWordVM.mainLanguage?.id == "") {
                Text("Detected Language: " + "\(addNewWordVM.detectedLanguage ?? "")")
                    .font(.system(size: Constants.FontSizeConstants.x2Large))
                    .foregroundStyle(Color.textColorWhite)
                    .padding()

            }else {
                EmptyView()
            }
            
        }
    }
}

#Preview {
    AddNewWordView()
}
