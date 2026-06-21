# SIG-GCM - Casos de Uso

Estrutura sugerida conforme requisito da disciplina:

```text
projeto/
└── specs/
    └── casos_de_uso/
        ├── analise_casos_de_uso.puml
        ├── especificacao_uc001_realizar_autenticacao.md
        ├── especificacao_uc002_gerenciar_perfis_permissoes.md
        └── ...
```

## Gerar PDF/SVG do diagrama

Instale PlantUML ou use Docker:

```bash
docker run --rm -v "$PWD/specs/casos_de_uso:/work" plantuml/plantuml -tsvg /work/analise_casos_de_uso.puml
```

Para PDF:

```bash
docker run --rm -v "$PWD/specs/casos_de_uso:/work" plantuml/plantuml -tpdf /work/analise_casos_de_uso.puml
```

## Gerar PDFs das especificações Markdown

Com Pandoc instalado:

```bash
pandoc specs/casos_de_uso/especificacao_uc001_realizar_autenticacao.md -o specs/casos_de_uso/especificacao_uc001_realizar_autenticacao.pdf
```
