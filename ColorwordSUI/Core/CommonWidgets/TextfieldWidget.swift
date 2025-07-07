import SwiftUI

struct TextfieldWidget: View {
    @Binding var text: String
    var keyboardType: UIKeyboardType?
    var hintKey: LocalizedStringKey  
    var textInputAutoCapitalization: TextInputAutocapitalization?

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(hintKey)
                        .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                        .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                }
                TextField("", text: $text)
                    .keyboardType(keyboardType ?? .default)
                    .textInputAutocapitalization(textInputAutoCapitalization ?? .none)
                    .padding(12)
                    .background(Color.white.opacity(0.05).blur(radius: 50))
                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                    .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                    .padding(.all, Constants.PaddingSizeConstants.xxSmallSize)
                    .foregroundColor(.white.opacity(0.8))
                
            }
        }
    }
}
