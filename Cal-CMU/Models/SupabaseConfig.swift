import Foundation
import Supabase

enum SupabaseConfig {
    // MARK: - Replace these with your Supabase project values
    static let projectURL = URL(string: "https://tkjraiwjhrymfueonbpz.supabase.co")!
    static let anonKey = "sb_publishable_yzxbmLnqNwwt2CnBaHzGaw_Gv3MWcxn"

    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey
    )
}
