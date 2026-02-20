import Supabase
import Foundation

enum SupabaseConfig {
    // TODO: Replace these with your actual Supabase project values
    static let projectURL = URL(string: "https://oggchqkgbzxehqeyoqvm.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9nZ2NocWtnYnp4ZWhxZXlvcXZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1NzEzMzIsImV4cCI6MjA4NzE0NzMzMn0.1c6WXB_33hftuROx6Bc0IuZmtTHc-hjF9I2HgKtGHPg"

    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey
    )
}
