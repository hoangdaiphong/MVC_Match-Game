// TẠO 1 PROJECT SỬ DỤNG MÔ HÌNH MVC
/*
 Mô hình MVC trong dự án iOS
 MVC là viết tắt của 3 từ Model, View và Controller:
 Models: Là dối tượng có vai trò định nghĩa, tổ chức trữ và thao tác trực tiếp với dữ liệu
 Views: Là đối tượng chịu trách nhiệm về hiển thị giao diện hay nói cách khác đó là tầng mà người dùng quan sát và tương tác trực tiếp.
 Controller: Là bộ điều kiển trung gian có vai trò quản lý, điều phối tất cả công việc. Nó truy cập dữ liệu từ Model và quyết định hiển thị nó trên View. Khi có một sự kiện được truyền xuống từ View, Controller quyết định cách thức xử lý: có thể là tương tác với dữ liệu, thay đổi giao diện trên View
 */
/*
 Các bước thực hiện:
 B1: Project Setup: Chỉnh màn hình chỉ nằm nghiêng, thêm thứ tự UI Image View(Auto Layout, chỉnh background), Collection View( AutoLayout),chỉnh kích thước cho Collection View Cell, thêm 2 UI Image View( Autolayout), Đặt Identifier cho Collection View Cell là CardCell
 B2: Custom Classes: Tạo một file swift là CardModel để khởi tạo các cặp bài random và một file swift là Card để khởi tạo đối tượng card, Tạo file CardCollectionViewCell để quản trị cho Collection View Cell( gán file quản trị ở thanh thuộc tính)
 B3: Protocol & Delegates: Ánh xạ 2 Image View vào trong file CardCollectionViewCell, ánh xạ CollectionView vào View Controller và viết các hàm khởi tạo UICollectionViewCell
 B4: Card Flipping: Khởi tạo biến và viết các hàm lật úp bài trong CardCollectionViewCell, viết các hàm khởi tạo cell và ép về CardCollectionViewCell trong ViewController, viết các hàm khi người dùng ấn vào Cell bài sẽ úp hoặc mở
 B5: Game Logic: Tạo thêm biến firstFlippedCardIndex và chỉnh sửa trong hàm selectCell, viết hàm remove trong file CardCollectionViewCell
 B6: Win Condition: Vào mainstoryboad chỉnh CollectionView vào StackView(Ở thanh thuộc tính: Aligment là center và AutoLayout , Sau đó thêm vào một Label kéo vào trong StackView( Chỉnh tiêu đề thành Time Remaining: 10, AutoLayout width và height và căn trái, chỉnh background là clearcolor), Ánh xạ, Tạo biến timer, milliseconds và viết hàm thời gian, hàm hiện thông báo
 B7: Sounds: Tạo một thư mục mới chứa file âm thanh và thêm framework AVFoundation vào, tạo thêm file swift SoundManager, viết hàm viewDidAppear và viết thêm code âm thanh ở ViewController
 */


import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var model = CardModel()
    var cardArray = [Card]()
    
    var firstFlippedCardIndex: IndexPath?
    
    var timer: Timer?
    var milliseconds: Float = 30 * 1000 // 10 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the gerCards method of the card model
        cardArray = model.getCards()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Create timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        SoundManager.playSound(.shuffle)
    }
    
    // MARK: Timer Methods
    
    @objc func timerElapsed() {
        
        milliseconds -= 1
        
        // Convert to seconds
        let seconds = String(format: "%.2f", milliseconds/1000)
        
        // Set label
        timerLabel.text = "Time Remaining: \(seconds)"
        
        // When the timer has reached 0...
        if milliseconds <= 0 {
            
            // Stop the timer
            timer?.invalidate()
            timerLabel.textColor = .red
            
            // Check if there are any cards unmatched
            checkGameEnded()
        }
    }

    // MARK: UICollectionView Protocol Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get an CardCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Get the card hat the collection view is trying to display
        let card = cardArray[indexPath.row]
        
        // Set that card for the cell
        cell.setCard(card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if there's any time left
        if milliseconds <= 0 {
            return
        }
        
        // Get the cell that the user selected
        let cell =  collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        // Get the card that the user selected
        let card = cardArray[indexPath.row]
        
        if card.isFlipped == false && card.isMatched == false {
            
            // Flip the card
            cell.flip()
            
            // Play the flip sound
            SoundManager.playSound(.flip)
            
            // Set the status of the card
            card.isFlipped = true
            
            // Determine if it's the first card or second card that's flipped over
            if firstFlippedCardIndex == nil {
                
                // This is the first card being flipped
                firstFlippedCardIndex = indexPath
            }
            else {
                
                // This is the second card being flipped
                
                // Perform the maching logic
                checkForMatches(indexPath)
            }
        }
        else {
            
            // Flip the card back
            cell.flipBack()
            
            // Set the status of the card
            card.isFlipped = false
        }
        
    } // End the didSeclectItemAt method
    
    // MARK: - Game Logic Methods
    
    func checkForMatches(_ secondFlippedCardIndex: IndexPath) {
        
        // Get the cells for the two cards that were revealed
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        // Get the cards for the two cards that were revealed
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        // Compare the two cards:
        if cardOne.imageName == cardTwo.imageName {
            
            // It's a match
            
            // Play sound
            SoundManager.playSound(.match)
            
            // Set the statuses of the cards
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            // Remove the cards from the grid
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Check if there are any cards left unmatched
            checkGameEnded()
        }
        else {
            
            // It's not a match
            
            // Play sound
            SoundManager.playSound(.nomatch)
            
            // Set the statuses of the cards
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Flip both cards back
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
        }
        
        // Tell the collectionview to reload the cell of the first card if it is nil
        if cardOneCell == nil {
            
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        // Reset the property that tracks the first card flipped
        firstFlippedCardIndex = nil
    }
    
    func checkGameEnded() {
        
        // Determine if there are any cards unmatched
        var isWon = true
        
        for card in cardArray {
            
            if card.isMatched == false {
                
                isWon = false
                break
            }
        }
        
        // Messaging variables
        var title = ""
        var message = ""
        
        // If not, then user has won, stop the timer
        if isWon == true {
            
            if milliseconds > 0 {
                
                timer?.invalidate()
            }
            
            title = "Congratulations!"
            message = "You've won"
        }
        else {
            
            // If there are unmatched cards, check if there's any time left
            if milliseconds > 0 {
                
                return
            }
            
            title = "Game Over"
            message = "You've lost"
            
        }
        
        // Show won/lost messaging
        showAlert(title, message)
    }
    
    func showAlert(_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
} // End ViewController class


