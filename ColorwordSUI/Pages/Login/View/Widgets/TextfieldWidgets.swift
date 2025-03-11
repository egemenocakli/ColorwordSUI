import SwiftUI

struct TextfieldWidgets: View {
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        
        TextfieldWidget(text: $email, keyboardType: .emailAddress, hintKey: "email",textInputAutoCapitalization: .never)
            
        SecureTextfieldWidget(password: $password)
        
    }
}
