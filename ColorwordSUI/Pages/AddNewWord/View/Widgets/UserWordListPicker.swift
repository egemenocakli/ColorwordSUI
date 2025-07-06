
 //
 //  userWordListPicker.swift
 //  ColorwordSUI
 //
 //  Created by Emre Ocaklı on 21.06.2025.
 //

 import SwiftUI

 struct UserWordListPicker: View {
     
     @ObservedObject var addNewWordVM: AddNewWordViewModel
     @Binding var showNewWordGroupWidget: Bool
     @EnvironmentObject var languageManager: LanguageManager
     
     
     var body: some View {
         
         
         HStack {
             
             Text("selected_user_word_list")
                 .font(.system(size: 20))
                 .fontWeight(.bold)
                 .foregroundStyle(Color.textColorWhite)

             Picker("Selection", selection: Binding<String>(
                 get: { addNewWordVM.selectedUserWordGroup },
                 set: { addNewWordVM.selectedUserWordGroup = $0 }
             )) {
                 ForEach(addNewWordVM.userWordGroups, id: \.self) { userWordGroup in
                     
                     let displayText: LocalizedStringKey = userWordGroup == "wordLists" ? "word_lists" : LocalizedStringKey(userWordGroup)
                     
                     Text(displayText)
                         .tag(userWordGroup)
                         .font(.subheadline)
                         .fontWeight(.bold)
                         .foregroundStyle(Color.textColorWhite)
                 }
             }
             .background(.pickerButton)
             .accentColor(.pickerButtonText)
             .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
             .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
             .font(.subheadline)
             .foregroundStyle(Color.textColorWhite)
             .padding(.trailing, 10)
             .onChange(of: addNewWordVM.selectedUserWordGroup) { oldValue, newValue in
                 Task {
                     try await  addNewWordVM.orderWordGroup(languageListName: newValue)
                 }
                 debugPrint("Seçili kelime listesi değiştirildi. \(newValue)")
             }
         
                         Button(action: {
                             showNewWordGroupWidget = true
             
                         } ) {
                             Image(systemName: Constants.IconTextConstants.addButtonRectangle)
                             .resizable()
                             .scaledToFit()
                             .frame(width: 16, height: 16)
                             .padding(8)
                         }
                         .foregroundStyle(Constants.ColorConstants.buttonForegroundColor)
                         .background(.translateButton)
                         .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xSmall))
                         .shadow(radius: Constants.SizeRadiusConstants.xSmall)
                     }
             .environment(\.locale, .init(identifier: languageManager.currentLanguage))
         }
         
     }
