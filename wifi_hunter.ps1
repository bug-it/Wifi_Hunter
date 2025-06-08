# Banner ASCII
Write-Host ""
Write-Host "██╗    ██╗██╗███████╗██╗    ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ " -ForegroundColor Cyan
Write-Host "██║    ██║██║██╔════╝██║    ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗" -ForegroundColor Cyan
Write-Host "██║ █╗ ██║██║█████╗  ██║    ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝" -ForegroundColor Cyan
Write-Host "██║███╗██║██║██╔══╝  ██║    ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗" -ForegroundColor Cyan
Write-Host "╚███╔███╔╝██║██║     ██║    ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║" -ForegroundColor Cyan
Write-Host " ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "                                                        Desenvolvido por: BUG IT" -ForegroundColor Green
Write-Host ""
Write-Host ""

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
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
    pause
    exit
}

# Exibe as redes disponíveis
Write-Host ""
Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Redes Wi-Fi Salvas         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

for ($i = 0; $i -lt $redes.Count; $i++) {
    Write-Host "$($i+1). $($redes[$i])" -ForegroundColor Green
}

# Escolha do usuário
$escolha = Read-Host "`nDigite o número da rede para ver a senha"

# Validação
if ($escolha -notmatch '^\d+$' -or [int]$escolha -lt 1 -or [int]$escolha -gt $redes.Count) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          ❌ Número inválido         ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
    pause
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
    Write-Host "║          Rede Selecionada          ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Rede: $rede" -ForegroundColor Green
    Write-Host "Senha: $senha" -ForegroundColor Green
    Write-Host ""
    # Conteúdo e caminho do arquivo
    $saida = "Rede: $rede`nSenha: $senha"
    $nomeArquivo = "WIFI_$($rede.Replace(' ', '_')).txt"
    $caminhoArquivo = Join-Path $diretorioScript $nomeArquivo

    $saida | Out-File -Encoding UTF8 -FilePath $caminhoArquivo

    Write-Host ""
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║      Arquivo salvo com sucesso     ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`nCaminho: $caminhoArquivo" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║         Senha não encontrada       ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
}

pause