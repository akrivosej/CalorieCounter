//
//  SubscriptionsViewController.swift
//  AINutritionist
//
//  Created by muser on 07.04.2025.
//

import Foundation
import UIKit
import RevenueCat
import StoreKit

class SubscriptionsViewController: UIViewController {
    
    // UI елементи
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let headerView = UIView()
    private let headerLabel = UILabel()
    
    // Дані про доступні пакети
    private var packages: [Package] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSubscriptions()
    }
    
    private func setupUI() {
        title = "Преміум підписка"
        view.backgroundColor = .systemBackground
        
        // Налаштування заголовку
        headerLabel.text = "Виберіть план підписки"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        headerLabel.textAlignment = .center
        
        headerView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        
        // Налаштування таблиці
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubscriptionPackageCell.self, forCellReuseIdentifier: "PackageCell")
        tableView.tableHeaderView = headerView
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
        
        // Додавання на view
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // Обмеження для таблиці
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Обмеження для індикатора завантаження
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Відновлення покупок кнопка у футері
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Відновити покупки", for: .normal)
        restoreButton.addTarget(self, action: #selector(restorePurchasesTapped), for: .touchUpInside)
        
        footerView.addSubview(restoreButton)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restoreButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            restoreButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        tableView.tableFooterView = footerView
    }
    
    private func loadSubscriptions() {
        loadingIndicator.startAnimating()
        
//        // Спробуємо спочатку використати StoreKit конфігурацію
//        let fetchOptions = FetchOptions()
//        // Важливо: вимикаємо кешування, щоб завжди отримувати свіжі дані
//        fetchOptions.cachePolicy = .fetchAndReplaceLocalData
        
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                // Якщо є помилка, перевіряємо тип помилки
                if let error = error {
                    // Перевіряємо, чи можна продовжити роботу, незважаючи на помилку
                    if let purchasesError = error as? RevenueCat.ErrorCode,
                       purchasesError == .offlineConnectionError || purchasesError == .configurationError {
                        // Спробуємо отримати локальні кешовані дані
                        self?.tryLoadCachedOfferings()
                    } else {
                        self?.showAlert(title: "Помилка", message: "Не вдалося завантажити підписки: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let offerings = offerings, let currentOffering = offerings.current else {
                    // Якщо offerings порожні, спробуємо використати StoreKit конфігурацію напряму
                    self?.tryLoadCachedOfferings()
                    return
                }
                
                self?.packages = currentOffering.availablePackages
                self?.tableView.reloadData()
                
                // Налаштування розміру headerView після завантаження даних
                if let headerView = self?.headerView {
                    headerView.frame.size.height = 80
                    self?.tableView.tableHeaderView = headerView
                }
            }
        }
        
//        Purchases.shared.getOfferings(fetchOptions: fetchOptions) { [weak self] offerings, error in
//            DispatchQueue.main.async {
//                self?.loadingIndicator.stopAnimating()
//                
//            // Якщо є помилка, перевіряємо тип помилки
//            if let error = error {
//                // Перевіряємо, чи можна продовжити роботу, незважаючи на помилку
//                    if let purchasesError = error as? RevenueCat.ErrorCode,
//                       purchasesError == .offlineConnectionError || purchasesError == .configurationError {
//                        // Спробуємо отримати локальні кешовані дані
//                        self?.tryLoadCachedOfferings()
//                    } else {
//                        self?.showAlert(title: "Помилка", message: "Не вдалося завантажити підписки: \(error.localizedDescription)")
//                    }
//                    return
//                }
//                
//                guard let offerings = offerings, let currentOffering = offerings.current else {
//                    // Якщо offerings порожні, спробуємо використати StoreKit конфігурацію напряму
//                    self?.tryLoadCachedOfferings()
//                    return
//                }
//                
//                self?.packages = currentOffering.availablePackages
//                self?.tableView.reloadData()
//                
//                // Налаштування розміру headerView після завантаження даних
//                if let headerView = self?.headerView {
//                    headerView.frame.size.height = 80
//                    self?.tableView.tableHeaderView = headerView
//                }
//            }
//        }
    }
                        
                        // Метод для завантаження кешованих offerings або використання StoreKit напряму
                private func tryLoadCachedOfferings() {
                    Purchases.shared.getOfferings { [weak self] offerings, error in
                        if let error = error {
                            // Якщо все ще є помилка, показуємо повідомлення
                            self?.showAlert(title: "Інформація", message: "Підписки недоступні в даний момент. Перевірте підключення до інтернету або спробуйте пізніше.")
                            return
                        }
                        
                        guard let offerings = offerings, let currentOffering = offerings.current else {
                            self?.showAlert(title: "Інформація", message: "Підписки недоступні в даний момент")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self?.packages = currentOffering.availablePackages
                            self?.tableView.reloadData()
                            
                            // Налаштування розміру headerView після завантаження даних
                            if let headerView = self?.headerView {
                                headerView.frame.size.height = 80
                                self?.tableView.tableHeaderView = headerView
                            }
                        }
                    }
                }
                        
                        private func purchasePackage(_ package: Package) {
                            loadingIndicator.startAnimating()
                            
                            // Використовуємо додаткову обробку помилок при покупці
                            Purchases.shared.purchase(package: package) { [weak self] transaction, purchaserInfo, error, userCancelled in
                                DispatchQueue.main.async {
                                    self?.loadingIndicator.stopAnimating()
                                    
                                    if userCancelled {
                                        print("Користувач скасував покупку")
                                        return
                                    }
                                    
                                    if let error = error {
                                        // Додаткова обробка помилок StoreKit
                                        if let storeKitError = error as? SKError {
                                            switch storeKitError.code {
                                            case .paymentCancelled:
                                                print("Користувач скасував покупку")
                                                return
                                            case .paymentInvalid:
                                                self?.showAlert(title: "Помилка", message: "Неправильні дані оплати. Спробуйте ще раз.")
                                            case .paymentNotAllowed:
                                                self?.showAlert(title: "Помилка", message: "Цей пристрій не може здійснювати платежі.")
                                            case .storeProductNotAvailable:
                                                self?.showAlert(title: "Помилка", message: "Продукт недоступний у вашому регіоні.")
                                            default:
                                                self?.showAlert(title: "Помилка", message: "Не вдалося здійснити покупку: \(error.localizedDescription)")
                                            }
                                        } else if let purchasesError = error as? RevenueCat.ErrorCode {
                                            switch purchasesError {
                                            case .networkError:
                                                self?.showAlert(title: "Помилка мережі", message: "Перевірте підключення до інтернету та спробуйте ще раз.")
                                            case .purchaseCancelledError:
                                                print("Користувач скасував покупку")
                                                return
                                            default:
                                                self?.showAlert(title: "Помилка", message: "Не вдалося здійснити покупку: \(error.localizedDescription)")
                                            }
                                        } else {
                                            self?.showAlert(title: "Помилка", message: "Не вдалося здійснити покупку: \(error.localizedDescription)")
                                        }
                                        return
                                    }
                                    
                                    guard let purchaserInfo = purchaserInfo else { return }
                                    
                                    if purchaserInfo.entitlements["premium"]?.isActive == true {
                                        self?.showAlert(title: "Успіх!", message: "Ви успішно оформили підписку! Дякуємо за підтримку.", onClose: {
                                            self?.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }
                            }
                        }
                        
                        @objc private func restorePurchasesTapped() {
                            loadingIndicator.startAnimating()
                            
                            Purchases.shared.restorePurchases { [weak self] purchaserInfo, error in
                                DispatchQueue.main.async {
                                    self?.loadingIndicator.stopAnimating()
                                    
                                    if let error = error {
                                        // Обробка можливих помилок при відновленні покупок
                                        if let purchasesError = error as? RevenueCat.ErrorCode,
                                           purchasesError == .networkError {
                                            self?.showAlert(title: "Помилка мережі", message: "Перевірте підключення до інтернету та спробуйте ще раз.")
                                        } else {
                                            self?.showAlert(title: "Помилка", message: "Не вдалося відновити покупки: \(error.localizedDescription)")
                                        }
                                        return
                                    }
                                    
                                    if purchaserInfo?.entitlements["premium"]?.isActive == true {
                                        self?.showAlert(title: "Успіх", message: "Ваші підписки успішно відновлено!", onClose: {
                                            self?.navigationController?.popViewController(animated: true)
                                        })
                                    } else {
                                        self?.showAlert(title: "Інформація", message: "Активних підписок не знайдено.")
                                    }
                                }
                            }
                        }
                        
                        private func showAlert(title: String, message: String, onClose: (() -> Void)? = nil) {
                            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                onClose?()
                            })
                            present(alert, animated: true, completion: nil)
                        }
                        
                        // Повертає локалізований опис типу пакета
                        private func getPackageDescription(_ packageType: PackageType) -> String {
                            switch packageType {
                            case .monthly:
                                return "Щомісячний платіж"
                            case .annual:
                                return "Щорічний платіж (економія 16%)"
                            case .lifetime:
                                return "Довічна підписка"
                            case .weekly:
                                return "Щотижневий платіж"
                            case .sixMonth:
                                return "На 6 місяців"
                            case .threeMonth:
                                return "На 3 місяці"
                            case .twoMonth:
                                return "На 2 місяці"
                            case .custom:
                                return "Спеціальна пропозиція"
                            @unknown default:
                                return "Підписка"
                            }
                        }
                    }

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SubscriptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCell", for: indexPath) as! SubscriptionPackageCell
        
        let package = packages[indexPath.row]
        let product = package.storeProduct
        
        // Налаштування комірки з даними підписки
        cell.configure(
            title: product.localizedTitle,
            price: product.localizedPriceString,
            description: getPackageDescription(package.packageType),
            isPopular: package.packageType == .annual
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let package = packages[indexPath.row]
        
        // Показуємо підтвердження перед покупкою
        let alert = UIAlertController(
            title: "Підтвердження покупки",
            message: "Ви впевнені, що хочете придбати \(package.storeProduct.localizedTitle) за \(package.storeProduct.localizedPriceString)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel))
        alert.addAction(UIAlertAction(title: "Купити", style: .default) { [weak self] _ in
            self?.purchasePackage(package)
        })
        
        present(alert, animated: true)
    }
}
// MARK: - Клас комірки для підписок
class SubscriptionPackageCell: UITableViewCell {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let popularBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        
        // Налаштування контейнера
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        // Налаштування міток
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        priceLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        
        // Налаштування бейджа "Популярний"
        popularBadge.text = "Найвигідніше"
        popularBadge.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        popularBadge.textColor = .white
        popularBadge.backgroundColor = .systemGreen
        popularBadge.textAlignment = .center
        popularBadge.layer.cornerRadius = 8
        popularBadge.clipsToBounds = true
        popularBadge.isHidden = true
        
        // Додавання підвидів
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(popularBadge)
        
        // Налаштування обмежень
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        popularBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            popularBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            popularBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            popularBadge.widthAnchor.constraint(equalToConstant: 100),
            popularBadge.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(title: String, price: String, description: String, isPopular: Bool = false) {
            titleLabel.text = title
            priceLabel.text = price
            descriptionLabel.text = description
            popularBadge.isHidden = !isPopular
            
            // Додаємо зелену рамку для популярного варіанту
            if isPopular {
                containerView.layer.borderColor = UIColor.systemGreen.cgColor
                containerView.layer.borderWidth = 2
            } else {
                containerView.layer.borderWidth = 0
            }
        }
    }

//class SubscriptionsViewController: UIViewController {
//    
//    // UI елементи
//    private let tableView = UITableView()
//    private let loadingIndicator = UIActivityIndicatorView(style: .large)
//    
//    // Дані про доступні пакети
//    private var packages: [Package] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadSubscriptions()
//    }
//    
//    private func setupUI() {
//        title = "Преміум підписка"
//        view.backgroundColor = .systemBackground
//        
//        // Налаштування таблиці
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PackageCell")
//        
//        // Додавання на view
//        view.addSubview(tableView)
//        view.addSubview(loadingIndicator)
//        
//        // Обмеження для таблиці
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        
//        // Обмеження для індикатора завантаження
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    private func loadSubscriptions() {
//        loadingIndicator.startAnimating()
//        
//        Purchases.shared.getOfferings { [weak self] offerings, error in
//            DispatchQueue.main.async {
//                self?.loadingIndicator.stopAnimating()
//                
//                if let error = error {
//                    self?.showAlert(title: "Помилка", message: "Не вдалося завантажити підписки: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let offerings = offerings, let currentOffering = offerings.current else {
//                    self?.showAlert(title: "Інформація", message: "Підписки недоступні в даний момент")
//                    return
//                }
//                
//                self?.packages = currentOffering.availablePackages
//                self?.tableView.reloadData()
//            }
//        }
//    }
//    
//    private func purchasePackage(_ package: Package) {
//        loadingIndicator.startAnimating()
//        
//        Purchases.shared.purchase(package: package) { [weak self] transaction, purchaserInfo, error, userCancelled in
//            DispatchQueue.main.async {
//                self?.loadingIndicator.stopAnimating()
//                
//                if userCancelled {
//                    print("Користувач скасував покупку")
//                    return
//                }
//                
//                if let error = error {
//                    self?.showAlert(title: "Помилка", message: "Не вдалося здійснити покупку: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let purchaserInfo = purchaserInfo else { return }
//                
//                // Перевіряємо права користувача, використовуючи entitlement ID
//                // Замініть "premium" на ваш фактичний ідентифікатор права
//                if purchaserInfo.entitlements["premium"]?.isActive == true {
//                    self?.showAlert(title: "Успіх!", message: "Ви успішно оформили підписку! Дякуємо за підтримку.")
//                    // Тут можна додати код для розблокування преміум функцій
//                }
//            }
//        }
//    }
//    
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//}
//
//// MARK: - UITableViewDelegate, UITableViewDataSource
//extension SubscriptionsViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return packages.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCell", for: indexPath)
//        
//        let package = packages[indexPath.row]
//        let product = package.storeProduct
//        
//        // Форматування вмісту комірки
//        var content = cell.defaultContentConfiguration()
//        content.text = product.localizedTitle
//        
//        // Замість package.packageType.description використовуємо власну функцію
//        let packageDescription = getPackageTypeDescription(package.packageType)
//        content.secondaryText = "\(product.localizedPriceString) - \(packageDescription)"
//        
//        cell.contentConfiguration = content
//        
//        return cell
//    }
//
//    // Додайте цю функцію до вашого класу
//    private func getPackageTypeDescription(_ packageType: PackageType) -> String {
//        switch packageType {
//        case .monthly:
//            return "Щомісячна підписка"
//        case .annual:
//            return "Річна підписка"
//        case .lifetime:
//            return "Довічна підписка"
//        case .weekly:
//            return "Тижнева підписка"
//        case .sixMonth:
//            return "Підписка на 6 місяців"
//        case .threeMonth:
//            return "Підписка на 3 місяці"
//        case .twoMonth:
//            return "Підписка на 2 місяці"
//        case .custom:
//            return "Спеціальна пропозиція"
//        case .unknown:
//            return "Підписка"
//        @unknown default:
//            return "Підписка"
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let package = packages[indexPath.row]
//        
//        // Показуємо підтвердження перед покупкою
//        let alert = UIAlertController(
//            title: "Підтвердження покупки",
//            message: "Ви впевнені, що хочете придбати \(package.storeProduct.localizedTitle) за \(package.storeProduct.localizedPriceString)?",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Купити", style: .default) { [weak self] _ in
//            self?.purchasePackage(package)
//        })
//        
//        present(alert, animated: true)
//    }
//}
