Requirement.create(title: 'Meta Anual', requirement_type: 'sales', weight: 11, max: 11)
Requirement.create(title: 'Líder de Vendas Mensal', requirement_type: 'sales', weight: 1.5, max: 18)
Requirement.create(title: 'Regularidade Mensal', requirement_type: 'sales', weight: 0.5, max: 6)

Requirement.create(title: 'Contatos com Clientes', requirement_type: 'strategy', weight: 0.05, max: 10)
Requirement.create(title: 'Cadastro de Novos Contatos', requirement_type: 'strategy', weight: 0.1, max: 4)
Requirement.create(title: 'Seminários ou Treinamentos', requirement_type: 'strategy', weight: 0.5, max: 5)
Requirement.create(title: 'Treinamentos em Salvador', requirement_type: 'strategy', weight: 0.5, max: 6)
Requirement.create(title: 'Elaboração de Material promocional', requirement_type: 'strategy', weight: 1, max: 5)

Requirement.create(title: 'Nova Aplicação', requirement_type: 'technical_information', weight: 1.5, max: 3)
Requirement.create(title: 'Relatório Técnico', requirement_type: 'technical_information', weight: 0.3, max: 3)
Requirement.create(title: 'Atestado', requirement_type: 'technical_information', weight: 0.3, max: 3)
Requirement.create(title: 'Atestado com custo benefício', requirement_type: 'technical_information', weight: 1, max: 5)

Requirement.create(title: 'Feedback de propostas recusadas', requirement_type: 'communication', weight: 0.2, max: 3)
Requirement.create(title: 'Priorização de propostas', requirement_type: 'communication', weight: 0.3, max: 3)
Requirement.create(title: 'QSC', requirement_type: 'communication', weight: 0.3, max: 3)
Requirement.create(title: 'FS', requirement_type: 'communication', weight: 0.2, max: 3)
Requirement.create(title: 'Solicitações via Sistema', requirement_type: 'communication', weight: 0.2, max: 5)

Requirement.create(title: 'BU', requirement_type: 'empowerment', weight: 1, max: 2)
Requirement.create(title: 'Cursos técnicos profissionalizantes', requirement_type: 'empowerment', weight: 1, max: 3)
Requirement.create(title: 'Webinars', requirement_type: 'empowerment', weight: 0.3, max: 3)
Requirement.create(title: 'Fluxograma', requirement_type: 'empowerment', weight: 0.3, max: 3)
Requirement.create(title: 'Organograma', requirement_type: 'empowerment', weight: 0.3, max: 3)

Product.create(name: 'Frete')
Product.create(name: 'Valor Serviço')
