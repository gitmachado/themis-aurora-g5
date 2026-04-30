import { createClient, SupabaseClient } from '@supabase/supabase-js';
import {
  getSupabaseAuthRedirectUrl,
  getSupabasePublishableKey,
  getSupabaseServiceRoleKey,
  getSupabaseUrl,
} from '../../config/runtime';
import {
  ISupabaseAuthService,
  SupabaseAuthUserResult,
  SupabaseInviteInput,
  SupabasePasswordSignInInput,
  SupabasePasswordSignUpInput,
} from '../interfaces/supabase-auth.service';
import { UnauthorizedError, ValidationError } from './errors';

export class SupabaseAuthService implements ISupabaseAuthService {
  private readonly url = getSupabaseUrl();
  private readonly publishableKey = getSupabasePublishableKey();
  private readonly serviceRoleKey = getSupabaseServiceRoleKey();
  private publicClient?: SupabaseClient;
  private adminClient?: SupabaseClient;

  isPasswordAuthConfigured(): boolean {
    return Boolean(this.url && this.publishableKey);
  }

  isAdminAuthConfigured(): boolean {
    return Boolean(this.url && this.serviceRoleKey);
  }

  async signUpWithPassword(input: SupabasePasswordSignUpInput): Promise<SupabaseAuthUserResult> {
    const client = this.getPublicClient();
    const { data, error } = await client.auth.signUp({
      email: input.email,
      password: input.password,
      options: {
        emailRedirectTo: getSupabaseAuthRedirectUrl(),
        data: {
          name: input.name,
          role: input.role,
          whatsappNumber: input.whatsappNumber,
          cpf: input.cpf,
        },
      },
    });

    if (error || !data.user) {
      throw new ValidationError(error?.message || 'Não foi possível cadastrar usuário no Supabase');
    }

    return {
      supabaseUserId: data.user.id,
      email: data.user.email ?? input.email,
      emailConfirmedAt: data.user.email_confirmed_at ?? null,
      accessToken: data.session?.access_token ?? null,
    };
  }

  async signInWithPassword(input: SupabasePasswordSignInInput): Promise<SupabaseAuthUserResult> {
    const client = this.getPublicClient();
    const { data, error } = await client.auth.signInWithPassword({
      email: input.email,
      password: input.password,
    });

    if (error || !data.user) {
      throw new UnauthorizedError(error?.message || 'Credenciais inválidas');
    }

    return {
      supabaseUserId: data.user.id,
      email: data.user.email ?? input.email,
      emailConfirmedAt: data.user.email_confirmed_at ?? null,
      accessToken: data.session?.access_token ?? null,
    };
  }

  async inviteUserByEmail(input: SupabaseInviteInput): Promise<SupabaseAuthUserResult> {
    const client = this.getAdminClient();
    const { data, error } = await client.auth.admin.inviteUserByEmail(input.email, {
      data: {
        name: input.name,
        role: input.role,
        localUserId: input.localUserId,
        whatsappNumber: input.whatsappNumber,
        cpf: input.cpf,
      },
      redirectTo: getSupabaseAuthRedirectUrl(),
    });

    if (error || !data.user) {
      throw new ValidationError(error?.message || 'Não foi possível convidar usuário no Supabase');
    }

    return {
      supabaseUserId: data.user.id,
      email: data.user.email ?? input.email,
      emailConfirmedAt: data.user.email_confirmed_at ?? null,
    };
  }

  private getPublicClient(): SupabaseClient {
    if (!this.url || !this.publishableKey) {
      throw new ValidationError('Supabase Auth não está configurado para login por email');
    }

    this.publicClient ??= createClient(this.url, this.publishableKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    return this.publicClient;
  }

  private getAdminClient(): SupabaseClient {
    if (!this.url || !this.serviceRoleKey) {
      throw new ValidationError('SUPABASE_SERVICE_ROLE_KEY é obrigatório para convidar usuários');
    }

    this.adminClient ??= createClient(this.url, this.serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    return this.adminClient;
  }
}
