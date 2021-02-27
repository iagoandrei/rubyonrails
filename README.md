# CRM de produtos e serviços, personalizado para Hita

**Objetivo**

Projeto de CRM com objetivo de controlar o fluxo de vendas de produtos e serviços, da proposta, oportunidades, funil de vendas ao contrato. Foi feito de forma personalizada para empresa Hita. Produzido pela equipe da **E-Rural**

**Sobre Hita**

HITA Comércio E Serviços Ltda é Distribuidora Autorizada Belzona para todo o Brasil, fornecendo produtos e serviços para solucionar problemas de manutenção que se apresentam em equipamentos e estruturas nas mais diversas indústrias.

A Belzona foi fundada em 1952, a Belzona é líder mundial na inovação de compostos para reparos e revestimentos industriais.

[site do Hita](http://www.hita.com.br/pt/index.aspx)

[site da Belzona](https://www.belzona.com/pt/about.aspx)

**Funcionalidades**
As principais funcionalidades  são:

- Cadastro de clientes (empresas e contatos)
- Gerenciar usuários
- Gestão de Propostas
- Elaboração de formulários através de templates(estilo google forms)
- Relacionar e parametrizar documentos do word como formulários
- Gerenciar fluxo de propostas com impedimentos
- Calendário
- Gestão de oportunidades (funil de vendas de produtos e serviços)
- API para conexão dos dados de estoque
- Gestão de sistema de pontuação para consultores de vendas
- Relatórios de empresas, produtos e serviços
- Gerenciar equipamentos
- Gerenciar preços de produtos

**Tecnologias**

Linguagens de programação:

- Ruby
- JavaScript

Frameworks:

- Rails
- Freetds (conexão com banco mysql server)
- Bundler (gerenciador de dependências)
- Node JS
- Bulma Rails (CSS framework)
- Puma (web server API)
- Solr (Indexador) - Página de biblioteca

Banco de dados:

- Postgres

Devops:

- Docker
- Docker-compose

Versionamento:

- GitLab

Infra:

- Nginx (web server)

**Arquitetura**

![arquitetura](/Doc/arquitetura.png)

**Configuração e comandos**

* Para build (no-prod env):

`sudo docker-compose build`

* Banco:

`docker-compose run app rake db:create`

`docker-compose run app rake db:migrate`

* Caso de erro: 

`docker-compose run app yarn --check-files`


* Subir a aplicação (no-prod env):

`docker-compose up -d`

* configuração de ambiente (prod env):

**Em:** /hita-crm/config/environments/production.rb

**Alterar:** 
> `config.public_file_server.enabled = true`

* configuração de ambiente (prod env):

**Em:** /hita-crm/config/master.key

> Colocar a chave da aplicação (solicitar ao responsável do projeto)

* para build (prod env):

`sudo docker-compose -f compose-production.yml build`

* Subir a aplicação (prod env):

`docker-compose -f compose-production.yml up -d`

* Criar entidades manualmente (terminal):

`docker-compose run app rails c`

* Criar um novo usuário:

```
a = User.new
a.name = "nome"
a.email = "email@exemplo"
a.password = "senha123"
a.role = 3
a.save
```

* Script para atualizar produtos do banco: 

`hita-crm/lib/tasks/db_utils.rake`


* [Diagrama do banco](./Doc/database_crm_diagram.pdf)