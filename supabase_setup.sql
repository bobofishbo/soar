-- Create user_profiles table
CREATE TABLE public.user_profiles (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    username text UNIQUE NOT NULL,
    age integer NOT NULL CHECK (age > 0 AND age < 150),
    college_name text NOT NULL,
    major text NOT NULL,
    minors text,
    intended_job_direction text NOT NULL CHECK (
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
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create an index on user_id for faster queries
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles(user_id);

-- Create an index on username for faster username availability checks
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
-- Users can only see and modify their own profile
CREATE POLICY "Users can view their own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER trigger_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
