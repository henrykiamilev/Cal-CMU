import Foundation
import Supabase

enum SupabaseConfig {
    // MARK: - Replace these with your Supabase project values
    static let projectURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
    static let anonKey = "YOUR_ANON_KEY"
    static let redirectURL = URL(string: "calcmu://login-callback")!

    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey
    )
}
