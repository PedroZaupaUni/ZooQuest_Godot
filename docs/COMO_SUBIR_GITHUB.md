# Como subir o projeto no GitHub

## Repositório novo

```bash
cd ZooQuest_Projeto_Completo_Godot
git init
git add .
git commit -m "feat: entrega versao funcional completa do ZooQuest"
git branch -M main
git remote add origin URL_DO_REPOSITORIO
git push -u origin main
```

## Repositório do portfólio já existente

O projeto Godot possui `project.godot` na raiz. Caso o grupo precise manter o site atual na mesma raiz, existem duas alternativas:

1. mover os arquivos do site para `portfolio/`; ou
2. mover todo o projeto Godot para `game/` e importar `game/project.godot` no editor.

Para a entrega de desenvolvimento, a opção mais simples é manter o projeto Godot na raiz do repositório.

## Antes do push

```bash
python3 scripts/validate_repository.py
./scripts/run_godot_smoke.sh
```

O segundo comando exige Godot 4.x instalado ou a variável `GODOT_BIN` apontando para o executável.
