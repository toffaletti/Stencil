import Foundation
import Spectre
@testable import Stencil


#if os(OSX)
@objc class Object : NSObject {
  let title = "Hello World"
}
#endif

fileprivate struct Wallet {
    let cash: String?
}

fileprivate struct Person {
  let name: String
  let nickname: String?
  let wallet: Wallet?
}

fileprivate struct Article {
  let author: Person
}


func testVariable() {
  describe("Variable") {
    let context = Context(dictionary: [
      "name": "Kyle",
      "contacts": ["Katie", "Carlton"],
      "profiles": [
        "github": "kylef",
      ],
      "article": Article(author: Person(name: "Kyle", nickname: "Ky", wallet: Wallet(cash: "Money")))
    ])

#if os(OSX)
    context["object"] = Object()
#endif

    $0.it("can resolve a string literal with double quotes") {
      let variable = Variable("\"name\"")
      let result = try variable.resolve(context) as? String
      try expect(result) == "name"
    }

    $0.it("can resolve a string literal with single quotes") {
      let variable = Variable("'name'")
      let result = try variable.resolve(context) as? String
      try expect(result) == "name"
    }

    $0.it("can resolve an integer literal") {
      let variable = Variable("5")
      let result = try variable.resolve(context) as? Number
      try expect(result) == 5
    }

    $0.it("can resolve an float literal") {
      let variable = Variable("3.14")
      let result = try variable.resolve(context) as? Number
      try expect(result) == 3.14
    }

    $0.it("can resolve a string variable") {
      let variable = Variable("name")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Kyle"
    }

    $0.it("can resolve an item from a dictionary") {
      let variable = Variable("profiles.github")
      let result = try variable.resolve(context) as? String
      try expect(result) == "kylef"
    }

    $0.it("can resolve an item from an array via it's index") {
      let variable = Variable("contacts.0")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Katie"

        let variable1 = Variable("contacts.1")
        let result1 = try variable1.resolve(context) as? String
        try expect(result1) == "Carlton"
    }

    $0.it("can resolve an item from an array via unknown index") {
      let variable = Variable("contacts.5")
      let result = try variable.resolve(context) as? String
      try expect(result).to.beNil()

      let variable1 = Variable("contacts.-5")
      let result1 = try variable1.resolve(context) as? String
      try expect(result1).to.beNil()
    }

    $0.it("can resolve the first item from an array") {
      let variable = Variable("contacts.first")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Katie"
    }

    $0.it("can resolve the last item from an array") {
      let variable = Variable("contacts.last")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Carlton"
    }

    $0.it("can resolve a property with reflection") {
      let variable = Variable("article.author.name")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Kyle"
    }

    $0.it("can resolve an optional property with reflection") {
      let variable = Variable("article.author.nickname")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Ky"
    }

    $0.it("can resolve nested optional property with reflection") {
      let variable = Variable("article.author.wallet.cash")
      let result = try variable.resolve(context) as? String 
      try expect(result) == "Money"
    }



#if os(OSX)
    $0.it("can resolve a value via KVO") {
      let variable = Variable("object.title")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Hello World"
    }
#endif
  }
}
