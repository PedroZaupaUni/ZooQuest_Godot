# Requisitos e rastreabilidade

| Requisito | Origem documental | Implementação |
|---|---|---|
| Jogo educativo 2D em Godot | Orientações UniFil; Visão | `project.godot` e todas as cenas 2D |
| Três mini-games | Visão e GDD | `minigames/frog`, `bird`, `worm` |
| Sapo escolhe vitórias-régias | Visão e documentação funcional | `frog_minigame.gd` + `lily_pad.gd` |
| Pássaro escolhe caminhos | Visão e documentação funcional | `bird_minigame.gd` + `answer_gate.gd` |
| Minhoca coleta fruta-resposta | Visão e documentação funcional | `worm_minigame.gd` + `fruit_answer.gd` |
| Pergunta, escolha, feedback, progresso ou reinício | GDD e documentação de gameplay | lógica de submissão nas três fases |
| Pontuação | GDD | `core/game_state.gd` e `ui/hud.gd` |
| Fluxo contínuo | Correção do grupo e documentação consolidada | `data/story_flow.json` + `core/main.gd` |
| Retorno à forma humana após cada fase | Correção do grupo | três etapas `return_human_*` no fluxo |
| Navegação completa | Atividade de Desenvolvimento | menu -> narrativa -> três fases -> final -> replay/menu |
| Rejogabilidade | Orientações UniFil | botão Jogar Novamente e reinício do estado |
| Sem API, banco ou backend | Orientações UniFil e Visão | todos os dados e recursos são locais |
| Interface clara e infantil | Visão e GDD | HUD, instruções e feedback visual |
