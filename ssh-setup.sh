#!/bin/bash
    SSH_DIR="$HOME/.ssh"
    SBM_KEY="$SSH_DIR/id_ed25519_sbm"
    PERSONAL_KEY="$SSH_DIR/id_ed25519_personal"

    generate_key() {
        local keyfile=$1
        local email=$2
        if [ ! -f "$keyfile" ]; then
            ssh-keygen -t ed25519 -C "$email" -f "$keyfile" -N ""
            chmod 600 "$keyfile"
            chmod 600 "$keyfile.pub"
            echo "Chave $keyfile criada."
        else
            echo "Chave $keyfile já existe."
        fi
    }

    view_key() {
        local keyfile=$1
        if [ -f "$keyfile.pub" ]; then
            cat "$keyfile.pub"
        else
            echo "Chave $keyfile.pub não encontrada."
        fi
    }

    delete_key() {
        local keyfile=$1
        rm -f "$keyfile" "$keyfile.pub"
        echo "Chave $keyfile removida."
    }

    set_default_key() {
        local keyfile=$1
        ln -sf "$keyfile" "$SSH_DIR/id_ed25519"
        ln -sf "$keyfile.pub" "$SSH_DIR/id_ed25519.pub"
        echo "Chave $keyfile definida como padrão."
    }

    case "$1" in
        gerar)
            case "$2" in
                sbm)
                    generate_key "$SBM_KEY" "otavio.campagnoli@sbmtechnology.com"
                    ;;
                personal)
                    generate_key "$PERSONAL_KEY" "otaviocampagnoli@hotmail.com"
                    ;;
                todas)
                    generate_key "$SBM_KEY" "otavio.campagnoli@sbmtechnology.com"
                    generate_key "$PERSONAL_KEY" "otaviocampagnoli@hotmail.com"
                    ;;
                *)
                    echo "Opção inválida. Use: sbm, personal ou todas."
                    ;;
            esac
            ;;
        visualizar)
            case "$2" in
                sbm)
                    view_key "$SBM_KEY"
                    ;;
                personal)
                    view_key "$PERSONAL_KEY"
                    ;;
                todas)
                    echo "Chave SBM:"
                    view_key "$SBM_KEY"
                    echo ""
                    echo "Chave Pessoal:"
                    view_key "$PERSONAL_KEY"
                    ;;
                *)
                    echo "Opção inválida. Use: sbm, personal ou todas."
                    ;;
            esac
            ;;
        deletar)
            case "$2" in
                sbm)
                    delete_key "$SBM_KEY"
                    ;;
                personal)
                    delete_key "$PERSONAL_KEY"
                    ;;
                todas)
                    delete_key "$SBM_KEY"
                    delete_key "$PERSONAL_KEY"
                    ;;
                *)
                    echo "Opção inválida. Use: sbm, personal ou todas."
                    ;;
            esac
            ;;
        usar)
            case "$2" in
            sbm)
                set_default_key "$SBM_KEY"
                git config --global user.name "sbm-ocampagnoli"
                git config --global user.email "otavio.campagnoli@sbmtechnology.com"
                echo "Configuração do git para SBM aplicada."
                ;;
            personal)
                set_default_key "$PERSONAL_KEY"
                git config --global user.name "Otavio Campagnoli"
                git config --global user.email "otaviocampagnoli@hotmail.com"
                echo "Configuração do git pessoal aplicada."
                ;;
            *)
                echo "Opção inválida. Use: sbm ou personal."
                ;;
            esac
            ;;
        *)
            echo "Uso: $0 {gerar|visualizar|deletar|usar} {sbm|personal|todas}"
            ;;
        esac 
