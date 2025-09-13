-- Custom user profiles table
-- This table extends the authentication with additional user information

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 13 AND age <= 100),
    college_name VARCHAR(255) NOT NULL,
    major VARCHAR(255) NOT NULL,
    minors TEXT, -- Optional field for minors (can be comma-separated)
    intended_job_direction VARCHAR(50) NOT NULL CHECK (
        intended_job_direction IN (
            'softwareEngineer',
            'dataScientist', 
            'productManager',
            'designer',
            'consultant',
            'entrepreneur',
            'researcher',
            'finance',
            'marketing',
            'other'
        )
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON user_profiles(username);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON user_profiles(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own profile
CREATE POLICY "Users can view their own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can only insert their own profile
CREATE POLICY "Users can insert their own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own profile
CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- Policy: Users can delete their own profile
CREATE POLICY "Users can delete their own profile" ON user_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- Optional: Create a view for easier querying with auth user data
CREATE OR REPLACE VIEW user_profiles_with_auth AS
SELECT 
    up.*,
    au.email,
    au.email_confirmed_at,
    au.last_sign_in_at
FROM user_profiles up
JOIN auth.users au ON up.user_id = au.id;

-- Grant necessary permissions
GRANT ALL ON user_profiles TO authenticated;
GRANT SELECT ON user_profiles_with_auth TO authenticated;
