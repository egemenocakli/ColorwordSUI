import SwiftUI

struct TextfieldWidgets: View {
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .leading) {
                    if email.isEmpty {
                        Text("email")
                            .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                            .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                    }
                    TextField("", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                        .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                        .foregroundColor(.white)
                }
            }
            
            VStack {
                ZStack(alignment: .leading) {
                    if password.isEmpty {
                        Text("login_password")
                            .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                            .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                    }
                    SecureField("", text: $password)
                        .textInputAutocapitalization(.none)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                        .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, Constants.PaddingSizeConstants.smallSize)
        }
    }
}
