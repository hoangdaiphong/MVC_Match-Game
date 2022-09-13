//
//  CardModel.swift
//  MVC_Match Game
//
//  Created by Hoang Dai Phong on 2020/02/11.
//  Copyright © 2020 Hoang Dai Phong. All rights reserved.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
        
        // Declare an array to store numbers we've already generated
        var generatedNumbersArray = [Int]()
        
        // Declare an array to store the generated cards
        // Khai báo một mảng để lưu trữ các thẻ đã tạo
        var generatedCardsArray = [Card]()
        
        // Randomly generate pairs of cards
        // Tạo ngẫu nhiên các cặp thẻ
        while generatedCardsArray.count < 16 {
        
            //Get a random number
            let randomNumber = arc4random_uniform(13) + 1
            
            // Ensure that the random number isn't one we already have
            if generatedNumbersArray.contains(Int(randomNumber)) == false {
                
                // Log the number
                print("generating a random number \(randomNumber)")
                
                // Store the number into the generateNumbersArray
                generatedNumbersArray.append(Int(randomNumber))
                
                // Create the first card object
                let cardOne = Card()
                cardOne.imageName = "card\(randomNumber)"
                
                generatedCardsArray.append(cardOne)
                
                // Create the second card object
                let cardTwo = Card()
                cardTwo.imageName = "card\(randomNumber)"
                
                generatedCardsArray.append(cardTwo)
            }
        }
        
        // Randomize the array
        for i in 0..<generatedCardsArray.count {
            
            // Find a random index to swap with
            let randomNumber = Int(arc4random_uniform(UInt32(generatedCardsArray.count)))
            
            // Swap the two cards
            let temporaryStorage = generatedCardsArray[i]
            generatedCardsArray[i] = generatedCardsArray[randomNumber]
            generatedCardsArray[randomNumber] = temporaryStorage
        }
       
        // Return the array
        return generatedCardsArray
    }
}
