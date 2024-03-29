/*
 * Copyright (c) 2016-2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import Then

class ListPeopleViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var messageView: UIView!

  private let bag = DisposeBag()
  fileprivate var viewModel: ListPeopleViewModel!
  fileprivate var navigator: Navigator!

  static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: ListPeopleViewModel) -> ListPeopleViewController {
    return storyboard.instantiateViewController(ofType: ListPeopleViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "List Members"
    tableView.estimatedRowHeight = 90
    tableView.rowHeight = UITableViewAutomaticDimension
    bindUI()
  }

  func bindUI() {
    //show tweets in table view
    viewModel.people.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .addDisposableTo(bag)

    //show message when no account available
    
    
    viewModel.people.asObservable()
        .map { people in people == nil ? false : true }
        .bindTo(messageView.rx.isHidden)
        .addDisposableTo(bag)
  }
}

extension ListPeopleViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.people.value?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueCell(ofType: UserCellView.self).then { cell in
      cell.update(with: viewModel.people.value![indexPath.row])
    }
  }
}

extension ListPeopleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let tweet = viewModel.people.value?[indexPath.row] else { return }
    navigator.show(segue: .personTimeline(viewModel.account, username: tweet.username), sender: self)
  }
}

