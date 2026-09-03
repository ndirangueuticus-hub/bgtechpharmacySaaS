-- Create a demo auth user for MediCare Pharmacy
-- Password: pharma123
-- Email: owner@medicarepharmacy.co.ke

INSERT INTO auth.users (
  id,
  aud,
  role,
  email,
  email_confirmed_at,
  encrypted_password,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change_token_new,
  email_change
) VALUES (
  'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380d01',
  'authenticated',
  'authenticated',
  'owner@medicarepharmacy.co.ke',
  now(),
  crypt('pharma123', gen_salt('bf')),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"John Kamau"}',
  now(),
  now(),
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Create the user profile linked to the seeded org
INSERT INTO user_profiles (
  id,
  organization_id,
  role_id,
  full_name,
  email,
  phone,
  system_role,
  is_global_access,
  is_active
) VALUES (
  'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380d01',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c01',
  'John Kamau',
  'owner@medicarepharmacy.co.ke',
  '+254 712 345 678',
  'owner',
  true,
  true
) ON CONFLICT (id) DO NOTHING;

-- Assign user to both branches
INSERT INTO user_branches (user_id, branch_id) VALUES
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b01'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b02')
ON CONFLICT DO NOTHING;
