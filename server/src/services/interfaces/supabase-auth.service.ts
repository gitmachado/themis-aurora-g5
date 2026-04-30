export interface SupabasePasswordSignUpInput {
  email: string;
  password: string;
  name: string;
  role: string;
  whatsappNumber?: string;
  cpf?: string | null;
}

export interface SupabasePasswordSignInInput {
  email: string;
  password: string;
}

export interface SupabaseInviteInput {
  email: string;
  name: string;
  role: string;
  localUserId: string;
  whatsappNumber?: string;
  cpf?: string | null;
}

export interface SupabaseAuthUserResult {
  supabaseUserId: string;
  email: string | null;
  emailConfirmedAt: string | null;
  accessToken?: string | null;
}

export interface ISupabaseAuthService {
  isPasswordAuthConfigured(): boolean;
  isAdminAuthConfigured(): boolean;
  signUpWithPassword(input: SupabasePasswordSignUpInput): Promise<SupabaseAuthUserResult>;
  signInWithPassword(input: SupabasePasswordSignInInput): Promise<SupabaseAuthUserResult>;
  inviteUserByEmail(input: SupabaseInviteInput): Promise<SupabaseAuthUserResult>;
}
