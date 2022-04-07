//
//  ChatVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 06.04.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Member: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    let text: String
    let messageId: String
    
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}

class ChatVC: MessagesViewController {

    var messages: [Message] = []
    var member: Member!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        member = Member(senderId: "1234", displayName: "Stepa")
        messages.append(Message(sender: member, text: "y yo yo", messageId: "dkfbvhdkfb"))
        //self.messageInputBar.setup()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.backgroundColor = .blue
        messageInputBar.bottomStackView.addArrangedSubview(view)
    }
}

extension ChatVC: MessagesDataSource {
    
  func numberOfSections(
    in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func currentSender() -> SenderType {
    return member
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 12
  }
  
  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return NSAttributedString(
      string: message.sender.displayName,
      attributes: [.font: UIFont.systemFont(ofSize: 12)])
  }
}


extension ChatVC: MessagesLayoutDelegate {
  func heightForLocation(message: MessageType,
    at indexPath: IndexPath,
    with maxWidth: CGFloat,
    in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    
    return 0
  }
}


extension ChatVC: MessagesDisplayDelegate {
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    
    //let message = messages[indexPath.section]
    
  }
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(
            sender: member,
            text: text,
            messageId: UUID().uuidString)
        
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}





