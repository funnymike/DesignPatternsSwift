// MARK: - 组合模式

import Foundation

protocol File {
    var name: String {
        get
    }
    func open()
}

final class eBook: File {
    var name: String
    var author: String
    
    init(name: String, author: String) {
        self.name = name
        self.author = author
    }
    
    func open() {
        print("Opening \(name) by \(author) in iBooks...\n")
    }
}

final class Music: File {
    var name: String, artist: String
    
    init(name: String, artist: String) {
        self.name = name
        self.artist = artist
    }
    
    func open() {
        print("Playing \(name) by \(artist) in iTunes...\n")
    }
}

class Folder: File {
    var name: String
    lazy var files: [File] = []
    
    init(name: String) {
        self.name = name
    }
    
    func addFile(_ file: File) {
        self.files.append(file)
    }
    
    func open() {
        print("Displaying the following files in \(name)...")
        for file in files {
            print(file.name)
        }
        print("\n")
    }
}

let psychoKiller = Music(name: "Psycho Killer", artist: "The Talking Heads")
let rebelRebel = Music(name: "Rebel Rebel", artist: "David Bowie")
let blisterInTheSun = Music(name: "Blister in the Sun", artist: "Violent Femmes")

let justKids = eBook(name: "Just Kids", author: "Patti Smith")
let documents = Folder(name: "Documents")
let musicFolder = Folder(name: "Great 70s Music")

documents.addFile(musicFolder)
documents.addFile(justKids)
musicFolder.addFile(psychoKiller)
musicFolder.addFile(rebelRebel)
blisterInTheSun.open()
justKids.open()
documents.open()
musicFolder.open()

//Playing Blister in the Sun by Violent Femmes in iTunes...
//
//Opening Just Kids by Patti Smith in iBooks...
//
//Displaying the following files in Documents...
//Great 70s Music
//Just Kids
//
//
//Displaying the following files in Great 70s Music...
//Psycho Killer
//Rebel Rebel
