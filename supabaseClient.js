const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL || 'https://nrkmmsyuqkcxcmzgbias.supabase.co';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ya21tc3l1cWtjeGNtemdiaWFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NTM5NDIsImV4cCI6MjA3NTQyOTk0Mn0.uaLz09QqBEXkKYSTyxJcvqhzw9xydT6wghb-bcaJaIA';

const supabase = createClient(supabaseUrl, supabaseAnonKey);
module.exports = supabase;
