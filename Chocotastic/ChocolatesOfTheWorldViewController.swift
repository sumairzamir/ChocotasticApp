/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  // Sets the property as an observable
  // Just indicates no changes will be made to underlying value of the observable
  // Using just may suggest that an Rx implementation is overkill - case specific
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  private let disposeBag = DisposeBag()
}

//MARK: View Lifecycle
extension ChocolatesOfTheWorldViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
//    tableView.dataSource = self
//    tableView.delegate = self
    
    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    updateCartButton()
  }
}

//MARK: - Rx Setup
private extension ChocolatesOfTheWorldViewController {
  
  func setupCartObserver() {
    //1
    // This creates an observable on chocolates in the shopping cart
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: { //2
        // For ARC purposes and retain cycle management re: unowned self
        // Everytime the chocolate variable changes a notification is sent to the observer
        // Each time this notification is received the count is updated
        [unowned self] chocolates in
        self.cartButton.title = "\(chocolates.count) 🍫"
      })
      // The retain cycle is disposed
      .disposed(by: disposeBag) //3
  }
  
  func setupCellConfiguration() {
    ///
    europeanChocolates
      // Bind the europeanChocolates observable to the tableView
      .bind(to: tableView
        // Access the RxCocoa extension
        .rx
        // Specify the cell identifier similar to UITableViewDataSource
        .items(cellIdentifier: ChocolateCell.Identifier,
               cellType: ChocolateCell.self)) {
                // For each row, pass in the following information
                row, chocolate, cell in
                cell.configureWithChocolate(chocolate: chocolate)
    }
    .disposed(by: disposeBag)
  }
  
  func setupCellTapHandling() {
    tableView
      .rx
      // Passes in a Chocolate model type as an observable
      .modelSelected(Chocolate.self)
      // What to do when a model is selected, i.e. a row is selected
      .subscribe(onNext: { [unowned self] chocolate in
        let newValue = ShoppingCart.sharedCart.chocolates.value + [chocolate]
        // Add the selected chocolate to the cart - this also leads to an increment of the count
        ShoppingCart.sharedCart.chocolates.accept(newValue)
        
        // Deselect the tapped row
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
      })
    .disposed(by: disposeBag)
  }
  
  
}

//MARK: - Imperative methods
private extension ChocolatesOfTheWorldViewController {

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  enum SegueIdentifier: String {
    case goToCart
  }
}
