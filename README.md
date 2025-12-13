# ssh-setup.sh

Script para gerenciar múltiplas chaves SSH (sbm e pessoal).

## Uso

```bash
./ssh-setup.sh {gerar|visualizar|deletar|usar} {sbm|personal|todas}
```

### Exemplos

- **Gerar chave sbm:**
  ```bash
  ./ssh-setup.sh gerar sbm
  ```

- **Gerar chave pessoal:**
  ```bash
  ./ssh-setup.sh gerar personal
  ```

- **Gerar todas as chaves:**
  ```bash
  ./ssh-setup.sh gerar todas
  ```

- **Visualizar chave pública sbm:**
  ```bash
  ./ssh-setup.sh visualizar sbm
  ```

- **Visualizar chave pública pessoal:**
  ```bash
  ./ssh-setup.sh visualizar personal
  ```

- **Deletar chave sbm:**
  ```bash
  ./ssh-setup.sh deletar sbm
  ```

- **Deletar chave pessoal:**
  ```bash
  ./ssh-setup.sh deletar personal
  ```

- **Deletar todas as chaves:**
  ```bash
  ./ssh-setup.sh deletar todas
  ```

- **Usar chave sbm como padrão:**
  ```bash
  ./ssh-setup.sh usar sbm
  ```

- **Usar chave pessoal como padrão:**
  ```bash
  ./ssh-setup.sh usar personal
  ```