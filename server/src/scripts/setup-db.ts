import fs from 'fs';
import path from 'path';
import { Client } from 'pg';
import dotenv from 'dotenv';
import pool from '../config/database';

// Garantir que o dotenv seja carregado aqui para a conexão inicial
dotenv.config({ path: path.join(__dirname, '../../.env') });

async function ensureDatabaseExists() {
  const dbName = process.env.DB_NAME || 'themis_db';
  
  // Conectamos ao banco padrão 'postgres' para poder criar o nosso banco
  const client = new Client({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '5432'),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: 'postgres', // Banco padrão que sempre existe
  });

  try {
    await client.connect();
    
    // Verificamos se o banco já existe
    const res = await client.query(`SELECT 1 FROM pg_database WHERE datname = $1`, [dbName]);
    
    if (res.rowCount === 0) {
      console.log(`💎 Banco de dados "${dbName}" não encontrado. Criando...`);
      // CREATE DATABASE não aceita parâmetros ($1), então usamos template string com cuidado
      await client.query(`CREATE DATABASE ${dbName}`);
      console.log(`✅ Banco "${dbName}" criado com sucesso.`);
    } else {
      console.log(`ℹ️ Banco de dados "${dbName}" já existe.`);
    }
  } catch (err) {
    console.error('❌ Erro ao verificar/criar banco de dados:', err);
    throw err;
  } finally {
    await client.end();
  }
}

async function setup() {
  try {
    console.log('🚀 Iniciando configuração do ambiente de banco de dados...');

    // 1. Garantir existência do banco
    await ensureDatabaseExists();

    // 2. Ler arquivos SQL
    const schemaSql = fs.readFileSync(path.join(__dirname, '../../database/schema.sql'), 'utf8');
    const seedSql = fs.readFileSync(path.join(__dirname, '../../database/seed.sql'), 'utf8');

    // 3. Executar Schema
    console.log('📝 Criando tabelas (Schema)...');
    await pool.query(schemaSql);
    console.log('✅ Schema criado com sucesso.');

    // 4. Executar Seed
    console.log('🌱 Populando dados (Seed)...');
    await pool.query(seedSql);
    console.log('✅ Seed executado com sucesso.');

    console.log('\n✨ Tudo pronto! O banco de dados está atualizado.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Erro crítico no setup:', err);
    process.exit(1);
  }
}

setup();
