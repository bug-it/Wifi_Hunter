# Força UTF-8 para acentuação correta
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Pega o diretório onde o script está sendo executado
$diretorioScript = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Coleta os perfis Wi-Fi salvos
$perfRaw = netsh wlan show profiles
$perfLines = $perfRaw | Where-Object { $_ -match "Todos os Perfis de Usuários" }
$redes = $perfLines | ForEach-Object { ($_ -split ":")[1].Trim() }

# Verifica se encontrou alguma rede
if ($redes.Count -eq 0) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Nenhuma rede Wi-Fi salva encontrada   ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════╝`n" -ForegroundColor Cyan
    exit
}

# Exibe as redes disponíveis
Write-Host ""
Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Redes Wi-Fi Salvas         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════╝`n" -ForegroundColor Cyan

for ($i = 0; $i -lt $redes.Count; $i++) {
    Write-Host "$($i+1). $($redes[$i])" -ForegroundColor Green
}

# Escolha do usuário
$escolha = Read-Host "`nDigite o número da rede para ver a senha"

# Validação
if ($escolha -notmatch '^\d+$' -or [int]$escolha -lt 1 -or [int]$escolha -gt $redes.Count) {
    Write-Host "`n❌ Número inválido." -ForegroundColor Red
    exit
}

$rede = $redes[[int]$escolha - 1]

# Obtém os detalhes do perfil
$detalhes = netsh wlan show profile name="$rede" key=clear
$senha = ($detalhes | Select-String "Conteúdo da Chave" | ForEach-Object {
    ($_ -split ":")[1].Trim()
})

# Exibe e salva
if ($senha) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🔐 Senha da Rede Selecionada       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "Rede: $rede" -ForegroundColor Green
    Write-Host "Senha: $senha" -ForegroundColor Green

    # Conteúdo e caminho do arquivo
    $saida = "Rede: $rede`nSenha: $senha"
    $nomeArquivo = "senha_$($rede.Replace(' ', '_')).txt"
    $caminhoArquivo = Join-Path $diretorioScript $nomeArquivo

    $saida | Out-File -Encoding UTF8 -FilePath $caminhoArquivo

    Write-Host "`n💾 Arquivo salvo em: $caminhoArquivo" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Senha não encontrada para '$rede'." -ForegroundColor Red
}
