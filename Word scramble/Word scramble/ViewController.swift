//
//  ViewController.swift
//  Word scramble
//
//  Created by hoom on 25/06/1444 AH.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        //load the words from the file
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }
    
    @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self ,weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac , animated: true)
    }
    
    func submit(_ answer: String){
        let loweranswer = answer.lowercased()
        
        if isPossible(word: loweranswer){
            
            if isOriginal(word: loweranswer){
                
                if isReal(word: loweranswer){
                    
                    usedWords.insert(answer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                    
                }else{
                    errormessages("Word not recognized",withTitle: "You can't make them up!")
                }
            }else{
                errormessages("Word already used", withTitle: "Think agin!")
                
            }
        }else{
            errormessages("Word not possible", withTitle: "You can't spell that worsd from \(title!.lowercased()).")
          
        }
        
    }
    
    func isPossible (word: String)->Bool{
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }else{
                return false
            }
        }
        
        return true
    }
    
    func isOriginal (word: String)->Bool{
        guard word != title else {
            errormessages("You enterd the same word as the title",withTitle: "Oops")
            return false
            }
        return !usedWords.contains(word)
    }
    
    func isReal (word: String)->Bool{
        
        guard word.count > 3 else {
            errormessages("The word is to short! 3 letters or more.",withTitle: "Oops")
            return false
            
            }

        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func errormessages(_ errorMessage: String, withTitle errorTitle: String){
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        
    }
    
    


}

