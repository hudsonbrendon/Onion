# Roadmap do fork (hudsonbrendon/Onion)

Levantamento feito em 21/10/2026 a partir de `OnionUI/Onion`: 113 issues abertas e 39 PRs abertos.
Foco: Miyoo Mini Plus (MMP).

## Status (21/10/2026)

- **Fase 0 concluída:** CI do fork ativo, versão `4.5.0-hb1`, OTA aponta pras releases de `hudsonbrendon/Onion`, nota de fork no README.
- **Fase 1 concluída:** 31 PRs do upstream integrados (branch `integration`). Conflitos resolvidos: `list_free` (#1430 × #1939), `runtime.sh` (#1923 × #1940/#1946), `Makefile` (#1890). Corrigido também: gitlink órfão `third-party/RetroArch` e falta de `libsqlite3-dev` no CI de testes.
- **Fase 2 em andamento:** corrigidos #781 (SSID oculto), #1684 (Blue Light ligando sozinho) e #1222 (`pressMenu2Kill` com SIGTERM).
- **Verificado:** `make build` completo no toolchain (EXIT 0), 26/26 testes bats e 9/9 testes gtest.
- **Rastreamento:** cada item abaixo virou issue no fork (#2–#60), com labels `P0`–`P3` e `needs-device` quando o item só pode ser reproduzido no aparelho.

## Onde o upstream parou

- **Estável:** v4.3.1-1, de 24/06/2024. É a última release "Latest".
- **`main`:** v4.4.0-beta-20260120 (pre-release, 21/01/2026). Depois disso não entrou mais nada.
- **Branch `v4.5-dev`:** 4 commits à frente da `main` (PR #1883, em draft).
- **PRs prontos e parados:** 36 dos 39 PRs estão `MERGEABLE`. Só em set/2026 chegaram 12 PRs de bugfix (autor `robcodedev`), e ninguém revisou.

O projeto não morreu, o problema é que ninguém faz merge. Por isso o ganho mais rápido do fork é **integrar o que a comunidade já escreveu**.

## Fase 0 — Infra do fork

- [ ] Ativar o GitHub Actions no fork (vem desativado em fork). Os workflows `build`, `test`, `pre-release` e `tagged-release` já existem.
- [ ] Mudar a versão no `Makefile` (`VERSION=`) para um esquema próprio, por exemplo `4.5.0-hb.N`, para não confundir com o upstream.
- [ ] Apontar o OTA updater para as releases do fork (hoje ele busca em `OnionUI/Onion`).
- [ ] Rotina de sync: `git fetch upstream && git merge upstream/main`.

## Fase 1 — Integrar PRs prontos (baixo risco, alto retorno)

### Bugfixes e performance (prioridade)
| PR | O que faz | Issue resolvida |
|---|---|---|
| #1939 | GameSwitcher: corrige a race que matava o jogo recém-trocado e os crashes; adiciona toggle de Favoritos | #1782, #1896 (provável) |
| #1897 | SQLite em modo WAL com busy timeout | #1876 (GameSwitcher mostra 0m 0s) |
| #1936 | keymon: atualiza o estado antes do atalho SELECT→MENU | — |
| #1940 | Transições de framebuffer e modo 640x480 forçado | #1765, #1779 (afeta MMv4) |
| #1941 | Limpa `.forceKillRetroarch` antes de cada launch | — |
| #1942 | Guarda a posição na lista de ROMs no cartão | — |
| #1943 | Reaplica ícones por device, não por cartão | — |
| #1944 | Limita os recentes a 200 ao alternar jogos ocultos | — |
| #1945 | Para de repatchar `retroarch.cfg` a cada launch | — |
| #1946 | Prepara o launch em paralelo (boot do jogo mais rápido) | — |
| #1947 | Desmonta o cartão de forma limpa no fim da instalação | — |
| #1948 | Polling do display a cada 100ms em vez de 500ms | — |
| #1937 | Corrige o JSON de `lt.lang` | — |
| #1921 | Corrige as capas do Pico-8 no Activity Tracker | — |
| #1914 | Corrige typos na tradução húngara | — |

### Features já implementadas
| PR | Feature | Issue |
|---|---|---|
| #1883 | Merge do `v4.5-dev` | — |
| #1868 | Rodar ROMs em zip/7z (extrai para tmp) | #1787 |
| #1430 | Activity Tracker com tema, rolagem e **apagar entradas** | #1326 |
| #1923 | Screen Time (limite diário, PIN) | #1328 (parcial) |
| #1910 | App Kids Mode | #1328 |
| #1918 | OTA por chunks (desync) | — |
| #1949 / #1950 | Scraper: metadados de PBP do PSX | — |
| #1919 | Overlays "Perfect" atualizados | — |
| #1891 | Refactor do Easy Netplay | — |
| #1899 / #1890 | Testes de integração em shell e hardening do Makefile | #85 (parcial) |
| #1879 | Overhaul da conexão do DB (draft, conflita com #1897) | — |
| #1515 / #1460 | Relógio na MainUI e ordenar emuladores (draft, **com conflito**) | — |

Docs (#1954, #1955, #1927, #1920, #1911, #1912, #1898): dá pra fazer merge em lote.

> Cuidado: #1923 (Screen Time) e #1910 (Kids Mode) se sobrepõem. Escolha um. O #1879 conflita conceitualmente com o #1897; entre primeiro com o #1897, que é menor.

## Fase 2 — Bugs a corrigir (sem PR ainda)

### P0: travamentos e perda de save no MMP
- **#1367 / #1406 / #1916: DraStic.** Grava múltiplos `.dss` e corrompe o save; trava ao carregar um state logo depois do boot; trava ao sair por menu+select ou pelo GameSwitcher. Confirmado na 4.4 beta. É o bug mais grave da lista.
- **#1905:** apertar o hotkey do Quick Menu várias vezes trava ou crasha, e chegou a corromper o core gpSP.
- **#845:** pausar no GameSwitcher, ligar/desligar o Wi-Fi e voltar ao jogo deixa a tela preta.
- **#1395:** o jogo demora cerca de 1 minuto para voltar do sleep, e volume e brilho ficam lentos.
- **#1152:** savestates quebrados em alguns cores do MMP.

### P1: GameSwitcher e saves
- **#1935:** o GameSwitcher ignora o slot de save do RetroArch e incrementa sem limite.
- **#1703:** jogos com o mesmo nome em sistemas diferentes misturam tempo de jogo e resume.
- **#1760 / #1742 / #813:** GnGeo sem GameSwitcher; áudio do FBNeo 2012 quebra; o GameSwitcher atrapalha a troca de disco.
- **#1930:** a rotação do Quick Menu no FBNeo TATE quebrou na 4.4 beta (regressão).
- **#848:** o GameSwitcher fica lento com RetroAchievements ligado.

### P1: Wi-Fi e sistema
- **#1922:** não conecta em SSID com espaço. Provavelmente falta aspas no script do `wpa_supplicant`, então deve ser um fix rápido.
- **#781:** não conecta em SSID oculto (precisa de `scan_ssid=1`).
- **#1117:** falha de Wi-Fi em alguns roteadores. O último comentário aponta uma config do AP, então é documentação mais fallback.
- **#1928:** o RTC/NTP perde a hora depois de problemas de Wi-Fi.
- **#1926:** o desligamento é inconsistente (às vezes desliga direto, às vezes pede confirmação).
- **#1684:** o Blue Light filter liga sozinho (gatilho: menu+B segurando B). Bug no keymon.
- **#1254:** FTP e HTTP não ficam ativados no Tweaks.
- **#1136 / #764:** Netplay no MMP trava ou não funciona.
- **#1248:** ícone de sinal do Wi-Fi errado.

### P2: emuladores e apps
- **#1861:** atualizar o PicoDrive para 2.04 (corrige o idioma no Game Gear).
- **#1104:** atualizar o core mGBA.
- **#1247:** MAME 2003 Plus não funciona; **#1162:** não sai com o botão menu.
- **#1906 / #1831 / #1826 / #1801:** Pico-8 standalone (tela preta, Splore sumiu, dependência do fake-08, ícone).
- **#1896 / #1522:** NeoGeo CD (erro 139 no GameSwitcher; overrides não salvam).
- **#1793:** PC88 não roda imagens de disco.
- **#1519 / #1510 / #1517 / #786 / #1274 / #1575:** ScummVM (áudio de CD, soundfont, `&` no importer, sample rate, crash, scraper).
- **#1154 / #957:** teclado e savestate no DOSBox Pure.
- **#1297 / #1761:** o core de GB não responde aos botões do sistema; Gambatte sem netlink.
- **#1516 / #1120 / #1302 / #1454:** overlays e filtros (atraso com RA, quebrados desde a 4.2, Blargg vs. integer scale, GBAOffset).
- **#1404:** easyRPG cria uma entrada nova no Activity Tracker a cada execução.
- **#1221:** o Activity Tracker não atualiza o boxart depois do scrape.

### P3: UI, i18n e outros
- **#1229 / #1788:** fonte chinesa no GameSwitcher e no Activity Tracker.
- **#1401 / #1368:** Unicode no FFPlay e UTF-8 nas letras do GMU.
- **#1534:** a busca mostra o nome do zip nos sistemas arcade.
- **#1584 / #1133:** `miyoogamelist.xml` não atualiza os Favoritos e é ignorado no Expert.
- **#1191:** jogo aleatório não aparece em Recentes. **#1260:** Netplay e Scraper aparecem duplicados.
- **#184:** o Guest Mode vê os Favoritos e Recentes do perfil principal.
- Docs: **#1915** (link de firmware quebrado, 4 👍), **#1932** e **#849**.

## Fase 3 — Features (ordenadas por demanda: 👍 + comentários)

| Issue | Feature | 👍 | Nota |
|---|---|---|---|
| #792 | **Cloud saves** (sync com EmuDeck/PC) | 40 | A mais pedida, de longe. Dá pra fazer com Syncthing ou rclone + WebDAV. |
| #1167 | Integração do DraStic/NDS | 12 | Já existe em parte; falta estabilizar (ver P0). |
| #1328 | Multi-perfis e Kid mode | 11 | Os PRs #1910 e #1923 cobrem parte. |
| #766 | App de presets visuais (overlay, filtro e core options) | 10 | |
| #161 | Menu como "quick menu" interativo em vez de sair | 9 | |
| #768 | Overclock on-the-fly in-game | 7 | |
| #770 | Som nas conquistas do RetroAchievements | 7 | |
| #1505 | Sistema Win 3.x via DOSBox | 6 | |
| #600 | Screenshot como boxart quando faltar | 6 | |
| #1499 / #1500 | Novo menu de settings e Wi-Fi no Tweaks, IP estático | 4/1 | Base para os fixes de Wi-Fi. |
| #1172 | NDS no Scraper | 2 | |
| #1219 | Start restaura o default no Tweaks | — | Simples. |
| #961 / #769 | OSD de desligamento e ícone de bateria fraca em SDL | 3 | |
| #1222 | `pressMenu2Kill` com SIGTERM antes de SIGKILL | 1 | Simples e ajuda nos crashes de saída. |
| #1329 | Downloader de ports (estilo PortMaster) | 1 | |
| #75 | Configurador de combos de atalho | — | Requer keymon com arquivo de config. |
| #1161 | ffplay com decode por hardware (mi_vdec) | — | |
| #1168 / #1220 | Cores Duckstation/Swanstation KMFD; Genesis Plus GX com low memory (netplay) | — | |
| #1503 | fsck mais leve antes do OTA | — | |
| #1502 / #76 / #571 / #814 | Vídeo de boot, música aleatória na MainUI, overhaul do Theme Switcher | — | Cosmético. |

## Fora de escopo, ou só com muito esforço

- **MainUI é closed source.** Os bugs dela vão para `OnionUI/MainUI-issues`. A #78 (MainUI open source) é um projeto à parte.
- Bugs internos de cores do RetroArch: corrigir no upstream do libretro e só atualizar o binário aqui.
- #128 (zip no Package Manager), #107 (CPU dos apps), #1318 (push para o repo do keyboard): manutenção de longo prazo.

## Ordem sugerida

1. Fase 0 e merge dos 15 PRs de bugfix, depois o primeiro release do fork (`4.5.0-hb.1`).
2. P0 do DraStic e do Quick Menu, mais os fixes rápidos de Wi-Fi (#1922, #781), Blue Light (#1684) e SIGTERM (#1222).
3. Cloud saves (#792).
4. O resto por demanda.
