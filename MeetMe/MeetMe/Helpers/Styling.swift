

import Foundation
import UIKit

/// Класс для стилизации UI элеентов
class Styling {
    
    /// Стилизация текстового поля 1
    static func styleTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.systemBlue.cgColor
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
    }
    
    /// Стилизация заполненной кнопки
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 15.0
        button.tintColor = UIColor.white
    }
    
    /// Стилизация пустой кнопки
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 15.0
        button.tintColor = UIColor.systemBlue
    }
    
    /// Стилизация кнопки
    static func styleButton(_ button:UIButton) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.setTitleColor(.systemBlue, for: .normal)
    }
    
    /// Стилизация UI элемента для отображения картинки 1
    static func styleImageView1(_ imageView:UIImageView) {
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    /// Стилизация UI элемента для отображения картинки 2
    static func styleImageView2(_ imageView:UIImageView) {
        
    }
    
    /// Стилизация текстового пространства 1
    static func styleTextView1(_ textView:UITextView ) {
        
    }
    
    /// Стилизация текстового пространства 2
    static func styleTextView2(_ textView:UITextView ) {
        
    }
    
    /// Стилизация текстового поля 2
    static func styleTextField2(_ textField: UITextField) {
        
    }
    
    /// Стилизация view c элементами
    static func styleContainerView(_ view: UIView) {
        
    }
    
    /// Получение списка инетерсов в виде строки из массива интересов
    static func getInterests(interestArray: [Interests]) -> String {
        var interests = ""
        for interest in interestArray {
            interests += interest.rawValue + ", "
        }
        return interests
    }
    
}
