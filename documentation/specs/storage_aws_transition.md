# Guia de Transição: Storage Local para AWS S3

Este documento descreve como migrar a implementação de armazenamento de arquivos do modo **Local** (atual) para o **AWS S3**.

## 1. Estrutura Atual (Local)

Atualmente usamos a classe `LocalFileStorageProvider` que:
- Salva arquivos na pasta `/uploads` na raiz do projeto `server`.
- Expõe os arquivos via rota estática no Express (`/uploads`).
- Não é persistente em ambientes stateless (Heroku/Render sem volumes).

## 2. Passos para Migração para AWS S3

### 2.1. Dependências
Instalar o SDK da AWS:
```bash
npm install @aws-sdk/client-s3
```

### 2.2. Variáveis de Ambiente (.env)
Adicionar as credenciais:
```env
AWS_ACCESS_KEY_ID=sua_chave
AWS_SECRET_ACCESS_KEY=seu_segredo
AWS_REGION=us-east-1
AWS_S3_BUCKET=nome-do-seu-bucket
```

### 2.3. Nova Implementação (`S3StorageProvider`)
Criar o arquivo `src/utils/storage/implementations/s3-storage.provider.ts`:

```typescript
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { IStorageProvider } from '../storage.provider';
import fs from 'fs';

export class S3StorageProvider implements IStorageProvider {
  private client: S3Client;
  private bucket: string;

  constructor() {
    this.client = new S3Client({ region: process.env.AWS_REGION });
    this.bucket = process.env.AWS_S3_BUCKET!;
  }

  async saveFile(file: Express.Multer.File): Promise<string> {
    const filename = `${Date.now()}-${file.originalname}`;
    const fileContent = fs.readFileSync(file.path);

    await this.client.send(new PutObjectCommand({
      Bucket: this.bucket,
      Key: filename,
      Body: fileContent,
      ContentType: file.mimetype,
      ACL: 'public-read'
    }));

    return `https://${this.bucket}.s3.${process.env.AWS_REGION}.amazonaws.com/${filename}`;
  }

  async deleteFile(fileUrl: string): Promise<void> {
    const key = fileUrl.split('/').pop();
    await this.client.send(new DeleteObjectCommand({
      Bucket: this.bucket,
      Key: key
    }));
  }
}
```

### 2.4. Troca de Classe
No `DocumentController.ts`, basta trocar a instância:
```typescript
// De:
this.storageProvider = new LocalFileStorageProvider();
// Para:
this.storageProvider = new S3StorageProvider();
```

## 3. Considerações de Produção
- Certifique-se de que o bucket tenha permissões de leitura pública se as URLs forem usadas diretamente no App.
- Use IAM roles em vez de chaves fixas se estiver rodando dentro da AWS (EC2/Lambda).
