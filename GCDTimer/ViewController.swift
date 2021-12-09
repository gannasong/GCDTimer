//
//  ViewController.swift
//  GCDTimer
//
//  Created by SUNG HAO LIN on 2021/12/9.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class GCDTimer {
    private enum State {
        case suspended
        case resumed
    }

    private let timeInterval: TimeInterval
    private var state: State = .suspended
    public var eventHandler: (() -> Void)?

    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return timer
    }()

    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        // If the timer is suspended, calling cancel without resuming triggers a crash.
        resume()
        eventHandler = nil
    }

    func resume() {
        print("🪓 Tap resume")
        guard state != .resumed else { return }
        state = .resumed
        timer.resume()
        print("🪓 Do resume")
        print("🪓 Timer should run")
        print("🪓 ----------------------------")
    }

    func suspend() {
        print("🪓 Tap suspend")
        guard state != .suspended else { return }
        state = .suspended
        timer.suspend()
        print("🪓 Do suspend")
        print("🪓 Timer should stop")
        print("🪓 ----------------------------")
    }
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()

    private lazy var timer: GCDTimer = {
        let timer = GCDTimer(timeInterval: 1)
        timer.eventHandler = { [weak self] in
            self?.printCount()
        }
        return timer
    }()

    var count: Int = 0

    func printCount() {
        count += 1
        print("🟡 count: ", count)
    }

    lazy var resumeButton: UIButton = {
        let button = UIButton(type: .system)
      button.backgroundColor = .white
      button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
      button.setTitleColor(.red, for: .normal)
      button.setTitle("Resume", for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
      return button
    }()

    lazy var suspendButton: UIButton = {
        let button = UIButton(type: .system)
      button.backgroundColor = .white
      button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
      button.setTitleColor(.red, for: .normal)
      button.setTitle("Suspend", for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
      return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightText
        view.addSubview(resumeButton)
        view.addSubview(suspendButton)

        resumeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-44)
            $0.height.equalTo(44)
            $0.width.equalTo(140)
        }

        suspendButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(44)
            $0.height.equalTo(44)
            $0.width.equalTo(140)
        }

        resumeButton.rx.tap.subscribe { [weak self] _ in
            self?.timer.resume()
        }.disposed(by: disposeBag)

        suspendButton.rx.tap.subscribe { [weak self] _ in
            self?.timer.suspend()
        }.disposed(by: disposeBag)
    }
}
