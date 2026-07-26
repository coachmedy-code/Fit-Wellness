// ============================================================
// SEM VLOŽ SVÉ ÚDAJE ZE SUPABASE (Project Settings -> API)
// ============================================================
const SUPABASE_URL = "https://nygmuvqkqfyvoayepagh.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55Z211dnFrcWZ5dm9heWVwYWdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUwOTAwNTcsImV4cCI6MjEwMDY2NjA1N30.O47N0SoEtUEfPKmNwV2oGPDkhCDFdLav5NzRqZAkHWU";

// Vytvoří sdíleného Supabase klienta - používají ho index.html i coach.html
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
