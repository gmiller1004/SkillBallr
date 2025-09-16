import Foundation
import Combine
import SwiftUI
import StoreKit

/// Subscription manager for handling in-app purchases and subscriptions with real StoreKit 2
@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentSubscriptionTier: SubscriptionTier = .free
    @Published var purchasedNonConsumables: Set<String> = []
    
    // MARK: - Product IDs (from your App Store Connect setup)
    private let subscriptionProductIds: Set<String> = [
        "skillballr.player_monthly",
        "skillballr.player_yearly", 
        "skillballr.coach_pro_monthly",
        "skillballr.coach_pro_yearly",
        "skillballr.team_unlimited_monthly",
        "skillballr.team_unlimited_yearly"
    ]
    
    private let nonConsumableProductIds: Set<String> = [
        "skillballr.extra_position_db",
        "skillballr.extra_position_ol",
        "skillballr.ar_playbook_template"
    ]
    
    private let allProductIds: Set<String>
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var updates: Task<Void, Never>? = nil
    
    // MARK: - Initialization
    init() {
        self.allProductIds = subscriptionProductIds.union(nonConsumableProductIds)
        loadPurchasedProducts()
        requestProducts()
        listenForTransactions()
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Request products from App Store
    func requestProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let products = try await Product.products(for: allProductIds)
                
                await MainActor.run {
                    self.products = products
                    self.isLoading = false
                    print("✅ Loaded \(products.count) products from App Store")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Failed to load products: \(error)")
                }
            }
        }
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateCustomerProductStatus(for: transaction)
                await transaction.finish()
                
            case .userCancelled:
                await MainActor.run {
                    self.isLoading = false
                    print("User cancelled purchase")
                }
                
            case .pending:
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Purchase pending approval"
                    print("Purchase pending approval")
                }
                
            @unknown default:
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Unknown purchase result"
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Purchase failed: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ Purchase failed: \(error)")
            }
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await MainActor.run {
                self.isLoading = false
                print("✅ Purchases restored")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ Failed to restore purchases: \(error)")
            }
        }
    }
    
    /// Check if user has access to a specific feature
    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .playerPremium:
            return currentSubscriptionTier == .playerPremium || 
                   currentSubscriptionTier == .coachPro || 
                   currentSubscriptionTier == .familyUnlimited
                   
        case .coachPro:
            return currentSubscriptionTier == .coachPro || 
                   currentSubscriptionTier == .familyUnlimited
                   
        case .familyUnlimited:
            return currentSubscriptionTier == .familyUnlimited
            
        case .extraPositionDB:
            return purchasedNonConsumables.contains("skillballr.extra_position_db")
            
        case .extraPositionOL:
            return purchasedNonConsumables.contains("skillballr.extra_position_ol")
            
        case .arPlaybookTemplate:
            return purchasedNonConsumables.contains("skillballr.ar_playbook_template")
        }
    }
    
    /// Get subscription product by tier
    func getSubscriptionProduct(for tier: SubscriptionTier, isYearly: Bool = false) -> Product? {
        let productId = getProductId(for: tier, isYearly: isYearly)
        return products.first { $0.id == productId }
    }
    
    /// Get non-consumable product by ID
    func getNonConsumableProduct(id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() {
        updates = Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateCustomerProductStatus(for: transaction)
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updateCustomerProductStatus(for transaction: StoreKit.Transaction) async {
        let productId = transaction.productID
        
        if subscriptionProductIds.contains(productId) {
            // Handle subscription
            await MainActor.run {
                self.purchasedProducts.insert(productId)
                self.updateSubscriptionTier()
            }
        } else if nonConsumableProductIds.contains(productId) {
            // Handle non-consumable
            await MainActor.run {
                self.purchasedNonConsumables.insert(productId)
            }
        }
        
        // Save to UserDefaults
        await savePurchasedProducts()
    }
    
    private func loadPurchasedProducts() {
        // Load subscription products
        if let storedSubscriptions = UserDefaults.standard.stringArray(forKey: "purchased_subscriptions") {
            purchasedProducts = Set(storedSubscriptions)
        }
        
        // Load non-consumable products
        if let storedNonConsumables = UserDefaults.standard.stringArray(forKey: "purchased_non_consumables") {
            purchasedNonConsumables = Set(storedNonConsumables)
        }
        
        updateSubscriptionTier()
    }
    
    private func savePurchasedProducts() {
        UserDefaults.standard.set(Array(purchasedProducts), forKey: "purchased_subscriptions")
        UserDefaults.standard.set(Array(purchasedNonConsumables), forKey: "purchased_non_consumables")
    }
    
    private func updateSubscriptionTier() {
        // Determine highest tier based on purchased subscriptions
        if purchasedProducts.contains("skillballr.team_unlimited_monthly") || 
           purchasedProducts.contains("skillballr.team_unlimited_yearly") {
            currentSubscriptionTier = .familyUnlimited
        } else if purchasedProducts.contains("skillballr.coach_pro_monthly") || 
                  purchasedProducts.contains("skillballr.coach_pro_yearly") {
            currentSubscriptionTier = .coachPro
        } else if purchasedProducts.contains("skillballr.player_monthly") || 
                  purchasedProducts.contains("skillballr.player_yearly") {
            currentSubscriptionTier = .playerPremium
        } else {
            currentSubscriptionTier = .free
        }
        
        print("✅ Updated subscription tier to: \(currentSubscriptionTier)")
    }
    
    private func getProductId(for tier: SubscriptionTier, isYearly: Bool) -> String {
        switch tier {
        case .free:
            return "skillballr.player_monthly" // Default to player monthly
            
        case .playerPremium:
            return isYearly ? "skillballr.player_yearly" : "skillballr.player_monthly"
            
        case .coachPro:
            return isYearly ? "skillballr.coach_pro_yearly" : "skillballr.coach_pro_monthly"
            
        case .familyUnlimited:
            return isYearly ? "skillballr.team_unlimited_yearly" : "skillballr.team_unlimited_monthly"
        }
    }
}

// MARK: - Supporting Types

enum SubscriptionTier: String, CaseIterable, Identifiable, Codable {
    case free = "free"
    case playerPremium = "player_premium"
    case coachPro = "coach_pro"
    case familyUnlimited = "family_unlimited"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .playerPremium: return "Player Premium"
        case .coachPro: return "Coach Pro"
        case .familyUnlimited: return "Family Unlimited"
        }
    }
    
    var description: String {
        switch self {
        case .free:
            return "Basic access to one position"
        case .playerPremium:
            return "All positions, unlimited quizzes, badges"
        case .coachPro:
            return "Everything in Player Premium plus team management, AI analysis"
        case .familyUnlimited:
            return "Everything in Coach Pro plus unlimited teams, advanced features"
        }
    }
}

enum PremiumFeature {
    case playerPremium
    case coachPro
    case familyUnlimited
    case extraPositionDB
    case extraPositionOL
    case arPlaybookTemplate
}

enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        }
    }
}