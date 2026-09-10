# Requisitos e rastreabilidade

| Requisito | Referência | Implementação |
|---|---|---|
| Jogo educativo 2D em Godot | `docs/referencias/ORIENTACOES_UNIFIL_JOGOS.pdf`; `docs/referencias/VISAO_ZOOQUEST.pdf` | `project.godot`, cenas e scripts 2D |
| Três mini-games | `docs/referencias/VISAO_ZOOQUEST.pdf`; `docs/referencias/GDD_ZOOQUEST.pdf` | `minigames/frog`, `minigames/bird`, `minigames/worm` |
| Sapo escolhe vitórias-régias | `docs/referencias/GDD_ZOOQUEST.pdf`; `docs/referencias/DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx` | `frog_minigame.gd`, `frog_player.gd`, `lily_pad.gd` |
| Pássaro escolhe caminhos | `docs/referencias/GDD_ZOOQUEST.pdf`; `docs/referencias/DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx` | `bird_minigame.gd`, `bird_player.gd`, `answer_gate.gd` |
| Minhoca coleta fruta-resposta | `docs/referencias/GDD_ZOOQUEST.pdf`; `docs/referencias/DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx` | `worm_minigame.gd`, `worm_player.gd`, `fruit_answer.gd` |
| Pergunta, escolha, validação, feedback e progresso | `docs/referencias/DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx` | lógica de submissão das três fases |
| Pontuação global | `docs/referencias/GDD_ZOOQUEST.pdf` | `core/game_state.gd`, `ui/hud.gd` |
| Fluxo contínuo | `docs/referencias/DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx` | `data/story_flow.json`, `core/main.gd` |
| Retorno à forma humana após cada fase | `docs/referencias/DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx` | etapas `return_human_*` de `data/story_flow.json` |
| Navegação completa | `docs/referencias/ORIENTACOES_UNIFIL_JOGOS.pdf`; documentação funcional | menu, narrativa, fases, encerramento e replay |
| Rejogabilidade | `docs/referencias/ORIENTACOES_UNIFIL_JOGOS.pdf` | tela final e reinicialização de `GameState` |
| Execução local, sem backend | `docs/referencias/ORIENTACOES_UNIFIL_JOGOS.pdf`; `docs/referencias/VISAO_ZOOQUEST.pdf` | dados e recursos locais |
| Interface adequada ao público infantil | `docs/referencias/VISAO_ZOOQUEST.pdf`; `docs/referencias/GDD_ZOOQUEST.pdf` | menu, HUD, instruções e feedback visual |
| Interação por mouse em fases compatíveis | evolução funcional registrada na PR #2 | pássaro, minhoca e componentes de seleção associados |
