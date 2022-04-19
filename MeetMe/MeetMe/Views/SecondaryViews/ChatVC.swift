//
//  ChatVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 06.04.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Accelerate
import Kingfisher

/// Контроллер, отвечающий за работу чата мероприятия
class ChatVC: MessagesViewController {
    /// Индикатор загрузки новых сообщений
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMessages), for: .valueChanged)
        return control
    }()
    /// Сообщения чата
    private var messages: [ChatMessage] = []
    /// Отправитель сообщений (текущий пользователь)
    private var currentMessageSender: SenderType!
    /// Мероприятия, чат которого отображается
    var meeting: Meeting!
    /// Форматер даты
    private let formatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "HH"
        currentMessageSender = MessageSender(senderId: User.currentUser.account!.id.description, displayName: User.currentUser.account!.name, avatarURL: User.currentUser.account!.imageDataURL)
        let viewMeetingButton = UIBarButtonItem.init(title: "О событии", style: .plain, target: self, action: #selector(viewMeeting))
        navigationItem.rightBarButtonItem = viewMeetingButton
        
        loadFirstMessages()
        view.backgroundColor = UIColor(named: "BackgroundDarker")
        messagesCollectionView.backgroundColor = UIColor(named: "BackgroundDarker")
        title = meeting.name
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    /// Проверка, является ли отправитель предыдущего сообщения тем же человеком что и текущего
    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    /// Проверка, является ли отправитель следующего сообщения тем же человеком что и текущего
    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 >= 0 else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }
    
    /// Проверка на разницу во времени между отправкой текующего сообщения и предыдущего
    private func isTimeDifferenceBig(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return true }
        return !formatter.string(from: messages[indexPath.section].sentDate).elementsEqual(formatter.string(from: messages[indexPath.section - 1].sentDate))
    }
    
    /// Отображение контроллера MeetingInfoVC с текущей информацией о мероприятии
    @objc private func viewMeeting() {
        let vc = MeetingInfoVC()
        vc.meeting = meeting
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Загрузка последних сообщений в чате
    private func loadFirstMessages() {
        ChatRequests.shared.getMessages(anchor: 0, messageNumber: 20, chatId: meeting.chatID, completion: {(messages, error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if let messages = messages {
                self.messages.append(contentsOf: messages)
                self.messages.reverse()
                self.refreshControl.endRefreshing()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        })
    }
    
    /// Подгрузка предыдущих сообщений чата
    @objc private func loadMessages() {
        ChatRequests.shared.getMessages(anchor: Int64(messages.first?.messageId ?? "0")!, messageNumber: 20, chatId: meeting.chatID, completion: {(messages, error) in
            print("Loading 20 messages for achor: \(Int64(self.messages.first?.messageId ?? "0")!))")
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if let messages = messages {
                print("Loaded \(messages.count) messages")
                self.messages.insert(contentsOf: messages.reversed(), at: 0)
                self.refreshControl.endRefreshing()
                self.messagesCollectionView.reloadData()
            }
        })
    }
    
    /// Получение изображения из кэша 
    private func getSingleImage(with urlString : String) -> UIImage? {
        guard let url = URL.init(string: urlString) else {
            return  nil
        }
        let resource = ImageResource(downloadURL: url)
        var image:  UIImage?
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                image = value.image
            case .failure:
                image = nil
            }
        }
        return image
    }
    
    // MARK: Config
    /// Формирование части экрана, отображающей список сообщений
    private func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        showMessageTimestampOnSwipeLeft = true
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
    
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        
        messagesCollectionView.refreshControl = refreshControl
    }
    
    /// Формирование части экрана, отображающей поле для ввода сообщения
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.systemBlue.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
}


extension ChatVC: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentMessageSender
    }
    
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
            return messages.count
        }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isPreviousMessageSameSender(at: indexPath) ? 0 : 15
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 0 : 12
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeDifferenceBig(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeDifferenceBig(at: indexPath) {
            return 10
        }
        return 0
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
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
        
        let sender = messages[indexPath.section].sender as! MessageSender
        
        let nameSplit = sender.displayName.split(separator: " ")
        if nameSplit.count > 1 {
            let initials = "\(nameSplit[0].first ?? "S")\(nameSplit[1].first ?? "R")"
            avatarView.set(avatar: Avatar(image: getSingleImage(with: sender.avatarURL), initials: initials))
        } else {
            let initials = "\(nameSplit[0].first ?? "S")"
            avatarView.set(avatar: Avatar(image: getSingleImage(with: sender.avatarURL), initials: initials))
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        ChatRequests.shared.sendMessage(content: text.trimmingCharacters(in: .whitespacesAndNewlines), chatId: meeting.chatID, senderId: User.currentUser.account!.id, completion: {(messageID, error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.messages.append(ChatMessage(sender: self.currentMessageSender, messageId: messageID!.description, sentDate: Date(), content: text.trimmingCharacters(in: .whitespacesAndNewlines)))
            print(self.messages)
            inputBar.inputTextView.text = ""
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        })
    }
}





