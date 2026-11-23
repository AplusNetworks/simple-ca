# SIMPLE CA

O **SIMPLE CA** oferece comandos simples e diretos via `Makefile` para atuar como uma Autoridade Certificadora (CA) local ou interna. Os comandos de emissão e renovação dependem da chave raiz (`myCA.key`) e do certificado raiz (`myCA.pem`) gerados pelo comando `generate-ca`.

Para visualizar todos os comandos e notas técnicas diretamente no terminal, execute:
```sh
make help
```

## Dependências
- `make`
- `openssl` (versão 1.1.1 ou superior)
- `bash`

## Notas Técnicas
- **SAN (Subject Alternative Name):** Navegadores modernos exigem a extensão SAN e ignoram o campo CN (*Common Name*). Os comandos deste projeto injetam o DNS no SAN automaticamente.
- **Compatibilidade com Safari/Apple:** Sistemas macOS e iOS bloqueiam certificados de servidor com validade superior a 825 dias. Por padrão, os certificados emitidos têm validade de **825 dias**, enquanto a Root CA tem validade de **1825 dias** (5 anos).
- **Segurança:** A chave privada da Root CA é gerada com **4096 bits** e protegida com criptografia **AES-256**.

---

## Exemplos de Uso

### 1. Criar a chave mestra e o certificado raiz (Root CA)
Gera os arquivos `myCA.key` e `myCA.pem`. Você pode informar um domínio personalizado ou usar o padrão (`Root CA Local`):
```sh
make generate-ca CA_DOMAIN=ca.empresa.local
```

### 2. Gerar e assinar um certificado de servidor (Atalho rápido)
Cria a chave privada (`.key`), o pedido de assinatura (`.csr`) e já gera o certificado assinado (`.crt`) em um único passo:
```sh
make cert CN=app.empresa.local
```

*(Para emitir um **certificado wildcard**, utilize aspas simples para evitar expansão no terminal):*
```sh
make cert CN='*.empresa.local'
```

### 3. Executar as etapas separadamente (Opcional)
Caso queira apenas gerar a chave e o CSR, ou assinar um CSR existente de forma avulsa:

* **Gerar chave privada e CSR:**
  ```sh
  make csr CN=app.empresa.local
  ```
* **Assinar o CSR e gerar o `.crt`:**
  ```sh
  make sign CN=app.empresa.local
  ```

### 4. Renovar um certificado existente
Faz um backup automático do certificado atual (`app.empresa.local.crt.bak`) e gera um novo certificado válido por mais 825 dias reaproveitando a chave e o CSR originais:
```sh
make renew CN=app.empresa.local
```
